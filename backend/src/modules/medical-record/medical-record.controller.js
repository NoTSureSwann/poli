const db = require('../../config/database');
const { success, error, paginated } = require('../../utils/response');

const getMedicalRecordsByPatient = async (req, res) => {
  const { patientId } = req.params;
  const { page = 1, limit = 10 } = req.query;
  const pageNum = Math.max(parseInt(page, 10) || 1, 1);
  const limitNum = Math.max(parseInt(limit, 10) || 10, 1);
  const offset = (pageNum - 1) * limitNum;

  try {
    const queryStr = `
      SELECT rm.*, u.nama as nama_dokter 
      FROM rekam_medis rm
      JOIN users u ON rm.dokter_id = u.id
      WHERE rm.pasien_id = $1
      ORDER BY rm.tanggal_kunjungan DESC
      LIMIT $2 OFFSET $3
    `;
    const countStr = 'SELECT COUNT(*) as total FROM rekam_medis WHERE pasien_id = $1';

    const [result, countResult] = await Promise.all([
      db.query(queryStr, [patientId, limitNum, offset]),
      db.query(countStr, [patientId])
    ]);

    const total = parseInt(countResult.rows[0].total || 0);
    return paginated(res, result.rows, total, pageNum, limitNum);
  } catch (err) {
    console.error(err);
    return error(res, 'Gagal mengambil rekam medis', 500, err.message);
  }
};

const createMedicalRecord = async (req, res) => {
  const { pasien_id, keluhan_utama, pemeriksaan_fisik, diagnosis, tindakan_rencana, icd10_code, tekanan_darah, nadi, suhu, berat_badan, tinggi_badan, saturasi_oksigen, catatan_tambahan } = req.body;

  try {
    const result = await db.query(
      `INSERT INTO rekam_medis (
        pasien_id, dokter_id, keluhan_utama, pemeriksaan_fisik, diagnosis, tindakan_rencana, 
        icd10_code, tekanan_darah, nadi, suhu, berat_badan, tinggi_badan, saturasi_oksigen, catatan_tambahan
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14) 
      `,
      [pasien_id, req.user.id, keluhan_utama, pemeriksaan_fisik, diagnosis, tindakan_rencana, icd10_code, tekanan_darah, nadi, suhu, berat_badan, tinggi_badan, saturasi_oksigen, catatan_tambahan]
    );

    const created = await db.query('SELECT * FROM rekam_medis WHERE id = $1', [result.lastID]);
    return success(res, created.rows[0], 'Rekam medis berhasil disimpan', 201);
  } catch (err) {
    console.error(err);
    return error(res, 'Gagal menyimpan rekam medis', 500, err.message);
  }
};

const getMedicalRecordById = async (req, res) => {
  const { id } = req.params;
  try {
    const queryStr = `
      SELECT rm.*, u.nama as nama_dokter, p.nama as nama_pasien, p.no_rm
      FROM rekam_medis rm
      JOIN users u ON rm.dokter_id = u.id
      JOIN pasien p ON rm.pasien_id = p.id
      WHERE rm.id = $1
    `;
    const result = await db.query(queryStr, [id]);
    if (result.rows.length === 0) {
      return error(res, 'Rekam medis tidak ditemukan', 404);
    }
    return success(res, result.rows[0]);
  } catch (err) {
    console.error(err);
    return error(res, 'Gagal mengambil data rekam medis', 500, err.message);
  }
};

module.exports = {
  getMedicalRecordsByPatient,
  createMedicalRecord,
  getMedicalRecordById
};
