import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/user_model.dart';
import '../../utils/app_theme.dart';
import 'register_screen.dart';
import 'buyer/buyer_home_screen.dart';
import 'seller/seller_home_screen.dart';
import 'admin/admin_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 48),
            const Icon(Icons.pets, size: 72, color: Colors.white),
            const SizedBox(height: 12),
            const Text('PawMart', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            const Text('Pet Shop Digital #1', style: TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 32),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        const Text('Selamat Datang!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const Text('Masuk ke akun PawMart kamu', style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _emailCtrl,
                          decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => v!.isEmpty ? 'Email wajib diisi' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passCtrl,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _obscure = !_obscure),
                            ),
                          ),
                          obscureText: _obscure,
                          validator: (v) => v!.isEmpty ? 'Password wajib diisi' : null,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loading ? null : _login,
                          child: _loading
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Masuk', style: TextStyle(fontSize: 16)),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Belum punya akun?'),
                            TextButton(
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                              child: const Text('Daftar Sekarang'),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        const Text('Akun Demo:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                        const SizedBox(height: 8),
                        _demoBtn('👤 Buyer', 'rizky@buyer.com'),
                        _demoBtn('🏪 Seller (Verified)', 'budi@seller.com'),
                        _demoBtn('🏪 Seller (Pending)', 'siti@seller.com'),
                        _demoBtn('🛡️ Admin', 'admin@pawmart.com'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _demoBtn(String label, String email) {
    return OutlinedButton(
      onPressed: () {
        _emailCtrl.text = email;
        _passCtrl.text = 'demo123';
      },
      child: Text(label, style: const TextStyle(fontSize: 13)),
    );
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final provider = context.read<AppProvider>();
      final success = provider.login(_emailCtrl.text.trim(), _passCtrl.text);
      if (!success) {
        _showError('Akun dinonaktifkan. Hubungi admin.');
        return;
      }
      final user = provider.currentUser!;
      Widget dest;
      if (user.role == UserRole.admin) {
        dest = const AdminHomeScreen();
      } else if (user.role == UserRole.seller) {
        dest = const SellerHomeScreen();
      } else {
        dest = const BuyerHomeScreen();
      }
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => dest));
    } catch (_) {
      _showError('Email atau password salah.');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppTheme.error));
  }
}