const { query } = require('../../config/database');

class DokterController {
    // Get all doctors (public endpoint)
    static async getAll(req, res) {
        try {
            const { tipe } = req.query;

            let whereClause = 'd.status_aktif = 1';
            let params = [];

            if (tipe) {
                whereClause += ' AND d.tipe = ?';
                params.push(tipe);
            }

            const queryStr = `
                SELECT
                  d.id, d.nama, d.tipe, d.spesialisasi, d.poli_id,
                  p.nama_poli, d.harga_konsultasi, d.foto_url, d.jadwal, d.status_aktif
                FROM dokter d
                LEFT JOIN poli p ON d.poli_id = p.id
                WHERE ${whereClause}
                ORDER BY d.nama ASC
            `;

            const result = await query(queryStr, params);

            res.json({
                success: true,
                data: result.rows,
                count: result.rows.length,
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Gagal mengambil data dokter',
                error: error.message,
            });
        }
    }

    // Get single doctor by ID
    static async getById(req, res) {
        try {
            const { id } = req.params;

            const result = await query(`
                SELECT
                  d.id, d.nama, d.tipe, d.spesialisasi, d.poli_id,
                  p.nama_poli, d.harga_konsultasi, d.foto_url, d.jadwal, d.status_aktif
                FROM dokter d
                LEFT JOIN poli p ON d.poli_id = p.id
                WHERE d.id = ?
            `, [id]);

            if (result.rows.length === 0) {
                return res.status(404).json({
                    success: false,
                    message: 'Dokter tidak ditemukan'
                });
            }

            res.json({
                success: true,
                data: result.rows[0],
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Gagal mengambil data dokter',
                error: error.message,
            });
        }
    }

    // Get doctors by poli
    static async getByPoli(req, res) {
        try {
            const { poli_id } = req.params;

            const result = await query(`
                SELECT
                  d.id, d.nama, d.tipe, d.spesialisasi, d.poli_id,
                  p.nama_poli, d.harga_konsultasi, d.foto_url, d.jadwal, d.status_aktif
                FROM dokter d
                LEFT JOIN poli p ON d.poli_id = p.id
                WHERE d.poli_id = ? AND d.status_aktif = 1
                ORDER BY d.nama ASC
            `, [poli_id]);

            res.json({
                success: true,
                data: result.rows,
                count: result.rows.length,
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Gagal mengambil data dokter berdasarkan poli',
                error: error.message,
            });
        }
    }

    // Create new doctor
    static async create(req, res) {
        try {
            const { nama, tipe, spesialisasi, poli_id, harga_konsultasi, foto_url, jadwal } = req.body;

            const result = await query(`
                INSERT INTO dokter (nama, tipe, spesialisasi, poli_id, harga_konsultasi, foto_url, jadwal, status_aktif, created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, 1, datetime('now'), datetime('now'))
            `, [nama, tipe, spesialisasi, poli_id, harga_konsultasi, foto_url, jadwal]);

            const createdResult = await query(`
                SELECT
                  d.id, d.nama, d.tipe, d.spesialisasi, d.poli_id,
                  p.nama_poli, d.harga_konsultasi, d.foto_url, d.jadwal, d.status_aktif
                FROM dokter d
                LEFT JOIN poli p ON d.poli_id = p.id
                WHERE d.id = ?
            `, [result.lastID]);

            res.status(201).json({
                success: true,
                message: 'Dokter berhasil dibuat',
                data: createdResult.rows[0],
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Gagal membuat dokter',
                error: error.message,
            });
        }
    }

    // Update doctor
    static async update(req, res) {
        try {
            const { id } = req.params;
            const { nama, tipe, spesialisasi, poli_id, harga_konsultasi, foto_url, jadwal, status_aktif } = req.body;

            const result = await query(`
                UPDATE dokter
                SET nama = ?, tipe = ?, spesialisasi = ?, poli_id = ?, harga_konsultasi = ?, foto_url = ?, jadwal = ?, status_aktif = ?, updated_at = datetime('now')
                WHERE id = ?
            `, [nama, tipe, spesialisasi, poli_id, harga_konsultasi, foto_url, jadwal, status_aktif, id]);

            if (result.rowCount === 0) {
                return res.status(404).json({
                    success: false,
                    message: 'Dokter tidak ditemukan'
                });
            }

            const updatedResult = await query(`
                SELECT
                  d.id, d.nama, d.tipe, d.spesialisasi, d.poli_id,
                  p.nama_poli, d.harga_konsultasi, d.foto_url, d.jadwal, d.status_aktif
                FROM dokter d
                LEFT JOIN poli p ON d.poli_id = p.id
                WHERE d.id = ?
            `, [id]);

            res.json({
                success: true,
                message: 'Dokter berhasil diperbarui',
                data: updatedResult.rows[0],
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Gagal memperbarui dokter',
                error: error.message,
            });
        }
    }

    // Delete doctor (soft delete)
    static async delete(req, res) {
        try {
            const { id } = req.params;

            const result = await query(`
                UPDATE dokter
                SET status_aktif = 0, updated_at = datetime('now')
                WHERE id = ?
            `, [id]);

            if (result.rowCount === 0) {
                return res.status(404).json({
                    success: false,
                    message: 'Dokter tidak ditemukan'
                });
            }

            res.json({
                success: true,
                message: 'Dokter berhasil dihapus',
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Gagal menghapus dokter',
                error: error.message,
            });
        }
    }

    // Get pricing statistics
    static async getPricingStats(req, res) {
        try {
            const result = await query(`
                SELECT
                  COUNT(*) as total_dokter,
                  AVG(harga_konsultasi) as avg_harga,
                  MIN(harga_konsultasi) as min_harga,
                  MAX(harga_konsultasi) as max_harga
                FROM dokter
                WHERE status_aktif = 1
            `, []);

            res.json({
                success: true,
                data: result.rows[0],
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Gagal mengambil statistik harga',
                error: error.message,
            });
        }
    }
}

module.exports = DokterController;