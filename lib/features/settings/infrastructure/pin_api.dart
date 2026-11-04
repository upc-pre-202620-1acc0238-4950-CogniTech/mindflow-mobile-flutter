import '../../../core/network/api_client.dart';

class PinApi {
  final ApiClient client;
  PinApi({required this.client});

  Future<bool> status() async {
    final json = await client.get('/users/pin/status') as Map<String, dynamic>;
    return json['has_pin'] as bool? ?? false;
  }

  Future<void> set(String pin) => client.post('/users/pin', body: {'pin': pin});

  Future<bool> verify(String pin) async {
    final json = await client.post('/users/pin/verify', body: {'pin': pin}) as Map<String, dynamic>;
    return json['valid'] as bool? ?? false;
  }

  Future<void> remove() => client.delete('/users/pin');
}
