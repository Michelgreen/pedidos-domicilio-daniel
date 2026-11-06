import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Servicio de autenticación de clientes con correo y contraseña.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Flujo del estado de sesión actual.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Usuario actualmente autenticado.
  User? get currentUser => _auth.currentUser;

  /// Iniciar sesión con correo y contraseña.
  Future<UserCredential> iniciarSesion({
    required String correo,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: correo.trim(),
      password: password,
    );
  }

  /// Registrar una cuenta nueva con nombre, correo y contraseña.
  Future<UserCredential> registrarUsuario({
    required String nombre,
    required String telefono,
    required String correo,
    required String password,
  }) async {
    final credencial = await _auth.createUserWithEmailAndPassword(
      email: correo.trim(),
      password: password,
    );

    await credencial.user?.updateDisplayName(nombre.trim());

    if (credencial.user != null) {
      await _db.collection('usuarios').doc(credencial.user!.uid).set({
        'uid': credencial.user!.uid,
        'nombre': nombre.trim(),
        'telefono': telefono.trim(),
        'correo': correo.trim(),
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
