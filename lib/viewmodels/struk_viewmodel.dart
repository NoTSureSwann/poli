import 'package:flutter/material.dart';
import '../data/models/struk_model.dart';
import '../data/repositories/pembayaran_repository.dart';
import '../helpers/pdf_generator.dart';
import 'dokter_viewmodel.dart' show ViewState;

class StrukViewModel extends ChangeNotifier {
  final PembayaranRepository _repo = PembayaranRepository();

  StrukModel? _struk;
  ViewState _state = ViewState.idle;
  String _errorMsg = '';
  String? _pdfPath;
  bool _isGenerating = false;

  StrukModel? get struk => _struk;
  ViewState get state => _state;
  String get errorMsg => _errorMsg;
  String? get pdfPath => _pdfPath;
  bool get isGenerating => _isGenerating;

  // Fetch struk pembayaran
  Future<void> fetchStruk(int pembayaranId) async {
    _state = ViewState.loading;
    notifyListeners();
    try {
      _struk = await _repo.getStruk(pembayaranId);
      _state = ViewState.loaded;
    } catch (e) {
      _errorMsg = e.toString();
      _state = ViewState.error;
    }
    notifyListeners();
  }

  // Fetch struk obat
  Future<void> fetchStrukObat(int pembayaranId) async {
    _state = ViewState.loading;
    notifyListeners();
    try {
      _struk = await _repo.getStrukObat(pembayaranId);
      _state = ViewState.loaded;
    } catch (e) {
      _errorMsg = e.toString();
      _state = ViewState.error;
    }
    notifyListeners();
  }

  // Generate struk pembayaran PDF
  Future<String?> generateStrukPdf() async {
    if (_struk == null) return null;
    _isGenerating = true;
    notifyListeners();
    try {
      _pdfPath = await PdfGenerator.generateStrukPembayaran(_struk!);
      _isGenerating = false;
      notifyListeners();
      return _pdfPath;
    } catch (e) {
      _errorMsg = e.toString();
      _isGenerating = false;
      notifyListeners();
      return null;
    }
  }

  // Generate struk obat PDF
  Future<String?> generateStrukObatPdf() async {
    if (_struk == null) return null;
    _isGenerating = true;
    notifyListeners();
    try {
      _pdfPath = await PdfGenerator.generateStrukObat(_struk!);
      _isGenerating = false;
      notifyListeners();
      return _pdfPath;
    } catch (e) {
      _errorMsg = e.toString();
      _isGenerating = false;
      notifyListeners();
      return null;
    }
  }

  // Clear struk
  void clearStruk() {
    _struk = null;
    _pdfPath = null;
    _state = ViewState.idle;
    _errorMsg = '';
    notifyListeners();
  }
}
