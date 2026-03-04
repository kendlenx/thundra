import 'dart:async';
import 'dart:convert';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class GrowthService {
  GrowthService(this._prefs, {AppLinks? appLinks})
    : _appLinks = appLinks ?? AppLinks();

  static const _referralCodeKey = 'growth_referral_code';
  static const _lastInviteReferrerKey = 'growth_last_invite_referrer';
  static const _lastInviteOpenedAtKey = 'growth_last_invite_opened_at';

  final SharedPreferences _prefs;
  final AppLinks _appLinks;
  final Uuid _uuid = const Uuid();

  StreamSubscription<Uri>? _uriSubscription;
  bool _started = false;

  Future<void> start() async {
    if (_started) return;
    _started = true;

    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) {
        await _handleIncomingUri(initial, source: 'initial');
      }
    } catch (_) {
      // Keep startup resilient even if initial deep link read fails.
    }

    _uriSubscription = _appLinks.uriLinkStream.listen(
      (uri) => unawaited(_handleIncomingUri(uri, source: 'stream')),
      onError: (_) {
        // No-op: deep links are optional for core app usage.
      },
    );
  }

  void dispose() {
    _uriSubscription?.cancel();
  }

  Future<String> getOrCreateReferralCode() async {
    final existing = _prefs.getString(_referralCodeKey);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final created = _uuid
        .v4()
        .replaceAll('-', '')
        .substring(0, 10)
        .toUpperCase();
    await _prefs.setString(_referralCodeKey, created);
    return created;
  }

  Future<Uri> buildReferralLink({required String source}) async {
    final code = await getOrCreateReferralCode();
    return Uri.https('thunda.kendlenx.com', '/invite/', {
      'ref': code,
      'src': source,
    });
  }

  Future<void> trackEvent(
    String name, {
    Map<String, Object?> props = const {},
  }) async {
    final sanitizedName = name.trim().toLowerCase().replaceAll(' ', '_');
    if (sanitizedName.isEmpty) return;

    final countKey = 'growth_event_${sanitizedName}_count';
    final lastAtKey = 'growth_event_${sanitizedName}_last_at';
    final propsKey = 'growth_event_${sanitizedName}_last_props';

    final count = (_prefs.getInt(countKey) ?? 0) + 1;
    await _prefs.setInt(countKey, count);
    await _prefs.setString(lastAtKey, DateTime.now().toUtc().toIso8601String());

    final serializedProps = <String, String>{};
    props.forEach((key, value) {
      if (value == null) return;
      serializedProps[key] = value.toString();
    });
    if (serializedProps.isNotEmpty) {
      await _prefs.setString(propsKey, jsonEncode(serializedProps));
    }

    debugPrint(
      '[Growth] $sanitizedName ${serializedProps.isEmpty ? '' : serializedProps}',
    );
  }

  Future<void> trackOnboardingCompleted({
    required String source,
    required bool locationGranted,
    required bool notificationsGranted,
  }) async {
    await trackEvent(
      'onboarding_completed',
      props: {
        'source': source,
        'location_granted': locationGranted,
        'notifications_granted': notificationsGranted,
      },
    );
  }

  Future<void> _handleIncomingUri(Uri uri, {required String source}) async {
    if (!_isInviteUri(uri)) return;

    final code = uri.queryParameters['ref']?.trim() ?? '';
    if (code.isEmpty) return;

    await _prefs.setString(_lastInviteReferrerKey, code);
    await _prefs.setString(
      _lastInviteOpenedAtKey,
      DateTime.now().toUtc().toIso8601String(),
    );

    await trackEvent('invite_opened', props: {'source': source, 'ref': code});
  }

  bool _isInviteUri(Uri uri) {
    if (uri.scheme == 'thundra' && uri.host == 'invite') {
      return true;
    }

    if ((uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host == 'thunda.kendlenx.com' &&
        uri.path.startsWith('/invite')) {
      return true;
    }

    return false;
  }
}
