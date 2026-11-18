# MindFlow — app móvil (Flutter)

Cliente móvil multiplataforma de MindFlow (CogniTech · UPC, curso 1ACC0238). Consume el backend
`mindflow-backend` (ASP.NET Core) y no guarda datos de negocio en el dispositivo: **requiere conexión**.

## Ejecutar

```bash
flutter pub get
flutter run                       # usa el backend desplegado en Railway
```

Para apuntar a un backend local desde el emulador de Android (`10.0.2.2` es el `localhost` del PC):

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5080/api/v1
```

## Pruebas y análisis

```bash
flutter analyze
flutter test
```

## Estructura

`lib/features/<feature>/{application,domain,infrastructure,presentation}`; DI con `get_it`
(`lib/core/di/service_locator.dart`), cliente HTTP en `lib/core/network/api_client.dart`
(JWT en `flutter_secure_storage`, timeouts, cierre de sesión ante 401).

## Notas

- El acceso con Google está oculto hasta integrar `google_sign_in` (backend y caso de uso listos).
- El APK se distribuye con Firebase App Distribution desde `.github/workflows/firebase-distribute.yml`.
