import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pedido.dart';

/// Servicio de acceso a datos en la nube con Cloud Firestore.
/// Gestiona el registro, consulta en tiempo real, actualización de estado y eliminación
/// de pedidos en la colección `pedidos`.
///
/// Autor: Daniel Michel Cruz Verde
class PedidoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Referencia a la colección principal en Cloud Firestore.
  CollectionReference<Map<String, dynamic>> get _pedidosRef =>
      _db.collection('pedidos');

  /// Registra un nuevo pedido en la nube de Firebase y devuelve el ID del documento.
  Future<String> registrarPedido(Pedido pedido) async {
    if (pedido.clienteNombre.trim().isEmpty ||
        pedido.telefono.trim().isEmpty ||
        pedido.direccion.trim().isEmpty ||
        pedido.platillo.trim().isEmpty) {
      throw ArgumentError('No se permiten registros con campos obligatorios vacíos.');
    }

    final docRef = await _pedidosRef.add(pedido.toFirestore());
    return docRef.id;
  }

  /// Obtiene un flujo (Stream) en tiempo real con todos los pedidos almacenados,
  /// ordenados del más reciente al más antiguo.
  Stream<List<Pedido>> obtenerPedidosEnTiempoReal() {
    return _pedidosRef.snapshots().map((snapshot) {
      final lista =
          snapshot.docs.map((doc) => Pedido.fromFirestore(doc)).toList();
      lista.sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));
      return lista;
    });
  }

  /// Actualiza el estado de entrega de un pedido ('En preparación', 'En camino', 'Entregado').
  Future<void> actualizarEstadoPedido(String pedidoId, String nuevoEstado) async {
    await _pedidosRef.doc(pedidoId).update({
      'estado': nuevoEstado,
      'ultimaActualizacion': FieldValue.serverTimestamp(),
    });
  }

  /// Elimina un pedido por su ID en Cloud Firestore.
  Future<void> eliminarPedido(String pedidoId) async {
    await _pedidosRef.doc(pedidoId).delete();
  }
}
