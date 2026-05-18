const { verifyToken } = require('../utils/auth');
const { error } = require('../utils/response');

const authenticate = (req, res, next) => {
  let token = req.query.token;
  const authHeader = req.headers.authorization;

  if (authHeader && authHeader.startsWith('Bearer ')) {
    token = authHeader.split(' ')[1];
  }

  if (!token) {
    return error(res, 'Akses ditolak. Token tidak ditemukan.', 401);
  }

  const decoded = verifyToken(token);

  if (!decoded) {
    return error(res, 'Token tidak valid atau kadaluarsa.', 401);
  }

  req.user = decoded;
  next();
};

const authorize = (...roles) => {
  return (req, res, next) => {
    if (!roles.includes(req.user.role)) {
      return error(res, 'Akses ditolak. Anda tidak memiliki izin.', 403);
    }
    next();
  };
};

module.exports = { authenticate, authorize };
