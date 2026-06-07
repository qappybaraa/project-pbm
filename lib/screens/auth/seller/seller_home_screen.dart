import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_provider.dart';
import '../../../models/user_model.dart';
import '../../../utils/app_theme.dart';
import '../login_screen.dart';
import 'seller_products_screen.dart';
import 'seller_orders_screen.dart';
import 'add_edit_product_screen.dart';

class SellerHomeScreen extends StatefulWidget {
  const SellerHomeScreen({super.key});

  @override
  State<SellerHomeScreen> createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser!;
    final isPending = user.sellerStatus == SellerStatus.pending;
    final isRejected = user.sellerStatus == SellerStatus.rejected;

    if (isPending || isRejected) return _buildPendingScreen(user, isPending);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🏪 PawMart Seller'),
        actions: [
          if (_tab == 0) IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditProductScreen()))),
          IconButton(icon: const Icon(Icons.logout), onPressed: () { provider.logout(); Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())); }),
        ],
      ),
      body: _tab == 0 ? const SellerProductsScreen() : const SellerOrdersScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab, onTap: (i) => setState(() => _tab = i), selectedItemColor: AppTheme.primary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), activeIcon: Icon(Icons.inventory_2), label: 'Produk Saya'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: 'Pesanan'),
        ],
      ),
    );
  }

  Widget _buildPendingScreen(UserModel user, bool isPending) {
    final provider = context.read<AppProvider>();
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(isPending ? Icons.hourglass_empty : Icons.cancel_outlined, size: 80, color: isPending ? AppTheme.accent : AppTheme.error),
              const SizedBox(height: 16),
              Text(isPending ? 'Menunggu Verifikasi' : 'Pendaftaran Ditolak', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(isPending ? 'Akun seller kamu sedang diverifikasi oleh admin. Proses ini biasanya 1x24 jam.' : 'Maaf, pendaftaran seller kamu ditolak oleh admin. Silakan hubungi support.', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, height: 1.5)),
              const SizedBox(height: 24),
              OutlinedButton.icon(icon: const Icon(Icons.logout), label: const Text('Keluar'), onPressed: () { provider.logout(); Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())); }),
            ],
          ),
        ),
      ),
    );
  }
}