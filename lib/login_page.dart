import 'dart:async';
import 'dart:io';

import 'package:dart_wing_mobile/dart_wing_apps_routers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:upgrader/upgrader.dart';

import 'dart_wing/core/custom_exceptions.dart';
import 'dart_wing/core/globals.dart';
import 'dart_wing/core/gateway_manager.dart';
import 'dart_wing/core/data/gateway_config.dart';
import 'dart_wing/gui/notification.dart';
import 'dart_wing/gui/widgets/base_scaffold.dart';
import 'dart_wing/network/dart_wing/data/user.dart';
import 'dart_wing/network/network_clients.dart';
import 'dart_wing/network/paper_trail.dart';
import 'dart_wing_mobile_global.dart';

// Gateway preset enum
enum GatewayPreset {
  production,
  qa,
  local,
  custom,
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with WidgetsBindingObserver {
  bool _loadingOverlayEnabled = false;
  bool _hasLoadedSession = false;
  StreamSubscription<bool>? _authSubscription;
  bool _isUpdatingSession = false;

  // Gateway selection state
  List<GatewayConfig> _availableGateways = [];
  GatewayConfig? _selectedKeycloakGateway;
  GatewayConfig? _selectedDartWingGateway;
  GatewayConfig? _selectedHealthcareGateway;
  final bool _isDebugMode = !bool.fromEnvironment('dart.vm.product');
  GatewayPreset _selectedPreset = GatewayPreset.local;

  // Gateway availability
  bool _isProductionAvailable = false;
  bool _isQAAvailable = false;
  bool _isLocalAvailable = false;

  Future<bool> _logout() {
    if (kIsWeb) {
      return Future.value(false); // TODO: ADDWEB
    }
    _hasLoadedSession = false;
    NetworkClients.dartWingRestClient.token = "";
    NetworkClients.frappeRestClient.token = "";
    return DartWingAppGlobals.authService.logout();
  }

  Future<bool> _login() async {
    if (kIsWeb) {
      return false; // TODO: ADDWEB
    }

    // Apply selected gateways before login (debug mode only)
    if (_isDebugMode && _selectedKeycloakGateway != null &&
        _selectedDartWingGateway != null && _selectedHealthcareGateway != null) {

      // Update auth service with selected Keycloak gateway
      DartWingAppGlobals.authService.updateAuthConfig(
        DartWingAppGlobals.authService.config.copyWith(
          issuer: _selectedKeycloakGateway!.keycloakUrl,
        ),
      );

      // Create a composite gateway config combining all selections
      final compositeGateway = GatewayConfig(
        name: 'Custom',
        keycloakUrl: _selectedKeycloakGateway!.keycloakUrl,
        dartWingUrl: _selectedDartWingGateway!.dartWingUrl,
        healthcareUrl: _selectedHealthcareGateway!.healthcareUrl,
        enabled: true,
      );

      // Update network clients with composite gateway
      await GatewayManager.initialize();
      GatewayManager.setSelectedGateway(compositeGateway);

      // Reinitialize NetworkClients with selected gateway URLs
      await NetworkClients.init(token: DartWingAppGlobals.authService.accessToken);

      PaperTrailClient.sendInfoMessageToPaperTrail(
        'Login using gateways: Keycloak=${_selectedKeycloakGateway!.name}, '
        'DartWing=${_selectedDartWingGateway!.name}, '
        'Healthcare=${_selectedHealthcareGateway!.name}'
      );
    }

    setState(() {
      _loadingOverlayEnabled = true;
    });
    _hasLoadedSession = false;
    final success = await DartWingAppGlobals.authService.login();
    if (!success && mounted) {
      setState(() {
        _loadingOverlayEnabled = false;
      });
    }
    return success;
  }

  Future<bool> _goToHomePage() {
    return Navigator.of(context)
        .pushNamed(DartWingAppsRouters.homePage, arguments: "")
        .then((value) {
          return _logout();
        })
        .then((_) {
          setState(() {
            _loadingOverlayEnabled = false;
          });
          return true;
        })
        .catchError((e) {
          setState(() {
            _loadingOverlayEnabled = false;
          });
          showWarningNotification(context, e.toString());
          return false;
        });
  }

  Future<bool> _updateTokenAndUserInfo() async {
    if (_isUpdatingSession) {
      return true;
    }
    _isUpdatingSession = true;
    setState(() {
      _loadingOverlayEnabled = true;
    });
    final auth = DartWingAppGlobals.authService;
    try {
      Map<String, dynamic>? userInfo =
          await auth.getUserInfo() ?? auth.idClaims;

      Globals.applicationInfo.username =
          userInfo != null && userInfo.containsKey('name')
          ? userInfo['name'] as String
          : userInfo != null && userInfo.containsKey('preferred_username')
          ? userInfo['preferred_username'] as String
          : '';
      Globals.applicationInfo.userEmail =
          userInfo != null && userInfo.containsKey('email')
          ? userInfo['email'] as String
          : '';

      String userId = Globals.applicationInfo.userEmail;
      if (userId.isEmpty && Globals.applicationInfo.username.isNotEmpty) {
        userId = Globals.applicationInfo.username
            .replaceAll(' ', '.')
            .toLowerCase();
      }
      Globals.applicationInfo.deviceId =
          "${kIsWeb ? "web" : Platform.operatingSystem.toLowerCase()}-$userId";

      await NetworkClients.init(token: auth.accessToken);

      if (auth.accessToken != null) {
        PaperTrailClient.sendInfoMessageToPaperTrail(
          "Token ${auth.accessToken}",
        );
      }
      if (auth.accessTokenExpiration != null) {
        PaperTrailClient.sendInfoMessageToPaperTrail(
          "New Token expires in ${auth.accessTokenExpiration}",
        );
      }

      User user;
      try {
        user = await NetworkClients.dartWingApi.fetchUser();
      } catch (_) {
        user = await _launchUserProfileSetup();
      }

      Globals.user = user;
      _hasLoadedSession = true;

      if (!mounted) {
        return true;
      }

      setState(() {
        _loadingOverlayEnabled = false;
      });

      if ((ModalRoute.of(context)?.isCurrent ?? false) &&
          user.email.isNotEmpty) {
        await _goToHomePage();
      }
      return true;
    } catch (e) {
      _hasLoadedSession = false;
      if (!mounted) {
        return false;
      }
      setState(() {
        _loadingOverlayEnabled = false;
      });
      if ((e is! CancelLoginException) && (e is! PlatformException)) {
        showWarningNotification(context, e.toString());
      }
      if (ModalRoute.of(context)?.isCurrent ?? false) {
        setState(() {});
      }
      return false;
    } finally {
      _isUpdatingSession = false;
    }
  }

  Future<User> _launchUserProfileSetup() async {
    if (!mounted) {
      return Globals.user;
    }
    final result = await Navigator.of(
      context,
    ).pushNamed(DartWingAppsRouters.addUserInfoPage);
    if (result is User) {
      return result;
    }
    return Globals.user;
  }

  Future<void> _loadGateways() async {
    await GatewayManager.initialize();
    _availableGateways = GatewayManager.getAvailableGateways();

    // Check which presets are available
    _isProductionAvailable = _availableGateways.any((g) => g.isDefaultRelease);
    _isQAAvailable = _availableGateways.any((g) => g.isDefaultDebug && !g.isLocalContainer);
    _isLocalAvailable = _availableGateways.any((g) => g.isLocalContainer && g.isRunning);

    // Set initial preset based on availability
    if (_isLocalAvailable) {
      _selectedPreset = GatewayPreset.local;
    } else if (_isQAAvailable) {
      _selectedPreset = GatewayPreset.qa;
    } else if (_isProductionAvailable) {
      _selectedPreset = GatewayPreset.production;
    } else {
      _selectedPreset = GatewayPreset.custom;
    }

    _applyPreset(_selectedPreset);
  }

  void _applyPreset(GatewayPreset preset) {
    setState(() {
      _selectedPreset = preset;

      switch (preset) {
        case GatewayPreset.production:
          final gateway = _availableGateways.firstWhere((g) => g.isDefaultRelease);
          _selectedKeycloakGateway = gateway;
          _selectedDartWingGateway = gateway;
          _selectedHealthcareGateway = gateway;
          break;

        case GatewayPreset.qa:
          final gateway = _availableGateways.firstWhere(
            (g) => g.isDefaultDebug && !g.isLocalContainer,
          );
          _selectedKeycloakGateway = gateway;
          _selectedDartWingGateway = gateway;
          _selectedHealthcareGateway = gateway;
          break;

        case GatewayPreset.local:
          final localGateway = _availableGateways.firstWhere(
            (g) => g.isLocalContainer && g.isRunning,
          );
          final qaGateway = _availableGateways.firstWhere(
            (g) => g.isDefaultDebug && !g.isLocalContainer,
          );
          // Local uses local DartWing but QA Keycloak and Healthcare
          _selectedKeycloakGateway = qaGateway;
          _selectedDartWingGateway = localGateway;
          _selectedHealthcareGateway = qaGateway;
          break;

        case GatewayPreset.custom:
          // Keep current selections or use first available
          _selectedKeycloakGateway ??= _availableGateways.first;
          _selectedDartWingGateway ??= _availableGateways.first;
          _selectedHealthcareGateway ??= _availableGateways.first;
          break;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    NetworkClients.init(token: DartWingAppGlobals.authService.accessToken);

    _authSubscription = DartWingAppGlobals.authService.authenticationStream
        .listen((success) {
          if (!success ||
              DartWingAppGlobals.authService.accessToken == null ||
              DartWingAppGlobals.authService.accessToken!.isEmpty) {
            return;
          }
          _handleAuthenticatedEvent();
        });

    DartWingAppGlobals.authService.onError = (message, error, stackTrace) {
      PaperTrailClient.sendWarningMessageToPaperTrail(message);
      if (!mounted) {
        return;
      }
      setState(() {
        _loadingOverlayEnabled = false;
      });
    };

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isDebugMode) {
        _loadGateways();
      }
      _bootstrapSession();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _bootstrapSession() async {
    final auth = DartWingAppGlobals.authService;
    if (auth.accessToken != null && !_hasLoadedSession) {
      await _updateTokenAndUserInfo();
    }
  }

  void _updateRestClientsToken() {
    final token = DartWingAppGlobals.authService.accessToken;
    if (token != null && token.isNotEmpty) {
      NetworkClients.dartWingRestClient.token = token;
      NetworkClients.frappeRestClient.token = token;
    }
  }

  Future<void> _handleAuthenticatedEvent() async {
    _updateRestClientsToken();
    if (_hasLoadedSession) {
      final auth = DartWingAppGlobals.authService;
      if (auth.accessToken != null) {
        PaperTrailClient.sendInfoMessageToPaperTrail(
          "Refreshed token ${auth.accessToken}",
        );
      }
      if (auth.accessTokenExpiration != null) {
        PaperTrailClient.sendInfoMessageToPaperTrail(
          "Token now expires in ${auth.accessTokenExpiration}",
        );
      }
      return;
    }
    await _updateTokenAndUserInfo();
  }

  Widget _buildPresetRadio(GatewayPreset preset, String label, bool available) {
    return RadioListTile<GatewayPreset>(
      title: Row(
        children: [
          Text(label),
          const SizedBox(width: 8),
          Icon(
            available ? Icons.check_circle : Icons.cancel,
            color: available ? Colors.green : Colors.red,
            size: 16,
          ),
        ],
      ),
      value: preset,
      groupValue: _selectedPreset,
      onChanged: available ? (value) => _applyPreset(value!) : null,
    );
  }

  Widget _buildPresetRadioGroup() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gateway Environment',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            _buildPresetRadio(GatewayPreset.production, 'Production', _isProductionAvailable),
            _buildPresetRadio(GatewayPreset.qa, 'QA', _isQAAvailable),
            _buildPresetRadio(GatewayPreset.local, 'Local', _isLocalAvailable),
            _buildPresetRadio(GatewayPreset.custom, 'Custom', true),
          ],
        ),
      ),
    );
  }

  Widget _buildGatewaySelector(
    String label,
    GatewayConfig? selected,
    ValueChanged<GatewayConfig?> onChanged,
  ) {
    final enabled = _selectedPreset == GatewayPreset.custom;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          DropdownButtonFormField<GatewayConfig>(
            value: selected,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              enabled: enabled,
            ),
            items: _availableGateways.map((gateway) {
              return DropdownMenuItem(
                value: gateway,
                child: Row(
                  children: [
                    Expanded(child: Text(gateway.name)),
                    if (gateway.isLocalContainer)
                      Icon(
                        gateway.isRunning ? Icons.check_circle : Icons.warning,
                        color: gateway.isRunning ? Colors.green : Colors.orange,
                        size: 16,
                      ),
                  ],
                ),
              );
            }).toList(),
            onChanged: enabled ? onChanged : null,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      child: BaseScaffold(
        loadingOverlayEnabled: _loadingOverlayEnabled,
        body: Column(
          children: [
            Visibility(
              visible: Globals.qaModeEnabled,
              child: const SizedBox(
                child: Text(
                  'QA',
                  style: TextStyle(fontSize: 30, color: Colors.red),
                ),
              ),
            ),
            Expanded(
              child: SvgPicture.asset(
                'lib/dart_wing/gui/images/dart_wing_icon.svg',
                alignment: Alignment.center,
              ),
            ),
            if (_isDebugMode && _availableGateways.isNotEmpty)
              SingleChildScrollView(
                child: Column(
                  children: [
                    _buildPresetRadioGroup(),
                    const SizedBox(height: 8),
                    _buildGatewaySelector(
                      'Keycloak Gateway',
                      _selectedKeycloakGateway,
                      (value) => setState(() => _selectedKeycloakGateway = value),
                    ),
                    _buildGatewaySelector(
                      'DartWing Gateway',
                      _selectedDartWingGateway,
                      (value) => setState(() => _selectedDartWingGateway = value),
                    ),
                    _buildGatewaySelector(
                      'Healthcare Gateway',
                      _selectedHealthcareGateway,
                      (value) => setState(() => _selectedHealthcareGateway = value),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[200],
                  minimumSize: const Size(160, 50),
                ),
                onPressed: () {
                  _login();
                },
                child: const Text("Login", style: TextStyle(fontSize: 18)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  Globals.applicationInfo.version,
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
