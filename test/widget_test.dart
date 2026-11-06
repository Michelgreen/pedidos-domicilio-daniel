import 'package:flutter_test/flutter_test.dart';
import 'package:pedidos_domicilio_daniel/models/pedido.dart';

void main() {
  test('El modelo Pedido convierte sus datos correctamente', () {
    final fecha = DateTime(2026, 11, 5, 22, 0);
    final pedido = Pedido(
      usuarioId: 'uid_12345',
      usuarioCorreo: 'cliente@correo.com',
      clienteNombre: 'Laura Gómez',
      telefono: '4421234567',
      direccion: 'Av. Universidad 123, Centro',
      platillo: 'Orden de Tacos al Pastor (5 pzas + Bebida)',
      precioUnitario: 135.0,
      cantidad: 2,
      costoEnvio: 25.0,
      total: 295.0,
      metodoPago: 'Efectivo',
      notas: 'Con todo',
      estado: 'En preparación',
      fechaCreacion: fecha,
    );

    final map = pedido.toFirestore();
    expect(map['usuarioId'], 'uid_12345');
    expect(map['usuarioCorreo'], 'cliente@correo.com');
    expect(map['clienteNombre'], 'Laura Gómez');
    expect(map['telefono'], '4421234567');
    expect(map['cantidad'], 2);
    expect(map['total'], 295.0);
  });
}
