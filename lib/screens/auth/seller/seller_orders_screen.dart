import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_provider.dart';
import '../../../models/order_model.dart';
import '../../../utils/app_theme.dart';

class SellerOrdersScreen extends StatelessWidget {
  const SellerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final orders = provider.getSellerOrders(provider.currentUser!.id);

    if (orders.isEmpty) return const Center(child: Text('Belum ada pesanan masuk', style: TextStyle(color: Colors.grey)));

    return ListView.builder(
      padding: const EdgeInsets.all(16), itemCount: orders.length,
      itemBuilder: (_, i) {
        final order = orders[i];
        final statusColor = _statusColor(order.status);
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Order #${order.id.substring(6, 16)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: statusColor)), child: Text(order.statusLabel, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold))),
              ]),
              const SizedBox(height: 6),
              Text('Pembeli: ${order.buyerName}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 6),
              ...order.items.map((item) => Text('• ${item.productName} x${item.quantity}', style: const TextStyle(fontSize: 13))),
              const Divider(),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Total: ${_fmt(order.totalPrice)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
                if (order.status == OrderStatus.waitingConfirmation)
                  ElevatedButton(style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), textStyle: const TextStyle(fontSize: 12)), onPressed: () => provider.updateOrderStatus(order.id, OrderStatus.processing), child: const Text('Konfirmasi'))
                else if (order.status == OrderStatus.processing)
                  ElevatedButton(style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), textStyle: const TextStyle(fontSize: 12), backgroundColor: AppTheme.success), onPressed: () => provider.updateOrderStatus(order.id, OrderStatus.done), child: const Text('Selesai')),
              ]),
            ]),
          ),
        );
      },
    );
  }

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.waitingPayment: return Colors.orange;
      case OrderStatus.waitingConfirmation: return Colors.blue;
      case OrderStatus.processing: return Colors.purple;
      case OrderStatus.done: return AppTheme.success;
      case OrderStatus.cancelled: return AppTheme.error;
    }
  }

  String _fmt(double a) => 'Rp ${a.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
}