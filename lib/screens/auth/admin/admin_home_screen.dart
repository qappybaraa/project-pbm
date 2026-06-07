import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_provider.dart';
import '../../../models/user_model.dart';
import '../../../models/product_model.dart';
import '../../../utils/app_theme.dart';
import '../login_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('🛡️ Admin Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              provider.logout();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
        ],
      ),
      body: _tab == 0
          ? _buildSellerVerification(provider)
          : _tab == 1
              ? _buildProductModeration(provider)
              : _buildUserManagement(provider),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        selectedItemColor: AppTheme.primary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.verified_user_outlined), activeIcon: Icon(Icons.verified_user), label: 'Verifikasi'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), activeIcon: Icon(Icons.inventory_2), label: 'Produk'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people), label: 'Pengguna'),
        ],
      ),
    );
  }

  Widget _buildSellerVerification(AppProvider provider) {
    final pendingSellers = provider.pendingSellers;
    if (pendingSellers.isEmpty) {
      return const Center(child: Text('Tidak ada seller yang menunggu verifikasi', style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pendingSellers.length,
      itemBuilder: (_, i) {
        final seller = pendingSellers[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(backgroundColor: AppTheme.accent, child: Text(seller.name[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(seller.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(seller.email, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(seller.phone, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
                if (seller.address != null) ...[
                  const SizedBox(height: 8),
                  Text('Alamat: ${seller.address}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.close, color: Colors.red, size: 18),
                        label: const Text('Tolak', style: TextStyle(color: Colors.red)),
                        onPressed: () => provider.updateSellerStatus(seller.id, SellerStatus.rejected),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Verifikasi'),
                        onPressed: () => provider.updateSellerStatus(seller.id, SellerStatus.verified),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductModeration(AppProvider provider) {
    final pendingProducts = provider.pendingProducts;
    if (pendingProducts.isEmpty) {
      return const Center(child: Text('Tidak ada produk yang menunggu moderasi', style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pendingProducts.length,
      itemBuilder: (_, i) {
        final product = pendingProducts[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    product.imageUrls.isNotEmpty ? product.imageUrls.first : '',
                    width: 60, height: 60, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(width: 60, height: 60, color: Colors.grey[200], child: const Icon(Icons.image_not_supported, size: 20)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text('Oleh: ${product.sellerName}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(_fmt(product.price), style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                      onPressed: () => provider.updateProductStatus(product.id, ProductStatus.active),
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                      onPressed: () => provider.updateProductStatus(product.id, ProductStatus.rejected),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserManagement(AppProvider provider) {
    final users = provider.allUsers;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (_, i) {
        final user = users[i];
        final roleLabel = user.role == UserRole.admin ? 'Admin' : user.role == UserRole.seller ? 'Seller' : 'Buyer';
        final roleColor = user.role == UserRole.admin ? Colors.purple : user.role == UserRole.seller ? AppTheme.accent : AppTheme.primary;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: roleColor,
              child: Text(user.name[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.email, style: const TextStyle(fontSize: 12)),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: roleColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                      child: Text(roleLabel, style: TextStyle(color: roleColor, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: user.status == UserStatus.active ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        user.status == UserStatus.active ? 'Aktif' : user.status == UserStatus.banned ? 'Banned' : 'Nonaktif',
                        style: TextStyle(color: user.status == UserStatus.active ? Colors.green : Colors.red, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: user.role != UserRole.admin
                ? PopupMenuButton(
                    itemBuilder: (_) => [
                      if (user.status == UserStatus.active)
                        const PopupMenuItem(value: 'ban', child: Text('Ban User', style: TextStyle(color: Colors.red)))
                      else
                        const PopupMenuItem(value: 'activate', child: Text('Aktifkan', style: TextStyle(color: Colors.green))),
                      const PopupMenuItem(value: 'delete', child: Text('Hapus', style: TextStyle(color: Colors.red))),
                    ],
                    onSelected: (v) {
                      if (v == 'ban') provider.updateUserStatus(user.id, UserStatus.banned);
                      if (v == 'activate') provider.updateUserStatus(user.id, UserStatus.active);
                      if (v == 'delete') provider.deleteUser(user.id);
                    },
                  )
                : null,
          ),
        );
      },
    );
  }

  String _fmt(double a) => 'Rp ${a.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
}
