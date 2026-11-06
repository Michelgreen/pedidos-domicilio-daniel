import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/pedido.dart';
import '../services/pedido_service.dart';

/// Pantalla de Formulario para Realizar un Pedido a Domicilio
class FormularioPedidoScreen extends StatefulWidget {
  final PlatilloMenu? platilloInicial;
  final VoidCallback? onPedidoGuardado;

  const FormularioPedidoScreen({
    super.key,
    this.platilloInicial,
    this.onPedidoGuardado,
  });

  @override
  State<FormularioPedidoScreen> createState() => _FormularioPedidoScreenState();
}

class _FormularioPedidoScreenState extends State<FormularioPedidoScreen> {
  final _formKey = GlobalKey<FormState>();
  final PedidoService _pedidoService = PedidoService();

  late TextEditingController _clienteController;
  late TextEditingController _telefonoController;
  late TextEditingController _direccionController;
  late TextEditingController _notasController;

  late PlatilloMenu _platilloSeleccionado;
  int _cantidad = 1;
  String _metodoPago = 'Efectivo';
  bool _guardando = false;

  static const double _costoEnvioFijo = 25.0;

  @override
  void initState() {
    super.initState();
    _platilloSeleccionado = widget.platilloInicial ?? catalogoPlatillos.first;
    final usuarioActual = FirebaseAuth.instance.currentUser;
    _clienteController = TextEditingController(
      text: usuarioActual?.displayName ?? '',
    );
    _telefonoController = TextEditingController();
    _direccionController = TextEditingController();
    _notasController = TextEditingController();
  }

  @override
  void didUpdateWidget(covariant FormularioPedidoScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.platilloInicial != null &&
        widget.platilloInicial != oldWidget.platilloInicial) {
      setState(() {
        _platilloSeleccionado = widget.platilloInicial!;
      });
    }
  }

  @override
  void dispose() {
    _clienteController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  double get _subtotal => _platilloSeleccionado.precio * _cantidad;
  double get _total => _subtotal + _costoEnvioFijo;

  Future<void> _guardarPedido() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor revisa los datos de entrega marcados como obligatorios.',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      final usuarioActual = FirebaseAuth.instance.currentUser;
      final nuevoPedido = Pedido(
        usuarioId: usuarioActual?.uid ?? 'invitado',
        usuarioCorreo: usuarioActual?.email ?? '',
        clienteNombre: _clienteController.text.trim(),
        telefono: _telefonoController.text.trim(),
        direccion: _direccionController.text.trim(),
        restaurante: _platilloSeleccionado.restaurante,
        platillo: _platilloSeleccionado.nombre,
        precioUnitario: _platilloSeleccionado.precio,
        cantidad: _cantidad,
        costoEnvio: _costoEnvioFijo,
        total: _total,
        metodoPago: _metodoPago,
        notas: _notasController.text.trim().isEmpty
            ? 'Sin indicaciones especiales'
            : _notasController.text.trim(),
        estado: 'En preparación',
        fechaCreacion: DateTime.now(),
      );

      final docId = await _pedidoService.registrarPedido(nuevoPedido);

      if (!mounted) return;

      _telefonoController.clear();
      _direccionController.clear();
      _notasController.clear();
      setState(() {
        _cantidad = 1;
        _metodoPago = 'Efectivo';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '¡Tu pedido #${docId.substring(0, 6).toUpperCase()} está en preparación!',
          ),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'VER PEDIDO',
            textColor: Colors.white,
            onPressed: () {
              widget.onPedidoGuardado?.call();
            },
          ),
        ),
      );

      widget.onPedidoGuardado?.call();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo procesar tu pedido: $e'),
          backgroundColor: Colors.red.shade800,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Completa tu Pedido',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Elige tu platillo e ingresa la dirección donde deseas recibir tu orden.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 18),

            // Selección de Platillo del Menú
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.fastfood, color: Color(0xFFD84315)),
                        SizedBox(width: 8),
                        Text(
                          'Tu Orden',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<PlatilloMenu>(
                      initialValue: _platilloSeleccionado,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Platillo seleccionado',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      items: catalogoPlatillos.map((platillo) {
                        return DropdownMenuItem<PlatilloMenu>(
                          value: platillo,
                          child: Text(
                            '${platillo.emoji} ${platillo.nombre} (\$${platillo.precio.toStringAsFixed(0)})',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (nuevo) {
                        if (nuevo != null) {
                          setState(() {
                            _platilloSeleccionado = nuevo;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${_platilloSeleccionado.restaurante} • Entrega estimada: ${_platilloSeleccionado.tiempoEstimado}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Cantidad:',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Row(
                          children: [
                            IconButton.filledTonal(
                              onPressed: _cantidad > 1
                                  ? () => setState(() => _cantidad--)
                                  : null,
                              icon: const Icon(Icons.remove),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                '$_cantidad',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton.filledTonal(
                              onPressed: _cantidad < 20
                                  ? () => setState(() => _cantidad++)
                                  : null,
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Datos del Cliente y Dirección de Entrega
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.location_on, color: Color(0xFFD84315)),
                        SizedBox(width: 8),
                        Text(
                          'Dirección y Contacto de Entrega',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _clienteController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: '¿Quién recibe el pedido? *',
                        hintText: 'Nombre completo',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresa el nombre de quien recibe';
                        }
                        if (value.trim().length < 4) {
                          return 'Ingresa un nombre válido (mínimo 4 letras)';
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
                        labelText: 'Teléfono celular (10 dígitos) *',
                        hintText: 'Para que el repartidor te contacte al llegar',
                        prefixIcon: Icon(Icons.phone_android),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El teléfono es necesario para la entrega';
                        }
                        if (value.trim().length != 10) {
                          return 'Ingresa un número válido de 10 dígitos';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _direccionController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Dirección exacta de entrega *',
                        hintText: 'Calle, número exterior/interior, colonia y referencias',
                        prefixIcon: Icon(Icons.home_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresa la dirección a donde enviaremos tu comida';
                        }
                        if (value.trim().length < 10) {
                          return 'Detalla calle, número y colonia (mínimo 10 caracteres)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    DropdownButtonFormField<String>(
                      initialValue: _metodoPago,
                      decoration: const InputDecoration(
                        labelText: 'Método de pago',
                        prefixIcon: Icon(Icons.payments_outlined),
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Efectivo',
                          child: Text('💵 Efectivo al recibir'),
                        ),
                        DropdownMenuItem(
                          value: 'Tarjeta en terminal',
                          child: Text('💳 Tarjeta bancaria al entregar'),
                        ),
                        DropdownMenuItem(
                          value: 'Transferencia SPEI',
                          child: Text('📲 Transferencia bancaria'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _metodoPago = val);
                        }
                      },
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _notasController,
                      decoration: const InputDecoration(
                        labelText: 'Notas para el restaurante o repartidor (Opcional)',
                        hintText: 'Ej. Sin cebolla, salsa aparte, portón blanco...',
                        prefixIcon: Icon(Icons.notes),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Resumen de Costos
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Subtotal ($_cantidad x \$${_platilloSeleccionado.precio.toStringAsFixed(2)}):'),
                      Text('\$${_subtotal.toStringAsFixed(2)} MXN'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Envío a domicilio:'),
                      Text('\$${_costoEnvioFijo.toStringAsFixed(2)} MXN'),
                    ],
                  ),
                  const Divider(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total a pagar:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '\$${_total.toStringAsFixed(2)} MXN',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFFD84315),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton.icon(
                onPressed: _guardando ? null : _guardarPedido,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFD84315),
                ),
                icon: _guardando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(
                  _guardando
                      ? 'Enviando tu pedido al restaurante...'
                      : 'Confirmar Pedido • \$${_total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
