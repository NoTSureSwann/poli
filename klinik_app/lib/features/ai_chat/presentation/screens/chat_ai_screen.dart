import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:klinik_app/services/api/groq_api_service.dart';

class ChatAiScreen extends StatefulWidget {
  const ChatAiScreen({super.key});

  @override
  State<ChatAiScreen> createState() => _ChatAiScreenState();
}

class _ChatAiScreenState extends State<ChatAiScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GroqApiService _groqApi = GroqApiService();

  final List<Map<String, String>> _messages = [
    {
      'role': 'system',
      'content': 'Anda adalah AI Asisten Klinik cerdas yang ramah. Bantu pasien dengan pertanyaan seputar kesehatan, jadwal dokter, obat-obatan, dan rekomendasi perawatan. Jawab dengan profesional dan gunakan Markdown jika diperlukan.'
    },
    {
      'role': 'assistant',
      'content': 'Halo! Saya AI Asisten Klinik Anda. Ada yang bisa saya bantu terkait kesehatan, jadwal dokter, atau informasi poli hari ini?'
    }
  ];

  bool _isTyping = false;
  String _currentStreamMessage = "";

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage([String? text]) async {
    final String message = text ?? _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'content': message});
      _messageController.clear();
      _isTyping = true;
      _currentStreamMessage = ""; // Reset streaming buffer
    });
    _scrollToBottom();

    try {
      final stream = _groqApi.streamMessage(_messages.where((m) => m['role'] != 'assistant' || m['content']!.isNotEmpty).toList());
      
      await for (final chunk in stream) {
        setState(() {
          _currentStreamMessage += chunk;
        });
        _scrollToBottom();
      }

      setState(() {
        _messages.add({'role': 'assistant', 'content': _currentStreamMessage});
        _currentStreamMessage = "";
        _isTyping = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add({'role': 'assistant', 'content': 'Maaf, terjadi kesalahan pada sistem AI kami. Silakan coba lagi.'});
        _isTyping = false;
      });
    }
  }

  Widget _buildSuggestionChip(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        label: Text(text, style: const TextStyle(fontSize: 12)),
        backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        side: BorderSide(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
        onPressed: () => _sendMessage(text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Exclude the system prompt from UI
    final displayMessages = _messages.where((msg) => msg['role'] != 'system').toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.primary, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('AI Clinic Assistant'),
          ],
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Chat List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: displayMessages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == displayMessages.length && _isTyping) {
                  return _buildChatBubble(
                    role: 'assistant',
                    content: _currentStreamMessage.isEmpty ? 'Typing...' : _currentStreamMessage,
                    isStreaming: true,
                  );
                }
                
                final msg = displayMessages[index];
                return _buildChatBubble(role: msg['role']!, content: msg['content']!);
              },
            ),
          ),

          // Suggestion Chips
          if (displayMessages.length <= 2)
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildSuggestionChip('Jadwal Dokter Gigi'),
                  _buildSuggestionChip('Cara Daftar Poli'),
                  _buildSuggestionChip('Cek Gejala Demam'),
                ],
              ),
            ),

          // Input Field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  offset: const Offset(0, -5),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Tanyakan sesuatu seputar kesehatan...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                    onSubmitted: (val) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble({required String role, required String content, bool isStreaming = false}) {
    final isUser = role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser 
              ? Theme.of(context).colorScheme.primary 
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(20),
            bottomLeft: !isUser ? const Radius.circular(4) : const Radius.circular(20),
          ),
          boxShadow: [
            if (!isUser)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                spreadRadius: 1,
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isStreaming && content == 'Typing...')
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.primary)),
                  const SizedBox(width: 8),
                  Text('AI is typing...', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12)),
                ],
              )
            else
              MarkdownBody(
                data: content,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(color: isUser ? Colors.white : Colors.black87, fontSize: 15),
                  strong: TextStyle(color: isUser ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
                  listBullet: TextStyle(color: isUser ? Colors.white : Colors.black87),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
