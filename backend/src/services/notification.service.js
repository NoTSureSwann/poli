const TelegramBot = require('node-telegram-bot-api');
const nodemailer = require('nodemailer');
require('dotenv').config();

class NotificationService {
  constructor() {
    // Telegram Setup
    if (process.env.TELEGRAM_BOT_TOKEN) {
      this.bot = new TelegramBot(process.env.TELEGRAM_BOT_TOKEN, { polling: false });
    }

    // Email Setup
    this.transporter = nodemailer.createTransport({
      host: process.env.SMTP_HOST,
      port: process.env.SMTP_PORT,
      secure: process.env.SMTP_PORT == 465,
      auth: {
        user: process.env.SMTP_USER,
        pass: process.env.SMTP_PASS,
      },
    });
  }

  async sendPaymentNotification(paymentData) {
    const { patientName, amount, paymentType, status } = paymentData;
    const message = `
🔔 *Notifikasi Pembayaran Baru*
--------------------------------
👤 Pasien: ${patientName}
💰 Total: Rp ${new Intl.NumberFormat('id-ID').format(amount)}
💳 Tipe: ${paymentType}
📌 Status: ${status}
--------------------------------
Klinik Merah Putih
    `;

    // Send Telegram
    if (this.bot && process.env.TELEGRAM_ADMIN_CHAT_ID) {
      try {
        await this.bot.sendMessage(process.env.TELEGRAM_ADMIN_CHAT_ID, message, { parse_mode: 'Markdown' });
        console.log('Telegram notification sent');
      } catch (err) {
        console.error('Failed to send Telegram notification:', err.message);
      }
    }

    // Send Email
    if (process.env.SMTP_USER) {
      try {
        await this.transporter.sendMail({
          from: process.env.SMTP_FROM || 'noreply@klinikmerahputih.com',
          to: process.env.SMTP_USER, // Sending to admin for now as requested
          subject: `Notifikasi Pembayaran: ${patientName}`,
          text: message.replace(/\*/g, ''),
          html: `<pre>${message.replace(/\*/g, '')}</pre>`,
        });
        console.log('Email notification sent');
      } catch (err) {
        console.error('Failed to send Email notification:', err.message);
      }
    }
  }
}

module.exports = new NotificationService();
