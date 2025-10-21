import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import 'product_detail_screen.dart';
import 'create_product_state.dart';
import 'create_product_step1.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ApiService _apiService = ApiService();

  // (NUEVO) Variables de estado para manejar la búsqueda y carga
  final TextEditingController _searchController = TextEditingController();
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // (MODIFICADO) Llama a la función de carga
    _fetchProducts();
    // (NUEVO) Añade un "listener" al buscador
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    // (NUEVO) Limpia el "listener" y el "controller"
    _searchController.removeListener(_filterProducts);
    _searchController.dispose();
    super.dispose();
  }

  // (NUEVO) Función para cargar los productos desde la API
  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final products = await _apiService.fetchProducts();
      setState(() {
        _allProducts = products;
        _filteredProducts =
            products; // Al inicio, la lista filtrada es igual a la total
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // (NUEVO) Función que se ejecuta cada vez que el usuario teclea
  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _allProducts.where((product) {
        final brand = product.brand.toLowerCase();
        final model = product.model.toLowerCase();

        // Busca si la marca O el modelo contienen el texto
        return brand.contains(query) || model.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // (MODIFICADO) El body ahora llama a una función que decide qué mostrar
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final state = CreateProductState();
          final created = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CreateProductStep1(state: state)),
          );
          if (created == true) {
            _fetchProducts();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Vender'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // (NUEVO) Widget que decide si mostrar Carga, Error o la Lista
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return _buildErrorView(_error!);
    }

    // (MODIFICADO) La lista ahora se construye con la data en estado
    return ListView.separated(
      padding: const EdgeInsets.all(20.0),
      // Si la lista filtrada está vacía, mostramos 3 items (Header, Search, EmptyView)
      // Si no, mostramos todos los productos + 2 (Header, Search)
      itemCount: _filteredProducts.isEmpty ? 3 : _filteredProducts.length + 2,
      separatorBuilder: (context, index) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        // Elemento 0: El encabezado
        if (index == 0) {
          return _buildHeader();
        }
        // Elemento 1: La barra de búsqueda
        if (index == 1) {
          return _buildSearchBar();
        }

        // (NUEVO) Si la lista está vacía, muestra el placeholder
        if (_filteredProducts.isEmpty) {
          return _buildEmptyView();
        }

        // El resto son los productos (usando la lista filtrada)
        final product = _filteredProducts[index - 2];
        return _buildProductCard(context, product);
      },
    );
  }

  // Encabezado "Bienvenido a ReMarket" (Sin cambios)
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bienvenido a',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          'ReMarket',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Encuentra y vende dispositivos de segunda mano',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // (MODIFICADO) Barra de búsqueda
  Widget _buildSearchBar() {
    return TextField(
      // Le quitamos el 'const'
      controller: _searchController, // (NUEVO) Asignamos el controller
      decoration: const InputDecoration(
        labelText: 'Buscar marca, modelo…',
        prefixIcon: Icon(Icons.search),
      ),
    );
  }

  // Tarjeta de producto (Sin cambios)
  Widget _buildProductCard(BuildContext context, Product product) {
    // Lógica para obtener la primera imagen válida (evita errores)
    final String imageUrl =
        product.imageUrls.isNotEmpty &&
            product.imageUrls.first.trim().isNotEmpty
        ? product.imageUrls.first
        : 'https_invalid_url_placeholder'; // Forzamos el errorBuilder

    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(productId: product.id),
            ),
          );
        },
        // Usamos Bordes redondeados en el InkWell
        borderRadius: BorderRadius.circular(20.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Imagen del producto (como en el código de Kotlin)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                clipBehavior: Clip.antiAlias, // Para recortar la imagen
                child: Image.network(
                  imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Placeholder si la imagen falla
                    return Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              // Información del producto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${product.brand} ${product.model}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // "Chip" de almacenamiento
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.secondaryContainer.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        product.storage,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Icono de flecha (como en el código de Kotlin)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 16.0,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // (MODIFICADO) Vistas de Error y Vacío
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
              onPressed:
                  _fetchProducts, // (MODIFICADO) Llama a la nueva función de carga
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No se encontraron productos',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            Text(
              'Intenta con otra palabra clave.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
