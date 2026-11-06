import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pedido.dart';

/// Servicio de gestión de pedidos de comida a domicilio.
class PedidoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _pedidosRef =>
      _db.collection('pedidos');

  /// Crea un nuevo pedido y devuelve su número de orden.
  Future<String> registrarPedido(Pedido pedido) async {
    if (pedido.clienteNombre.trim().isEmpty ||
        pedido.telefono.trim().isEmpty ||
        pedido.direccion.trim().isEmpty ||
        pedido.platillo.trim().isEmpty) {
      throw ArgumentError('Por favor completa todos los datos de entrega.');
    }

    final docRef = await _pedidosRef.add(pedido.toFirestore());
    return docRef.id;
  }

  /// Obtiene la lista de pedidos en tiempo real.
  /// - Si `esAdmin` es `true`, devuelve todos los pedidos de todos los clientes.
  /// - Si es un cliente normal, devuelve únicamente sus propios pedidos.
  Stream<List<Pedido>> obtenerPedidosEnTiempoReal({
    String? usuarioId,
    bool esAdmin = false,
  }) {
    return _pedidosRef.snapshots().map((snapshot) {
      var lista =
          snapshot.docs.map((doc) => Pedido.fromFirestore(doc)).toList();

      if (!esAdmin && usuarioId != null && usuarioId.isNotEmpty) {
        lista = lista.where((p) => p.usuarioId == usuarioId).toList();
      }

      lista.sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));
      return lista;
    });
  }

  /// (Solo Admin) Actualiza el estado de entrega de una orden
  /// ('En preparación', 'En camino', 'Entregado').
  Future<void> actualizarEstadoPedido(
    String pedidoId,
    String nuevoEstado,
  ) async {
    await _pedidosRef.doc(pedidoId).update({
      'estado': nuevoEstado,
      'ultimaActualizacion': FieldValue.serverTimestamp(),
    });
  }

  /// (Cliente) Cancela un pedido únicamente si todavía se encuentra 'En preparación'.
  Future<void> cancelarPedidoCliente(Pedido pedido) async {
    if (pedido.id == null) return;
    if (pedido.estado != 'En preparación') {
      throw StateError(
        'Solo se pueden cancelar pedidos que aún están en preparación.',
      );
    }

    await _pedidosRef.doc(pedido.id!).update({
      'estado': 'Cancelado',
      'ultimaActualizacion': FieldValue.serverTimestamp(),
    });
  }

  /// (Solo Admin) Elimina definitivamente un pedido que ya fue 'Cancelado'.
  Future<void> eliminarPedidoCancelado(Pedido pedido) async {
    if (pedido.id == null) return;
    if (pedido.estado != 'Cancelado') {
      throw StateError(
        'Solo se pueden eliminar pedidos que hayan sido cancelados.',
      );
    }

    await _pedidosRef.doc(pedido.id!).delete();
  }
}
