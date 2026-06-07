import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_provider.dart';
import '../../../models/user_model.dart';
import '../../../utils/app_theme.dart';

class GpsScreen extends StatelessWidget {
  const GpsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final sellers = provider.allSellers.where((s) => s.sellerStatus == SellerStatus.verified && s.latitude != null).toList();

    return Column(
      children: [
        Container(
          height: 260,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.grey[200],
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  'https://placehold.co/600x300/e8f5e9/388E3C?text=Peta+Jember',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[200],
                    child: const Center(child: Icon(Icons.map, size: 60, color: Colors.grey)),
                  ),
                ),
              ),
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map_outlined, size: 48, color: AppTheme.primaryDark),
                    SizedBox(height: 8),
                    Text('Peta Interaktif', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryDark)),
                    Text('(Integrasi Google Maps saat production)', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
              Positioned(
                bottom: 12,
                right: 12,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.my_location, size: 16),
                  label: const Text('Lokasi Saya', style: TextStyle(fontSize: 12)),
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('${sellers.length} Penjual Terdekat', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: sellers.length,
            itemBuilder: (_, i) {
              final s = sellers[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: AppTheme.primary, child: Text(s.name[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                  title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(s.address ?? 'Jember', style: const TextStyle(fontSize: 12)),
                  trailing: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on, color: AppTheme.primary, size: 18),
                      Text('~2 km', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}