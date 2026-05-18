import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/repositories/dokter_repository.dart';
import '../../data/repositories/layanan_repository.dart';
import '../../data/models/dokter_model.dart';
import '../../theme/app_theme.dart';

class TarifScreen extends StatefulWidget {
  const TarifScreen({super.key});

  @override
  State<TarifScreen> createState() => _TarifScreenState();
}

class _TarifScreenState extends State<TarifScreen> {
  final DokterRepository _dokterRepo = DokterRepository();
  final LayananRepository _layananRepo = LayananRepository();

  bool _loading = true;
  String? _error;

  List<DokterModel> _dokter = const [];
  Map<String, List<Map<String, dynamic>>> _layananGrouped = const {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final dokterList = await _dokterRepo.getDokterList();

      final grouped = await _layananRepo.getGroupedLayanan();

      setState(() {
        _dokter = dokterList;
        _layananGrouped = grouped;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tarif Klinik')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Gagal memuat tarif.\n\n$_error',
                  style: const TextStyle(color: AppTheme.error),
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _SectionTitle('DOKTER'),
                  const SizedBox(height: 12),
                  _DokterTarif(dokter: _dokter),
                  const SizedBox(height: 18),
                  _SectionTitle('LAYANAN'),
                  const SizedBox(height: 12),
                  _LayananTarif(grouped: _layananGrouped),
                ],
              ),
            ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
    );
  }
}

class _DokterTarif extends StatelessWidget {
  final List<DokterModel> dokter;
  const _DokterTarif({required this.dokter});

  @override
  Widget build(BuildContext context) {
    final umum = dokter.where((d) => d.tipe == 'umum').toList()
      ..sort((a, b) => a.nama.compareTo(b.nama));
    final poli = dokter.where((d) => d.tipe == 'poli').toList()
      ..sort((a, b) => a.nama.compareTo(b.nama));
    final spesialis = dokter.where((d) => d.tipe == 'spesialis').toList()
      ..sort((a, b) => a.nama.compareTo(b.nama));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TarifGroup(title: '🟢 DOKTER UMUM', items: umum),
        const SizedBox(height: 10),
        _TarifGroup(title: '🔵 DOKTER POLI', items: poli),
        const SizedBox(height: 10),
        _TarifGroup(title: '🟣 DOKTER SPESIALIS', items: spesialis),
      ],
    );
  }
}

class _TarifGroup extends StatelessWidget {
  final String title;
  final List<DokterModel> items;

  const _TarifGroup({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          ...items.map((d) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      d.nama,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Rp ${NumberFormat('#,###', 'id_ID').format(d.hargaKonsultasi)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _LayananTarif extends StatelessWidget {
  final Map<String, List<Map<String, dynamic>>> grouped;

  const _LayananTarif({required this.grouped});

  @override
  Widget build(BuildContext context) {
    final categories = grouped.keys.toList()..sort();

    if (categories.isEmpty) {
      return const Text('Tidak ada data layanan.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: categories.map((kategori) {
        final items = grouped[kategori] ?? [];
        items.sort((a, b) {
          final an = (a['nama_layanan'] ?? '').toString();
          final bn = (b['nama_layanan'] ?? '').toString();
          return an.compareTo(bn);
        });

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ${kategori.toUpperCase()}',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                ...items.map((item) {
                  final nama = (item['nama_layanan'] ?? '').toString();
                  final harga = (item['harga'] ?? item['harga_layanan'] ?? 0);
                  final hargaInt = harga is int
                      ? harga
                      : int.tryParse(harga.toString()) ?? 0;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            nama,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Rp ${NumberFormat('#,###', 'id_ID').format(hargaInt)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
