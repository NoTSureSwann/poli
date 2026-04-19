const db = require('../../config/database');
const { success, error, paginated } = require('../../utils/response');

const getAllPasien = async (req, res) => {
  const { page = 1, limit = 10, search = '' } = req.query;
  const offset = (page - 1) * limit;

  try {
    const queryStr = `
      SELECT * FROM pasien 
      WHERE nama ILIKE $1 OR no_rm ILIKE $1 OR nik ILIKE $1 
      ORDER BY created_at DESC 
      LIMIT $2 OFFSET $3
    `;
    const countStr = `
      SELECT COUNT(*) FROM pasien 
      WHERE nama ILIKE $1 OR no_rm ILIKE $1 OR nik ILIKE $1
    `;

    const searchQuery = `%${search}%`;
    const [result, countResult] = await Promise.all([
      db.query(queryStr, [searchQuery, limit, offset]),
      db.query(countStr, [searchQuery])
    ]);

    const total = parseInt(countResult.rows[0].count);
    return paginated(res, result.rows, total, page, limit);
  } catch (err) {
    console.error(err);
    return error(res, 'Gagal mengambil data pasien', 500, err.message);
  }
};

const getPasienById = async (req, res) => {
  const { id } = req.params;
  try {
    const result = await db.query('SELECT * FROM pasien WHERE id = $1', [id]);
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
  const { no_rm, nama, nik, bpjs_id, tanggal_lahir, jenis_kelamin, alamat, no_telepon } = req.body;
  
  try {
    const result = await db.query(
      `INSERT INTO pasien (no_rm, nama, nik, bpjs_id, tanggal_lahir, jenis_kelamin, alamat, no_telepon, created_by) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) 
       RETURNING *`,
      [no_rm, nama, nik, bpjs_id, tanggal_lahir, jenis_kelamin, alamat, no_telepon, req.user.id]
    );
    return success(res, result.rows[0], 'Pasien berhasil ditambahkan', 201);
  } catch (err) {
    console.error(err);
    return error(res, 'Gagal menambahkan pasien', 500, err.message);
  }
};

const updatePasien = async (req, res) => {
  const { id } = req.params;
  const { nama, nik, bpjs_id, tanggal_lahir, jenis_kelamin, alamat, no_telepon } = req.body;

  try {
    const result = await db.query(
      `UPDATE pasien 
       SET nama = $1, nik = $2, bpjs_id = $3, tanggal_lahir = $4, jenis_kelamin = $5, alamat = $6, no_telepon = $7, updated_at = NOW() 
       WHERE id = $8 RETURNING *`,
      [nama, nik, bpjs_id, tanggal_lahir, jenis_kelamin, alamat, no_telepon, id]
    );

    if (result.rows.length === 0) {
      return error(res, 'Pasien tidak ditemukan', 404);
    }
    return success(res, result.rows[0], 'Data pasien berhasil diperbarui');
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
