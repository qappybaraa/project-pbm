import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_provider.dart';
import '../../../models/product_model.dart';
import '../../../utils/app_theme.dart';
import '../../../services/api_service.dart';
import 'add_edit_product_screen.dart';

class SellerProductsScreen extends StatelessWidget {
  const SellerProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser!;
    final products = provider.getProductsBySeller(user.id);

    if (products.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.inventory_2_outlined, size: 72, color: Colors.grey), const SizedBox(height: 12),
        const Text('Belum ada produk', style: TextStyle(color: Colors.grey, fontSize: 16)), const SizedBox(height: 16),
        ElevatedButton.icon(icon: const Icon(Icons.add), label: const Text('Tambah Produk'), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditProductScreen()))),
      ]));
    }

    return ListView.builder(padding: const EdgeInsets.all(16), itemCount: products.length, itemBuilder: (_, i) => _ProductListTile(product: products[i]));
  }
}

class _ProductListTile extends StatelessWidget {
  final ProductModel product;
  const _ProductListTile({required this.product});

  @override
  Widget build(BuildContext context) {
    final statusColor = product.status == ProductStatus.active ? AppTheme.success : product.status == ProductStatus.pending ? AppTheme.accent : AppTheme.error;
    final statusLabel = product.status == ProductStatus.active ? 'Aktif' : product.status == ProductStatus.pending ? 'Pending' : 'Ditolak';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(product.imageUrls.isNotEmpty ? product.imageUrls.first : '', width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 60, height: 60, color: Colors.grey[200], child: const Icon(Icons.image_not_supported, size: 20)))),
        title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_fmt(product.price), style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
          Row(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: statusColor, width: 0.5)), child: Text(statusLabel, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold))),
            const SizedBox(width: 6),
            Text('Stok: ${product.stock}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ]),
        ]),
          trailing: PopupMenuButton<String>(
  itemBuilder: (_) => [
    const PopupMenuItem(
      value: 'submit',
      child: Text('Submit PBM'),
    ),
    const PopupMenuItem(
      value: 'edit',
      child: Text('Edit'),
    ),
    const PopupMenuItem(
      value: 'delete',
      child: Text('Hapus'),
    ),
  ],
  onSelected: (v) async {
    if (v == 'submit') {
      try {
        final api = ApiService();

        final token = await api.login();

        if (token == null) {
          throw Exception('Login API gagal');
        }

        final result = await api.submitProduct(
          token: token,
          name: product.name,
          price: product.price.toInt(),
          description: product.description,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result
                  ? 'Submit berhasil'
                  : 'Submit gagal',
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
          ),
        );
      }
    } else if (v == 'edit') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddEditProductScreen(product: product),
        ),
      );
    } else if (v == 'delete') {
      _confirmDelete(context);
    }
  },
),
      ),
    );
  }
  void _confirmDelete(BuildContext context) {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Hapus Produk?'), content: Text('Apakah kamu yakin ingin menghapus "${product.name}"?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error), onPressed: () { context.read<AppProvider>().deleteProduct(product.id); Navigator.pop(context); }, child: const Text('Hapus')),
      ],
    ));
  }

  String _fmt(double a) => 'Rp ${a.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
}