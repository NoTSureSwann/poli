import 'package:flutter_test/flutter_test.dart';
import 'package:klinik_app/features/poli/data/models/poli_model.dart';

void main() {
  group('PoliModel', () {
    test('fromJson should parse correctly with kategori', () {
      final json = {
        'id': '1',
        'nama_poli': 'Poli Anak Tumbuh Kembang',
        'deskripsi': 'Pemeriksaan khusus anak',
        'jam_buka': '09:00',
        'jam_tutup': '15:00',
        'icon': 'child_care',
        'kategori': 'Anak'
      };

      final result = PoliModel.fromJson(json);

      expect(result.id, '1');
      expect(result.namaPoli, 'Poli Anak Tumbuh Kembang');
      expect(result.kategori, 'Anak');
      expect(result.jamBuka, '09:00');
    });

    test('fromJson should provide default kategori if missing', () {
      final json = {
        'id': '2',
        'nama_poli': 'Poli Umum',
      };

      final result = PoliModel.fromJson(json);

      expect(result.kategori, 'Umum'); // Default
    });
  });
}
