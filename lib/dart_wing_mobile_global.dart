import 'package:keycloak_wrapper/keycloak_wrapper.dart';

class DartWingAppGlobals {
  static var keycloakWrapper = KeycloakWrapper(
    config: KeycloakConfig(
      bundleIdentifier: 'com.opensoft.dartwing',
      clientId: 'dartwingmobile',
      frontendUrl: 'https://qa.keycloak.tech-corps.com/',
      realm: 'DartWing',
    ),
  );
}
