import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mindflow_workday/core/network/api_client.dart';
import 'package:mindflow_workday/core/network/api_exception.dart';
import 'package:mindflow_workday/core/storage/token_storage.dart';
import 'package:mindflow_workday/features/habits/infrastructure/habits_api.dart';

class FakeTokenStorage extends TokenStorage {
  String? token;
  FakeTokenStorage([this.token]);

  @override
  Future<String?> read() async => token;

  @override
  Future<void> save(String value) async => token = value;

  @override
  Future<void> clear() async => token = null;
}

ApiClient clientFor(MockClientHandler handler, FakeTokenStorage storage,
        {Duration timeout = const Duration(seconds: 5)}) =>
    ApiClient(client: MockClient(handler), tokenStorage: storage, timeout: timeout);

http.Response json(int status, Object body) =>
    http.Response(jsonEncode(body), status, headers: {'content-type': 'application/json'});

void main() {
  group('ApiClient errors', () {
    test('reads the message from {error}', () async {
      final api = clientFor((_) async => json(400, {'error': 'Correo inválido'}), FakeTokenStorage());
      expect(
        () => api.post('/users/sign-in', auth: false),
        throwsA(isA<ApiException>().having((e) => e.message, 'message', 'Correo inválido')),
      );
    });

    test('reads the message from {message} (chat and habit-logs used it)', () async {
      final api = clientFor((_) async => json(404, {'message': 'Conversación no encontrada.'}), FakeTokenStorage());
      expect(
        () => api.get('/chat/conversations/9/messages'),
        throwsA(isA<ApiException>().having((e) => e.message, 'message', 'Conversación no encontrada.')),
      );
    });

    test('reads ProblemDetails detail', () async {
      final api = clientFor((_) async => json(400, {'title': 'Bad Request', 'detail': 'Frecuencia inválida'}), FakeTokenStorage());
      expect(
        () => api.get('/habits'),
        throwsA(isA<ApiException>().having((e) => e.message, 'message', 'Frecuencia inválida')),
      );
    });

    test('reads the first ASP.NET validation error', () async {
      final api = clientFor(
        (_) async => json(400, {
          'title': 'One or more validation errors occurred.',
          'errors': {
            'Content': ['El contenido es demasiado largo']
          }
        }),
        FakeTokenStorage(),
      );
      expect(
        () => api.post('/journal/entries'),
        throwsA(isA<ApiException>().having((e) => e.message, 'message', 'El contenido es demasiado largo')),
      );
    });

    test('falls back to a generic message for non-JSON bodies', () async {
      final api = clientFor((_) async => http.Response('<html>502</html>', 502), FakeTokenStorage());
      expect(
        () => api.get('/habits'),
        throwsA(isA<ApiException>().having((e) => e.message, 'message', contains('502'))),
      );
    });

    test('a 2xx response that is not JSON becomes an ApiException, not a FormatException', () async {
      final api = clientFor((_) async => http.Response('<html>ok</html>', 200), FakeTokenStorage());
      expect(() => api.get('/habits'), throwsA(isA<ApiException>()));
    });

    test('timeouts surface as ApiException(408)', () async {
      final api = clientFor(
        (_) => Future.delayed(const Duration(seconds: 2), () => json(200, {})),
        FakeTokenStorage(),
        timeout: const Duration(milliseconds: 50),
      );
      expect(
        () => api.get('/habits'),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 408)),
      );
    });
  });

  group('ApiClient 401 handling', () {
    test('clears the token and notifies when an authenticated call gets 401', () async {
      final storage = FakeTokenStorage('jwt');
      var notified = 0;
      final api = clientFor((_) async => json(401, {'error': 'expired'}), storage)
        ..onUnauthorized = () => notified++;

      await expectLater(() => api.get('/habits'), throwsA(isA<ApiException>()));
      expect(storage.token, isNull);
      expect(notified, 1);
    });

    test('a failed sign-in (auth: false) does not log out or notify', () async {
      final storage = FakeTokenStorage('jwt');
      var notified = 0;
      final api = clientFor((_) async => json(401, {'error': 'Email o contraseña incorrectos.'}), storage)
        ..onUnauthorized = () => notified++;

      await expectLater(() => api.post('/users/sign-in', auth: false), throwsA(isA<ApiException>()));
      expect(storage.token, 'jwt');
      expect(notified, 0);
    });

    test('sends the Bearer token on authenticated calls only', () async {
      final seen = <String?>[];
      final api = clientFor((request) async {
        seen.add(request.headers['Authorization']);
        return json(200, {});
      }, FakeTokenStorage('jwt'));

      await api.get('/habits');
      await api.get('/subscriptions/plans', auth: false);
      expect(seen, ['Bearer jwt', null]);
    });
  });

  group('HabitsApi contract', () {
    test('sends Daily/Weekly to the backend even though the UI says Diario/Semanal', () async {
      final bodies = <Map<String, dynamic>>[];
      final api = HabitsApi(
        client: clientFor((request) async {
          bodies.add(jsonDecode(request.body) as Map<String, dynamic>);
          return json(201, {
            'id': 1,
            'name': 'Leer',
            'category': 'Aprendizaje',
            'frequency': 'weekly',
            'streak': 0,
            'status': 'pending',
            'paused_by_ai': false,
          });
        }, FakeTokenStorage('jwt')),
      );

      final habit = await api.createHabit(name: 'Leer', category: 'Aprendizaje', frequency: 'Semanal');
      await api.createHabit(name: 'Agua', category: 'Salud física', frequency: 'Diario');

      expect(bodies[0]['frequency'], 'Weekly');
      expect(bodies[1]['frequency'], 'Daily');
      expect(habit.frequencyLabel, 'Semanal');
    });
  });
}
