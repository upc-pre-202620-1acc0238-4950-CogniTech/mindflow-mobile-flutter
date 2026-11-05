import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Same Terms and Conditions / Privacy Policy text published on the
/// Landing Page (`assets/legal/terms.html` / `privacy.html`) and in the
/// report's Anexo A, kept in sync by hand across the three surfaces.
class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  static const _sections = [
    (
      '1. Aceptación de los términos',
      'Al acceder o usar MindFlow (la "App"), desarrollada por el equipo CogniTech como proyecto académico en la UPC, aceptas estos Términos y Condiciones. Si no estás de acuerdo, no uses la App. MindFlow es una herramienta de autocuidado y reflexión: no reemplaza la atención de un psicólogo, psiquiatra u otro profesional de salud, y el asistente de IA no da diagnósticos ni tratamientos. Si sientes que estás en riesgo o podrías lastimarte, busca ayuda de inmediato: Línea 113, opción 5 (salud mental, Minsa) o 106 (SAMU).'
    ),
    (
      '2. Elegibilidad y cuentas',
      'Debes tener 18 años o más y capacidad legal para aceptar estos términos. Puedes registrarte con tu correo y contraseña o con tu cuenta de Google. Eres responsable de mantener seguras tus credenciales de acceso y de toda actividad en tu cuenta; la información que proporciones al registrarte debe ser exacta. Puedes eliminar tu cuenta desde la app: esto elimina tu diario, hábitos y conversaciones con la IA, aunque algunos registros de pago o soporte pueden conservarse por obligaciones legales o contables.'
    ),
    (
      '3. Uso de la App',
      'Puedes usar MindFlow solo para fines personales lícitos. No debes intentar acceder sin autorización a los datos de otros usuarios, comprometer la seguridad de la App, ni usar el asistente de IA para obtener contenido que promueva hacerte daño a ti mismo o a otros. Los análisis generados por IA (mediante la API de Google Gemini) son informativos, pueden contener errores y no constituyen un diagnóstico clínico.'
    ),
    (
      '4. Suscripciones y pagos',
      'Freemium es gratuito, con las funciones básicas de diario, hábitos y asistente. Premium cuesta USD 4.99 al mes (más impuestos según tu país), se cobra a través de Stripe — MindFlow no almacena los datos de tu tarjeta — y se renueva cada mes hasta que canceles escribiendo a cognitech.mindflow@gmail.com; la suscripción permanece activa hasta el final del periodo ya pagado. Los periodos ya iniciados no se reembolsan, salvo que la ley lo exija o el cargo haya sido un error nuestro.'
    ),
    (
      '5. Privacidad y datos',
      'El contenido de tus entradas de diario y de tus conversaciones con el asistente se almacena encriptado con AES-256. No vendemos tus datos ni los usamos para publicidad, y no usamos el contenido de tus entradas o conversaciones para entrenar nuestros modelos ni los de terceros. Las funciones de exportación se brindan para tu uso personal y para compartir con los profesionales que elijas; eres responsable de cómo compartes los datos exportados.'
    ),
    (
      '6. Limitación de responsabilidad',
      'MindFlow se ofrece "tal cual": se desarrolla en un contexto académico y puede tener interrupciones, errores o cambios. No garantizamos que esté siempre disponible ni que las respuestas de la IA sean precisas o adecuadas para tu situación. En la medida permitida por la ley, no somos responsables de daños indirectos derivados del uso de la App o de decisiones que tomes basándote en las respuestas de la IA.'
    ),
    (
      '7. Cambios y contacto',
      'Podemos actualizar estos Términos. Si el cambio es significativo, te notificaremos en la app o en el sitio antes de que entre en vigor; el uso continuado después de eso implica que aceptas el cambio. Para preguntas: cognitech.mindflow@gmail.com.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Términos y Condiciones'),
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Text('Última actualización: octubre 2026',
                style: TextStyle(fontSize: 13, color: colors.textSecondary)),
            const SizedBox(height: 16),
            for (final (title, body) in _sections) ...[
              Text(title,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text(body, style: TextStyle(fontSize: 15, height: 1.5, color: colors.text)),
              const SizedBox(height: 18),
            ],
          ],
        ),
      ),
    );
  }
}
