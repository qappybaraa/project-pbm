// ============================================================
// lib/providers/app_provider.dart
// ============================================================

import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../data/mock_data.dart';

class AppProvider extends ChangeNotifier {
  // ---- AUTH ----
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  bool login(String email, String password) {
    final user = MockData.users.firstWhere(
      (u) => u.email == email,
      orElse: () => throw Exception('User not found'),
    );
    if (user.status == UserStatus.banned) return false;
    _currentUser = user;
    notifyListeners();
    return true;
  }

  bool register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  }) {
    final exists = MockData.users.any((u) => u.email == email);
    if (exists) return false;
    final newUser = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      phone: phone,
      role: role,
      sellerStatus: role == UserRole.seller ? SellerStatus.pending : null,
      createdAt: DateTime.now(),
    );
    MockData.users.add(newUser);
    _currentUser = newUser;
    notifyListeners();
    return true;
  }

  void logout() {
    _currentUser = null;
    _cart.clear();
    notifyListeners();
  }

  // ---- PRODUCTS ----
  List<ProductModel> get allProducts => List.unmodifiable(MockData.products);

  List<ProductModel> get activeProducts =>
      MockData.products.where((p) => p.status == ProductStatus.active).toList();

  List<ProductModel> get pendingProducts =>
      MockData.products.where((p) => p.status == ProductStatus.pending).toList();

  List<ProductModel> getProductsBySeller(String sellerId) =>
      MockData.products.where((p) => p.sellerId == sellerId).toList();

  List<ProductModel> searchProducts(String query, {ProductCategory? category}) {
    return MockData.products.where((p) {
      final matchQuery = p.name.toLowerCase().contains(query.toLowerCase()) ||
          p.description.toLowerCase().contains(query.toLowerCase());
      final matchCategory = category == null || p.category == category;
      final isActive = p.status == ProductStatus.active;
      return matchQuery && matchCategory && isActive;
    }).toList();
  }

  void addProduct(ProductModel product) {
    MockData.products.add(product);
    notifyListeners();
  }

  void updateProduct(ProductModel updated) {
    final idx = MockData.products.indexWhere((p) => p.id == updated.id);
    if (idx >= 0) {
      MockData.products[idx] = updated;
      notifyListeners();
    }
  }

  void deleteProduct(String productId) {
    MockData.products.removeWhere((p) => p.id == productId);
    notifyListeners();
  }

  void updateProductStatus(String productId, ProductStatus status) {
    final idx = MockData.products.indexWhere((p) => p.id == productId);
    if (idx >= 0) {
      MockData.products[idx] = MockData.products[idx].copyWith(status: status);
      notifyListeners();
    }
  }

  // ---- CART ----
  final List<CartItem> _cart = [];
  List<CartItem> get cart => List.unmodifiable(_cart);

  double get cartTotal =>
      _cart.fold(0, (sum, item) => sum + item.product.price * item.quantity);

  void addToCart(ProductModel product) {
    final existing = _cart.indexWhere((c) => c.product.id == product.id);
    if (existing >= 0) {
      _cart[existing].quantity++;
    } else {
      _cart.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _cart.removeWhere((c) => c.product.id == productId);
    notifyListeners();
  }

  void updateCartQty(String productId, int qty) {
    final idx = _cart.indexWhere((c) => c.product.id == productId);
    if (idx >= 0) {
      if (qty <= 0) {
        _cart.removeAt(idx);
      } else {
        _cart[idx].quantity = qty;
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  // ---- ORDERS ----
  List<OrderModel> get allOrders => List.unmodifiable(MockData.orders);

  List<OrderModel> getBuyerOrders(String buyerId) =>
      MockData.orders.where((o) => o.buyerId == buyerId).toList();

  List<OrderModel> getSellerOrders(String sellerId) =>
      MockData.orders.where((o) => o.sellerId == sellerId).toList();

  OrderModel checkout({required String? paymentProofPath}) {
    final buyer = _currentUser!;
    // Group by seller — simplified: take first seller in cart
    final firstSeller = MockData.users.firstWhere(
      (u) => u.id == _cart.first.product.sellerId,
    );
    final items = _cart
        .map((c) => OrderItem(
              productId: c.product.id,
              productName: c.product.name,
              price: c.product.price,
              quantity: c.quantity,
              imageUrl: c.product.imageUrls.isNotEmpty ? c.product.imageUrls.first : null,
            ))
        .toList();

    final order = OrderModel(
      id: 'order_${DateTime.now().millisecondsSinceEpoch}',
      buyerId: buyer.id,
      buyerName: buyer.name,
      sellerId: firstSeller.id,
      sellerName: firstSeller.name,
      items: items,
      totalPrice: cartTotal,
      status: paymentProofPath != null
          ? OrderStatus.waitingConfirmation
          : OrderStatus.waitingPayment,
      paymentProofPath: paymentProofPath,
      createdAt: DateTime.now(),
    );
    MockData.orders.add(order);
    clearCart();
    return order;
  }

  void updateOrderStatus(String orderId, OrderStatus status) {
    final idx = MockData.orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      MockData.orders[idx].status = status;
      notifyListeners();
    }
  }

  // ---- ADMIN: USER MANAGEMENT ----
  List<UserModel> get allUsers => List.unmodifiable(MockData.users);

  List<UserModel> get allSellers =>
      MockData.users.where((u) => u.role == UserRole.seller).toList();

  List<UserModel> get pendingSellers => MockData.users
      .where((u) => u.role == UserRole.seller && u.sellerStatus == SellerStatus.pending)
      .toList();

  void updateUserStatus(String userId, UserStatus status) {
    final idx = MockData.users.indexWhere((u) => u.id == userId);
    if (idx >= 0) {
      MockData.users[idx] = MockData.users[idx].copyWith(status: status);
      notifyListeners();
    }
  }

  void updateSellerStatus(String userId, SellerStatus status) {
    final idx = MockData.users.indexWhere((u) => u.id == userId);
    if (idx >= 0) {
      MockData.users[idx] = MockData.users[idx].copyWith(sellerStatus: status);
      notifyListeners();
    }
  }

  void deleteUser(String userId) {
    MockData.users.removeWhere((u) => u.id == userId);
    notifyListeners();
  }
}