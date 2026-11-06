import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de datos para un Pedido de Comida a Domicilio.
/// Autor: Daniel Michel Cruz Verde
class Pedido {
  final String? id;
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
  final String registradoPor;

  Pedido({
    this.id,
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
    this.registradoPor = 'Daniel Michel Cruz Verde',
  });

  /// Convierte un DocumentSnapshot de Cloud Firestore en una instancia de [Pedido].
  factory Pedido.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Pedido(
      id: doc.id,
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
      registradoPor:
          data['registradoPor'] as String? ?? 'Daniel Michel Cruz Verde',
    );
  }

  /// Convierte la instancia de [Pedido] a un mapa compatible con Cloud Firestore.
  Map<String, dynamic> toFirestore() {
    return {
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
      'registradoPor': registradoPor,
    };
  }
}

/// Catálogo de platillos disponibles en el menú para selección rápida.
class PlatilloMenu {
  final String nombre;
  final String restaurante;
  final String categoria;
  final double precio;
  final String descripcion;
  final String emoji;
  final String tiempoEstimado;

  const PlatilloMenu({
    required this.nombre,
    required this.restaurante,
    required this.categoria,
    required this.precio,
    required this.descripcion,
    required this.emoji,
    required this.tiempoEstimado,
  });
}

const List<PlatilloMenu> catalogoPlatillos = [
  PlatilloMenu(
    nombre: 'Combo Tacos al Pastor (5 pzas + Refresco)',
    restaurante: 'Taquería El Fogón de Daniel',
    categoria: 'Mexicana',
    precio: 135.0,
    descripcion: 'Con piña, cilantro, cebolla y salsa artesanal.',
    emoji: '🌮',
    tiempoEstimado: '20-30 min',
  ),
  PlatilloMenu(
    nombre: 'Hamburguesa Doble Queso & Tocino + Papas',
    restaurante: 'Cruz Verde Burger Grill',
    categoria: 'Hamburguesas',
    precio: 185.0,
    descripcion: 'Carne Angus 200g, queso cheddar, tocino crujiente y papas.',
    emoji: '🍔',
    tiempoEstimado: '25-35 min',
  ),
  PlatilloMenu(
    nombre: 'Pizza Pepperoni Familiar Orilla de Queso',
    restaurante: 'Pizzería Bella Napoli Express',
    categoria: 'Pizzas',
    precio: 220.0,
    descripcion: '8 rebanadas grandes con mozzarella 100% y pepperoni.',
    emoji: '🍕',
    tiempoEstimado: '30-40 min',
  ),
  PlatilloMenu(
    nombre: 'Rollo Sushi Dragón Crunch (10 bocados)',
    restaurante: 'Sakura Sushi & Wok',
    categoria: 'Oriental',
    precio: 165.0,
    descripcion: 'Camarón empanizado, aguacate, queso crema y salsa anguila.',
    emoji: '🍣',
    tiempoEstimado: '25-35 min',
  ),
  PlatilloMenu(
    nombre: 'Alitas BBQ & Buffalo (12 piezas + Aderezo)',
    restaurante: 'Wings & Fries Express',
    categoria: 'Snacks',
    precio: 175.0,
    descripcion: 'Acompañadas de bastones de apio, zanahoria y aderezo ranch.',
    emoji: '🍗',
    tiempoEstimado: '20-30 min',
  ),
  PlatilloMenu(
    nombre: 'Ensalada César con Pollo a la Parrilla',
    restaurante: 'Green Bowl Saludable',
    categoria: 'Saludable',
    precio: 145.0,
    descripcion: 'Pechuga grill, lechuga fresca, crutones, parmesano y aderezo.',
    emoji: '🥗',
    tiempoEstimado: '15-25 min',
  ),
];
