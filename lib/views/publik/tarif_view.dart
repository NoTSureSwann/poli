import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/dokter_viewmodel.dart';

class TarifView extends StatefulWidget {
  const TarifView({super.key});

  @override
  State<TarifView> createState() => _TarifViewState();
}

class _TarifViewState extends State<TarifView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DokterViewModel>().fetchDokter();
      // Assume these methods exist on the other viewmodels
      // context.read<LayananViewModel>().fetchLayanan();
      // context.read<ObatViewModel>().fetchObat();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tarif Klinik'),
          backgroundColor: const Color(0xFFC62828),
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Tarif Dokter'),
              Tab(text: 'Tarif Layanan'),
              Tab(text: 'Tarif Obat'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTarifDokter(),
            _buildPlaceholder('Tarif Layanan\n(Silakan implementasikan LayananViewModel)'),
            _buildPlaceholder('Tarif Obat\n(Silakan implementasikan ObatViewModel)'),
          ],
        ),
      ),
    );
  }

  Widget _buildTarifDokter() {
    return Consumer<DokterViewModel>(
      builder: (context, vm, child) {
        if (vm.state == ViewState.loading) return const Center(child: CircularProgressIndicator());
        
        final umum = vm.dokterList.where((d) => d.tipe == 'umum').toList();
        final poli = vm.dokterList.where((d) => d.tipe == 'poli').toList();
        final spesialis = vm.dokterList.where((d) => d.tipe == 'spesialis').toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (umum.isNotEmpty) _buildSection('DOKTER UMUM', Colors.green, umum),
            if (poli.isNotEmpty) _buildSection('DOKTER POLI', Colors.blue, poli),
            if (spesialis.isNotEmpty) _buildSection('DOKTER SPESIALIS', Colors.purple, spesialis),
          ],
        );
      },
    );
  }

  Widget _buildSection(String title, Color color, List items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(radius: 8, backgroundColor: color),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          child: Column(
            children: items.map((d) => ListTile(
              title: Text(d.nama),
              trailing: Text('Rp ${d.hargaKonsultasi}', style: const TextStyle(fontWeight: FontWeight.bold)),
            )).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPlaceholder(String text) {
    return Center(
      child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
    );
  }
}
