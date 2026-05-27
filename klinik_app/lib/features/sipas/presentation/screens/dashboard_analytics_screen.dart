import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:klinik_app/services/api/ai_service.dart';
import 'package:klinik_app/services/firebase/log_service.dart';

class DashboardAnalyticsScreen extends StatefulWidget {
  const DashboardAnalyticsScreen({super.key});

  @override
  State<DashboardAnalyticsScreen> createState() => _DashboardAnalyticsScreenState();
}

class _DashboardAnalyticsScreenState extends State<DashboardAnalyticsScreen> {
  final LogService _logService = LogService();
  final AiService _aiService = AiService();
  
  List<Map<String, dynamic>> _logs = [];
  bool _isLoadingLogs = true;
  bool _isAnalyzing = false;
  String _aiAnalysisResult = '';

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    setState(() => _isLoadingLogs = true);
    try {
      final logs = await _logService.getRecentLogsForAnalytics();
      if (mounted) {
        setState(() {
          _logs = logs;
          _isLoadingLogs = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingLogs = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil data log: $e')),
        );
      }
    }
  }

  Future<void> _analyzeWithAI() async {
    if (_logs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada log untuk dianalisis.')),
      );
      return;
    }

    setState(() => _isAnalyzing = true);
    try {
      final result = await _aiService.analyzeTraffic(_logs);
      if (mounted) {
        setState(() {
          _aiAnalysisResult = result;
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAnalyzing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menganalisa data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ML Analytics Dashboard'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoadingLogs ? null : _fetchLogs,
            tooltip: 'Refresh Logs',
          ),
        ],
      ),
      body: Row(
        children: [
          // Kiri: Daftar Log
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.grey.shade100,
                    child: const Text(
                      'Data Traffic (50 Terbaru)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  Expanded(
                    child: _isLoadingLogs
                        ? const Center(child: CircularProgressIndicator())
                        : _logs.isEmpty
                            ? const Center(child: Text('Belum ada data traffic.'))
                            : ListView.builder(
                                itemCount: _logs.length,
                                itemBuilder: (context, index) {
                                  final log = _logs[index];
                                  final role = log['role'] ?? 'Unknown';
                                  final duration = log['duration_seconds'] ?? 0;
                                  
                                  return Card(
                                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: role == 'pasien' ? Colors.green : Colors.blue,
                                        child: Icon(
                                          role == 'pasien' ? Icons.person : Icons.medical_services,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      title: Text('Role: ${role.toString().toUpperCase()}'),
                                      subtitle: Text(
                                        'Durasi: $duration detik\n'
                                        'Mulai: ${log['session_start']}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      isThreeLine: true,
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
          ),
          
          // Kanan: Panel AI Analysis
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Analisis Machine Learning (Gemini)',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton.icon(
                        onPressed: _isAnalyzing || _logs.isEmpty ? null : _analyzeWithAI,
                        icon: _isAnalyzing 
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.auto_awesome),
                        label: const Text('Analisis dengan AI'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade600,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: _aiAnalysisResult.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.analytics_outlined, size: 64, color: Colors.grey.shade400),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Tekan tombol "Analisis dengan AI"\nuntuk melihat insight trafik aplikasi.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            )
                          : Markdown(
                              data: _aiAnalysisResult,
                              selectable: true,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
