import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';

/// Pantalla de Inicio de Sesión y Registro de Clientes con Correo Electrónico.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  bool _esRegistro = false;
  bool _cargando = false;
  bool _ocultarPassword = true;

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _correoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _traducirErrorAuth(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos. Verifica tus datos o crea una cuenta.';
      case 'wrong-password':
        return 'La contraseña ingresada es incorrecta.';
      case 'email-already-in-use':
        return 'Este correo electrónico ya está registrado. Inicia sesión.';
      case 'weak-password':
        return 'La contraseña es muy débil (usa al menos 6 caracteres).';
      case 'invalid-email':
        return 'El formato del correo electrónico no es válido.';
      case 'operation-not-allowed':
        return 'El acceso con correo y contraseña aún no está habilitado en el servidor.';
      default:
        return e.message ?? 'Ocurrió un problema al procesar tu solicitud.';
    }
  }

  Future<void> _procesarFormulario() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _cargando = true);

    try {
      if (_esRegistro) {
        await _authService.registrarUsuario(
          nombre: _nombreController.text,
          telefono: _telefonoController.text,
          correo: _correoController.text,
          password: _passwordController.text,
        );
      } else {
        await _authService.iniciarSesion(
          correo: _correoController.text,
          password: _passwordController.text,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_traducirErrorAuth(e)),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No fue posible conectar: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F5),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo y marca de la app de comida
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD84315), Color(0xFFFF7043)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepOrange.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.delivery_dining,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'ProntoBite Delivery',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _esRegistro
                        ? 'Crea tu cuenta para pedir tus platillos favoritos'
                        : 'Tus restaurantes favoritos hasta la puerta de tu casa',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Tarjeta del formulario de acceso / registro
                  Card(
                    elevation: 3,
                    shadowColor: Colors.black12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Selector Iniciar Sesión / Crear Cuenta
                            SegmentedButton<bool>(
                              segments: const [
                                ButtonSegment<bool>(
                                  value: false,
                                  label: Text('Iniciar Sesión'),
                                  icon: Icon(Icons.login),
                                ),
                                ButtonSegment<bool>(
                                  value: true,
                                  label: Text('Crear Cuenta'),
                                  icon: Icon(Icons.person_add_alt_1),
                                ),
                              ],
                              selected: {_esRegistro},
                              onSelectionChanged: (Set<bool> selection) {
                                setState(() {
                                  _esRegistro = selection.first;
                                  _formKey.currentState?.reset();
                                });
                              },
                            ),
                            const SizedBox(height: 22),

                            if (_esRegistro) ...[
                              TextFormField(
                                controller: _nombreController,
                                textCapitalization: TextCapitalization.words,
                                decoration: const InputDecoration(
                                  labelText: 'Nombre completo',
                                  hintText: 'Ej. Laura Gómez',
                                  prefixIcon: Icon(Icons.person_outline),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (!_esRegistro) return null;
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Ingresa tu nombre completo';
                                  }
                                  if (value.trim().length < 3) {
                                    return 'Ingresa al menos 3 caracteres';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _telefonoController,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                decoration: const InputDecoration(
                                  labelText: 'Teléfono celular (10 dígitos)',
                                  hintText: 'Ej. 4421234567',
                                  prefixIcon: Icon(Icons.phone_iphone),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (!_esRegistro) return null;
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Ingresa tu número de teléfono';
                                  }
                                  if (value.trim().length != 10) {
                                    return 'El teléfono debe tener 10 dígitos';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                            ],

                            TextFormField(
                              controller: _correoController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Correo electrónico',
                                hintText: 'ejemplo@correo.com',
                                prefixIcon: Icon(Icons.email_outlined),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Ingresa tu correo electrónico';
                                }
                                final emailRegex =
                                    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                                if (!emailRegex.hasMatch(value.trim())) {
                                  return 'Ingresa un correo electrónico válido';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            TextFormField(
                              controller: _passwordController,
                              obscureText: _ocultarPassword,
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                hintText: 'Mínimo 6 caracteres',
                                prefixIcon: const Icon(Icons.lock_outline),
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _ocultarPassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _ocultarPassword = !_ocultarPassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ingresa tu contraseña';
                                }
                                if (value.length < 6) {
                                  return 'La contraseña debe tener mínimo 6 caracteres';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 22),

                            SizedBox(
                              height: 50,
                              child: FilledButton(
                                onPressed:
                                    _cargando ? null : _procesarFormulario,
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFFD84315),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _cargando
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        _esRegistro
                                            ? 'Registrarme y Empezar a Pedir'
                                            : 'Ingresar a mi Cuenta',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
