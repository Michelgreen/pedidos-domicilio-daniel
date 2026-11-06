import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/pedido.dart';
import '../services/auth_service.dart';
import '../services/pedido_service.dart';

/// Pantalla de Seguimiento de Pedidos (Modo Cliente y Modo Administrador)
class ListaPedidosScreen extends StatefulWidget {
  const ListaPedidosScreen({super.key});

  @override
  State<ListaPedidosScreen> createState() => _ListaPedidosScreenState();
}

class _ListaPedidosScreenState extends State<ListaPedidosScreen> {
  final PedidoService _pedidoService = PedidoService();
  final AuthService _authService = AuthService();
  String _filtroEstado = 'Todos';

  Color _colorPorEstado(String estado) {
    switch (estado) {
      case 'En preparación':
        return Colors.orange.shade800;
      case 'En camino':
        return Colors.blue.shade700;
      case 'Entregado':
        return Colors.green.shade700;
      case 'Cancelado':
        return Colors.red.shade700;
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
      case 'Cancelado':
        return Icons.cancel_outlined;
      default:
        return Icons.receipt;
    }
  }

  Future<void> _confirmarCancelacionCliente(Pedido pedido) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Cancelar tu pedido?'),
        content: Text(
          'Tu pedido de "${pedido.platillo}" aún está en preparación. ¿Confirmas que deseas cancelarlo?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('No, conservar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sí, cancelar pedido'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await _pedidoService.cancelarPedidoCliente(pedido);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tu pedido ha sido cancelado.'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo cancelar el pedido: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  Future<void> _confirmarEliminacionAdmin(Pedido pedido) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar pedido cancelado'),
        content: Text(
          '¿Deseas eliminar permanentemente la orden cancelada de ${pedido.clienteNombre}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Volver'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade800),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar definitivamente'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await _pedidoService.eliminarPedidoCancelado(pedido);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pedido cancelado eliminado del sistema.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatoFecha = DateFormat('dd/MM/yyyy HH:mm');
    final bool esAdmin = _authService.esAdmin;
    final String? uidActual = _authService.currentUser?.uid;

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
              Row(
                children: [
                  Icon(
                    esAdmin ? Icons.admin_panel_settings : Icons.delivery_dining,
                    color: const Color(0xFFD84315),
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      esAdmin
                          ? 'Administración de Pedidos de Clientes'
                          : 'Seguimiento de Mis Pedidos',
                      style: const TextStyle(
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
                    'Cancelado',
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
            stream: _pedidoService.obtenerPedidosEnTiempoReal(
              usuarioId: uidActual,
              esAdmin: esAdmin,
            ),
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
                          'No se pudieron cargar los pedidos',
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
                      Text('Actualizando el estado de los pedidos...'),
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
                          'Aún no hay pedidos en esta sección',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          esAdmin
                              ? 'Cuando los clientes realicen pedidos, aparecerán aquí en tiempo real para que gestiones su envío.'
                              : 'Explora el menú y pide tu comida favorita para seguir su entrega desde aquí.',
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

                          // Platillo
                          Text(
                            '${pedido.cantidad}x ${pedido.platillo}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              decoration: pedido.estado == 'Cancelado'
                                  ? TextDecoration.lineThrough
                                  : null,
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
                                  esAdmin && pedido.usuarioCorreo.isNotEmpty
                                      ? 'Cliente: ${pedido.clienteNombre} (${pedido.telefono}) • ${pedido.usuarioCorreo}'
                                      : 'Recibe: ${pedido.clienteNombre} (${pedido.telefono})',
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

                          // Pie de tarjeta con Total y Controles según Rol (Cliente vs Admin)
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 10,
                            runSpacing: 10,
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

                              // ACCIONES PARA CLIENTE NORMAL:
                              // Solo puede cancelar cuando el pedido está 'En preparación'.
                              if (!esAdmin) ...[
                                if (pedido.estado == 'En preparación')
                                  OutlinedButton.icon(
                                    onPressed: () =>
                                        _confirmarCancelacionCliente(pedido),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red.shade700,
                                      side: BorderSide(
                                        color: Colors.red.shade300,
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.cancel_outlined,
                                      size: 17,
                                    ),
                                    label: const Text('Cancelar pedido'),
                                  )
                                else if (pedido.estado == 'En camino')
                                  Text(
                                    '🛵 Tu repartidor va en camino',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue.shade700,
                                    ),
                                  )
                                else if (pedido.estado == 'Entregado')
                                  Text(
                                    '✅ Pedido entregado',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green.shade700,
                                    ),
                                  )
                                else if (pedido.estado == 'Cancelado')
                                  Text(
                                    'Pedido cancelado',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                              ],

                              // ACCIONES EXCLUSIVAS DEL ADMINISTRADOR:
                              // - Cambiar el estado de los pedidos activos ('En preparación' -> 'En camino' -> 'Entregado')
                              // - Eliminar únicamente los pedidos que están 'Cancelado'
                              if (esAdmin && pedido.id != null) ...[
                                if (pedido.estado != 'Cancelado')
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'Cambiar estado: ',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      DropdownButton<String>(
                                        value: [
                                          'En preparación',
                                          'En camino',
                                          'Entregado',
                                        ].contains(pedido.estado)
                                            ? pedido.estado
                                            : 'En preparación',
                                        underline: Container(
                                          height: 1,
                                          color: const Color(0xFFD84315),
                                        ),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFD84315),
                                        ),
                                        items: const [
                                          DropdownMenuItem(
                                            value: 'En preparación',
                                            child: Text('🍳 En preparación'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'En camino',
                                            child: Text('🛵 En camino'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Entregado',
                                            child: Text('✅ Entregado'),
                                          ),
                                        ],
                                        onChanged: (nuevoEstado) async {
                                          if (nuevoEstado != null &&
                                              nuevoEstado != pedido.estado) {
                                            await _pedidoService
                                                .actualizarEstadoPedido(
                                              pedido.id!,
                                              nuevoEstado,
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                if (pedido.estado == 'Cancelado')
                                  FilledButton.tonalIcon(
                                    onPressed: () =>
                                        _confirmarEliminacionAdmin(pedido),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: Colors.red.shade50,
                                      foregroundColor: Colors.red.shade800,
                                    ),
                                    icon: const Icon(
                                      Icons.delete_forever,
                                      size: 18,
                                    ),
                                    label: const Text(
                                      'Eliminar pedido cancelado',
                                    ),
                                  ),
                              ],
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
