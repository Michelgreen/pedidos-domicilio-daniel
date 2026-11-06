import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/pedido.dart';
import '../services/pedido_service.dart';

/// Pantalla de Formulario para Registrar un Pedido de Comida a Domicilio
/// Incluye validaciones de campos obligatorios, formato de teléfono, cantidad y prevención
/// de registros vacíos.
///
/// Autor: Daniel Michel Cruz Verde
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
    _clienteController = TextEditingController();
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
    // 1. Validar todos los campos obligatorios del formulario
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor completa correctamente todos los campos obligatorios (*).',
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
      final nuevoPedido = Pedido(
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
            ? 'Sin indicaciones adicionales'
            : _notasController.text.trim(),
        estado: 'En preparación',
        fechaCreacion: DateTime.now(),
        registradoPor: 'Daniel Michel Cruz Verde',
      );

      final docId = await _pedidoService.registrarPedido(nuevoPedido);

      if (!mounted) return;

      // Limpiar formulario tras registro exitoso
      _formKey.currentState!.reset();
      _clienteController.clear();
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
            '¡Pedido registrado en Firebase! Folio: ${docId.substring(0, 6).toUpperCase()}',
          ),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'VER EN BD',
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
          content: Text('Error al guardar en Firebase Firestore: $e'),
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
              'Registrar Nuevo Pedido a Domicilio',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Los campos marcados con (*) son obligatorios y se validan antes de enviarse a Cloud Firestore.',
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
                          '1. Selección de Platillo y Cantidad *',
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
                        labelText: 'Platillo del Menú *',
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
                      'Restaurante: ${_platilloSeleccionado.restaurante} • Tiempo: ${_platilloSeleccionado.tiempoEstimado}',
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
                          'Cantidad de órdenes:',
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
                        Icon(Icons.person_pin_circle, color: Color(0xFFD84315)),
                        SizedBox(width: 8),
                        Text(
                          '2. Datos del Cliente y Entrega *',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Campo Nombre del Cliente
                    TextFormField(
                      controller: _clienteController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Nombre completo del cliente *',
                        hintText: 'Ej. Daniel Michel Cruz Verde',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El nombre del cliente es obligatorio';
                        }
                        if (value.trim().length < 4) {
                          return 'Ingresa un nombre válido (mínimo 4 caracteres)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Campo Teléfono
                    TextFormField(
                      controller: _telefonoController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Teléfono de contacto (10 dígitos) *',
                        hintText: 'Ej. 4421234567',
                        prefixIcon: Icon(Icons.phone_android),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El teléfono es obligatorio para el repartidor';
                        }
                        if (value.trim().length != 10) {
                          return 'El teléfono debe tener exactamente 10 dígitos numéricos';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Campo Dirección
                    TextFormField(
                      controller: _direccionController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Dirección completa de entrega *',
                        hintText: 'Calle, número, colonia y referencias del domicilio',
                        prefixIcon: Icon(Icons.location_on_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'La dirección de entrega no puede estar vacía';
                        }
                        if (value.trim().length < 10) {
                          return 'Especifica calle, número y colonia (mínimo 10 caracteres)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Método de Pago
                    DropdownButtonFormField<String>(
                      initialValue: _metodoPago,
                      decoration: const InputDecoration(
                        labelText: 'Método de pago *',
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
                          child: Text('💳 Tarjeta bancaria (Terminal)'),
                        ),
                        DropdownMenuItem(
                          value: 'Transferencia SPEI',
                          child: Text('📲 Transferencia SPEI'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _metodoPago = val);
                        }
                      },
                    ),
                    const SizedBox(height: 14),

                    // Notas adicionales
                    TextFormField(
                      controller: _notasController,
                      decoration: const InputDecoration(
                        labelText: 'Instrucciones o notas para el restaurante (Opcional)',
                        hintText: 'Ej. Sin cebolla, salsa extra, tocar timbre 2...',
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
                      const Text('Costo de envío a domicilio:'),
                      Text('\$${_costoEnvioFijo.toStringAsFixed(2)} MXN'),
                    ],
                  ),
                  const Divider(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TOTAL A PAGAR:',
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

            // Botón de Envío a Firebase
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
                    : const Icon(Icons.cloud_upload),
                label: Text(
                  _guardando
                      ? 'Guardando en Cloud Firestore...'
                      : 'Confirmar y Guardar Pedido en Firebase',
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
