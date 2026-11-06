import 'package:flutter_test/flutter_test.dart';
import 'package:pedidos_domicilio_daniel/models/pedido.dart';

void main() {
  test('El modelo Pedido serializa los datos correctamente para Firestore', () {
    final fecha = DateTime(2026, 11, 5, 22, 0);
    final pedido = Pedido(
      clienteNombre: 'Daniel Michel Cruz Verde',
      telefono: '4421234567',
      direccion: 'Av. Universidad 123, Centro',
      restaurante: 'Taquería El Fogón de Daniel',
      platillo: 'Combo Tacos al Pastor (5 pzas + Refresco)',
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
    expect(map['clienteNombre'], 'Daniel Michel Cruz Verde');
    expect(map['telefono'], '4421234567');
    expect(map['cantidad'], 2);
    expect(map['total'], 295.0);
    expect(map['registradoPor'], 'Daniel Michel Cruz Verde');
  });
}
