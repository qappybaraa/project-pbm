// ============================================================
// lib/screens/buyer/buyer_home_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/app_provider.dart';
import '../../../models/product_model.dart';
import '../../../utils/app_theme.dart';

import '../../../widgets/product_card.dart';

import '../login_screen.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';
import 'order_history_screen.dart';
import 'gps_screen.dart';

class BuyerHomeScreen extends StatefulWidget {
  const BuyerHomeScreen({super.key});

  @override
  State<BuyerHomeScreen> createState() => _BuyerHomeScreenState();
}

class _BuyerHomeScreenState extends State<BuyerHomeScreen> {
  int _tab = 0;
  ProductCategory? _selectedCategory;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  final _categories = [
    {'label': 'Semua', 'icon': Icons.grid_view_rounded, 'value': null},
    {'label': 'Hewan', 'icon': Icons.cruelty_free, 'value': ProductCategory.animal},
    {'label': 'Makanan', 'icon': Icons.restaurant, 'value': ProductCategory.food},
    {'label': 'Litter Box', 'icon': Icons.inbox_outlined, 'value': ProductCategory.litterBox},
    {'label': 'Kandang', 'icon': Icons.home_work_outlined, 'value': ProductCategory.cage},
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser!;
    final cartCount = provider.cart.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🐾 PawMart'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
              ),
              if (cartCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: AppTheme.error, shape: BoxShape.circle),
                    child: Text('$cartCount', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _tab == 0 ? _buildHome(provider) : _tab == 1 ? const GpsScreen() : const OrderHistoryScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        selectedItemColor: AppTheme.primary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.location_on_outlined), activeIcon: Icon(Icons.location_on), label: 'Peta'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: 'Pesanan'),
        ],
      ),
    );
  }

  Widget _buildHome(AppProvider provider) {
    final products = provider.searchProducts(_searchQuery, category: _selectedCategory);
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner
              Container(
                margin: const EdgeInsets.all(16),
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppTheme.primary, AppTheme.primaryDark]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Temukan Hewan\n& Aksesoris Terbaik!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            SizedBox(height: 6),
                            Text('Kandang bekas layak juga ada!', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: Text('🐶🐱\n🐹🐰', style: TextStyle(fontSize: 32)),
                    ),
                  ],
                ),
              ),
              // Search
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Cari produk...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchCtrl.clear(); setState(() => _searchQuery = ''); })
                        : null,
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
              const SizedBox(height: 12),
              // Categories
              SizedBox(
                height: 80,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) {
                    final cat = _categories[i];
                    final selected = _selectedCategory == cat['value'];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat['value'] as ProductCategory?),
                      child: Column(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: selected ? AppTheme.primary : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: selected ? AppTheme.primary : Colors.grey.shade200),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
                            ),
                            child: Icon(cat['icon'] as IconData, color: selected ? Colors.white : Colors.grey[600], size: 26),
                          ),
                          const SizedBox(height: 4),
                          Text(cat['label'] as String, style: TextStyle(fontSize: 11, fontWeight: selected ? FontWeight.bold : FontWeight.normal, color: selected ? AppTheme.primary : Colors.grey[700])),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('${products.length} Produk Ditemukan', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        products.isEmpty
            ? const SliverFillRemaining(child: Center(child: Text('Produk tidak ditemukan')))
            : SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => ProductCard(
                      product: products[i],
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(product: products[i]),
                      )),
                    ),
                    childCount: products.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                ),
              ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}