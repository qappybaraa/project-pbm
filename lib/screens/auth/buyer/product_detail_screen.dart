import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/product_model.dart';
import '../../../providers/app_provider.dart';
import '../../../utils/app_theme.dart';
import 'cart_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  final ProductModel product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                product.imageUrls.isNotEmpty ? product.imageUrls.first : 'https://placehold.co/400x300/gray/white?text=No+Image',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: Colors.grey[200], child: const Icon(Icons.image_not_supported, size: 60)),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text(product.categoryLabel, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      const SizedBox(width: 8),
                      if (product.condition == ProductCondition.used)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppTheme.accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                          child: const Text('Bekas Layak', style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(product.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(_formatRupiah(product.price), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(children: [const Icon(Icons.store_outlined, size: 18, color: Colors.grey), const SizedBox(width: 6), Text(product.sellerName, style: const TextStyle(fontWeight: FontWeight.w600)), const SizedBox(width: 4), const Text('(Penjual)', style: TextStyle(color: Colors.grey, fontSize: 12))]),
                  const SizedBox(height: 8),
                  Row(children: [const Icon(Icons.inventory_2_outlined, size: 18, color: Colors.grey), const SizedBox(width: 6), Text('Stok: ${product.stock}', style: const TextStyle(color: Colors.grey))]),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text('Deskripsi Produk', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(product.description, style: const TextStyle(color: Colors.black87, height: 1.5)),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, -4))],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Chat Penjual'),
                onPressed: () => _showChat(context),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Tambah ke Keranjang'),
                onPressed: product.stock > 0
                    ? () {
                        provider.addToCart(product);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Ditambahkan ke keranjang!'), backgroundColor: AppTheme.success, action: SnackBarAction(label: 'Lihat', textColor: Colors.white, onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())); })));
                      }
                    : null,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatRupiah(double amount) => 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

  void _showChat(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6, maxChildSize: 0.9, minChildSize: 0.4, expand: false,
        builder: (_, ctrl) => Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            Padding(padding: const EdgeInsets.all(16), child: Row(children: [const Icon(Icons.store, color: AppTheme.primary), const SizedBox(width: 8), Text('Chat dengan ${product.sellerName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))])),
            const Divider(height: 1),
            Expanded(
              child: ListView(controller: ctrl, padding: const EdgeInsets.all(16), children: [
                _chatBubble(product.sellerName, 'Halo! Ada yang bisa kami bantu? 😊', false),
                _chatBubble('Saya', 'Halo, apakah ${product.name} masih tersedia?', true),
                _chatBubble(product.sellerName, 'Masih tersedia! Stok ada ${product.stock}. Bisa langsung order ya 🐾', false),
              ]),
            ),
            Padding(
              padding: EdgeInsets.only(left: 12, right: 12, bottom: MediaQuery.of(context).viewInsets.bottom + 12),
              child: Row(children: [
                Expanded(child: TextField(decoration: InputDecoration(hintText: 'Ketik pesan...', contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), border: OutlineInputBorder(borderRadius: BorderRadius.circular(24))))),
                const SizedBox(width: 8),
                const CircleAvatar(backgroundColor: AppTheme.primary, child: Icon(Icons.send, color: Colors.white, size: 18)),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chatBubble(String sender, String message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 260),
        decoration: BoxDecoration(color: isMe ? AppTheme.primary : Colors.grey[100], borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (!isMe) Text(sender, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary)),
          Text(message, style: TextStyle(color: isMe ? Colors.white : Colors.black87)),
        ]),
      ),
    );
  }
}