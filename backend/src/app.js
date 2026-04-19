const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
require('dotenv').config();

const { error } = require('./utils/response');

// Import Routes
const authRoutes = require('./modules/auth/auth.routes');
const pasienRoutes = require('./modules/pasien/pasien.routes');
const medicalRecordRoutes = require('./modules/medical-record/medical-record.routes');
const paymentRoutes = require('./modules/pembayaran/pembayaran.routes');

const app = express();

// Middleware
app.use(helmet());
app.use(cors());
app.use(morgan('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/patients', pasienRoutes);
app.use('/api/medical-records', medicalRecordRoutes);
app.use('/api/payments', paymentRoutes);


// Health Check
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'OK', message: 'Klinik Merah Putih API is running' });
});

// Error Handling
app.use((err, req, res, next) => {
  console.error(err.stack);
  error(res, 'Internal Server Error', 500, err.message);
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});

module.exports = app;
