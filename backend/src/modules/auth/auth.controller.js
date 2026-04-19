const db = require('../../config/database');
const { hashPassword, comparePassword, generateToken } = require('../../utils/auth');
const { success, error } = require('../../utils/response');

const register = async (req, res) => {
  const { nama, email, password, role, nip } = req.body;

  try {
    const existingUser = await db.query('SELECT * FROM users WHERE email = $1', [email]);
    if (existingUser.rows.length > 0) {
      return error(res, 'Email sudah terdaftar', 400);
    }

    const hashedPassword = await hashPassword(password);
    const result = await db.query(
      'INSERT INTO users (nama, email, password_hash, role, nip) VALUES ($1, $2, $3, $4, $5) RETURNING id, nama, email, role',
      [nama, email, hashedPassword, role || 'perawat', nip]
    );

    const user = result.rows[0];
    const token = generateToken({ id: user.id, role: user.role });

    return success(res, { user, token }, 'Registrasi berhasil', 201);
  } catch (err) {
    console.error(err);
    return error(res, 'Gagal registrasi', 500, err.message);
  }
};

const login = async (req, res) => {
  const { email, password } = req.body;

  try {
    const result = await db.query('SELECT * FROM users WHERE email = $1', [email]);
    if (result.rows.length === 0) {
      return error(res, 'Email atau password salah', 401);
    }

    const user = result.rows[0];
    const isMatch = await comparePassword(password, user.password_hash);
    if (!isMatch) {
      return error(res, 'Email atau password salah', 401);
    }

    const token = generateToken({ id: user.id, role: user.role });
    
    // Update last login
    await db.query('UPDATE users SET last_login = NOW() WHERE id = $1', [user.id]);

    delete user.password_hash;
    delete user.refresh_token_hash;

    return success(res, { user, token }, 'Login berhasil');
  } catch (err) {
    console.error(err);
    return error(res, 'Gagal login', 500, err.message);
  }
};

module.exports = {
  register,
  login
};
