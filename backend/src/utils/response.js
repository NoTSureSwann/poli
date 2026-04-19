const success = (res, data, message = 'Berhasil', code = 200) => {
    return res.status(code).json({
        status: 'success',
        message,
        data,
        timestamp: new Date().toISOString(),
    });
};

const paginated = (res, data, total, page, limit, message = 'Berhasil') => {
    return res.status(200).json({
        status: 'success',
        message,
        data,
        pagination: {
            total,
            page: parseInt(page),
            limit: parseInt(limit),
            totalPages: Math.ceil(total / limit),
            hasNext: page * limit < total,
            hasPrev: page > 1,
        },
        timestamp: new Date().toISOString(),
    });
};

const error = (res, message, code = 400, details = null) => {
    return res.status(code).json({
        status: 'error',
        message,
        details,
        timestamp: new Date().toISOString(),
    });
};

module.exports = { success, paginated, error };