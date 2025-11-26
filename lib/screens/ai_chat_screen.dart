import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../services/grok_service.dart';
import '../widgets/theme_language_controls.dart';
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
  bool _isLimitReached = false;
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
    
    // Check limit status on load
    _checkLimitStatus();
  }
  
  Future<void> _checkLimitStatus() async {
    final rateLimitStatus = await GrokService.instance.checkRateLimit();
    if (mounted) {
      setState(() {
        _isLimitReached = !rateLimitStatus.canProceed;
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    if (_isLimitReached) return; // Don't send if limit is reached

    // Check limit before sending
    final rateLimitStatus = await GrokService.instance.checkRateLimit();
    if (!rateLimitStatus.canProceed) {
      setState(() {
        _isLimitReached = true;
      });
      // Show message will be handled in _getAIResponse
    }

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

    // Scroll to bottom after layout is updated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // Get AI response using Grok API
    _getAIResponse(userMessage);
  }

  Future<void> _getAIResponse(String userMessage) async {
    try {
      // Check rate limit before making request
      final rateLimitStatus = await GrokService.instance.checkRateLimit();
      
      // If limit is reached, don't make the request
      if (!rateLimitStatus.canProceed) {
        setState(() {
          _isTyping = false;
          _isLimitReached = true;
          _messages.add(
            ChatMessage(
              text: "⚠️ API limit reached. ${rateLimitStatus.reason}\n\n"
                  "You've used ${rateLimitStatus.remainingRequests == 0 ? 'all' : 'most of'} your monthly API quota. "
                  "Limits reset automatically at the start of each month.\n\n"
                  "You can check your usage in Settings.",
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        });
        
        // Scroll to bottom
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
        return;
      }
      
      // Reset limit flag if we can proceed
      if (_isLimitReached) {
        setState(() {
          _isLimitReached = false;
        });
      }
      
      // Show warning if approaching limit
      if (rateLimitStatus.isWarning) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '⚠️ ${rateLimitStatus.reason}\n'
                'Remaining: ${rateLimitStatus.remainingRequests} requests, '
                '${rateLimitStatus.remainingTokens} tokens',
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }

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

      final response = await GrokService.instance.sendMessage(conversationHistory);

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

      // Scroll to bottom after layout is updated
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
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
                  const ThemeLanguageControls(),
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

            // Messages list
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.only(
                  top: _messages.length <= 1 ? 0 : 16,
                  left: 16,
                  right: 16,
                  bottom: 16,
                ),
                itemCount: (_messages.length <= 1 
                    ? 1 + _messages.length  // 1 for suggested prompts + messages
                    : _messages.length) + (_isTyping ? 1 : 0), // +1 for typing indicator
                itemBuilder: (context, index) {
                  final totalItems = _messages.length <= 1 
                      ? 1 + _messages.length 
                      : _messages.length;
                  
                  // Show typing indicator as last item
                  if (_isTyping && index == totalItems) {
                    return _buildTypingBubble(isDark);
                  }
                  
                  // Show suggested prompts as first item when there's only welcome message
                  if (_messages.length <= 1 && index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
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
                    );
                  }
                  
                  // Show messages
                  final messageIndex = _messages.length <= 1 ? index - 1 : index;
                  return _buildMessageBubble(_messages[messageIndex], isDark);
                },
              ),
            ),

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
                          enabled: !_isLimitReached,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration(
                            hintText: _isLimitReached 
                                ? 'API limit reached' 
                                : context.t('enter_message'),
                            hintStyle: TextStyle(
                              color: _isLimitReached
                                  ? Colors.red.withValues(alpha: 0.7)
                                  : (isDark ? Colors.grey[600] : Colors.grey[400]),
                            ),
                        filled: true,
                        fillColor: _isLimitReached
                            ? (isDark ? Colors.grey[800] : Colors.grey[200])
                            : (isDark ? Colors.grey[900] : Colors.grey[100]),
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
                      gradient: _isLimitReached
                          ? null
                          : const LinearGradient(
                              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                            ),
                      color: _isLimitReached ? Colors.grey : null,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.send_rounded, 
                        color: _isLimitReached ? Colors.grey[600] : Colors.white,
                      ),
                      onPressed: _isLimitReached ? null : _sendMessage,
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

  Widget _buildTypingBubble(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.grey[100],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
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
          margin: EdgeInsets.only(top: value > 0 ? value * 3 : 0),
          decoration: BoxDecoration(
            color: Colors.grey[600],
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  void _showSettingsDialog(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Get usage stats
    final usageStats = await GrokService.instance.getUsageStats();
    
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        title: Text(
          'Grok API Settings',
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Model info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Model',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Grok 3 Mini',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Icon(Icons.check_circle, color: Colors.green, size: 24),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Usage statistics
              Text(
                'Monthly Usage',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              
              // Requests
              _buildUsageItem(
                isDark,
                'Requests',
                '${usageStats['requestCount']} / ${usageStats['maxRequests']}',
                usageStats['requestCount'] as int,
                usageStats['maxRequests'] as int,
                Icons.send,
              ),
              const SizedBox(height: 8),
              
              // Tokens
              _buildUsageItem(
                isDark,
                'Tokens',
                '${usageStats['tokenCount']} / ${usageStats['maxTokens']}',
                usageStats['tokenCount'] as int,
                usageStats['maxTokens'] as int,
                Icons.token,
              ),
              const SizedBox(height: 8),
              
              // Cost
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.attach_money, 
                      color: isDark ? Colors.grey[400] : Colors.grey[600], 
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Total Cost: \$${((usageStats['totalCost'] as double).toStringAsFixed(3))}',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, 
                      color: Colors.blue, 
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Limits reset monthly. Approaching limits will show warnings.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.blue[200] : Colors.blue[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // Reset counters (for testing/admin)
              await GrokService.instance.resetUsageCounters();
              await _checkLimitStatus();
              if (context.mounted) {
                Navigator.of(context, rootNavigator: true).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Usage counters reset'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: Text(
              'Reset Counters',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 12,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Text(
              'Close',
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageItem(
    bool isDark,
    String label,
    String text,
    int used,
    int max,
    IconData icon,
  ) {
    final percentage = used / max;
    final isWarning = percentage >= 0.9;
    final isDanger = percentage >= 1.0;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: isDanger 
            ? Border.all(color: Colors.red, width: 2)
            : isWarning 
                ? Border.all(color: Colors.orange, width: 1)
                : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, 
                color: isDanger 
                    ? Colors.red 
                    : isWarning 
                        ? Colors.orange 
                        : (isDark ? Colors.grey[400] : Colors.grey[600]), 
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const Spacer(),
              Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDanger 
                      ? Colors.red 
                      : isWarning 
                          ? Colors.orange 
                          : (isDark ? Colors.white : Colors.black),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage.clamp(0.0, 1.0),
              backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                isDanger 
                    ? Colors.red 
                    : isWarning 
                        ? Colors.orange 
                        : Colors.green,
              ),
              minHeight: 6,
            ),
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

