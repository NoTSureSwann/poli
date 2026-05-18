import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../../../viewmodels/struk_viewmodel.dart';
import '../../../viewmodels/dokter_viewmodel.dart' show ViewState;

class StrukPreviewView extends StatefulWidget {
  final int pembayaranId;

  const StrukPreviewView({super.key, required this.pembayaranId});

  @override
  State<StrukPreviewView> createState() => _StrukPreviewViewState();
}

class _StrukPreviewViewState extends State<StrukPreviewView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final vm = context.read<StrukViewModel>();
    vm.fetchStruk(widget.pembayaranId).then((_) {
      if (vm.struk != null) {
        vm.generateStrukPdf();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Struk Pembayaran'),
          backgroundColor: const Color(0xFFC62828),
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Struk Pembayaran'),
              Tab(text: 'Struk Obat'),
            ],
          ),
          actions: [
            Consumer<StrukViewModel>(
              builder: (context, vm, child) {
                if (vm.pdfPath == null) return const SizedBox.shrink();
                return Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () {
                        SharePlus.instance.share(ShareParams(files: [XFile(vm.pdfPath!)]));
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.print),
                      onPressed: () async {
                        final file = File(vm.pdfPath!);
                        final bytes = await file.readAsBytes();
                        await Printing.layoutPdf(
                          onLayout: (_) => Uint8List.fromList(bytes),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        body: Consumer<StrukViewModel>(
          builder: (context, vm, child) {
            if (vm.state == ViewState.loading || vm.pdfPath == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (vm.state == ViewState.error) {
              return Center(child: Text('Error: ${vm.errorMsg}'));
            }

            return TabBarView(
              children: [
                _buildPdfPreview(vm.pdfPath!),
                _buildPdfPreview(vm.pdfPath!), // Assuming struk obat is also generated and handled similarly or merged.
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _loadData,
          label: const Text('Generate Ulang'),
          icon: const Icon(Icons.refresh),
          backgroundColor: const Color(0xFFC62828),
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildPdfPreview(String path) {
    return Column(
      children: [
        Expanded(
          child: FutureBuilder<Uint8List>(
            future: File(path).readAsBytes(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return PdfPreview(
                  build: (format) => Future.value(snapshot.data!),
                  allowPrinting: false,
                  allowSharing: false,
                  canChangeOrientation: false,
                  canChangePageFormat: false,
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Export PDF'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tersimpan di $path')));
                },
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.print),
                label: const Text('Cetak'),
                onPressed: () async {
                  final file = File(path);
                  final bytes = await file.readAsBytes();
                  await Printing.layoutPdf(
                    onLayout: (_) => Uint8List.fromList(bytes),
                  );
                },
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.share),
                label: const Text('Bagikan'),
                onPressed: () {
                  SharePlus.instance.share(ShareParams(files: [XFile(path)]));
                },
              ),
            ],
          ),
        )
      ],
    );
  }
}
