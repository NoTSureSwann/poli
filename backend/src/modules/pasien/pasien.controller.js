const { query } = require('../../config/database');
const { success, error, paginated } = require('../../utils/response');

const getAllPasien = async (req, res) => {
  const { page = 1, limit = 10, search = '' } = req.query;
  const pageNum = Math.max(parseInt(page, 10) || 1, 1);
  const limitNum = Math.max(parseInt(limit, 10) || 10, 1);
  const offset = (pageNum - 1) * limitNum;

  try {
    const queryStr = `
      SELECT * FROM pasien
      WHERE nama LIKE ? OR no_rm LIKE ? OR nik LIKE ?
      ORDER BY created_at DESC
      LIMIT ? OFFSET ?
    `;
    const countStr = `
      SELECT COUNT(*) as total FROM pasien
      WHERE nama LIKE ? OR no_rm LIKE ? OR nik LIKE ?
    `;

    const searchQuery = `%${search}%`;
    const [result, countResult] = await Promise.all([
      query(queryStr, [searchQuery, searchQuery, searchQuery, limitNum, offset]),
      query(countStr, [searchQuery, searchQuery, searchQuery])
    ]);

    const total = parseInt(countResult.rows[0].total || 0);
    return paginated(res, result.rows, total, pageNum, limitNum);
  } catch (err) {
    console.error(err);
    return error(res, 'Gagal mengambil data pasien', 500, err.message);
  }
};

const getPasienById = async (req, res) => {
  const { id } = req.params;
  try {
    const result = await query('SELECT * FROM pasien WHERE id = ?', [id]);
    if (result.rows.length === 0) {
      return error(res, 'Pasien tidak ditemukan', 404);
    }
    return success(res, result.rows[0]);
  } catch (err) {
    console.error(err);
    return error(res, 'Gagal mengambil data pasien', 500, err.message);
  }
};

const createPasien = async (req, res) => {
  const { no_rm, nama, nik, bpjs_id, tanggal_lahir, jenis_kelamin, alamat, no_telepon, email, nama_wali, no_telepon_wali, alergi, riwayat_penyakit, foto_url, wallet_address } = req.body;
  const generatedNoRm = no_rm || `RM${Date.now()}`;

  try {
    const result = await query(
      `INSERT INTO pasien (no_rm, nama, nik, bpjs_id, tanggal_lahir, jenis_kelamin, alamat, no_telepon, email, nama_wali, no_telepon_wali, alergi, riwayat_penyakit, foto_url, wallet_address, is_active, created_by, created_at, updated_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, datetime('now'), datetime('now'))`,
      [generatedNoRm, nama, nik, bpjs_id, tanggal_lahir, jenis_kelamin, alamat, no_telepon, email, nama_wali, no_telepon_wali, alergi, riwayat_penyakit, foto_url, wallet_address, 1, req.user?.id || null]
    );

    const createdResult = await query('SELECT * FROM pasien WHERE id = ?', [result.lastID]);
    return success(res, createdResult.rows[0], 'Pasien berhasil ditambahkan', 201);
  } catch (err) {
    console.error(err);
    return error(res, 'Gagal menambahkan pasien', 500, err.message);
  }
};

const updatePasien = async (req, res) => {
  const { id } = req.params;
  const { nama, nik, bpjs_id, tanggal_lahir, jenis_kelamin, alamat, no_telepon, email, nama_wali, no_telepon_wali, alergi, riwayat_penyakit, foto_url, wallet_address, is_active } = req.body;

  try {
    const result = await query(
      `UPDATE pasien
       SET nama = ?, nik = ?, bpjs_id = ?, tanggal_lahir = ?, jenis_kelamin = ?, alamat = ?, no_telepon = ?, email = ?, nama_wali = ?, no_telepon_wali = ?, alergi = ?, riwayat_penyakit = ?, foto_url = ?, wallet_address = ?, is_active = ?, updated_at = datetime('now')
       WHERE id = ?`,
      [nama, nik, bpjs_id, tanggal_lahir, jenis_kelamin, alamat, no_telepon, email, nama_wali, no_telepon_wali, alergi, riwayat_penyakit, foto_url, wallet_address, is_active || 1, id]
    );

    if (result.rowCount === 0) {
      return error(res, 'Pasien tidak ditemukan', 404);
    }

    const updatedResult = await query('SELECT * FROM pasien WHERE id = ?', [id]);
    return success(res, updatedResult.rows[0], 'Data pasien berhasil diperbarui');
  } catch (err) {
    console.error(err);
    return error(res, 'Gagal memperbarui pasien', 500, err.message);
  }
};

module.exports = {
  getAllPasien,
  getPasienById,
  createPasien,
  updatePasien
};
