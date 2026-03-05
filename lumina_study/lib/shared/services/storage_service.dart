import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lumina_study/core/constants/api_constants.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── API Keys ───────────────────────────────────────────────────────────────
  static String get groqApiKey => _prefs?.getString(AppStrings.groqKeyPref) ?? '';
  static String get geminiApiKey => _prefs?.getString(AppStrings.geminiKeyPref) ?? '';

  static Future<void> saveGroqKey(String key) async =>
      await _prefs?.setString(AppStrings.groqKeyPref, key);

  static Future<void> saveGeminiKey(String key) async =>
      await _prefs?.setString(AppStrings.geminiKeyPref, key);

  // ── Onboarding ─────────────────────────────────────────────────────────────
  static bool get onboardingDone =>
      _prefs?.getBool(AppStrings.onboardingDonePref) ?? false;

  static Future<void> setOnboardingDone() async =>
      await _prefs?.setBool(AppStrings.onboardingDonePref, true);

  // ── Daily Usage Limit ──────────────────────────────────────────────────────
  static int get dailyMessageCount {
    final today = _todayString();
    final savedDate = _prefs?.getString(AppStrings.dailyDatePref) ?? '';
    if (savedDate != today) {
      _prefs?.setString(AppStrings.dailyDatePref, today);
      _prefs?.setInt(AppStrings.dailyCountPref, 0);
      return 0;
    }
    return _prefs?.getInt(AppStrings.dailyCountPref) ?? 0;
  }

  static Future<void> incrementDailyCount() async {
    final today = _todayString();
    await _prefs?.setString(AppStrings.dailyDatePref, today);
    final current = dailyMessageCount;
    await _prefs?.setInt(AppStrings.dailyCountPref, current + 1);
  }

  static bool get isLimitReached =>
      groqApiKey.isEmpty && dailyMessageCount >= ApiConstants.freeUserDailyLimit;

  // ── Study Streak ───────────────────────────────────────────────────────────
  static int get studyStreak => _prefs?.getInt(AppStrings.streakPref) ?? 0;

  static Future<void> updateStreak() async {
    final today = _todayString();
    final last = _prefs?.getString(AppStrings.lastStudyDatePref) ?? '';
    if (last == today) return;

    final yesterday = _yesterdayString();
    final streak = last == yesterday ? studyStreak + 1 : 1;

    await _prefs?.setInt(AppStrings.streakPref, streak);
    await _prefs?.setString(AppStrings.lastStudyDatePref, today);
  }

  // ── Chat History (simple, local) ───────────────────────────────────────────
  static List<Map<String, String>> getChatHistory(String sessionId) {
    final raw = _prefs?.getString('chat_$sessionId') ?? '[]';
    final list = jsonDecode(raw) as List;
    return list.map((e) => Map<String, String>.from(e as Map)).toList();
  }

  static Future<void> saveChatHistory(
      String sessionId, List<Map<String, String>> messages) async {
    await _prefs?.setString('chat_$sessionId', jsonEncode(messages));
  }

  // ── Model preference ───────────────────────────────────────────────────────
  static String get selectedModel =>
      _prefs?.getString(AppStrings.selectedModelPref) ?? 'llama3';

  static Future<void> saveSelectedModel(String model) async =>
      await _prefs?.setString(AppStrings.selectedModelPref, model);

  // ── Helpers ─────────────────────────────────────────────────────────────────
  static String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  static String _yesterdayString() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return '${yesterday.year}-${yesterday.month}-${yesterday.day}';
  }
}
