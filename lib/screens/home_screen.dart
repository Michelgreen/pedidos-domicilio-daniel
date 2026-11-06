import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/pedido.dart';
import '../services/auth_service.dart';
import '../services/pedido_service.dart';
import 'admin_restaurante_screen.dart';
import 'formulario_pedido_screen.dart';
import 'lista_pedidos_screen.dart';

/// Pantalla Principal de ProntoBite Restaurante
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  PlatilloMenu? _platilloPreseleccionado;
  final PedidoService _pedidoService = PedidoService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _pedidoService.asegurarMenuInicial();
  }

  void _irAFormularioConPlatillo(PlatilloMenu platillo) {
    setState(() {
      _platilloPreseleccionado = platillo;
      _selectedIndex = 1;
    });
  }

  void _irAListaPedidos() {
    setState(() {
      _selectedIndex = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    final User? usuario = _authService.currentUser;
    final bool esAdmin = _authService.esAdmin;
    final String nombreSaludo =
        (usuario?.displayName != null && usuario!.displayName!.trim().isNotEmpty)
            ? usuario.displayName!
            : (usuario?.email?.split('@').first ?? 'Cliente');

    // Si es Admin (Dueño del restaurante), no hace pedidos:
    // Gestiona los Pedidos, el Menú de Comidas y los Clientes Registrados.
    final List<Widget> paginas = esAdmin
        ? const [
            ListaPedidosScreen(),
            AdminMenuScreen(),
            AdminClientesScreen(),
          ]
        : [
            _InicioMenuTab(
              nombreUsuario: nombreSaludo,
              usuarioId: usuario?.uid,
              pedidoService: _pedidoService,
              onSeleccionarPlatillo: _irAFormularioConPlatillo,
              onIrANuevoPedido: () {
                setState(() {
                  _platilloPreseleccionado = null;
                  _selectedIndex = 1;
                });
              },
              onIrAMisPedidos: _irAListaPedidos,
            ),
            FormularioPedidoScreen(
              platilloInicial: _platilloPreseleccionado,
              onPedidoGuardado: _irAListaPedidos,
            ),
            const ListaPedidosScreen(),
          ];

    final List<NavigationDestination> destinos = esAdmin
        ? const [
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: 'Pedidos',
            ),
            NavigationDestination(
              icon: Icon(Icons.restaurant_menu_outlined),
              selectedIcon: Icon(Icons.restaurant_menu),
              label: 'Menú de Comidas',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_alt_outlined),
              selectedIcon: Icon(Icons.people_alt),
              label: 'Clientes',
            ),
          ]
        : const [
            NavigationDestination(
              icon: Icon(Icons.restaurant_menu_outlined),
              selectedIcon: Icon(Icons.restaurant_menu),
              label: 'Menú',
            ),
            NavigationDestination(
              icon: Icon(Icons.shopping_bag_outlined),
              selectedIcon: Icon(Icons.shopping_bag),
              label: 'Hacer Pedido',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: 'Mis Pedidos',
            ),
          ];

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFD84315),
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.restaurant, size: 24),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ProntoBite Restaurante',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    esAdmin
                        ? 'Administración del Restaurante'
                        : 'Hola, $nombreSaludo • Servicio a domicilio',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.cerrarSesion();
            },
          ),
        ],
      ),
      body: paginas[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: destinos,
      ),
    );
  }
}

class _InicioMenuTab extends StatefulWidget {
  final String nombreUsuario;
  final String? usuarioId;
  final PedidoService pedidoService;
  final ValueChanged<PlatilloMenu> onSeleccionarPlatillo;
  final VoidCallback onIrANuevoPedido;
  final VoidCallback onIrAMisPedidos;

  const _InicioMenuTab({
    required this.nombreUsuario,
    required this.usuarioId,
    required this.pedidoService,
    required this.onSeleccionarPlatillo,
    required this.onIrANuevoPedido,
    required this.onIrAMisPedidos,
  });

  @override
  State<_InicioMenuTab> createState() => _InicioMenuTabState();
}

class _InicioMenuTabState extends State<_InicioMenuTab> {
  String _categoriaSeleccionada = 'Todas';

  List<String> get _categorias => [
        'Todas',
        'Tacos y Parrilla',
        'Hamburguesas',
        'Pizzas',
        'Entradas y Snacks',
        'Ensaladas',
        'Postres y Bebidas',
      ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PlatilloMenu>>(
      stream: widget.pedidoService.obtenerPlatillosEnTiempoReal(),
      builder: (context, menuSnap) {
        final todosPlatillos = menuSnap.data ?? catalogoPlatillosInicial;
        final platillosFiltrados = _categoriaSeleccionada == 'Todas'
            ? todosPlatillos
            : todosPlatillos
                .where((p) => p.categoria == _categoriaSeleccionada)
                .toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner de bienvenida del restaurante para sus clientes
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD84315), Color(0xFFFF7043)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepOrange.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '🛵 Servicio a Domicilio • Envío \$25 MXN',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '¡Bienvenido a nuestro restaurante, ${widget.nombreUsuario}!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Preparamos cada platillo al momento con ingredientes frescos y lo llevamos directo hasta tu mesa.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ElevatedButton.icon(
                          onPressed: widget.onIrANuevoPedido,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFFD84315),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                          icon: const Icon(Icons.fastfood),
                          label: const Text(
                            'Hacer un Pedido',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: widget.onIrAMisPedidos,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                          icon: const Icon(Icons.delivery_dining),
                          label: const Text('Mis Pedidos'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Resumen del restaurante para el cliente
              StreamBuilder<List<Pedido>>(
                stream: widget.pedidoService.obtenerPedidosEnTiempoReal(
                  usuarioId: widget.usuarioId,
                  esAdmin: false,
                ),
                builder: (context, snapshot) {
                  final pedidos = snapshot.data ?? [];
                  final enCurso = pedidos
                      .where(
                        (p) =>
                            p.estado == 'En preparación' ||
                            p.estado == 'En camino',
                      )
                      .length;
                  final entregados =
                      pedidos.where((p) => p.estado == 'Entregado').length;

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _MetricItem(
                          icon: Icons.restaurant_menu,
                          label: 'Platillos en Menú',
                          value: '${todosPlatillos.length}',
                          color: Colors.deepOrange,
                        ),
                        _MetricItem(
                          icon: Icons.delivery_dining,
                          label: 'Mis Órdenes Activas',
                          value: '$enCurso',
                          color: Colors.amber.shade900,
                        ),
                        _MetricItem(
                          icon: Icons.check_circle_outline,
                          label: 'Recibidos',
                          value: '$entregados',
                          color: Colors.green.shade700,
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Filtro por categoría del menú
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categorias.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = _categorias[index];
                    final activa = _categoriaSeleccionada == cat;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: activa,
                      onSelected: (_) {
                        setState(() => _categoriaSeleccionada = cat);
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Nuestro Menú del Día',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: platillosFiltrados.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = platillosFiltrados[index];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.deepOrange.shade50,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              item.emoji,
                              style: const TextStyle(fontSize: 34),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.nombre,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${item.categoria} • Prep: ${item.tiempoEstimado}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.descripcion,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '\$${item.precio.toStringAsFixed(2)} MXN',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFD84315),
                                      ),
                                    ),
                                    FilledButton.tonalIcon(
                                      onPressed: () =>
                                          widget.onSeleccionarPlatillo(item),
                                      icon: const Icon(
                                        Icons.add_shopping_cart,
                                        size: 18,
                                      ),
                                      label: const Text('Ordenar'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MetricItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}
