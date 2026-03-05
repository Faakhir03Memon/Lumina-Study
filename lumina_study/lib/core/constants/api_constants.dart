class ApiConstants {
  // Groq API
  static const String groqBaseUrl = 'https://api.groq.com/openai/v1';
  static const String groqChatEndpoint = '$groqBaseUrl/chat/completions';

  // Groq Models
  static const String llama3Model = 'llama-3.3-70b-versatile';
  static const String llama3FastModel = 'llama-3.1-8b-instant';
  static const String mixtralModel = 'mixtral-8x7b-32768';

  // Gemini API
  static const String geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta';
  static const String geminiModel = 'gemini-1.5-flash';
  static const String geminiProModel = 'gemini-1.5-pro';

  // Pollinations (Free - no key needed)
  static const String pollinationsImageUrl = 'https://image.pollinations.ai/prompt/';

  // Default settings
  static const int defaultMaxTokens = 1024;
  static const int pdfMaxTokens = 2048;
  static const int freeUserDailyLimit = 20;
}

class AppStrings {
  static const String appName = 'Lumina Study';
  static const String tagline = 'Your AI Study Companion';
  static const String groqKeyPref = 'groq_api_key';
  static const String geminiKeyPref = 'gemini_api_key';
  static const String onboardingDonePref = 'onboarding_done';
  static const String dailyCountPref = 'daily_msg_count';
  static const String dailyDatePref = 'daily_msg_date';
  static const String streakPref = 'study_streak';
  static const String lastStudyDatePref = 'last_study_date';
  static const String selectedModelPref = 'selected_model';
}
