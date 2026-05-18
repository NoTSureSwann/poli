const { query } = require('../../config/database');

class LayananController {
    // Get all services (public endpoint)
    static async getAll(req, res) {
        try {
            const { kategori } = req.query;

            let whereClause = '1=1';
            let params = [];

            if (kategori) {
                whereClause += ' AND kategori = ?';
                params.push(kategori);
            }

            const queryStr = `SELECT id, nama_layanan, kategori, harga, keterangan FROM layanan WHERE ${whereClause} ORDER BY nama_layanan ASC`;

            const result = await query(queryStr, params);

            res.json({
                success: true,
                data: result.rows,
                count: result.rows.length,
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Gagal mengambil data layanan',
                error: error.message,
            });
        }
    }

    // Get single service by ID
    static async getById(req, res) {
        try {
            const { id } = req.params;

            const result = await query('SELECT id, nama_layanan, kategori, harga, keterangan FROM layanan WHERE id = ?', [id]);

            if (result.rows.length === 0) {
                return res.status(404).json({
                    success: false,
                    message: 'Layanan tidak ditemukan'
                });
            }

            res.json({
                success: true,
                data: result.rows[0],
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Gagal mengambil data layanan',
                error: error.message,
            });
        }
    }

    // Create new service
    static async create(req, res) {
        try {
            const { nama_layanan, kategori, harga, keterangan } = req.body;

            const result = await query(`
                INSERT INTO layanan (nama_layanan, kategori, harga, keterangan, created_at, updated_at)
                VALUES (?, ?, ?, ?, datetime('now'), datetime('now'))
            `, [nama_layanan, kategori, harga, keterangan]);

            const createdResult = await query('SELECT id, nama_layanan, kategori, harga, keterangan FROM layanan WHERE id = ?', [result.lastID]);

            res.status(201).json({
                success: true,
                message: 'Layanan berhasil dibuat',
                data: createdResult.rows[0],
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Gagal membuat layanan',
                error: error.message,
            });
        }
    }

    // Update service
    static async update(req, res) {
        try {
            const { id } = req.params;
            const { nama_layanan, kategori, harga, keterangan } = req.body;

            const result = await query(`
                UPDATE layanan
                SET nama_layanan = ?, kategori = ?, harga = ?, keterangan = ?, updated_at = datetime('now')
                WHERE id = ?
            `, [nama_layanan, kategori, harga, keterangan, id]);

            if (result.rowCount === 0) {
                return res.status(404).json({
                    success: false,
                    message: 'Layanan tidak ditemukan'
                });
            }

            const updatedResult = await query('SELECT id, nama_layanan, kategori, harga, keterangan FROM layanan WHERE id = ?', [id]);

            res.json({
                success: true,
                message: 'Layanan berhasil diperbarui',
                data: updatedResult.rows[0],
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Gagal memperbarui layanan',
                error: error.message,
            });
        }
    }

    // Delete service
    static async delete(req, res) {
        try {
            const { id } = req.params;

            const result = await query('DELETE FROM layanan WHERE id = ?', [id]);

            if (result.rowCount === 0) {
                return res.status(404).json({
                    success: false,
                    message: 'Layanan tidak ditemukan'
                });
            }

            res.json({
                success: true,
                message: 'Layanan berhasil dihapus',
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Gagal menghapus layanan',
                error: error.message,
            });
        }
    }

    // Get pricing statistics by category
    static async getPricingByCategory(req, res) {
        try {
            const result = await query(`
                SELECT
                  kategori,
                  COUNT(*) as total_layanan,
                  AVG(harga) as avg_harga,
                  MIN(harga) as min_harga,
                  MAX(harga) as max_harga
                FROM layanan
                GROUP BY kategori
                ORDER BY kategori ASC
            `, []);

            res.json({
                success: true,
                data: result.rows,
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Gagal mengambil statistik harga berdasarkan kategori',
                error: error.message,
            });
        }
    }
}

module.exports = LayananController;