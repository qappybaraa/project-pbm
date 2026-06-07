import 'product_model.dart';

enum OrderStatus { waitingPayment, waitingConfirmation, processing, done, cancelled }

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class OrderModel {
  final String id;
  final String buyerId;
  final String buyerName;
  final String sellerId;
  final String sellerName;
  final List<OrderItem> items;
  final double totalPrice;
  OrderStatus status;
  final String? paymentProofPath;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.buyerId,
    required this.buyerName,
    required this.sellerId,
    required this.sellerName,
    required this.items,
    required this.totalPrice,
    this.status = OrderStatus.waitingPayment,
    this.paymentProofPath,
    required this.createdAt,
  });

  String get statusLabel {
    switch (status) {
      case OrderStatus.waitingPayment: return 'Menunggu Pembayaran';
      case OrderStatus.waitingConfirmation: return 'Menunggu Konfirmasi';
      case OrderStatus.processing: return 'Diproses';
      case OrderStatus.done: return 'Selesai';
      case OrderStatus.cancelled: return 'Dibatalkan';
    }
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String? imageUrl;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.imageUrl,
  });
}