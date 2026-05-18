const db = require('../../config/database');
const { success, error } = require('../../utils/response');

const escapeCsvValue = (value) => {
  if (value === null || value === undefined) {
    return '';
  }

  const stringValue = String(value);
  if (/[,"\n]/.test(stringValue)) {
    return `"${stringValue.replace(/"/g, '""')}"`;
  }
  return stringValue;
};

const rowsToCsv = (rows) => {
  if (!rows.length) {
    return '';
  }

  const headers = Object.keys(rows[0]);
  const headerLine = headers.join(',');
  const lines = rows.map((row) =>
    headers.map((key) => escapeCsvValue(row[key])).join(',')
  );
  return `${headerLine}\n${lines.join('\n')}`;
};

/**
 * Export Patient & Medical Record data to CSV for Machine Learning
 * Joins patients with their medical records to provide features (age, sex, vitals) 
 * and targets (diagnosis).
 */
const exportMLData = async (req, res) => {
  try {
    const queryStr = `
      SELECT 
        p.id as patient_id,
        p.no_rm,
        p.nama as patient_name,
        p.jenis_kelamin,
        (strftime('%Y', 'now') - strftime('%Y', p.tanggal_lahir)) as age,
        p.golongan_darah,
        p.alergi,
        rm.tanggal_kunjungan,
        rm.keluhan_utama,
        rm.diagnosis,
        rm.icd10_code,
        rm.tekanan_darah,
        rm.nadi,
        rm.suhu,
        rm.berat_badan,
        rm.tinggi_badan,
        rm.saturasi_oksigen
      FROM pasien p
      JOIN rekam_medis rm ON p.id = rm.pasien_id
      WHERE p.is_active = 1 AND rm.is_active = 1
      ORDER BY rm.tanggal_kunjungan DESC
    `;

    const result = await db.query(queryStr);
    
    if (result.rows.length === 0) {
      return error(res, 'Tidak ada data untuk diekspor', 404);
    }

    // Convert to CSV without external dependency
    const csv = rowsToCsv(result.rows);

    // Set headers for file download
    res.setHeader('Content-Type', 'text/csv');
    res.setHeader('Content-Disposition', 'attachment; filename=klinik_ml_export.csv');
    
    return res.send(csv);
  } catch (err) {
    console.error('[ML Export Error]:', err);
    return error(res, 'Gagal mengekspor data ML', 500, err.message);
  }
};

module.exports = {
  exportMLData
};
