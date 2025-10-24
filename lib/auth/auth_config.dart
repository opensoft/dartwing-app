class AuthConfig {
  const AuthConfig({
    required this.issuer,
    required this.clientId,
    required this.redirectUri,
    required this.postLogoutRedirectUri,
    required this.scopes,
  });

  final String issuer;
  final String clientId;
  final String redirectUri;
  final String postLogoutRedirectUri;
  final List<String> scopes;

  String get discoveryUrl => '$issuer/.well-known/openid-configuration';
  String get userInfoEndpoint =>
      '$issuer/protocol/openid-connect/userinfo'; // Keycloak standard

  AuthConfig copyWith({
    String? issuer,
    String? clientId,
    String? redirectUri,
    String? postLogoutRedirectUri,
    List<String>? scopes,
  }) {
    return AuthConfig(
      issuer: issuer ?? this.issuer,
      clientId: clientId ?? this.clientId,
      redirectUri: redirectUri ?? this.redirectUri,
      postLogoutRedirectUri: postLogoutRedirectUri ?? this.postLogoutRedirectUri,
      scopes: scopes ?? this.scopes,
    );
  }
}

const keycloakIssuer = 'https://qa.keycloak.tech-corps.com/realms/DartWing';
const keycloakClientId = 'dartwingmobile';
const keycloakRedirectUri = 'com.opensoft.dartwing://login-callback';
const keycloakPostLogoutRedirectUri = keycloakRedirectUri;
const keycloakDefaultScopes = <String>[
  'openid',
  'profile',
  'email',
  'offline_access',
];

const keycloakAuthConfig = AuthConfig(
  issuer: keycloakIssuer,
  clientId: keycloakClientId,
  redirectUri: keycloakRedirectUri,
  postLogoutRedirectUri: keycloakPostLogoutRedirectUri,
  scopes: keycloakDefaultScopes,
);
