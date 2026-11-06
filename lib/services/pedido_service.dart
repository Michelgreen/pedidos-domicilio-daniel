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

  /// Obtiene la lista de pedidos actualizada en tiempo real.
  Stream<List<Pedido>> obtenerPedidosEnTiempoReal() {
    return _pedidosRef.snapshots().map((snapshot) {
      final lista =
          snapshot.docs.map((doc) => Pedido.fromFirestore(doc)).toList();
      lista.sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));
      return lista;
    });
  }

  /// Actualiza el estado de entrega de una orden ('En preparación', 'En camino', 'Entregado').
  Future<void> actualizarEstadoPedido(String pedidoId, String nuevoEstado) async {
    await _pedidosRef.doc(pedidoId).update({
      'estado': nuevoEstado,
      'ultimaActualizacion': FieldValue.serverTimestamp(),
    });
  }

  /// Cancela o elimina un pedido del historial.
  Future<void> eliminarPedido(String pedidoId) async {
    await _pedidosRef.doc(pedidoId).delete();
  }
}
