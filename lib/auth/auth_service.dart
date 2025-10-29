import 'dart:async';
import 'dart:convert';

import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';

import 'auth_config.dart';

class AuthService {
  AuthService({required AuthConfig config}) : _config = config;

  AuthConfig _config;
  final FlutterAppAuth _appAuth = const FlutterAppAuth();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  final StreamController<bool> _authStateController =
      StreamController<bool>.broadcast();

  // Getter for config
  AuthConfig get config => _config;

  // Method to update auth config at runtime
  void updateAuthConfig(AuthConfig newConfig) {
    _config = newConfig;
  }

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _idTokenKey = 'id_token';
  static const _accessExpiresAtKey = 'access_expires_at';

  bool _isInitialized = false;
  String? _accessToken;
  String? _refreshToken;
  String? _idToken;
  DateTime? _accessTokenExpiration;
  TokenResponse? _tokenResponse;
  Timer? _refreshTimer;

  void Function(String message, Object error, StackTrace stackTrace)? onError;

  bool get isInitialized => _isInitialized;
  String? get accessToken => _accessToken;
  TokenResponse? get tokenResponse => _tokenResponse;
  DateTime? get accessTokenExpiration => _accessTokenExpiration;
  Stream<bool> get authenticationStream => _authStateController.stream;

  Future<bool> get isLoggedIn async => _accessToken?.isNotEmpty == true;

  Map<String, dynamic>? get idClaims =>
      _idToken == null ? null : Jwt.parseJwt(_idToken!);

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }
    try {
      _accessToken = await _secureStorage.read(key: _accessTokenKey);
      _refreshToken = await _secureStorage.read(key: _refreshTokenKey);
      _idToken = await _secureStorage.read(key: _idTokenKey);

      final expiresAt = await _secureStorage.read(key: _accessExpiresAtKey);
      if (expiresAt != null) {
        final epochSeconds = int.tryParse(expiresAt);
        if (epochSeconds != null) {
          _accessTokenExpiration = DateTime.fromMillisecondsSinceEpoch(
            epochSeconds * 1000,
          );
        }
      }

      if (_accessToken != null) {
        final isTokenExpired =
            _accessTokenExpiration != null &&
            !_isAccessTokenValid(_accessTokenExpiration!);
        if (isTokenExpired && _refreshToken != null) {
          try {
            await refreshTokens();
            _isInitialized = true;
            return;
          } catch (error, stackTrace) {
            _notifyError(
              'Failed to refresh tokens during initialization',
              error,
              stackTrace,
            );
            await _clearPersistedState();
          }
        } else {
          _scheduleRefresh();
          _authStateController.add(true);
        }
      }
      _isInitialized = true;
    } catch (error, stackTrace) {
      _notifyError('Initialization failed', error, stackTrace);
      _isInitialized = false;
      rethrow;
    }
  }

  Future<bool> login() async {
    try {
      final response = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          config.clientId,
          config.redirectUri,
          discoveryUrl: config.discoveryUrl,
          scopes: config.scopes,
        ),
      );

      if (response == null || response.accessToken == null) {
        return false;
      }

      await _persistTokenResponse(response);
      _authStateController.add(true);
      return true;
    } catch (error, stackTrace) {
      _notifyError('Authorization failed', error, stackTrace);
      return false;
    }
  }

  Future<void> refreshTokens() async {
    if (_refreshToken == null) {
      throw StateError('No refresh token available');
    }
    try {
      final response = await _appAuth.token(
        TokenRequest(
          config.clientId,
          config.redirectUri,
          discoveryUrl: config.discoveryUrl,
          refreshToken: _refreshToken,
          scopes: config.scopes,
        ),
      );

      if (response.accessToken == null) {
        throw StateError('Token refresh returned an empty access token');
      }

      await _persistTokenResponse(response);
      _authStateController.add(true);
    } catch (error, stackTrace) {
      _notifyError('Token refresh failed', error, stackTrace);
      rethrow;
    }
  }

  Future<bool> logout() async {
    try {
      if (_idToken != null) {
        await _appAuth.endSession(
          EndSessionRequest(
            idTokenHint: _idToken,
            postLogoutRedirectUrl: config.postLogoutRedirectUri,
            discoveryUrl: config.discoveryUrl,
          ),
        );
      }
    } catch (error, stackTrace) {
      _notifyError('Failed to revoke Keycloak session', error, stackTrace);
    } finally {
      await _clearPersistedState();
      _authStateController.add(false);
    }
    return true;
  }

  Future<Map<String, dynamic>?> getUserInfo({
    bool retryOnUnauthorized = true,
  }) async {
    if (_accessToken == null) {
      return null;
    }
    final response = await http.get(
      Uri.parse(config.userInfoEndpoint),
      headers: {'Authorization': 'Bearer $_accessToken'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    if (response.statusCode == 401 &&
        retryOnUnauthorized &&
        _refreshToken != null) {
      await refreshTokens();
      return getUserInfo(retryOnUnauthorized: false);
    }

    throw Exception(
      'Failed to fetch user info: ${response.statusCode} ${response.reasonPhrase}',
    );
  }

  bool _isAccessTokenValid(DateTime expiration) {
    final now = DateTime.now();
    // Refresh one minute before expiration to be safe.
    return now.isBefore(expiration.subtract(const Duration(minutes: 1)));
  }

  Future<void> _persistTokenResponse(TokenResponse response) async {
    _tokenResponse = response;
    _accessToken = response.accessToken;
    _refreshToken = response.refreshToken ?? _refreshToken;
    _idToken = response.idToken ?? _idToken;
    _accessTokenExpiration = response.accessTokenExpirationDateTime;

    await _secureStorage.write(key: _accessTokenKey, value: _accessToken);
    if (_refreshToken != null) {
      await _secureStorage.write(key: _refreshTokenKey, value: _refreshToken);
    }
    if (_idToken != null) {
      await _secureStorage.write(key: _idTokenKey, value: _idToken);
    }
    if (_accessTokenExpiration != null) {
      final epoch = (_accessTokenExpiration!.millisecondsSinceEpoch ~/ 1000)
          .toString();
      await _secureStorage.write(key: _accessExpiresAtKey, value: epoch);
    }

    _scheduleRefresh();
  }

  void _scheduleRefresh() {
    _refreshTimer?.cancel();
    if (_accessTokenExpiration == null) {
      return;
    }
    final secondsUntilExpiry = _accessTokenExpiration!
        .difference(DateTime.now())
        .inSeconds;
    final refreshLead = secondsUntilExpiry - 60;
    int scheduledInSeconds;
    if (secondsUntilExpiry <= 0) {
      scheduledInSeconds = 1;
    } else if (refreshLead <= 0) {
      scheduledInSeconds = 5;
    } else {
      scheduledInSeconds = refreshLead;
      if (scheduledInSeconds < 5) {
        scheduledInSeconds = 5;
      }
      final maxSeconds = 3600 * 12;
      if (scheduledInSeconds > maxSeconds) {
        scheduledInSeconds = maxSeconds;
      }
    }
    _refreshTimer = Timer(Duration(seconds: scheduledInSeconds), () async {
      try {
        await refreshTokens();
      } catch (error, stackTrace) {
        _notifyError('Scheduled refresh failed', error, stackTrace);
      }
    });
  }

  Future<void> _clearPersistedState() async {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    _accessToken = null;
    _refreshToken = null;
    _idToken = null;
    _tokenResponse = null;
    _accessTokenExpiration = null;

    await Future.wait([
      _secureStorage.delete(key: _accessTokenKey),
      _secureStorage.delete(key: _refreshTokenKey),
      _secureStorage.delete(key: _idTokenKey),
      _secureStorage.delete(key: _accessExpiresAtKey),
    ]);
  }

  void _notifyError(String message, Object error, StackTrace stackTrace) {
    final handler = onError;
    if (handler != null) {
      handler(message, error, stackTrace);
    }
  }
}
