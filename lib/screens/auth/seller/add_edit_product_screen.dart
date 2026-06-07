import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import '../../../providers/app_provider.dart';
import '../../../models/product_model.dart';
import '../../../utils/app_theme.dart';

class AddEditProductScreen extends StatefulWidget {
  final ProductModel? product;
  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(text: widget.product?.name);
  late final _descCtrl = TextEditingController(text: widget.product?.description);
  late final _priceCtrl = TextEditingController(text: widget.product?.price.toStringAsFixed(0) ?? '');
  late final _stockCtrl = TextEditingController(text: widget.product?.stock.toString() ?? '1');
  late ProductCategory _category = widget.product?.category ?? ProductCategory.animal;
  late ProductCondition _condition = widget.product?.condition ?? ProductCondition.newItem;
  final List<String> _imagePaths = [];

  final _categories = [
    (ProductCategory.animal, '🐾 Hewan'),
    (ProductCategory.food, '🍖 Makanan'),
    (ProductCategory.litterBox, '📦 Litter Box'),
    (ProductCategory.cage, '🏠 Kandang'),
  ];

  bool get _isEdit => widget.product != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Produk' : 'Tambah Produk')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Text('Foto Produk', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 110,
              child: ListView(scrollDirection: Axis.horizontal, children: [
                ..._imagePaths.map((path) => Container(
                  margin: const EdgeInsets.only(right: 10), width: 100, height: 100,
                  child: Stack(children: [
                    ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(path), width: 100, height: 100, fit: BoxFit.cover)),
                    Positioned(top: 4, right: 4, child: GestureDetector(onTap: () => setState(() => _imagePaths.remove(path)), child: Container(width: 22, height: 22, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: const Icon(Icons.close, size: 14, color: Colors.white)))),
                  ]),
                )),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(width: 100, height: 100, decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.camera_alt_outlined, color: Colors.grey[500], size: 28), const SizedBox(height: 4), Text('Tambah Foto', style: TextStyle(fontSize: 11, color: Colors.grey[500]))])),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Nama Produk'), validator: (v) => v!.isEmpty ? 'Nama wajib diisi' : null),
            const SizedBox(height: 12),
            TextFormField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Deskripsi Produk'), maxLines: 3, validator: (v) => v!.isEmpty ? 'Deskripsi wajib diisi' : null),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextFormField(controller: _priceCtrl, decoration: const InputDecoration(labelText: 'Harga (Rp)', prefixText: 'Rp '), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Harga wajib diisi' : null)),
              const SizedBox(width: 12),
              Expanded(child: TextFormField(controller: _stockCtrl, decoration: const InputDecoration(labelText: 'Stok'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Stok wajib diisi' : null)),
            ]),
            const SizedBox(height: 16),
            const Text('Kategori', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: _categories.map((c) {
              final selected = _category == c.$1;
              return ChoiceChip(label: Text(c.$2), selected: selected, selectedColor: AppTheme.primary.withValues(alpha: 0.15), onSelected: (_) => setState(() => _category = c.$1), labelStyle: TextStyle(color: selected ? AppTheme.primary : null, fontWeight: selected ? FontWeight.bold : null));
            }).toList()),
            const SizedBox(height: 16),
            const Text('Kondisi Produk', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _conditionCard(ProductCondition.newItem, '✨ Baru', 'Produk baru belum pernah dipakai')),
              const SizedBox(width: 12),
              Expanded(child: _conditionCard(ProductCondition.used, '♻️ Bekas Layak', 'Bekas namun masih layak pakai')),
            ]),
            const SizedBox(height: 24),
            ElevatedButton.icon(icon: Icon(_isEdit ? Icons.save : Icons.add), label: Text(_isEdit ? 'Simpan Perubahan' : 'Tambahkan Produk', style: const TextStyle(fontSize: 16)), onPressed: _save),
          ]),
        ),
      ),
    );
  }

  Widget _conditionCard(ProductCondition condition, String title, String subtitle) {
    final selected = _condition == condition;
    return GestureDetector(
      onTap: () => setState(() => _condition = condition),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: selected ? AppTheme.primary.withValues(alpha: 0.1) : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: selected ? AppTheme.primary : Colors.grey.shade300, width: selected ? 2 : 1)),
        child: Column(children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: selected ? AppTheme.primary : null)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey), textAlign: TextAlign.center),
        ]),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final result = await showModalBottomSheet<ImageSource>(context: context, builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
      ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Ambil Foto'), onTap: () => Navigator.pop(context, ImageSource.camera)),
      ListTile(leading: const Icon(Icons.photo_library), title: const Text('Pilih dari Galeri'), onTap: () => Navigator.pop(context, ImageSource.gallery)),
    ])));
    if (result == null) return;
    final img = await picker.pickImage(source: result, imageQuality: 80);
    if (img != null) setState(() => _imagePaths.add(img.path));
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<AppProvider>();
    final user = provider.currentUser!;
    final images = _imagePaths.isNotEmpty ? _imagePaths : (widget.product?.imageUrls ?? ['https://picsum.photos/seed/no-image/300/200']);

    if (_isEdit) {
      provider.updateProduct(widget.product!.copyWith(name: _nameCtrl.text.trim(), description: _descCtrl.text.trim(), price: double.tryParse(_priceCtrl.text) ?? widget.product!.price, category: _category, condition: _condition, imageUrls: images, stock: int.tryParse(_stockCtrl.text) ?? widget.product!.stock));
    } else {
      provider.addProduct(ProductModel(id: const Uuid().v4(), sellerId: user.id, sellerName: user.name, name: _nameCtrl.text.trim(), description: _descCtrl.text.trim(), price: double.tryParse(_priceCtrl.text) ?? 0, category: _category, condition: _condition, status: ProductStatus.pending, imageUrls: images, stock: int.tryParse(_stockCtrl.text) ?? 1, createdAt: DateTime.now()));
    }
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isEdit ? 'Produk berhasil diperbarui!' : 'Produk berhasil ditambahkan, menunggu verifikasi admin.'), backgroundColor: AppTheme.success));
  }
}