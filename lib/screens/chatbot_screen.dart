import 'package:flutter/material.dart';

import '../models/chat_message_model.dart';
import '../services/chatbot_service.dart';
import '../theme/app_theme.dart';

class ChatbotScreen extends StatefulWidget {
  final int userId;

  const ChatbotScreen({super.key, required this.userId});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final ChatbotService _chatbotService = ChatbotService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String _sessionId = 'chat-${DateTime.now().millisecondsSinceEpoch}';

  List<ChatMessage> messages = [];
  List<LLMModel> models = [];
  String? _selectedModel;
  String _provider = 'Unknown';
  bool _serviceAvailable = false;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future.wait([
      _loadServiceStatus(),
      _loadModels(),
      _loadChatHistory(),
    ]);
  }

  Future<void> _loadServiceStatus() async {
    final status = await _chatbotService.getServiceStatus();
    if (!mounted) {
      return;
    }
    setState(() {
      _serviceAvailable = status['available'] == true;
      _provider = status['provider']?.toString() ?? 'Unknown';
      _selectedModel ??= status['defaultModel']?.toString();
    });
  }

  Future<void> _loadModels() async {
    try {
      final loadedModels = await _chatbotService.getAvailableModels();
      if (!mounted) {
        return;
      }
      setState(() {
        models = loadedModels;
        if (_selectedModel == null && loadedModels.isNotEmpty) {
          _selectedModel = loadedModels.first.name;
        }
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = 'Gagal mengambil model AI: $e';
      });
    }
  }

  Future<void> _loadChatHistory() async {
    try {
      final history = await _chatbotService.getChatHistory(
        widget.userId,
        sessionId: _sessionId,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        messages = history;
      });
      _scrollToBottom();
    } catch (_) {
      // session baru, history kosong itu normal
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) {
      return;
    }

    _messageController.clear();
    setState(() {
      _error = null;
      _isLoading = true;
      messages.add(
        ChatMessage(
          id: 0,
          sender: 'user',
          message: text,
          timestamp: DateTime.now(),
        ),
      );
    });
    _scrollToBottom();

    try {
      final response = await _chatbotService.sendMessage(
        userId: widget.userId,
        message: text,
        sessionId: _sessionId,
        model: _selectedModel,
      );

      if (!mounted) {
        return;
      }
      setState(() {
        messages.add(
          ChatMessage(
            id: 0,
            sender: 'ai',
            message: response['aiResponse']?.toString() ?? 'Tidak ada respons.',
            timestamp: DateTime.now(),
            modelUsed: response['modelUsed']?.toString(),
            responseTimeMs: response['responseTimeMs'] as int?,
          ),
        );
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = 'Gagal mengirim pesan: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _clearHistory() async {
    try {
      await _chatbotService.clearChatHistory(
        widget.userId,
        sessionId: _sessionId,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        messages.clear();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Riwayat chat dihapus')));
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menghapus riwayat: $e')));
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konsultasi AI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Hapus Riwayat',
            onPressed: _isLoading ? null : _clearHistory,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildServiceHeader(context),
          Expanded(child: _buildMessages(context)),
          if (_error != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(
                _error!,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
          _buildInput(context),
        ],
      ),
    );
  }

  Widget _buildServiceHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      color: Theme.of(context).cardColor,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _serviceAvailable
                  ? AppTheme.success.withAlpha(32)
                  : AppTheme.error.withAlpha(24),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _serviceAvailable ? 'Online' : 'Offline',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _serviceAvailable ? AppTheme.success : AppTheme.error,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Provider: $_provider',
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (models.isNotEmpty)
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 180),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedModel,
                  isExpanded: true,
                  hint: const Text('Pilih Model'),
                  items: models
                      .map(
                        (model) => DropdownMenuItem<String>(
                          value: model.name,
                          child: Text(
                            model.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: _isLoading
                      ? null
                      : (value) => setState(() => _selectedModel = value),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessages(BuildContext context) {
    if (messages.isEmpty && !_isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.smart_toy_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 14),
              Text(
                'Mulai konsultasi dengan model AI pilihan Anda.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      itemCount: messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (_isLoading && index == messages.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            ),
          );
        }

        final message = messages[index];
        final isUser = message.sender == 'user';
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 320),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isUser ? AppTheme.primary : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.message,
                  style: TextStyle(
                    color: isUser ? Colors.white : Colors.black87,
                  ),
                ),
                if (!isUser &&
                    (message.modelUsed != null ||
                        message.responseTimeMs != null))
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${message.modelUsed ?? _selectedModel ?? '-'}'
                      '${message.responseTimeMs != null ? ' • ${message.responseTimeMs} ms' : ''}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isUser ? Colors.white70 : Colors.grey.shade600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor.withAlpha(120)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              minLines: 1,
              maxLines: 4,
              enabled: !_isLoading,
              decoration: InputDecoration(
                hintText: 'Tulis pertanyaan kesehatan...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: _isLoading ? null : _sendMessage,
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
