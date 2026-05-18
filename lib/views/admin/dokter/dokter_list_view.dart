import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/dokter_viewmodel.dart';
import 'dokter_form_view.dart';
// Assume exists or use Colors

class DokterListView extends StatefulWidget {
  const DokterListView({super.key});

  @override
  State<DokterListView> createState() => _DokterListViewState();
}

class _DokterListViewState extends State<DokterListView> {
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
        title: const Text('Kelola Dokter'),
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
              // Stat Cards
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    _buildStatCard(
                      'Total',
                      vm.totalDokter.toString(),
                      Colors.grey,
                    ),
                    _buildStatCard(
                      'Umum',
                      vm.totalUmum.toString(),
                      Colors.green,
                    ),
                    _buildStatCard(
                      'Poli',
                      vm.totalPoli.toString(),
                      Colors.blue,
                    ),
                    _buildStatCard(
                      'Spesialis',
                      vm.totalSpesialis.toString(),
                      Colors.purple,
                    ),
                  ],
                ),
              ),
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Cari Dokter',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) => vm.searchDokter(val),
                ),
              ),
              // Filter Chips
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
              // List
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
                                const CircleAvatar(child: Icon(Icons.person)),
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
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildBadge(d.labelTipe, d.badgeColor),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Jadwal: ${d.jadwal ?? "-"}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Harga: Rp ${d.hargaKonsultasi}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                DokterFormView(dokter: d),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        _confirmDelete(context, vm, d.id);
                                      },
                                    ),
                                  ],
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFC62828),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DokterFormView()),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        color: color.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(title, style: TextStyle(fontSize: 12, color: color)),
            ],
          ),
        ),
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

  void _confirmDelete(BuildContext context, DokterViewModel vm, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Dokter?'),
        content: const Text('Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await vm.hapusDokter(id);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
