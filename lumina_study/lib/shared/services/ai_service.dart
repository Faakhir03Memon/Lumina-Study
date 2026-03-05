import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lumina_study/core/constants/api_constants.dart';

enum AiModel { llama3, llama3Fast, geminiFlash, geminiPro }

class ChatMessage {
  final String role; // 'user' or 'assistant' or 'system'
  final String content;

  const ChatMessage({required this.role, required this.content});

  Map<String, dynamic> toGroqJson() => {'role': role, 'content': content};
}

class AiService {
  final String groqApiKey;
  final String geminiApiKey;

  AiService({required this.groqApiKey, required this.geminiApiKey});

  String _modelName(AiModel model) {
    switch (model) {
      case AiModel.llama3:
        return ApiConstants.llama3Model;
      case AiModel.llama3Fast:
        return ApiConstants.llama3FastModel;
      case AiModel.geminiFlash:
        return ApiConstants.geminiModel;
      case AiModel.geminiPro:
        return ApiConstants.geminiProModel;
    }
  }

  // ── Groq Chat ─────────────────────────────────────────────────────────────
  Future<String> sendGroqMessage({
    required List<ChatMessage> messages,
    AiModel model = AiModel.llama3,
    int maxTokens = ApiConstants.defaultMaxTokens,
  }) async {
    if (groqApiKey.isEmpty) {
      return '⚠️ Groq API key not set. Please go to **Settings** and enter your free Groq API key from [groq.com](https://groq.com).';
    }

    final response = await http.post(
      Uri.parse(ApiConstants.groqChatEndpoint),
      headers: {
        'Authorization': 'Bearer $groqApiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': _modelName(model),
        'messages': messages.map((m) => m.toGroqJson()).toList(),
        'max_tokens': maxTokens,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'] as String;
    } else {
      final error = jsonDecode(response.body);
      throw Exception('Groq error: ${error['error']?['message'] ?? 'Unknown error'}');
    }
  }

  // ── Gemini Chat ───────────────────────────────────────────────────────────
  Future<String> sendGeminiMessage({
    required String prompt,
    String model = ApiConstants.geminiModel,
    int maxTokens = ApiConstants.defaultMaxTokens,
  }) async {
    if (geminiApiKey.isEmpty) {
      return '⚠️ Gemini API key not set. Please go to **Settings** and enter your free Gemini API key from [aistudio.google.com](https://aistudio.google.com).';
    }

    final url =
        '${ApiConstants.geminiBaseUrl}/models/$model:generateContent?key=$geminiApiKey';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'maxOutputTokens': maxTokens,
          'temperature': 0.7,
        },
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'] as String;
    } else {
      final error = jsonDecode(response.body);
      throw Exception('Gemini error: ${error['error']?['message'] ?? 'Unknown error'}');
    }
  }

  // ── Smart Router ──────────────────────────────────────────────────────────
  Future<String> smartChat({
    required List<ChatMessage> messages,
    required String taskType, // 'chat', 'coding', 'pdf', 'quiz'
  }) async {
    // Route to best model per task
    switch (taskType) {
      case 'pdf':
      case 'long':
        // Use Gemini for long documents
        final fullPrompt = messages.map((m) => '${m.role}: ${m.content}').join('\n');
        return sendGeminiMessage(
          prompt: fullPrompt,
          maxTokens: ApiConstants.pdfMaxTokens,
        );
      case 'coding':
        return sendGroqMessage(
          messages: messages,
          model: AiModel.llama3,
          maxTokens: 2048,
        );
      default:
        return sendGroqMessage(messages: messages);
    }
  }

  // ── Pollinations Image (Free, no key) ─────────────────────────────────────
  String getPollinationsImageUrl(String prompt, {int width = 512, int height = 512}) {
    final encoded = Uri.encodeComponent(prompt);
    return '${ApiConstants.pollinationsImageUrl}$encoded?width=$width&height=$height&nologo=true&seed=${DateTime.now().millisecondsSinceEpoch}';
  }
}
