import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de datos para un Pedido de Comida a Domicilio.
class Pedido {
  final String? id;
  final String usuarioId;
  final String usuarioCorreo;
  final String clienteNombre;
  final String telefono;
  final String direccion;
  final String restaurante;
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
    required this.restaurante,
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
      restaurante: data['restaurante'] as String? ?? '',
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
      'restaurante': restaurante.trim(),
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

/// Catálogo de platillos disponibles en el menú.
class PlatilloMenu {
  final String nombre;
  final String restaurante;
  final String categoria;
  final double precio;
  final String descripcion;
  final String emoji;
  final String tiempoEstimado;
  final double calificacion;

  const PlatilloMenu({
    required this.nombre,
    required this.restaurante,
    required this.categoria,
    required this.precio,
    required this.descripcion,
    required this.emoji,
    required this.tiempoEstimado,
    required this.calificacion,
  });
}

const List<PlatilloMenu> catalogoPlatillos = [
  PlatilloMenu(
    nombre: 'Combo Tacos al Pastor (5 pzas + Refresco)',
    restaurante: 'Taquería El Fogón Tradicional',
    categoria: 'Mexicana',
    precio: 135.0,
    descripcion: 'Con piña asada, cilantro, cebolla y salsa artesanal de la casa.',
    emoji: '🌮',
    tiempoEstimado: '20-30 min',
    calificacion: 4.9,
  ),
  PlatilloMenu(
    nombre: 'Hamburguesa Doble Queso & Tocino + Papas',
    restaurante: 'Urban Burger Grill',
    categoria: 'Hamburguesas',
    precio: 185.0,
    descripcion: 'Carne Angus 200g, queso cheddar, tocino crujiente y papas gajo.',
    emoji: '🍔',
    tiempoEstimado: '25-35 min',
    calificacion: 4.8,
  ),
  PlatilloMenu(
    nombre: 'Pizza Pepperoni Familiar Orilla de Queso',
    restaurante: 'Pizzería Bella Napoli',
    categoria: 'Pizzas',
    precio: 220.0,
    descripcion: '8 rebanadas grandes con queso mozzarella 100% y pepperoni.',
    emoji: '🍕',
    tiempoEstimado: '30-40 min',
    calificacion: 4.7,
  ),
  PlatilloMenu(
    nombre: 'Rollo Sushi Dragón Crunch (10 bocados)',
    restaurante: 'Sakura Sushi & Wok',
    categoria: 'Oriental',
    precio: 165.0,
    descripcion: 'Camarón empanizado, aguacate, queso crema y salsa de anguila.',
    emoji: '🍣',
    tiempoEstimado: '25-35 min',
    calificacion: 4.9,
  ),
  PlatilloMenu(
    nombre: 'Alitas BBQ & Buffalo (12 piezas + Aderezo)',
    restaurante: 'Wings & Fries Express',
    categoria: 'Snacks',
    precio: 175.0,
    descripcion: 'Acompañadas de bastones de apio, zanahoria y aderezo ranch.',
    emoji: '🍗',
    tiempoEstimado: '20-30 min',
    calificacion: 4.6,
  ),
  PlatilloMenu(
    nombre: 'Ensalada César con Pollo a la Parrilla',
    restaurante: 'Green Bowl Kitchen',
    categoria: 'Saludable',
    precio: 145.0,
    descripcion: 'Pechuga grill, lechuga fresca, crutones, parmesano y aderezo César.',
    emoji: '🥗',
    tiempoEstimado: '15-25 min',
    calificacion: 4.8,
  ),
];
