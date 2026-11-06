import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pedido.dart';

/// Servicio de gestión de pedidos, menú de platillos y clientes del restaurante.
class PedidoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _pedidosRef =>
      _db.collection('pedidos');

  CollectionReference<Map<String, dynamic>> get _platillosRef =>
      _db.collection('platillos');

  CollectionReference<Map<String, dynamic>> get _usuariosRef =>
      _db.collection('usuarios');

  // ==================== PEDIDOS ====================

  /// Crea un nuevo pedido de un cliente.
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
  /// - Si `esAdmin` es `true`, devuelve todos los pedidos del restaurante.
  /// - Si es cliente, devuelve únicamente los pedidos de ese cliente.
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

  /// (Admin) Actualiza el estado de entrega de un pedido.
  Future<void> actualizarEstadoPedido(
    String pedidoId,
    String nuevoEstado,
  ) async {
    await _pedidosRef.doc(pedidoId).update({
      'estado': nuevoEstado,
      'ultimaActualizacion': FieldValue.serverTimestamp(),
    });
  }

  /// (Cliente) Cancela su propio pedido solo si sigue 'En preparación'.
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

  /// (Admin) Elimina definitivamente un pedido que ya fue 'Cancelado'.
  Future<void> eliminarPedidoCancelado(Pedido pedido) async {
    if (pedido.id == null) return;
    if (pedido.estado != 'Cancelado') {
      throw StateError(
        'Solo se pueden eliminar pedidos que hayan sido cancelados.',
      );
    }

    await _pedidosRef.doc(pedido.id!).delete();
  }

  // ==================== MENÚ DEL RESTAURANTE ====================

  /// Inicializa el menú base del restaurante si aún no hay platillos guardados.
  Future<void> asegurarMenuInicial() async {
    try {
      final snap = await _platillosRef.limit(1).get();
      if (snap.docs.isEmpty) {
        for (final p in catalogoPlatillosInicial) {
          await _platillosRef.add(p.toFirestore());
        }
      }
    } catch (_) {
      // Si ocurre algún error de red, la app usa catalogoPlatillosInicial como respaldo.
    }
  }

  /// Obtiene todos los platillos del restaurante en tiempo real.
  Stream<List<PlatilloMenu>> obtenerPlatillosEnTiempoReal() {
    return _platillosRef.snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return catalogoPlatillosInicial;
      }
      final lista =
          snapshot.docs.map((doc) => PlatilloMenu.fromFirestore(doc)).toList();
      lista.sort((a, b) => a.nombre.compareTo(b.nombre));
      return lista;
    });
  }

  /// (Admin) Agrega un nuevo platillo al menú del restaurante.
  Future<void> agregarPlatillo(PlatilloMenu platillo) async {
    await _platillosRef.add(platillo.toFirestore());
  }

  /// (Admin) Elimina un platillo del menú del restaurante.
  Future<void> eliminarPlatillo(String platilloId) async {
    await _platillosRef.doc(platilloId).delete();
  }

  // ==================== CLIENTES REGISTRADOS (SOLO ADMIN) ====================

  /// Obtiene la lista de clientes registrados en el restaurante en tiempo real.
  Stream<List<ClienteRegistrado>> obtenerClientesRegistrados() {
    return _usuariosRef.snapshots().map((snapshot) {
      final todos = snapshot.docs
          .map((doc) => ClienteRegistrado.fromFirestore(doc))
          .where((u) => u.rol != 'admin')
          .toList();
      todos.sort((a, b) => b.fechaRegistro.compareTo(a.fechaRegistro));
      return todos;
    });
  }
}
