import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../models/user_model.dart';
import '../../../providers/app_provider.dart';
import '../../../utils/app_theme.dart';

class GpsScreen extends StatefulWidget {
  const GpsScreen({super.key});

  @override
  State<GpsScreen> createState() => _GpsScreenState();
}

class _GpsScreenState extends State<GpsScreen> {
  static const _jemberCenter = LatLng(-8.1727, 113.7020);
  final _mapController = MapController();
  LatLng? _myLocation;
  bool _loadingLocation = false;
  UserModel? _selectedSeller;

  Future<void> _getMyLocation() async {
    setState(() => _loadingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnack('Aktifkan layanan lokasi terlebih dahulu');
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnack('Izin lokasi ditolak');
          return;
        }
      }
      final pos = await Geolocator.getCurrentPosition();
      final loc = LatLng(pos.latitude, pos.longitude);
      setState(() => _myLocation = loc);
      _mapController.move(loc, 14);
    } catch (_) {
      // fallback ke tengah Jember jika gagal (mis. di web/emulator)
      setState(() => _myLocation = _jemberCenter);
      _mapController.move(_jemberCenter, 14);
      _showSnack('Lokasi tidak tersedia, menampilkan pusat Jember');
    } finally {
      setState(() => _loadingLocation = false);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final sellers = context
        .watch<AppProvider>()
        .allSellers
        .where((s) => s.sellerStatus == SellerStatus.verified && s.latitude != null)
        .toList();

    return Column(
      children: [
        _buildMap(sellers),
        if (_selectedSeller != null) _buildSellerInfo(_selectedSeller!),
        _buildSellerList(sellers),
      ],
    );
  }

  Widget _buildMap(List<UserModel> sellers) {
    return Container(
      height: 280,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: _jemberCenter,
              initialZoom: 13,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.pawmart.app',
              ),
              MarkerLayer(
                markers: [
                  // Marker penjual
                  ...sellers.map((s) => Marker(
                        point: LatLng(s.latitude!, s.longitude!),
                        width: 44,
                        height: 44,
                        child: GestureDetector(
                          onTap: () => setState(() =>
                              _selectedSeller = _selectedSeller?.id == s.id ? null : s),
                          child: Tooltip(
                            message: s.name,
                            child: CircleAvatar(
                              backgroundColor: _selectedSeller?.id == s.id
                                  ? AppTheme.accent
                                  : AppTheme.primary,
                              child: Text(s.name[0],
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      )),
                  // Marker lokasi saya
                  if (_myLocation != null)
                    Marker(
                      point: _myLocation!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.my_location,
                          color: Colors.blue, size: 36),
                    ),
                ],
              ),
            ],
          ),
          // Tombol lokasi saya
          Positioned(
            bottom: 12,
            right: 12,
            child: ElevatedButton.icon(
              icon: _loadingLocation
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.my_location, size: 16),
              label: const Text('Lokasi Saya', style: TextStyle(fontSize: 12)),
              onPressed: _loadingLocation ? null : _getMyLocation,
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerInfo(UserModel seller) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.primary,
            child: Text(seller.name[0],
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(seller.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(seller.address ?? 'Jember',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () => setState(() => _selectedSeller = null),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerList(List<UserModel> sellers) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('${sellers.length} Penjual Terdekat',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: sellers.length,
              itemBuilder: (_, i) {
                final s = sellers[i];
                final isSelected = _selectedSeller?.id == s.id;
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  color: isSelected
                      ? AppTheme.primary.withValues(alpha: 0.08)
                      : null,
                  child: ListTile(
                    onTap: () {
                      setState(() => _selectedSeller = isSelected ? null : s);
                      _mapController.move(LatLng(s.latitude!, s.longitude!), 15);
                    },
                    leading: CircleAvatar(
                      backgroundColor:
                          isSelected ? AppTheme.accent : AppTheme.primary,
                      child: Text(s.name[0],
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(s.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(s.address ?? 'Jember',
                        style: const TextStyle(fontSize: 12)),
                    trailing: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_on, color: AppTheme.primary, size: 18),
                        Text('~2 km',
                            style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
