const axios = require('axios');
require('dotenv').config();

const OLLAMA_BASE_URL = process.env.OLLAMA_BASE_URL || 'http://localhost:11434';
const VLLM_BASE_URL = process.env.VLLM_BASE_URL || 'http://localhost:8000';
const DEFAULT_MODEL = process.env.LLM_MODEL || 'mistral';
const USE_VLLM = process.env.USE_VLLM === 'true';
const VLLM_API_KEY = process.env.VLLM_API_KEY || '';

/**
 * Get AI response from Ollama or vLLM
 * @param {string} message - User message
 * @param {string} model - Model name (optional)
 * @returns {Promise<{text: string, modelUsed: string, provider: string, responseTimeMs: number}>}
 */
exports.getAIResponse = async (message, model = DEFAULT_MODEL) => {
  const startedAt = Date.now();
  try {
    const modelToUse = model || DEFAULT_MODEL;
    const result = USE_VLLM
      ? await this.getResponseFromVLLM(message, modelToUse)
      : await this.getResponseFromOllama(message, modelToUse);

    return {
      ...result,
      responseTimeMs: Date.now() - startedAt,
    };
  } catch (err) {
    console.error('Error getting AI response:', err.message);
    throw new Error(`Failed to get AI response: ${err.message}`);
  }
};

/**
 * Get response from Ollama
 */
exports.getResponseFromOllama = async (message, model = DEFAULT_MODEL) => {
  try {
    const response = await axios.post(
      `${OLLAMA_BASE_URL}/api/generate`,
      {
        model,
        prompt: message,
        stream: false,
        temperature: 0.7,
        top_k: 40,
        top_p: 0.9,
      },
      {
        timeout: 120000,
      }
    );

    return {
      text: (response.data?.response || '').trim(),
      modelUsed: response.data?.model || model,
      provider: 'Ollama',
    };
  } catch (err) {
    console.error('Ollama API Error:', err.message);
    throw new Error(`Ollama API Error: ${err.message}`);
  }
};

/**
 * Get response from vLLM Cloud
 */
exports.getResponseFromVLLM = async (message, model = DEFAULT_MODEL) => {
  try {
    const response = await axios.post(
      `${VLLM_BASE_URL}/v1/chat/completions`,
      {
        model,
        messages: [
          {
            role: 'system',
            content: 'Anda adalah asisten kesehatan digital untuk Klinik Merah Putih.',
          },
          {
            role: 'user',
            content: message,
          },
        ],
        max_tokens: 512,
        temperature: 0.7,
        top_p: 0.9,
      },
      {
        headers: {
          Authorization: `Bearer ${VLLM_API_KEY}`,
          'Content-Type': 'application/json',
        },
        timeout: 120000,
      }
    );

    const text = response.data?.choices?.[0]?.message?.content?.trim() || '';
    return {
      text,
      modelUsed: response.data?.model || model,
      provider: 'vLLM Cloud',
    };
  } catch (err) {
    console.error('vLLM API Error:', err.message);
    throw new Error(`vLLM API Error: ${err.message}`);
  }
};

/**
 * Get available Ollama models
 */
exports.getAvailableModels = async () => {
  try {
    if (USE_VLLM) {
      const response = await axios.get(`${VLLM_BASE_URL}/v1/models`, {
        headers: {
          Authorization: `Bearer ${VLLM_API_KEY}`,
        },
      });
      return response.data.data.map((m) => ({
        name: m.id,
        provider: 'vLLM Cloud',
      }));
    }
    const response = await axios.get(`${OLLAMA_BASE_URL}/api/tags`);
    return (response.data.models || []).map((m) => ({
      name: m.name,
      size: m.size,
      modified: m.modified_at,
      provider: 'Ollama',
    }));
  } catch (err) {
    console.error('Error fetching models:', err.message);
    throw new Error(`Failed to fetch models: ${err.message}`);
  }
};

/**
 * Check if Ollama/vLLM service is available
 */
exports.isServiceAvailable = async () => {
  try {
    if (USE_VLLM) {
      await axios.get(`${VLLM_BASE_URL}/v1/models`, {
        timeout: 5000,
        headers: {
          Authorization: `Bearer ${VLLM_API_KEY}`,
        },
      });
    } else {
      await axios.get(`${OLLAMA_BASE_URL}/api/tags`, {
        timeout: 5000,
      });
    }
    return {
      available: true,
      provider: USE_VLLM ? 'vLLM Cloud' : 'Ollama',
      defaultModel: DEFAULT_MODEL,
    };
  } catch {
    return {
      available: false,
      provider: USE_VLLM ? 'vLLM Cloud' : 'Ollama',
      defaultModel: DEFAULT_MODEL,
    };
  }
};
