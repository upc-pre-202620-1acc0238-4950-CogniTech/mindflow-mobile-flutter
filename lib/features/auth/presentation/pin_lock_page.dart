import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/navigation/app_shell.dart';
import '../../../core/theme/app_colors.dart';
import '../../settings/infrastructure/pin_api.dart';
import '../domain/auth_repository.dart';
import 'login_page.dart';

/// Full-screen PIN gate shown on launch when "Bloqueo con PIN" is enabled
/// in Settings — blocks access to [AppShell] until the PIN is verified
/// against the backend. Previously the setting saved a preference but
/// nothing ever re-prompted for it, so it had no real effect.
class PinLockPage extends StatefulWidget {
  const PinLockPage({super.key});

  @override
  State<PinLockPage> createState() => _PinLockPageState();
}

class _PinLockPageState extends State<PinLockPage> {
  final _controller = TextEditingController();
  bool _checking = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_controller.text.length != 4) return;
    setState(() {
      _checking = true;
      _error = null;
    });
    final valid = await getIt<PinApi>().verify(_controller.text);
    if (!mounted) return;
    if (valid) {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => const AppShell()));
      return;
    }
    setState(() {
      _checking = false;
      _error = 'PIN incorrecto.';
      _controller.clear();
    });
  }

  Future<void> _signOutInstead() async {
    await getIt<AuthRepository>().signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Ingresa tu PIN',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text('Introduce el código de 4 dígitos para continuar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: colors.textSecondary)),
              const SizedBox(height: 32),
              TextField(
                controller: _controller,
                autofocus: true,
                enabled: !_checking,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28, letterSpacing: 10),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(counterText: ''),
                onChanged: (value) {
                  if (value.length == 4) _submit();
                },
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: TextStyle(color: colors.crisisText)),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: (_checking || _controller.text.length != 4) ? null : _submit,
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                child: _checking
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Continuar'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _checking ? null : _signOutInstead,
                child: const Text('Olvidé mi PIN, cerrar sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
