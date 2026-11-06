import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de datos para un Pedido del Restaurante a Domicilio.
class Pedido {
  final String? id;
  final String usuarioId;
  final String usuarioCorreo;
  final String clienteNombre;
  final String telefono;
  final String direccion;
  final String platillo;
  final double precioUnitario;
  final int cantidad;
  final double costoEnvio;
  final double total;
  final String metodoPago;
  final String notas;
  final String estado;
  final DateTime fechaCreacion;

  Pedido({
    this.id,
    required this.usuarioId,
    required this.usuarioCorreo,
    required this.clienteNombre,
    required this.telefono,
    required this.direccion,
    required this.platillo,
    required this.precioUnitario,
    required this.cantidad,
    required this.costoEnvio,
    required this.total,
    required this.metodoPago,
    required this.notas,
    required this.estado,
    required this.fechaCreacion,
  });

  factory Pedido.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Pedido(
      id: doc.id,
      usuarioId: data['usuarioId'] as String? ?? '',
      usuarioCorreo: data['usuarioCorreo'] as String? ?? '',
      clienteNombre: data['clienteNombre'] as String? ?? '',
      telefono: data['telefono'] as String? ?? '',
      direccion: data['direccion'] as String? ?? '',
      platillo: data['platillo'] as String? ?? '',
      precioUnitario: (data['precioUnitario'] as num?)?.toDouble() ?? 0.0,
      cantidad: (data['cantidad'] as num?)?.toInt() ?? 1,
      costoEnvio: (data['costoEnvio'] as num?)?.toDouble() ?? 25.0,
      total: (data['total'] as num?)?.toDouble() ?? 0.0,
      metodoPago: data['metodoPago'] as String? ?? 'Efectivo',
      notas: data['notas'] as String? ?? '',
      estado: data['estado'] as String? ?? 'En preparación',
      fechaCreacion: data['fechaCreacion'] is Timestamp
          ? (data['fechaCreacion'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'usuarioId': usuarioId,
      'usuarioCorreo': usuarioCorreo.trim(),
      'clienteNombre': clienteNombre.trim(),
      'telefono': telefono.trim(),
      'direccion': direccion.trim(),
      'platillo': platillo.trim(),
      'precioUnitario': precioUnitario,
      'cantidad': cantidad,
      'costoEnvio': costoEnvio,
      'total': total,
      'metodoPago': metodoPago,
      'notas': notas.trim(),
      'estado': estado,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
    };
  }
}

/// Modelo de un Platillo del Menú del Restaurante (almacenado en Firestore).
class PlatilloMenu {
  final String? id;
  final String nombre;
  final String categoria;
  final double precio;
  final String descripcion;
  final String emoji;
  final String tiempoEstimado;
  final bool disponible;

  const PlatilloMenu({
    this.id,
    required this.nombre,
    required this.categoria,
    required this.precio,
    required this.descripcion,
    required this.emoji,
    required this.tiempoEstimado,
    this.disponible = true,
  });

  factory PlatilloMenu.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PlatilloMenu(
      id: doc.id,
      nombre: data['nombre'] as String? ?? '',
      categoria: data['categoria'] as String? ?? 'Especialidades',
      precio: (data['precio'] as num?)?.toDouble() ?? 0.0,
      descripcion: data['descripcion'] as String? ?? '',
      emoji: data['emoji'] as String? ?? '🍽️',
      tiempoEstimado: data['tiempoEstimado'] as String? ?? '20-30 min',
      disponible: data['disponible'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre.trim(),
      'categoria': categoria.trim(),
      'precio': precio,
      'descripcion': descripcion.trim(),
      'emoji': emoji.trim(),
      'tiempoEstimado': tiempoEstimado.trim(),
      'disponible': disponible,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlatilloMenu &&
          runtimeType == other.runtimeType &&
          nombre == other.nombre;

  @override
  int get hashCode => nombre.hashCode;
}

/// Modelo de Cliente Registrado en la aplicación del restaurante.
class ClienteRegistrado {
  final String uid;
  final String nombre;
  final String telefono;
  final String correo;
  final String rol;
  final DateTime fechaRegistro;

  ClienteRegistrado({
    required this.uid,
    required this.nombre,
    required this.telefono,
    required this.correo,
    required this.rol,
    required this.fechaRegistro,
  });

  factory ClienteRegistrado.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ClienteRegistrado(
      uid: doc.id,
      nombre: data['nombre'] as String? ?? 'Cliente',
      telefono: data['telefono'] as String? ?? 'Sin teléfono',
      correo: data['correo'] as String? ?? '',
      rol: data['rol'] as String? ?? 'cliente',
      fechaRegistro: data['fechaRegistro'] is Timestamp
          ? (data['fechaRegistro'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}

/// Menú base inicial del restaurante (se carga automáticamente si el menú está vacío).
const List<PlatilloMenu> catalogoPlatillosInicial = [
  PlatilloMenu(
    nombre: 'Orden de Tacos al Pastor (5 pzas + Bebida)',
    categoria: 'Tacos y Parrilla',
    precio: 135.0,
    descripcion: 'Con piña asada, cilantro, cebolla y salsa artesanal de la casa.',
    emoji: '🌮',
    tiempoEstimado: '20-25 min',
  ),
  PlatilloMenu(
    nombre: 'Hamburguesa Especial de la Casa + Papas',
    categoria: 'Hamburguesas',
    precio: 185.0,
    descripcion: 'Carne Angus 200g, queso cheddar, tocino crujiente y papas gajo.',
    emoji: '🍔',
    tiempoEstimado: '25-30 min',
  ),
  PlatilloMenu(
    nombre: 'Pizza Artesanal Pepperoni al Horno',
    categoria: 'Pizzas',
    precio: 220.0,
    descripcion: '8 rebanadas grandes con queso mozzarella 100% y pepperoni.',
    emoji: '🍕',
    tiempoEstimado: '30-35 min',
  ),
  PlatilloMenu(
    nombre: 'Alitas BBQ & Buffalo (12 piezas + Ranch)',
    categoria: 'Entradas y Snacks',
    precio: 175.0,
    descripcion: 'Acompañadas de bastones de apio, zanahoria y aderezo ranch.',
    emoji: '🍗',
    tiempoEstimado: '20-25 min',
  ),
  PlatilloMenu(
    nombre: 'Ensalada César con Pechuga Grill',
    categoria: 'Ensaladas',
    precio: 145.0,
    descripcion: 'Pechuga a la parrilla, lechuga fresca, crutones y parmesano.',
    emoji: '🥗',
    tiempoEstimado: '15-20 min',
  ),
  PlatilloMenu(
    nombre: 'Malteada Cremosa de Chocolate o Vainilla',
    categoria: 'Postres y Bebidas',
    precio: 75.0,
    descripcion: 'Preparada con helado artesanal y crema batida.',
    emoji: '🥤',
    tiempoEstimado: '10-15 min',
  ),
];
