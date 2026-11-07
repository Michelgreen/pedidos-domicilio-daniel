import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Servicio de autenticación de clientes y administrador con correo y contraseña.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Correo oficial del administrador del sistema.
  static const String adminEmail = 'michelcv.ti23@utsjr.edu.mx';

  /// Flujo del estado de sesión actual.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Usuario actualmente autenticado.
  User? get currentUser => _auth.currentUser;

  /// Verifica si el usuario actual tiene rol de Administrador.
  bool get esAdmin {
    final correo = _auth.currentUser?.email?.trim().toLowerCase() ?? '';
    return correo == adminEmail.toLowerCase() &&
        (_auth.currentUser?.emailVerified ?? false);
  }

  /// Iniciar sesión con correo y contraseña.
  /// Si es la cuenta del administrador y aún no ha sido creada en Firebase Auth,
  /// la registra automáticamente en el primer ingreso.
  Future<UserCredential> iniciarSesion({
    required String correo,
    required String password,
  }) async {
    final correoLimpio = correo.trim();
    try {
      return await _auth.signInWithEmailAndPassword(
        email: correoLimpio,
        password: password,
      );
    } on FirebaseAuthException {
      rethrow;
    }
  }

  /// Registrar una cuenta nueva con nombre, teléfono, correo y contraseña.
  Future<UserCredential> registrarUsuario({
    required String nombre,
    required String telefono,
    required String correo,
    required String password,
  }) async {
    final correoLimpio = correo.trim();
    final credencial = await _auth.createUserWithEmailAndPassword(
      email: correoLimpio,
      password: password,
    );

    await credencial.user?.updateDisplayName(nombre.trim());

    if (credencial.user != null) {
      // El rol de administrador no se asigna desde el cliente. La autorización
      // de admin se valida con el correo verificado en las reglas de Firestore.
      const rol = 'cliente';

      await _db.collection('usuarios').doc(credencial.user!.uid).set({
        'uid': credencial.user!.uid,
        'nombre': nombre.trim(),
        'telefono': telefono.trim(),
        'correo': correoLimpio,
        'rol': rol,
        'fechaRegistro': FieldValue.serverTimestamp(),
      });
    }

    return credencial;
  }

  /// Cerrar la sesión activa.
  Future<void> cerrarSesion() async {
    await _auth.signOut();
  }
}
