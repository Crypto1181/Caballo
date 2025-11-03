import 'package:dart_openai/dart_openai.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OpenAIService {
  static OpenAIService? _instance;
  static OpenAIService get instance => _instance ??= OpenAIService._();
  
  OpenAIService._();

  bool _isInitialized = false;

  /// Initialize OpenAI with API key
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('openai_api_key');
    
    if (apiKey != null && apiKey.isNotEmpty) {
      OpenAI.apiKey = apiKey;
      _isInitialized = true;
    }
  }

  /// Save API key to local storage
  Future<void> saveApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('openai_api_key', apiKey);
    OpenAI.apiKey = apiKey;
    _isInitialized = true;
  }

  /// Get stored API key
  Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('openai_api_key');
  }

  /// Check if API key is set
  Future<bool> hasApiKey() async {
    final apiKey = await getApiKey();
    return apiKey != null && apiKey.isNotEmpty;
  }

  /// Send a chat message and get response
  Future<String> sendMessage(List<Map<String, String>> messages) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (!_isInitialized) {
      return "Please configure your OpenAI API key in settings.";
    }

    try {
      final chatCompletion = await OpenAI.instance.chat.create(
        model: "gpt-4",
        messages: messages.map((msg) {
          OpenAIChatMessageRole role;
          switch (msg['role']) {
            case 'user':
              role = OpenAIChatMessageRole.user;
              break;
            case 'system':
              role = OpenAIChatMessageRole.system;
              break;
            case 'assistant':
              role = OpenAIChatMessageRole.assistant;
              break;
            default:
              role = OpenAIChatMessageRole.user;
          }
          
          return OpenAIChatCompletionChoiceMessageModel(
            role: role,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                msg['content'] ?? '',
              ),
            ],
          );
        }).toList(),
        temperature: 0.7,
        maxTokens: 500,
      );

      return chatCompletion.choices.first.message.content?.first.text ?? 
        "Sorry, I couldn't generate a response.";
    } catch (e) {
      if (e.toString().contains('API key')) {
        return "Invalid API key. Please check your OpenAI API key in settings.";
      }
      return "Error: ${e.toString()}";
    }
  }

  /// Get a streaming response (for typing effect)
  Stream<String> sendMessageStream(List<Map<String, String>> messages) async* {
    if (!_isInitialized) {
      await initialize();
    }

    if (!_isInitialized) {
      yield "Please configure your OpenAI API key in settings.";
      return;
    }

    try {
      final stream = OpenAI.instance.chat.createStream(
        model: "gpt-4",
        messages: messages.map((msg) {
          OpenAIChatMessageRole role;
          switch (msg['role']) {
            case 'user':
              role = OpenAIChatMessageRole.user;
              break;
            case 'system':
              role = OpenAIChatMessageRole.system;
              break;
            case 'assistant':
              role = OpenAIChatMessageRole.assistant;
              break;
            default:
              role = OpenAIChatMessageRole.user;
          }
          
          return OpenAIChatCompletionChoiceMessageModel(
            role: role,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                msg['content'] ?? '',
              ),
            ],
          );
        }).toList(),
        temperature: 0.7,
        maxTokens: 500,
      );

      await for (final event in stream) {
        try {
          final content = event.choices.first.delta.content;
          if (content != null && content.isNotEmpty) {
            for (final item in content) {
              if (item is OpenAIChatCompletionChoiceMessageContentItemModel) {
                final itemText = item.text;
                if (itemText != null && itemText.isNotEmpty) {
                  yield itemText;
                }
              }
            }
          }
        } catch (_) {
          // Skip malformed delta
        }
      }
    } catch (e) {
      if (e.toString().contains('API key')) {
        yield "Invalid API key. Please check your OpenAI API key in settings.";
      } else {
        yield "Error: ${e.toString()}";
      }
    }
  }
}

