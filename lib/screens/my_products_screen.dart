// lib/screens/my_products_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Para kDebugMode
import '../models/product.dart';
import '../models/user.dart';
import '../models/transaction.dart';
import '../services/api_service.dart';
import '../widgets/product_card.dart';

class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

// Añadimos 'SingleTickerProviderStateMixin' para el TabController
class _MyProductsScreenState extends State<MyProductsScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late TabController _tabController;

  // Usamos un solo Future para manejar toda la carga de datos
  late Future<Map<String, List<Product>>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _dataFuture = _fetchData();
  }

  // --- LÓGICA DE CARGA DE DATOS REESCRITA ---
  Future<Map<String, List<Product>>> _fetchData() async {
    try {
      // 1. Obtenemos el perfil para saber quiénes somos
      final User myProfile = await _apiService.getMyProfile();
      final String myId = myProfile.id;

      // 2. Obtenemos TODAS nuestras transacciones (compras y ventas)
      //    [cite: 445]
      final List<Transaction> myTransactions =
          await _apiService.fetchMyTransactions();

      // 3. Obtenemos los productos públicos (activos, en venta)
      final List<Product> publicProducts = await _apiService.fetchProducts();

      // 4. SECCIÓN "EN VENTA":
      //    Incluye productos públicos donde soy vendedor
      final List<Product> productsOnSale =
          publicProducts.where((p) => p.sellerId == myId).toList();

      //    También incluye productos de transacciones donde soy VENDEDOR
      //    (ej. "Reservado" o "Vendido")
      final Set<String> soldProductIds = myTransactions
          .where((t) => t.sellerId == myId)
          .map((t) => t.productId)
          .toSet();

      // 5. SECCIÓN "COMPRADOS":
      //    Incluye productos de transacciones donde soy COMPRADOR
      final Set<String> boughtProductIds = myTransactions
          .where((t) => t.buyerId == myId)
          .map((t) => t.productId)
          .toSet();

      // 6. Buscamos los detalles de los productos no-públicos
      //    (los que ya están en una transacción)
      final Set<String> nonPublicIds =
          soldProductIds.union(boughtProductIds);

      // Evitamos buscar productos que ya tenemos de la lista pública
      final Set<String> publicIds =
          productsOnSale.map((p) => p.id).toSet();
      final Set<String> idsToFetch =
          nonPublicIds.difference(publicIds);

      final List<Product> nonPublicProducts = [];
      if (idsToFetch.isNotEmpty) {
        try {
          // Usamos Future.wait para buscar todos los productos a la vez
          final results = await Future.wait(
            idsToFetch.map((id) => _apiService.fetchProductById(id)),
          );
          nonPublicProducts.addAll(results);
        } catch (e) {
          if (kDebugMode) {
            print(
                "Error al buscar un producto no público, puede que haya sido eliminado: $e");
          }
          // Ignoramos errores de productos individuales (ej. 404)
        }
      }

      // 7. Combinamos las listas
      final List<Product> allMySellingProducts = [
        ...productsOnSale,
        ...nonPublicProducts.where((p) => soldProductIds.contains(p.id))
      ];

      final List<Product> allMyBoughtProducts = nonPublicProducts
          .where((p) => boughtProductIds.contains(p.id))
          .toList();

      // Devolvemos un mapa con las dos listas separadas
      return {
        'selling': allMySellingProducts,
        'bought': allMyBoughtProducts,
      };
    } catch (e) {
      if (kDebugMode) print('Error en _fetchData (MyProducts): $e');
      rethrow; // Permite que el FutureBuilder maneje el error
    }
  }

  // Función para refrescar los datos
  void _refreshData() {
    setState(() {
      _dataFuture = _fetchData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Productos'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'En Venta'),
            Tab(text: 'Comprados'),
          ],
        ),
        // Botón para refrescar manualmente
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: FutureBuilder<Map<String, List<Product>>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _buildErrorView(snapshot.error.toString());
          }
          if (snapshot.hasData) {
            // Obtenemos las listas del mapa
            final List<Product> productsOnSale =
                snapshot.data!['selling'] ?? [];
            final List<Product> boughtProducts =
                snapshot.data!['bought'] ?? [];

            return TabBarView(
              controller: _tabController,
              children: [
                _ProductListView(
                  products: productsOnSale,
                  emptyMessage: "No tienes productos en venta",
                ),
                _ProductListView(
                  products: boughtProducts,
                  emptyMessage: "No has comprado ningún producto",
                ),
              ],
            );
          }
          return _buildErrorView('No se pudieron cargar los datos.');
        },
      ),
    );
  }

  // Vista de Error
  Widget _buildErrorView(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Error al cargar',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _refreshData,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

// --- WIDGET PARA LA LISTA (MODIFICADO) ---
class _ProductListView extends StatelessWidget {
  final List<Product> products;
  final String emptyMessage;

  const _ProductListView({
    required this.products,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Usamos ProductCard, que ya tiene el chip de estado
    return ListView.separated(
      padding: const EdgeInsets.all(20.0),
      itemCount: products.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return ProductCard(product: products[index]);
      },
    );
  }
}