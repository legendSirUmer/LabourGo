import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../services/websocket_service.dart';
import '../../theme/cust_theme.dart';

class ChatScreen extends StatefulWidget {
  final int bookingId;
  final String otherUserName;
  final String? otherUserAvatar;

  const ChatScreen({
    super.key,
    required this.bookingId,
    required this.otherUserName,
    this.otherUserAvatar,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final WebSocketService _wsService = WebSocketService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _messages = [];

  bool _isLoading = true;
  bool _isConnected = false;

  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    await _loadCurrentUser();
    await _loadMessages();
    await _connectWebSocket();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final response = await ApiService.getRequest('/api/auth/profile/');

      if (response != null) {
        setState(() {
          _currentUserId = response['id'];
        });
      }
    } catch (e) {
      debugPrint('Failed to load current user: $e');
    }
  }

  Future<void> _loadMessages() async {
    try {
      final response = await ApiService.getRequest(
        '/api/messaging/messages/by_booking/?booking_id=${widget.bookingId}',
      );

      if (response != null) {
        final loadedMessages = List<Map<String, dynamic>>.from(
          response.map(
            (msg) => {
              'id': msg['id'],
              'sender': msg['sender'] is Map
                  ? msg['sender']['id']
                  : msg['sender'],
              'sender_details': {
                'full_name': msg['sender_details']?['full_name'] ?? '',
                'avatar': msg['sender_details']?['avatar'],
              },
              'content': msg['content'],
              'created_at': msg['created_at'],
              'is_read': msg['is_read'] ?? false,
            },
          ),
        );

        setState(() {
          _messages = loadedMessages;
          _isLoading = false;
        });

        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('Failed to load messages: $e');

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _connectWebSocket() async {
    try {
      await _wsService.connect(widget.bookingId);

      setState(() {
        _isConnected = true;
      });

      _wsService.stream?.listen(
        (dynamic message) {
          _handleIncomingMessage(message);
        },
        onError: (error) {
          debugPrint('WebSocket Error: $error');

          setState(() {
            _isConnected = false;
          });
        },
        onDone: () {
          setState(() {
            _isConnected = false;
          });
        },
      );
    } catch (e) {
      debugPrint('WebSocket connection failed: $e');

      setState(() {
        _isConnected = false;
      });
    }
  }

  void _handleIncomingMessage(dynamic message) {
    try {
      final data = jsonDecode(message);

      if (data['type'] == 'message') {
        final newMessage = {
          'id': data['message_id'],
          'sender': data['sender_id'],
          'sender_details': {
            'full_name': data['sender_name'],
            'avatar': data['sender_avatar'],
          },
          'content': data['content'],
          'created_at': data['created_at'],
          'is_read': data['is_read'] ?? false,
        };

        setState(() {
          // Prevent duplicate messages
          final alreadyExists = _messages.any(
            (msg) => msg['id'] == newMessage['id'],
          );

          if (!alreadyExists) {
            _messages.add(newMessage);
          }
        });

        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('Error parsing WebSocket message: $e');
    }
  }

  void _sendMessage() {
    final content = _messageController.text.trim();

    if (content.isEmpty || !_isConnected) {
      return;
    }

    _wsService.sendMessage(content);

    _messageController.clear();
  }

  void _scrollToBottom() {
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

  String _formatTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString).toLocal();

      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      return '';
    }
  }

  @override
  void dispose() {
    _wsService.disconnect();
    _messageController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.otherUserName,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              _isConnected ? 'Online' : 'Disconnected',
              style: TextStyle(
                color: _isConnected ? Colors.green : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary.withOpacity(0.2),
              backgroundImage: widget.otherUserAvatar != null
                  ? NetworkImage(widget.otherUserAvatar!)
                  : null,
              child: widget.otherUserAvatar == null
                  ? const Icon(Icons.person, color: AppColors.primary)
                  : null,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _messages.isEmpty
                ? Center(
                    child: Text(
                      'No messages yet.\nStart the conversation!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textDark.withOpacity(0.5),
                        fontSize: 14,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];

                      final isSentByMe = message['sender'] == _currentUserId;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: isSentByMe
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (!isSentByMe) ...[
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: AppColors.primary.withOpacity(
                                  0.2,
                                ),
                                backgroundImage:
                                    message['sender_details']['avatar'] != null
                                    ? NetworkImage(
                                        message['sender_details']['avatar'],
                                      )
                                    : null,
                                child:
                                    message['sender_details']['avatar'] == null
                                    ? const Icon(
                                        Icons.person,
                                        size: 16,
                                        color: AppColors.primary,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 8),
                            ],

                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isSentByMe
                                      ? AppColors.primary
                                      : Colors.grey.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      message['content'],
                                      style: TextStyle(
                                        color: isSentByMe
                                            ? Colors.white
                                            : AppColors.textDark,
                                        fontSize: 14,
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      _formatTime(message['created_at']),
                                      style: TextStyle(
                                        color: isSentByMe
                                            ? Colors.white.withOpacity(0.7)
                                            : AppColors.textDark.withOpacity(
                                                0.6,
                                              ),
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: 12 + MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.withOpacity(0.1),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),

                const SizedBox(width: 8),

                GestureDetector(
                  onTap: _isConnected ? _sendMessage : null,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isConnected ? AppColors.primary : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
