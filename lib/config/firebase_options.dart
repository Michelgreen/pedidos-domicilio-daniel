import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Configuración de Firebase para el proyecto: pedidos-domicilio-daniel
/// Autor: Daniel Michel Cruz Verde
/// Materia: Desarrollo Móvil Integral - Docente: Dolores Abril Sánchez Camacho
///
/// SEGURIDAD: Permite inyectar credenciales por variables de entorno (--dart-define)
/// en compilaciones de producción o utilizar la configuración del proyecto Firebase.
class DefaultFirebaseOptions {
  static const String _apiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: 'AIzaSyDZ1UjvRsMW7eMz-TTujFix-Ro_UftnaSg',
  );
  static const String _webAppId = String.fromEnvironment(
    'FIREBASE_APP_ID',
    defaultValue: '1:410979282648:web:2e5f3d228d70459b3931ad',
  );
  static const String _messagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
    defaultValue: '410979282648',
  );
  static const String _projectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'pedidos-domicilio-daniel',
  );
  static const String _storageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
    defaultValue: 'pedidos-domicilio-daniel.firebasestorage.app',
  );

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return web;
      case TargetPlatform.windows:
        return web;
      case TargetPlatform.linux:
        return web;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDZ1UjvRsMW7eMz-TTujFix-Ro_UftnaSg',
    appId: '1:410979282648:web:2e5f3d228d70459b3931ad',
    messagingSenderId: '410979282648',
    projectId: 'pedidos-domicilio-daniel',
    authDomain: 'pedidos-domicilio-daniel.firebaseapp.com',
    storageBucket: 'pedidos-domicilio-daniel.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAKS2oUeEHoFQlCTHr4Wt-z8--TLeY6s74',
    appId: '1:410979282648:android:bcde62f5f1c099913931ad',
    messagingSenderId: '410979282648',
    projectId: 'pedidos-domicilio-daniel',
    storageBucket: 'pedidos-domicilio-daniel.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: _apiKey,
    appId: _webAppId,
    messagingSenderId: _messagingSenderId,
    projectId: _projectId,
    storageBucket: _storageBucket,
    iosBundleId: 'com.danielcruz.pedidosDomicilioDaniel',
  );
}
