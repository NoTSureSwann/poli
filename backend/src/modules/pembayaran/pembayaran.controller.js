const db = require('../../config/database');
const { success, error } = require('../../utils/response');
const notificationService = require('../../services/notification.service');

const createPayment = async (req, res) => {
  const { pasien_id, rekam_medis_id, resep_id, jenis_pembayaran, total_biaya, keterangan } = req.body;

  try {
    // 1. Insert to database
    const result = await db.query(
      `INSERT INTO pembayaran (pasien_id, rekam_medis_id, resep_id, jenis_pembayaran, total_biaya, keterangan, processed_by) 
       VALUES ($1, $2, $3, $4, $5, $6, $7) 
       RETURNING *`,
      [pasien_id, rekam_medis_id, resep_id, jenis_pembayaran || 'UMUM', total_biaya, keterangan, req.user.id]
    );

    const payment = result.rows[0];

    // 2. Fetch patient name for notification
    const patientResult = await db.query('SELECT nama FROM pasien WHERE id = $1', [pasien_id]);
    const patientName = patientResult.rows[0]?.nama || 'Pasien Umum';

    // 3. Trigger Notification (Async - non blocking)
    notificationService.sendPaymentNotification({
      patientName,
      amount: total_biaya,
      paymentType: jenis_pembayaran || 'UMUM',
      status: 'pending'
    });

    return success(res, payment, 'Pembayaran berhasil dibuat dan notifikasi sedang dikirim', 201);
  } catch (err) {
    console.error(err);
    return error(res, 'Gagal membuat pembayaran', 500, err.message);
  }
};

const getPaymentById = async (req, res) => {
  const { id } = req.params;
  try {
    const result = await db.query(
      `SELECT p.*, pas.nama as nama_pasien, u.nama as nama_admin
       FROM pembayaran p
       JOIN pasien pas ON p.pasien_id = pas.id
       JOIN users u ON p.processed_by = u.id
       WHERE p.id = $1`,
      [id]
    );
    if (result.rows.length === 0) {
      return error(res, 'Pembayaran tidak ditemukan', 404);
    }
    return success(res, result.rows[0]);
  } catch (err) {
    console.error(err);
    return error(res, 'Gagal mengambil data pembayaran', 500, err.message);
  }
};

module.exports = {
  createPayment,
  getPaymentById
};
