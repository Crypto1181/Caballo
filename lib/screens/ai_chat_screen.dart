import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../services/openai_service.dart';
import '../widgets/language_toggle.dart';
import '../utils/translation_helper.dart';
import '../providers/language_provider.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    
    // Add welcome message
    _messages.add(
      ChatMessage(
        text: "Hi! I'm your Caballo AI assistant. I can help you with trading insights, market analysis, portfolio advice, and answer any questions about crypto and stocks. How can I help you today?",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          text: _messageController.text,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isTyping = true;
    });

    final userMessage = _messageController.text;
    _messageController.clear();

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    // Get AI response using OpenAI
    _getAIResponse(userMessage);
  }

  Future<void> _getAIResponse(String userMessage) async {
    try {
      // Build conversation history
      final conversationHistory = _messages.map((msg) {
        return {
          'role': msg.isUser ? 'user' : 'assistant',
          'content': msg.text,
        };
      }).toList();

      // Add system message for context
      conversationHistory.insert(0, {
        'role': 'system',
        'content': 'You are a helpful AI assistant for Caballo, a trading and investment app. '
            'You help users with trading insights, market analysis, portfolio advice, crypto and stock information. '
            'Keep responses concise, friendly, and informative. Focus on practical advice for investors.',
      });

      final response = await OpenAIService.instance.sendMessage(conversationHistory);

      setState(() {
        _isTyping = false;
        _messages.add(
          ChatMessage(
            text: response,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });

      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    } catch (e) {
      setState(() {
        _isTyping = false;
        _messages.add(
          ChatMessage(
            text: "Sorry, I encountered an error: ${e.toString()}",
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.black : Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // AI Avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Consumer<LanguageProvider>(
                          builder: (context, lang, _) {
                            return Text(
                              context.t('ai_assistant'),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            );
                          },
                        ),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Consumer<LanguageProvider>(
                              builder: (context, lang, _) {
                                return Text(
                                  context.t('online'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const LanguageToggle(),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.settings_outlined, color: isDark ? Colors.white : Colors.black),
                    onPressed: () {
                      _showSettingsDialog(context);
                    },
                  ),
                ],
              ),
            ),

            // Suggested prompts (show when no messages)
            if (_messages.length <= 1)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Consumer<LanguageProvider>(
                      builder: (context, lang, _) {
                        return Text(
                          context.t('suggested_prompts'),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Consumer<LanguageProvider>(
                      builder: (context, lang, _) {
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildPromptChip(context.t('prompt_analysis'), isDark),
                            _buildPromptChip(context.t('prompt_market'), isDark),
                            _buildPromptChip(context.t('prompt_portfolio'), isDark),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

            // Messages list
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildMessageBubble(_messages[index], isDark);
                },
              ),
            ),

            // Typing indicator
            if (_isTyping)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[900] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildTypingDot(0),
                          const SizedBox(width: 4),
                          _buildTypingDot(1),
                          const SizedBox(width: 4),
                          _buildTypingDot(2),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 8),

            // Input area
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.black : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Consumer<LanguageProvider>(
                      builder: (context, lang, _) {
                        return TextField(
                          controller: _messageController,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration(
                            hintText: context.t('enter_message'),
                            hintStyle: TextStyle(
                              color: isDark ? Colors.grey[600] : Colors.grey[400],
                            ),
                        filled: true,
                        fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      ),
                      borderRadius: BorderRadius.circular(24),
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
      ),
    );
  }

  Widget _buildPromptChip(String text, bool isDark) {
    return InkWell(
      onTap: () {
        _messageController.text = text;
        _sendMessage();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.isUser
                    ? const Color(0xFF667EEA)
                    : (isDark ? Colors.grey[900] : Colors.grey[100]),
                borderRadius: BorderRadius.circular(16).copyWith(
                  topLeft: message.isUser ? const Radius.circular(16) : Radius.zero,
                  topRight: message.isUser ? Radius.zero : const Radius.circular(16),
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontSize: 15,
                  color: message.isUser
                      ? Colors.white
                      : (isDark ? Colors.white : Colors.black),
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final value = math.sin((_pulseController.value * 2 * math.pi) - (index * math.pi / 3));
        return Container(
          width: 8,
          height: 8,
          margin: EdgeInsets.only(top: value * 3),
          decoration: BoxDecoration(
            color: Colors.grey[600],
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  void _showSettingsDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final apiKeyController = TextEditingController();
    
    // Load existing API key
    OpenAIService.instance.getApiKey().then((key) {
      if (key != null) {
        apiKeyController.text = key;
      }
    });
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        title: Text(
          'OpenAI Settings',
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'API Key',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: apiKeyController,
              decoration: InputDecoration(
                hintText: 'sk-...',
                hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400]),
                filled: true,
                fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              obscureText: true,
            ),
            const SizedBox(height: 8),
            Text(
              'Get your API key from: platform.openai.com',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.grey[600] : Colors.grey[500],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Model',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'GPT-4',
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  ),
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              apiKeyController.dispose();
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final apiKey = apiKeyController.text.trim();
              final navigator = Navigator.of(context, rootNavigator: true);
              final messenger = ScaffoldMessenger.of(context);
              
              if (apiKey.isNotEmpty) {
                await OpenAIService.instance.saveApiKey(apiKey);
                apiKeyController.dispose();
                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('✅ OpenAI API key saved! You can now chat with AI.'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 3),
                  ),
                );
              } else {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid API key'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667EEA),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

