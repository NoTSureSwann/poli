import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:klinik_app/features/sipas/presentation/screens/dashboard_analytics_screen.dart';

class DashboardAdminSipasScreen extends StatelessWidget {
  const DashboardAdminSipasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Admin Klinik App')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > 800;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildQuickActions(context),
                const SizedBox(height: 24),
                
                // 5 KPI Cards
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: isDesktop ? 5 : 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: isDesktop ? 1.5 : 2.0,
                  children: [
                    _buildKPICard('Kunjungan Bln Ini', '1,245', Colors.blue),
                    _buildKPICard('Pasien BPJS', '890', Colors.teal),
                    _buildKPICard('Pasien Umum', '355', Colors.orange),
                    _buildKPICard('Resep Diproses', '42', Colors.purple),
                    _buildKPICard('Stok Obat Kritis', '12', Colors.red, isDanger: true),
                  ],
                ),
                
                const SizedBox(height: 24),
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _buildBarChartSection()),
                      const SizedBox(width: 16),
                      Expanded(flex: 1, child: _buildPieChartSection()),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildBarChartSection(),
                      const SizedBox(height: 16),
                      _buildPieChartSection(),
                    ],
                  ),
                
                const SizedBox(height: 24),
                _buildTableStok(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.person_add),
          label: const Text('Tambah Dokter'),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.medical_services),
          label: const Text('Tambah Obat'),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DashboardAnalyticsScreen()),
            );
          },
          icon: const Icon(Icons.auto_awesome),
          label: const Text('Analisis ML'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple.shade600,
            foregroundColor: Colors.white,
          ),
        ),
        const Spacer(),
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mengekspor laporan ke Excel...')));
          },
          icon: const Icon(Icons.download),
          label: const Text('Export Laporan'),
        ),
      ],
    );
  }

  Widget _buildKPICard(String title, String value, Color color, {bool isDanger = false}) {
    return Card(
      color: isDanger ? Colors.red.shade50 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: isDanger ? const BorderSide(color: Colors.red, width: 2) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChartSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Kunjungan 7 Hari Terakhir', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const style = TextStyle(color: Colors.grey, fontSize: 10);
                          String text;
                          switch (value.toInt()) {
                            case 0: text = 'Sen'; break;
                            case 1: text = 'Sel'; break;
                            case 2: text = 'Rab'; break;
                            case 3: text = 'Kam'; break;
                            case 4: text = 'Jum'; break;
                            case 5: text = 'Sab'; break;
                            case 6: text = 'Min'; break;
                            default: text = ''; break;
                          }
                          return SideTitleWidget(meta: meta, child: Text(text, style: style));
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    _buildBarGroup(0, 40, 20),
                    _buildBarGroup(1, 50, 30),
                    _buildBarGroup(2, 30, 10),
                    _buildBarGroup(3, 80, 40),
                    _buildBarGroup(4, 70, 50),
                    _buildBarGroup(5, 20, 10),
                    _buildBarGroup(6, 10, 5),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _indicator(Colors.blue, 'Poli Umum'),
                const SizedBox(width: 16),
                _indicator(Colors.green, 'Poli Gigi'),
              ],
            )
          ],
        ),
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y1, double y2) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(toY: y1, color: Colors.blue, width: 12),
        BarChartRodData(toY: y2, color: Colors.green, width: 12),
      ],
    );
  }

  Widget _buildPieChartSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Proporsi Penjamin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(color: Colors.teal, value: 70, title: '70%\nBPJS', radius: 50, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                    PieChartSectionData(color: Colors.orange, value: 30, title: '30%\nUmum', radius: 50, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _indicator(Colors.teal, 'BPJS'),
                const SizedBox(width: 16),
                _indicator(Colors.orange, 'Umum'),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _indicator(Color color, String text) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildTableStok() {
    final dummyObat = [
      {'kode': 'OBT-001', 'nama': 'Amoxicillin Syrup', 'stok': 5, 'status': 'Kritis'},
      {'kode': 'OBT-002', 'nama': 'Paracetamol Drop', 'stok': 2, 'status': 'Kritis'},
      {'kode': 'OBT-003', 'nama': 'Salep Hydrocortisone', 'stok': 0, 'status': 'Habis'},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Stok Obat Kritis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Kode')),
                  DataColumn(label: Text('Nama Obat')),
                  DataColumn(label: Text('Stok')),
                  DataColumn(label: Text('Status')),
                ],
                rows: dummyObat.map((obat) {
                  return DataRow(cells: [
                    DataCell(Text(obat['kode'].toString())),
                    DataCell(Text(obat['nama'].toString())),
                    DataCell(Text(obat['stok'].toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: obat['status'] == 'Habis' ? Colors.red : Colors.orange,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(obat['status'].toString(), style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
