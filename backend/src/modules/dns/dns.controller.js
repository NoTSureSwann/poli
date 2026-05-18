const dns = require('node:dns').promises;
const os = require('os');
const axios = require('axios');
const { success, error } = require('../../utils/response');

const getLocalAddresses = () => {
  const nets = os.networkInterfaces();
  const addresses = [];

  for (const [name, entries] of Object.entries(nets)) {
    for (const entry of entries || []) {
      if (entry.internal) {
        continue;
      }

      addresses.push({
        interface: name,
        family: entry.family,
        address: entry.address,
      });
    }
  }

  return addresses;
};

/**
 * GET /api/dns/resolve?host=example.com
 * Resolve a hostname into IP addresses.
 */
exports.resolveHost = async (req, res) => {
  try {
    const host = (req.query.host || '').trim();
    if (!host) {
      return error(res, 'Parameter query "host" wajib diisi', 400);
    }

    const resolved = await dns.lookup(host, { all: true });
    return success(res, {
      host,
      records: resolved,
      count: resolved.length,
    });
  } catch (err) {
    return error(res, 'Gagal resolve DNS host', 500, err.message);
  }
};

/**
 * GET /api/dns/check?url=http://localhost:3000/health
 * Check API endpoint reachability for Postman troubleshooting.
 */
exports.checkEndpoint = async (req, res) => {
  try {
    const targetUrl =
      (req.query.url || '').trim() || `${req.protocol}://${req.get('host')}/health`;
    const startedAt = Date.now();

    const response = await axios.get(targetUrl, {
      timeout: 5000,
      validateStatus: () => true,
    });

    return success(res, {
      url: targetUrl,
      statusCode: response.status,
      reachable: response.status < 500,
      latencyMs: Date.now() - startedAt,
    });
  } catch (err) {
    return error(res, 'Endpoint tidak terjangkau', 500, err.message);
  }
};

/**
 * GET /api/dns/info
 * Return local network info to help mobile device API setup.
 */
exports.getInfo = async (req, res) => {
  try {
    return success(res, {
      hostname: os.hostname(),
      localAddresses: getLocalAddresses(),
    });
  } catch (err) {
    return error(res, 'Gagal mengambil info DNS lokal', 500, err.message);
  }
};
