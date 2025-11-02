// lib/screens/my_products_screen.dart
import 'package:flutter/material.dart';
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

class _MyProductsScreenState extends State<MyProductsScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late TabController _tabController;
  late Future<Map<String, dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _dataFuture = _fetchData();
  }

  Future<Map<String, dynamic>> _fetchData() async {
    try {
      final results = await Future.wait([
        _apiService.getMyProfile(), 
        _apiService.fetchProducts(),
        _apiService.fetchMyTransactions(), 
      ]);

      return {
        'profile': results[0] as User,
        'products': results[1] as List<Product>,
        'transactions': results[2] as List<Transaction>,
      };
    } catch (e) {
      rethrow;
    }
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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'En Venta'),
            Tab(text: 'Comprados'),
          ],
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _buildErrorView(snapshot.error.toString());
          }
          if (snapshot.hasData) {
            final User myProfile = snapshot.data!['profile'];
            final List<Product> allProducts = snapshot.data!['products'];
            final List<Transaction> myTransactions =
                snapshot.data!['transactions'];

            final List<Product> productsOnSale = allProducts
                .where((p) => p.sellerId == myProfile.id)
                .toList();

            final Set<String> boughtProductIds = myTransactions
                .where((t) => t.buyerId == myProfile.id)
                .map((t) => t.productId)
                .toSet();
            final List<Product> boughtProducts = allProducts
                .where((p) => boughtProductIds.contains(p.id))
                .toList();

            return TabBarView(
              controller: _tabController,
              children: [
                _ProductListView(products: productsOnSale),
                _ProductListView(products: boughtProducts),
              ],
            );
          }
          return _buildErrorView('No se pudieron cargar los datos.');
        },
      ),
    );
  }

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
              onPressed: () {
                setState(() {
                  _dataFuture = _fetchData();
                });
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductListView extends StatelessWidget {
  final List<Product> products;
  const _ProductListView({required this.products});

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
              'No hay productos aquí',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

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