import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/pedido.dart';
import '../services/pedido_service.dart';

/// Pantalla para que el dueño del restaurante gestione el Menú de Comidas.
class AdminMenuScreen extends StatefulWidget {
  const AdminMenuScreen({super.key});

  @override
  State<AdminMenuScreen> createState() => _AdminMenuScreenState();
}

class _AdminMenuScreenState extends State<AdminMenuScreen> {
  final PedidoService _pedidoService = PedidoService();

  static const List<String> _categoriasRestaurante = [
    'Tacos y Parrilla',
    'Hamburguesas',
    'Pizzas',
    'Entradas y Snacks',
    'Ensaladas',
    'Postres y Bebidas',
  ];

  static const List<String> _iconosComida = [
    '🌮',
    '🍔',
    '🍕',
    '🍗',
    '🥗',
    '🥤',
    '🌯',
    '🍟',
    '🍰',
    '🍝',
  ];

  Future<void> _mostrarDialogoNuevoPlatillo() async {
    final formKey = GlobalKey<FormState>();
    final nombreCtrl = TextEditingController();
    final precioCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final tiempoCtrl = TextEditingController(text: '20-30 min');
    String categoria = _categoriasRestaurante.first;
    String emoji = _iconosComida.first;

    final guardar = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text('Agregar Comida al Menú'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: emoji,
                        decoration: const InputDecoration(
                          labelText: 'Ícono del platillo',
                          border: OutlineInputBorder(),
                        ),
                        items: _iconosComida
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e,
                                  style: const TextStyle(fontSize: 22),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() => emoji = val);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: nombreCtrl,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Nombre del platillo *',
                          hintText: 'Ej. Enchiladas Suizas Gratinadas',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Ingresa el nombre del platillo';
                          }
                          if (v.trim().length < 4) {
                            return 'Mínimo 4 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: categoria,
                        decoration: const InputDecoration(
                          labelText: 'Categoría *',
                          border: OutlineInputBorder(),
                        ),
                        items: _categoriasRestaurante
                            .map(
                              (c) => DropdownMenuItem(
                                value: c,
                                child: Text(c),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() => categoria = val);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: precioCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'),
                          ),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Precio (MXN) *',
                          hintText: 'Ej. 155.00',
                          prefixText: '\$ ',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          final monto = double.tryParse(v ?? '');
                          if (monto == null || monto <= 0) {
                            return 'Ingresa un precio mayor a 0';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: tiempoCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Tiempo estimado de preparación *',
                          hintText: 'Ej. 20-25 min',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Ingresa el tiempo estimado'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Descripción de ingredientes *',
                          hintText: 'Ej. Acompañado de arroz, frijoles y salsa',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Describe brevemente el platillo';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Cancelar'),
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFD84315),
                  ),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.of(ctx).pop(true);
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Guardar en el Menú'),
                ),
              ],
            );
          },
        );
      },
    );

    if (guardar != true) return;

    await _pedidoService.asegurarMenuInicial();

    final nuevoPlatillo = PlatilloMenu(
      nombre: nombreCtrl.text.trim(),
      categoria: categoria,
      precio: double.parse(precioCtrl.text.trim()),
      descripcion: descCtrl.text.trim(),
      emoji: emoji,
      tiempoEstimado: tiempoCtrl.text.trim(),
    );

    await _pedidoService.agregarPlatillo(nuevoPlatillo);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Platillo "${nuevoPlatillo.nombre}" agregado al menú.'),
        backgroundColor: Colors.green.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarDialogoNuevoPlatillo,
        backgroundColor: const Color(0xFFD84315),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Agregar Platillo'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.orange.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Carta del Restaurante',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Agrega nuevas comidas o administra los platillos disponibles para tus clientes.',
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: _mostrarDialogoNuevoPlatillo,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFD84315),
                  ),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Nueva Comida'),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<PlatilloMenu>>(
              stream: _pedidoService.obtenerPlatillosEnTiempoReal(),
              builder: (context, snapshot) {
                final platillos = snapshot.data ?? catalogoPlatillosInicial;

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  itemCount: platillos.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = platillos[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.deepOrange.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                item.emoji,
                                style: const TextStyle(fontSize: 30),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.nombre,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${item.categoria} • Prep: ${item.tiempoEstimado}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.descripcion,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '\$${item.precio.toStringAsFixed(2)} MXN',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFD84315),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (item.id != null)
                              IconButton(
                                tooltip: 'Quitar del menú',
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () async {
                                  await _pedidoService
                                      .eliminarPlatillo(item.id!);
                                },
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Pantalla para que el dueño del restaurante consulte los Clientes Registrados y sus pedidos.
class AdminClientesScreen extends StatelessWidget {
  const AdminClientesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PedidoService pedidoService = PedidoService();
    final formatoFecha = DateFormat('dd/MM/yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.orange.shade50,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Directorio de Clientes Registrados',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Clientes con cuenta activa en el restaurante y su historial de compras.',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<ClienteRegistrado>>(
            stream: pedidoService.obtenerClientesRegistrados(),
            builder: (context, userSnap) {
              if (userSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final clientes = userSnap.data ?? [];

              if (clientes.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Aún no hay clientes registrados',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Cuando los clientes creen su cuenta con correo electrónico, aparecerán en este listado.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return StreamBuilder<List<Pedido>>(
                stream: pedidoService.obtenerPedidosEnTiempoReal(esAdmin: true),
                builder: (context, pedidosSnap) {
                  final todosPedidos = pedidosSnap.data ?? [];

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: clientes.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final cliente = clientes[index];
                      final pedidosCliente = todosPedidos
                          .where((p) => p.usuarioId == cliente.uid)
                          .toList();
                      final totalGastado = pedidosCliente
                          .where((p) => p.estado != 'Cancelado')
                          .fold<double>(0.0, (s, p) => s + p.total);

                      return Card(
                        elevation: 1.5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFD84315),
                            foregroundColor: Colors.white,
                            child: Text(
                              cliente.nombre.isNotEmpty
                                  ? cliente.nombre[0].toUpperCase()
                                  : 'C',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            cliente.nombre,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('📧 ${cliente.correo}'),
                              Text('📱 Tel: ${cliente.telefono}'),
                              Text(
                                'Miembro desde: ${formatoFecha.format(cliente.fechaRegistro)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.deepOrange.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${pedidosCliente.length} pedidos',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Color(0xFFD84315),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\$${totalGastado.toStringAsFixed(0)} MXN',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
