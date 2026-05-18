const { query } = require('../../config/database');

class PembayaranController {
  // Helper: Generate no_struk
  static async generateNoStruk() {
    const today = new Date();
    const dateStr = today.toISOString().split('T')[0].replace(/-/g, '');

    // Get count of payments today
    const countResult = await query(`
      SELECT COUNT(*) as count FROM pembayaran
      WHERE DATE(created_at) = DATE('now')
    `, []);
    const count = countResult.rows[0].count || 0;

    return `STR${dateStr}${(count + 1).toString().padStart(4, '0')}`;
  }

  // Get all payments
  static async getAll(req, res) {
    try {
      const { page = 1, limit = 10, search = '', status } = req.query;
      const pageNum = Math.max(parseInt(page, 10) || 1, 1);
      const limitNum = Math.max(parseInt(limit, 10) || 10, 1);
      const offset = (pageNum - 1) * limitNum;

      let whereClause = '1=1';
      let params = [];

      if (search) {
        whereClause += ' AND (p.nama LIKE ? OR pb.no_struk LIKE ?)';
        params.push(`%${search}%`, `%${search}%`);
      }

      if (status) {
        whereClause += ' AND pb.status = ?';
        params.push(status);
      }

      const queryStr = `
        SELECT pb.*, p.nama as pasien_nama, p.no_rm,
               u.nama as processed_by_nama
        FROM pembayaran pb
        JOIN pasien p ON pb.pasien_id = p.id
        LEFT JOIN users u ON pb.processed_by = u.id
        WHERE ${whereClause}
        ORDER BY pb.created_at DESC
        LIMIT ? OFFSET ?
      `;

      const countStr = `
        SELECT COUNT(*) as total
        FROM pembayaran pb
        JOIN pasien p ON pb.pasien_id = p.id
        WHERE ${whereClause}
      `;

      params.push(limitNum, offset);

      const [result, countResult] = await Promise.all([
        query(queryStr, params.slice(0, -2).concat([limitNum, offset])),
        query(countStr, params.slice(0, -2))
      ]);

      const total = parseInt(countResult.rows[0].total || 0);

      res.json({
        success: true,
        data: result.rows,
        pagination: {
          page: pageNum,
          limit: limitNum,
          total,
          pages: Math.ceil(total / limitNum)
        }
      });
    } catch (err) {
      console.error(err);
      res.status(500).json({
        success: false,
        message: 'Gagal mengambil data pembayaran',
        error: err.message
      });
    }
  }

  // Get payment by ID
  static async getById(req, res) {
    try {
      const { id } = req.params;

      const result = await query(`
        SELECT pb.*, p.nama as pasien_nama, p.no_rm,
               u.nama as processed_by_nama
        FROM pembayaran pb
        JOIN pasien p ON pb.pasien_id = p.id
        LEFT JOIN users u ON pb.processed_by = u.id
        WHERE pb.id = ?
      `, [id]);

      if (result.rows.length === 0) {
        return res.status(404).json({
          success: false,
          message: 'Pembayaran tidak ditemukan'
        });
      }

      res.json({
        success: true,
        data: result.rows[0]
      });
    } catch (err) {
      console.error(err);
      res.status(500).json({
        success: false,
        message: 'Gagal mengambil data pembayaran',
        error: err.message
      });
    }
  }

  // Create new payment
  static async create(req, res) {
    try {
      const {
        pasien_id, rekam_medis_id, resep_id, jenis_pembayaran,
        total_biaya, bpjs_claim_id, sep_number, keterangan
      } = req.body;

      const no_struk = await PembayaranController.generateNoStruk();

      const result = await query(`
        INSERT INTO pembayaran (
          pasien_id, rekam_medis_id, resep_id, jenis_pembayaran,
          status, total_biaya, total_dibayar, bpjs_claim_id, sep_number,
          keterangan, processed_by, created_at, updated_at
        ) VALUES (?, ?, ?, ?, 'pending', ?, 0, ?, ?, ?, ?, datetime('now'), datetime('now'))
      `, [
        pasien_id, rekam_medis_id, resep_id, jenis_pembayaran,
        total_biaya, bpjs_claim_id, sep_number, keterangan, req.user?.id
      ]);

      const createdResult = await query(`
        SELECT pb.*, p.nama as pasien_nama, p.no_rm
        FROM pembayaran pb
        JOIN pasien p ON pb.pasien_id = p.id
        WHERE pb.id = ?
      `, [result.lastID]);

      res.status(201).json({
        success: true,
        message: 'Pembayaran berhasil dibuat',
        data: createdResult.rows[0]
      });
    } catch (err) {
      console.error(err);
      res.status(500).json({
        success: false,
        message: 'Gagal membuat pembayaran',
        error: err.message
      });
    }
  }

  // Update payment
  static async update(req, res) {
    try {
      const { id } = req.params;
      const { status, total_dibayar, keterangan } = req.body;

      const result = await query(`
        UPDATE pembayaran
        SET status = ?, total_dibayar = ?, keterangan = ?, processed_by = ?, updated_at = datetime('now')
        WHERE id = ?
      `, [status, total_dibayar, keterangan, req.user?.id, id]);

      if (result.rowCount === 0) {
        return res.status(404).json({
          success: false,
          message: 'Pembayaran tidak ditemukan'
        });
      }

      const updatedResult = await query(`
        SELECT pb.*, p.nama as pasien_nama, p.no_rm,
               u.nama as processed_by_nama
        FROM pembayaran pb
        JOIN pasien p ON pb.pasien_id = p.id
        LEFT JOIN users u ON pb.processed_by = u.id
        WHERE pb.id = ?
      `, [id]);

      res.json({
        success: true,
        message: 'Pembayaran berhasil diperbarui',
        data: updatedResult.rows[0]
      });
    } catch (err) {
      console.error(err);
      res.status(500).json({
        success: false,
        message: 'Gagal memperbarui pembayaran',
        error: err.message
      });
    }
  }

  // Delete payment
  static async delete(req, res) {
    try {
      const { id } = req.params;

      const result = await query('DELETE FROM pembayaran WHERE id = ?', [id]);

      if (result.rowCount === 0) {
        return res.status(404).json({
          success: false,
          message: 'Pembayaran tidak ditemukan'
        });
      }

      res.json({
        success: true,
        message: 'Pembayaran berhasil dihapus'
      });
    } catch (err) {
      console.error(err);
      res.status(500).json({
        success: false,
        message: 'Gagal menghapus pembayaran',
        error: err.message
      });
    }
  }

  // Placeholder methods for routes that exist but aren't implemented yet
  static async getStruk(req, res) {
    res.json({ success: false, message: 'Method not implemented yet' });
  }

  static async getStrukObat(req, res) {
    res.json({ success: false, message: 'Method not implemented yet' });
  }

  static async getRevenueReport(req, res) {
    res.json({ success: false, message: 'Method not implemented yet' });
  }
}

module.exports = PembayaranController;