const express = require('express');
const router = express.Router();
const chatbotController = require('./chatbot.controller');

/**
 * POST /api/chatbot/send
 * Send message to AI chatbot
 */
router.post('/send', chatbotController.sendMessage);

/**
 * GET /api/chatbot/history/:userId
 * Get chat history for user
 */
router.get('/history/:userId', chatbotController.getChatHistory);

/**
 * DELETE /api/chatbot/clear/:userId
 * Clear chat history for user
 */
router.delete('/clear/:userId', chatbotController.clearChatHistory);

/**
 * GET /api/chatbot/models
 * Get available Ollama models
 */
router.get('/models', chatbotController.getAvailableModels);

/**
 * GET /api/chatbot/status
 * Check AI service status and selected provider
 */
router.get('/status', chatbotController.getServiceStatus);

module.exports = router;
