const { query } = require('../../config/database');

class ObatController {
    // Get all medicines (admin only)
    static async getAll(req, res) {
        try {
            const result = await query(`
                SELECT id, nama_obat, jenis, satuan, harga_satuan, stok, keterangan
                FROM obat
                ORDER BY nama_obat ASC
            `, []);

            res.json({
                success: true,
                data: result.rows,
                count: result.rows.length,
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Gagal mengambil data obat',
                error: error.message,
            });
        }
    }

    // Get single medicine by ID
    static async getById(req, res) {
        try {
            const { id } = req.params;

            const result = await query(`
                SELECT id, nama_obat, jenis, satuan, harga_satuan, stok, keterangan
                FROM obat
                WHERE id = ?
            `, [id]);

            if (result.rows.length === 0) {
                return res.status(404).json({
                    success: false,
                    message: 'Obat tidak ditemukan'
                });
            }

            res.json({
                success: true,
                data: result.rows[0],
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Gagal mengambil data obat',
                error: error.message,
            });
        }
    }

    // Create new medicine
    static async create(req, res) {
        try {
            const { nama_obat, jenis, satuan, harga_satuan, stok, keterangan } = req.body;

            const result = await query(`
                INSERT INTO obat (nama_obat, jenis, satuan, harga_satuan, stok, keterangan, created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, datetime('now'), datetime('now'))
            `, [nama_obat, jenis, satuan, harga_satuan, stok, keterangan]);

            const createdResult = await query(`
                SELECT id, nama_obat, jenis, satuan, harga_satuan, stok, keterangan
                FROM obat
                WHERE id = ?
            `, [result.lastID]);

            res.status(201).json({
                success: true,
                message: 'Obat berhasil dibuat',
                data: createdResult.rows[0],
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Gagal membuat obat',
                error: error.message,
            });
        }
    }

    // Update medicine
    static async update(req, res) {
        try {
            const { id } = req.params;
            const { nama_obat, jenis, satuan, harga_satuan, stok, keterangan } = req.body;

            const result = await query(`
                UPDATE obat
                SET nama_obat = ?, jenis = ?, satuan = ?, harga_satuan = ?, stok = ?, keterangan = ?, updated_at = datetime('now')
                WHERE id = ?
            `, [nama_obat, jenis, satuan, harga_satuan, stok, keterangan, id]);

            if (result.rowCount === 0) {
                return res.status(404).json({
                    success: false,
                    message: 'Obat tidak ditemukan'
                });
            }

            const updatedResult = await query(`
                SELECT id, nama_obat, jenis, satuan, harga_satuan, stok, keterangan
                FROM obat
                WHERE id = ?
            `, [id]);

            res.json({
                success: true,
                message: 'Obat berhasil diperbarui',
                data: updatedResult.rows[0],
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Gagal memperbarui obat',
                error: error.message,
            });
        }
    }

    // Delete medicine
    static async delete(req, res) {
        try {
            const { id } = req.params;

            const result = await query('DELETE FROM obat WHERE id = ?', [id]);

            if (result.rowCount === 0) {
                return res.status(404).json({
                    success: false,
                    message: 'Obat tidak ditemukan'
                });
            }

            res.json({
                success: true,
                message: 'Obat berhasil dihapus',
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Gagal menghapus obat',
                error: error.message,
            });
        }
    }

    // Get low stock medicines
    static async getLowStock(req, res) {
        try {
            const { threshold = 10 } = req.query;

            const result = await query(`
                SELECT id, nama_obat, jenis, satuan, harga_satuan, stok, keterangan
                FROM obat
                WHERE stok <= ?
                ORDER BY stok ASC
            `, [threshold]);

            res.json({
                success: true,
                data: result.rows,
                count: result.rows.length,
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Gagal mengambil data obat stok rendah',
                error: error.message,
            });
        }
    }

    // Get medicine statistics overview
    static async getStats(req, res) {
        try {
            const result = await query(`
                SELECT
                  COUNT(*) as total_obat,
                  SUM(stok) as total_stok,
                  AVG(harga_satuan) as avg_harga,
                  MIN(harga_satuan) as min_harga,
                  MAX(harga_satuan) as max_harga,
                  SUM(stok * harga_satuan) as total_nilai_stok
                FROM obat
            `, []);

            res.json({
                success: true,
                data: result.rows[0],
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Gagal mengambil statistik obat',
                error: error.message,
            });
        }
    }
}

module.exports = ObatController;