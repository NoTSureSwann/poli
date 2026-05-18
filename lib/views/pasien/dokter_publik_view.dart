import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/dokter_viewmodel.dart';

class DokterPublikView extends StatefulWidget {
  const DokterPublikView({super.key});

  @override
  State<DokterPublikView> createState() => _DokterPublikViewState();
}

class _DokterPublikViewState extends State<DokterPublikView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DokterViewModel>().fetchDokter();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Dokter'),
        backgroundColor: const Color(0xFFC62828),
        foregroundColor: Colors.white,
      ),
      body: Consumer<DokterViewModel>(
        builder: (context, vm, child) {
          if (vm.state == ViewState.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.state == ViewState.error) {
            return Center(child: Text('Error: ${vm.errorMsg}'));
          }

          return Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    _buildFilterChip(vm, 'semua', 'Semua'),
                    const SizedBox(width: 8),
                    _buildFilterChip(vm, 'umum', 'Dokter Umum'),
                    const SizedBox(width: 8),
                    _buildFilterChip(vm, 'poli', 'Poli'),
                    const SizedBox(width: 8),
                    _buildFilterChip(vm, 'spesialis', 'Spesialis'),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: vm.dokterList.length,
                  itemBuilder: (context, index) {
                    final d = vm.dokterList[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(
                                  radius: 30,
                                  child: Icon(Icons.person, size: 30),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        d.nama,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      if (d.spesialisasi != null)
                                        Text(
                                          'Spesialis ${d.spesialisasi}',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      if (d.namaPoli != null)
                                        Text(
                                          d.namaPoli!,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                _buildBadge(d.labelTipe, d.badgeColor),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text('Jadwal Praktek: ${d.jadwal ?? "-"}'),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Biaya: Rp ${d.hargaKonsultasi}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFC62828),
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFC62828),
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    // Navigate to antrian registration
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Fitur daftar antrian belum diimplementasikan',
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('Daftar Antrian'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(DokterViewModel vm, String tipe, String label) {
    final isSelected = vm.filterTipe == tipe;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) vm.setFilter(tipe);
      },
    );
  }

  Widget _buildBadge(String text, String hexColor) {
    final color = Color(int.parse(hexColor.replaceAll('#', '0xFF')));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 10)),
    );
  }
}
