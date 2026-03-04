import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewPromptService {
  ReviewPromptService(this._prefs, {InAppReview? review})
    : _review = review ?? InAppReview.instance;

  static const _launchCountKey = 'review_launch_count';
  static const _lastPromptAtKey = 'review_last_prompt_at';
  static const _lastPromptLaunchCountKey = 'review_last_prompt_launch_count';

  // First prompt after a meaningful number of sessions.
  static const _minLaunchesBeforeFirstPrompt = 6;

  // Then prompt occasionally, not on every launch.
  static const _minLaunchesBetweenPrompts = 10;
  static const _cooldownDays = 45;

  final SharedPreferences _prefs;
  final InAppReview _review;

  Future<void> registerLaunchAndMaybePrompt() async {
    final launches = (_prefs.getInt(_launchCountKey) ?? 0) + 1;
    await _prefs.setInt(_launchCountKey, launches);

    final reviewAvailable = await _review.isAvailable();
    if (!reviewAvailable) return;

    if (!_isEligibleByLaunchCount(launches)) return;
    if (!_isEligibleByTime()) return;

    await _review.requestReview();

    final now = DateTime.now().toUtc();
    await _prefs.setString(_lastPromptAtKey, now.toIso8601String());
    await _prefs.setInt(_lastPromptLaunchCountKey, launches);
    debugPrint('[ReviewPrompt] requestReview launched at session=$launches');
  }

  bool _isEligibleByLaunchCount(int launches) {
    final lastPromptLaunch = _prefs.getInt(_lastPromptLaunchCountKey);
    if (lastPromptLaunch == null) {
      return launches >= _minLaunchesBeforeFirstPrompt;
    }
    return launches - lastPromptLaunch >= _minLaunchesBetweenPrompts;
  }

  bool _isEligibleByTime() {
    final iso = _prefs.getString(_lastPromptAtKey);
    if (iso == null || iso.isEmpty) return true;

    final lastPromptAt = DateTime.tryParse(iso)?.toUtc();
    if (lastPromptAt == null) return true;

    final daysSince = DateTime.now().toUtc().difference(lastPromptAt).inDays;
    return daysSince >= _cooldownDays;
  }
}
