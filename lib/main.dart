import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'config/firebase_options.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProntoBiteApp());
}

class ProntoBiteApp extends StatelessWidget {
  const ProntoBiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ProntoBite Delivery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD84315),
          primary: const Color(0xFFD84315),
        ),
        appBarTheme: const AppBarTheme(centerTitle: false),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final user = snapshot.data;
          if (user == null) return const AuthScreen();
          final esCorreoAdmin =
              user.email?.trim().toLowerCase() == AuthService.adminEmail;
          if (esCorreoAdmin && !user.emailVerified) {
            return AdminVerificacionScreen(user: user);
          }
          return const HomeScreen();
        },
      ),
    );
  }
}

class AdminVerificacionScreen extends StatefulWidget {
  final User user;

  const AdminVerificacionScreen({super.key, required this.user});

  @override
  State<AdminVerificacionScreen> createState() =>
      _AdminVerificacionScreenState();
}

class _AdminVerificacionScreenState extends State<AdminVerificacionScreen> {
  bool _cargando = false;
  bool _verificado = false;

  Future<void> _enviarVerificacion() async {
    setState(() => _cargando = true);
    try {
      await widget.user.sendEmailVerification();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Correo enviado. Revisa tu bandeja y también Spam.'),
        ),
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? 'No se pudo enviar el correo.')),
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _yaVerifique() async {
    setState(() => _cargando = true);
    try {
      await widget.user.reload();
      final usuarioActual = FirebaseAuth.instance.currentUser;
      if (usuarioActual?.emailVerified ?? false) {
        await usuarioActual?.getIdToken(true);
        if (mounted) setState(() => _verificado = true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Aún no aparece como verificado. Abre el enlace del correo e inténtalo de nuevo.',
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? 'No se pudo revisar la cuenta.')),
        );
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_verificado) return const HomeScreen();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificación de administrador'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.mark_email_unread_outlined,
                  size: 64,
                  color: Color(0xFFD84315),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Verifica el correo del administrador',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Enviaremos un enlace a ${widget.user.email}. Ábrelo y luego regresa aquí. El panel administrativo se habilitará cuando Firebase confirme la verificación.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _cargando ? null : _enviarVerificacion,
                  icon: const Icon(Icons.email_outlined),
                  label: const Text('Enviar correo de verificación'),
                ),
                TextButton(
                  onPressed: _cargando ? null : _yaVerifique,
                  child: const Text('Ya verifiqué, continuar'),
                ),
                if (_cargando) const CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
