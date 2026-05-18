const chatbotService = require('./chatbot.service');
const { success, error } = require('../../utils/response');
const { query } = require('../../config/database');

/**
 * Send message to AI chatbot
 */
exports.sendMessage = async (req, res) => {
  try {
    const { userId, message, sessionId, model } = req.body;

    if (!userId || !message) {
      return error(res, 'Missing required fields', 400);
    }

    await query(
      `INSERT INTO chat_messages (user_id, session_id, sender, message, model_used, created_at)
       VALUES (?, ?, ?, ?, ?, CURRENT_TIMESTAMP)`,
      [userId, sessionId || null, 'user', message, model || null]
    );

    const aiResult = await chatbotService.getAIResponse(message, model);

    await query(
      `INSERT INTO chat_messages (user_id, session_id, sender, message, model_used, response_time_ms, created_at)
       VALUES (?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)`,
      [
        userId,
        sessionId || null,
        'ai',
        aiResult.text,
        aiResult.modelUsed,
        aiResult.responseTimeMs,
      ]
    );

    return success(res, {
      userMessage: message,
      aiResponse: aiResult.text,
      modelUsed: aiResult.modelUsed,
      provider: aiResult.provider,
      responseTimeMs: aiResult.responseTimeMs,
      timestamp: new Date().toISOString(),
    });
  } catch (err) {
    console.error('Error in sendMessage:', err);
    return error(res, 'Failed to get AI response', 500, err.message);
  }
};

/**
 * Get chat history for user
 */
exports.getChatHistory = async (req, res) => {
    try {
        const { userId } = req.params;
        const { sessionId } = req.query;

        if (!userId) {
            return error(res, 'Missing userId', 400);
        }

        let sql = `SELECT * FROM chat_messages WHERE user_id = ? ORDER BY created_at ASC`;
        let params = [userId];

        if (sessionId) {
            sql = `SELECT * FROM chat_messages WHERE user_id = ? AND session_id = ? ORDER BY created_at ASC`;
            params = [userId, sessionId];
        }

        const result = await query(sql, params);
        return success(res, result.rows);

    } catch (err) {
        console.error('Error in getChatHistory:', err);
        return error(res, 'Failed to retrieve chat history', 500, err.message);
    }
};

/**
 * Clear chat history for user
 */
exports.clearChatHistory = async (req, res) => {
    try {
        const { userId } = req.params;
        const { sessionId } = req.query;

        if (!userId) {
            return error(res, 'Missing userId', 400);
        }

        let sql = `DELETE FROM chat_messages WHERE user_id = ?`;
        let params = [userId];

        if (sessionId) {
            sql = `DELETE FROM chat_messages WHERE user_id = ? AND session_id = ?`;
            params = [userId, sessionId];
        }

        await query(sql, params);
        return success(res, { message: 'Chat history cleared successfully' });

    } catch (err) {
        console.error('Error in clearChatHistory:', err);
        return error(res, 'Failed to clear chat history', 500, err.message);
    }
};

/**
 * Get available Ollama models
 */
exports.getAvailableModels = async (req, res) => {
  try {
    const models = await chatbotService.getAvailableModels();
    return success(res, { models });
  } catch (err) {
    console.error('Error in getAvailableModels:', err);
    return error(res, 'Failed to retrieve available models', 500, err.message);
  }
};

/**
 * Get AI service status (provider, availability, default model)
 */
exports.getServiceStatus = async (req, res) => {
  try {
    const status = await chatbotService.isServiceAvailable();
    return success(res, status);
  } catch (err) {
    console.error('Error in getServiceStatus:', err);
    return error(res, 'Failed to retrieve AI service status', 500, err.message);
  }
};
