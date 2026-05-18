import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/dokter_model.dart';
import '../../data/repositories/dokter_repository.dart';
import '../../theme/app_theme.dart';

class DokterListScreen extends StatefulWidget {
  const DokterListScreen({super.key});

  @override
  State<DokterListScreen> createState() => _DokterListScreenState();
}

class _DokterListScreenState extends State<DokterListScreen> {
  final DokterRepository _repo = DokterRepository();

  String _filterTipe = 'semua';
  String _query = '';

  List<DokterModel> _all = const [];
  bool _loading = true;
  String? _error;

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
      final list = await _repo.getDokterList();
      setState(() {
        _all = list;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<DokterModel> get _filtered {
    final q = _query.trim().toLowerCase();
    return _all.where((d) {
      final tipeOk = _filterTipe == 'semua' ? true : d.tipe == _filterTipe;
      final qOk = q.isEmpty
          ? true
          : d.nama.toLowerCase().contains(q) ||
                (d.spesialisasi?.toLowerCase().contains(q) ?? false) ||
                (d.namaPoli?.toLowerCase().contains(q) ?? false);
      return tipeOk && qOk;
    }).toList()..sort((a, b) => a.nama.compareTo(b.nama));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dokter & Harga')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Gagal memuat data dokter.\n\n$_error',
                  style: const TextStyle(color: AppTheme.error),
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Cari nama dokter / spesialisasi / poli',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onChanged: (v) => setState(() => _query = v),
                    ),
                  ),
                  SizedBox(
                    height: 44,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _chip('semua'),
                        const SizedBox(width: 8),
                        _chip('umum'),
                        const SizedBox(width: 8),
                        _chip('poli'),
                        const SizedBox(width: 8),
                        _chip('spesialis'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filtered.length,
                      itemBuilder: (context, index) {
                        final d = _filtered[index];
                        return _DokterCard(d: d);
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _chip(String tipe) {
    final selected = _filterTipe == tipe;
    final colorHex = (tipe == 'umum')
        ? '#4CAF50'
        : (tipe == 'poli')
        ? '#2196F3'
        : (tipe == 'spesialis')
        ? '#9C27B0'
        : '#757575';
    final color = _hexToColor(colorHex);

    return GestureDetector(
      onTap: () => setState(() => _filterTipe = tipe),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withAlpha(30) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(
          tipe == 'semua'
              ? 'Semua'
              : (tipe == 'umum'
                    ? 'Umum'
                    : (tipe == 'poli' ? 'Poli' : 'Spesialis')),
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            color: selected ? color : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Color _hexToColor(String hex) {
    final cleaned = hex.replaceAll('#', '');
    final value = int.parse(cleaned, radix: 16);
    return Color(0xFF000000 | value);
  }
}

class _DokterCard extends StatelessWidget {
  final DokterModel d;

  const _DokterCard({required this.d});

  @override
  Widget build(BuildContext context) {
    final badgeColor = _hexToColor(d.badgeColor);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: badgeColor.withAlpha(30),
                  child: const Icon(Icons.medical_services, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d.nama,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        d.spesialisasi != null &&
                                d.spesialisasi!.trim().isNotEmpty
                            ? d.spesialisasi!
                            : d.namaPoli != null &&
                                  d.namaPoli!.trim().isNotEmpty
                            ? d.namaPoli!
                            : d.labelTipe,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: badgeColor.withAlpha(80)),
                  ),
                  child: Text(
                    d.labelTipe,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: badgeColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (d.jadwal != null && d.jadwal!.trim().isNotEmpty)
              Text(
                'Jadwal: ${d.jadwal}',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            const SizedBox(height: 6),
            Text(
              'Harga Konsultasi: Rp ${NumberFormat('#,###', 'id_ID').format(d.hargaKonsultasi)}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: AppTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _hexToColor(String hex) {
    final cleaned = hex.replaceAll('#', '');
    final value = int.parse(cleaned, radix: 16);
    return Color(0xFF000000 | value);
  }
}
