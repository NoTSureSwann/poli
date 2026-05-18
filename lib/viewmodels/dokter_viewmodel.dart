import 'package:flutter/material.dart';
import '../data/models/dokter_model.dart';
import '../data/repositories/dokter_repository.dart';

enum ViewState { idle, loading, loaded, error }

class DokterViewModel extends ChangeNotifier {
  final DokterRepository _repo = DokterRepository();

  List<DokterModel> _dokterList = [];
  List<DokterModel> _filtered = [];
  ViewState _state = ViewState.idle;
  String _errorMsg = '';
  String _filterTipe = 'semua'; // semua | umum | poli | spesialis

  List<DokterModel> get dokterList => _filtered;
  ViewState get state => _state;
  String get errorMsg => _errorMsg;
  String get filterTipe => _filterTipe;

  // Statistik harga
  int get minHarga => _dokterList.isEmpty
      ? 0
      : _dokterList
            .map((d) => d.hargaKonsultasi)
            .reduce((a, b) => a < b ? a : b);

  int get maxHarga => _dokterList.isEmpty
      ? 0
      : _dokterList
            .map((d) => d.hargaKonsultasi)
            .reduce((a, b) => a > b ? a : b);

  int get totalDokter => _dokterList.length;

  int get totalUmum => _dokterList.where((d) => d.tipe == 'umum').length;

  int get totalPoli => _dokterList.where((d) => d.tipe == 'poli').length;

  int get totalSpesialis =>
      _dokterList.where((d) => d.tipe == 'spesialis').length;

  // Fetch all doctors
  Future<void> fetchDokter() async {
    _state = ViewState.loading;
    notifyListeners();
    try {
      _dokterList = await _repo.getDokterList();
      _applyFilter();
      _state = ViewState.loaded;
    } catch (e) {
      _errorMsg = e.toString();
      _state = ViewState.error;
    }
    notifyListeners();
  }

  // Set filter and apply
  void setFilter(String tipe) {
    _filterTipe = tipe;
    _applyFilter();
    notifyListeners();
  }

  // Apply filter to list
  void _applyFilter() {
    if (_filterTipe == 'semua') {
      _filtered = List.from(_dokterList);
    } else {
      _filtered = _dokterList.where((d) => d.tipe == _filterTipe).toList();
    }
  }

  // Add doctor (admin)
  Future<bool> tambahDokter(Map<String, dynamic> data) async {
    try {
      await _repo.createDokter(data);
      await fetchDokter();
      return true;
    } catch (e) {
      _errorMsg = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Update doctor (admin)
  Future<bool> editDokter(int id, Map<String, dynamic> data) async {
    try {
      await _repo.updateDokter(id, data);
      await fetchDokter();
      return true;
    } catch (e) {
      _errorMsg = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Delete doctor (admin)
  Future<bool> hapusDokter(int id) async {
    try {
      await _repo.deleteDokter(id);
      await fetchDokter();
      return true;
    } catch (e) {
      _errorMsg = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Get doctor by ID
  Future<DokterModel?> getDokterById(int id) async {
    try {
      return await _repo.getDokterById(id);
    } catch (e) {
      _errorMsg = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Search doctor
  void searchDokter(String query) {
    if (query.isEmpty) {
      _applyFilter();
    } else {
      _filtered = _dokterList
          .where(
            (d) =>
                d.nama.toLowerCase().contains(query.toLowerCase()) ||
                (d.spesialisasi?.toLowerCase().contains(query.toLowerCase()) ??
                    false),
          )
          .toList();
    }
    notifyListeners();
  }
}
