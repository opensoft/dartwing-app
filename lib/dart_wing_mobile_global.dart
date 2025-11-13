import 'auth/auth_config.dart';
import 'auth/auth_service.dart';

class DartWingAppGlobals {
  static final AuthService authService = AuthService(
    config: keycloakAuthConfig,
  );
}
