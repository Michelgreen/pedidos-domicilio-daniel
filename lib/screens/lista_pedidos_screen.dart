import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/pedido.dart';
import '../services/pedido_service.dart';

/// Pantalla de Seguimiento e Historial de Pedidos del Cliente
class ListaPedidosScreen extends StatefulWidget {
  const ListaPedidosScreen({super.key});

  @override
  State<ListaPedidosScreen> createState() => _ListaPedidosScreenState();
}

class _ListaPedidosScreenState extends State<ListaPedidosScreen> {
  final PedidoService _pedidoService = PedidoService();
  String _filtroEstado = 'Todos';

  Color _colorPorEstado(String estado) {
    switch (estado) {
      case 'En preparación':
        return Colors.orange.shade800;
      case 'En camino':
        return Colors.blue.shade700;
      case 'Entregado':
        return Colors.green.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  IconData _iconoPorEstado(String estado) {
    switch (estado) {
      case 'En preparación':
        return Icons.soup_kitchen;
      case 'En camino':
        return Icons.delivery_dining;
      case 'Entregado':
        return Icons.check_circle;
      default:
        return Icons.receipt;
    }
  }

  String _siguienteEstado(String actual) {
    if (actual == 'En preparación') return 'En camino';
    if (actual == 'En camino') return 'Entregado';
    return 'En preparación';
  }

  @override
  Widget build(BuildContext context) {
    final formatoFecha = DateFormat('dd/MM/yyyy HH:mm');

    return Column(
      children: [
        // Encabezado y filtros de seguimiento
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          color: Colors.grey.shade100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.delivery_dining, color: Color(0xFFD84315), size: 22),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Seguimiento de Mis Pedidos',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    'Todos',
                    'En preparación',
                    'En camino',
                    'Entregado',
                  ].map((estado) {
                    final seleccionado = _filtroEstado == estado;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(estado),
                        selected: seleccionado,
                        onSelected: (_) {
                          setState(() => _filtroEstado = estado);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        // Lista de órdenes en tiempo real
        Expanded(
          child: StreamBuilder<List<Pedido>>(
            stream: _pedidoService.obtenerPedidosEnTiempoReal(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.wifi_off_rounded,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No se pudieron cargar tus pedidos',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Verifica tu conexión a internet e inténtalo de nuevo.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text('Actualizando el estado de tus pedidos...'),
                    ],
                  ),
                );
              }

              final todosLosPedidos = snapshot.data ?? [];
              final pedidosFiltrados = _filtroEstado == 'Todos'
                  ? todosLosPedidos
                  : todosLosPedidos
                      .where((p) => p.estado == _filtroEstado)
                      .toList();

              if (pedidosFiltrados.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.fastfood_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Aún no tienes pedidos en esta sección',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Explora el menú y pide tu comida favorita para seguir su entrega desde aquí.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: pedidosFiltrados.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final pedido = pedidosFiltrados[index];
                  final colorEstado = _colorPorEstado(pedido.estado);

                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Cabecera con Número de Orden y Estado
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Orden #${pedido.id != null && pedido.id!.length >= 6 ? pedido.id!.substring(0, 6).toUpperCase() : pedido.id ?? ''}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    formatoFecha.format(pedido.fechaCreacion),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: colorEstado.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: colorEstado),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _iconoPorEstado(pedido.estado),
                                      size: 14,
                                      color: colorEstado,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      pedido.estado,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: colorEstado,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 18),

                          // Platillo y Restaurante
                          Text(
                            '${pedido.cantidad}x ${pedido.platillo}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            pedido.restaurante,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.deepOrange.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Información de Entrega
                          Row(
                            children: [
                              const Icon(
                                Icons.person_outline,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Recibe: ${pedido.clienteNombre} (${pedido.telefono})',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Domicilio: ${pedido.direccion}',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                          if (pedido.notas.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.notes,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Notas: ${pedido.notas}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 12),

                          // Total y acciones sobre el pedido
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pago: ${pedido.metodoPago}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  Text(
                                    'Total: \$${pedido.total.toStringAsFixed(2)} MXN',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFD84315),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  if (pedido.id != null)
                                    OutlinedButton.icon(
                                      onPressed: () async {
                                        final nuevo =
                                            _siguienteEstado(pedido.estado);
                                        await _pedidoService
                                            .actualizarEstadoPedido(
                                          pedido.id!,
                                          nuevo,
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.local_shipping_outlined,
                                        size: 16,
                                      ),
                                      label: Text(
                                        pedido.estado == 'Entregado'
                                            ? 'Repetir preparación'
                                            : 'Marcar ${_siguienteEstado(pedido.estado)}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  const SizedBox(width: 6),
                                  if (pedido.id != null)
                                    IconButton(
                                      tooltip: 'Cancelar pedido',
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.redAccent,
                                      ),
                                      onPressed: () async {
                                        await _pedidoService
                                            .eliminarPedido(pedido.id!);
                                      },
                                    ),
                                ],
                              ),
                            ],
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
    );
  }
}
