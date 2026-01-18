import 'package:flutter/material.dart';
import 'package:frontend/pages/dashboard/chat/chatservice.dart';
// Import the service

class ChatPage extends StatefulWidget {
  final VoidCallback onBack;
  final String? initialProductContext;
  final String? initialAiFeedback;

  const ChatPage({
    super.key,
    required this.onBack,
    this.initialProductContext,
    this.initialAiFeedback,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();

  List<ChatMessage> _messages = [];
  bool _isLoadingHistory = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await _chatService.getHistory();
    if (mounted) {
      setState(() {
        _messages = history;
        _isLoadingHistory = false;
      });

      // If we have initial product context, send it as a message
      if (widget.initialProductContext != null &&
          widget.initialProductContext!.isNotEmpty) {
        _sendProductContextMessage();
      } else {
        _scrollToBottom();
      }
    }
  }

  Future<void> _sendProductContextMessage() async {
    final contextMessage =
        "I just scanned a product: ${widget.initialProductContext}. "
        "Your previous analysis was: ${widget.initialAiFeedback ?? 'Not available'}. "
        "Can you tell me more about this product?";

    setState(() {
      _messages.add(
        ChatMessage(
          text: contextMessage,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isSending = true;
    });
    _scrollToBottom();

    final aiResponse = await _chatService.sendMessage(contextMessage);

    if (mounted) {
      setState(() {
        _isSending = false;
        if (aiResponse != null) {
          _messages.add(aiResponse);
        } else {
          _messages.add(
            ChatMessage(
              text: "Failed to get response. Please try again.",
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        }
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    // Small delay to ensure list is rendered before scrolling
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    // 1. Add User Message Immediately (Optimistic UI)
    setState(() {
      _messages.add(
        ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
      );
      _isSending = true;
    });
    _controller.clear();
    _scrollToBottom();

    // 2. Send to Backend
    final aiResponse = await _chatService.sendMessage(text);

    if (mounted) {
      setState(() {
        _isSending = false;
        if (aiResponse != null) {
          _messages.add(aiResponse);
        } else {
          // Error handling: Add a system error message locally
          _messages.add(
            ChatMessage(
              text: "Failed to get response. Please try again.",
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        }
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // --- Header ---
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: widget.onBack,
              ),
              const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.green,
                child: Icon(Icons.auto_awesome, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Nutritionist',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Online',
                    style: TextStyle(fontSize: 12, color: Colors.green),
                  ),
                ],
              ),
            ],
          ),
        ),

        // --- Chat List ---
        Expanded(
          child: _isLoadingHistory
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.green),
                )
              : _messages.isEmpty
              ? Center(
                  child: Text(
                    "Ask me anything about your diet!",
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length + (_isSending ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Show a loading bubble if sending
                    if (index == _messages.length) {
                      return const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 16, bottom: 12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      );
                    }

                    final msg = _messages[index];
                    return Align(
                      alignment: msg.isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: msg.isUser ? Colors.green : Colors.grey[100],
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: msg.isUser
                                ? const Radius.circular(16)
                                : Radius.zero,
                            bottomRight: msg.isUser
                                ? Radius.zero
                                : const Radius.circular(16),
                          ),
                        ),
                        child: Text(
                          msg.text,
                          style: TextStyle(
                            color: msg.isUser ? Colors.white : Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),

        // --- Input Area ---
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, -2),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Ask about food, calories...',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(), // Send on Enter
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: _isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
