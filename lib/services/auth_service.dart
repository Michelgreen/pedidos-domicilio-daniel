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
    return correo == adminEmail.toLowerCase();
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
    } on FirebaseAuthException catch (e) {
      // Auto-provisionamiento de la cuenta Admin en su primer inicio de sesión
      if (correoLimpio.toLowerCase() == adminEmail.toLowerCase() &&
          password == 'Skrillex' &&
          (e.code == 'user-not-found' || e.code == 'invalid-credential')) {
        try {
          return await registrarUsuario(
            nombre: 'Administrador ProntoBite',
            telefono: '4271234567',
            correo: adminEmail,
            password: password,
          );
        } catch (_) {
          rethrow;
        }
      }
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
      final rol = correoLimpio.toLowerCase() == adminEmail.toLowerCase()
          ? 'admin'
          : 'cliente';

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
