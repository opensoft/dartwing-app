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

    PaperTrailClient.sendInfoMessageToPaperTrail(
      'DEBUG: _login called, isDebugMode=$kDebugMode, '
      'keycloak=${_selectedKeycloakGateway?.name}, '
      'dartwing=${_selectedDartWingGateway?.name}, '
      'healthcare=${_selectedHealthcareGateway?.name}'
    );

    // Apply selected gateways before login
    // In debug mode: Use selected gateway from UI
    // In release mode: GatewayManager.getCurrentGateway() will return production gateway
    if (_selectedKeycloakGateway != null &&
        _selectedDartWingGateway != null && _selectedHealthcareGateway != null) {

      PaperTrailClient.sendInfoMessageToPaperTrail(
        'DEBUG: Applying gateway selection: Keycloak URL=${_selectedKeycloakGateway!.keycloakUrl}'
      );

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
    } else {
      PaperTrailClient.sendInfoMessageToPaperTrail(
        'DEBUG: Skipping gateway selection - condition not met'
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

      try {
        switch (preset) {
          case GatewayPreset.production:
            print('DEBUG: Applying Production preset, available gateways: ${_availableGateways.length}');
            final gateway = _availableGateways.firstWhere(
              (g) => g.isDefaultRelease,
              orElse: () {
                print('DEBUG: No production gateway found! Using first gateway.');
                return _availableGateways.first;
              },
            );
            print('DEBUG: Production gateway selected: ${gateway.name}');
            _selectedKeycloakGateway = gateway;
            _selectedDartWingGateway = gateway;
            _selectedHealthcareGateway = gateway;
            print('DEBUG: Keycloak: ${_selectedKeycloakGateway?.keycloakUrl}');
            break;

          case GatewayPreset.qa:
            print('DEBUG: Applying QA preset');
            final gateway = _availableGateways.firstWhere(
              (g) => g.isDefaultDebug && !g.isLocalContainer,
              orElse: () => _availableGateways.first,
            );
            print('DEBUG: QA gateway selected: ${gateway.name}');
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
      } catch (e) {
        print('DEBUG: Error applying preset $preset: $e');
        // Fallback to first available gateway
        if (_availableGateways.isNotEmpty) {
          _selectedKeycloakGateway = _availableGateways.first;
          _selectedDartWingGateway = _availableGateways.first;
          _selectedHealthcareGateway = _availableGateways.first;
        }
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

    // Load gateways immediately in debug mode so they're available
    // even if user has an existing session
    if (kDebugMode) {
      _loadGateways();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    // In debug mode, always show the login screen with gateway selector
    // so user can change backend services before logging in
    if (kDebugMode) {
      return;
    }

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

  Widget _buildGatewayButton({
    required String title,
    required GatewayPreset preset,
    required bool isAvailable,
    GatewayConfig? gateway,
  }) {
    final isSelected = _selectedPreset == preset;
    // Healthcare is optional - only require DartWing and Keycloak to be available
    final isEnabled = isAvailable && (gateway == null || (gateway.isDartWingAvailable && gateway.isKeycloakAvailable));

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue[300] : Colors.grey[300],
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onPressed: isEnabled ? () {
        _applyPreset(preset);
      } : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Icon(
                isEnabled ? Icons.check_circle : Icons.cancel,
                color: isEnabled ? Colors.green : Colors.red,
              ),
            ],
          ),
          if (gateway != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildServiceStatusIcon('Gateway', gateway.isDartWingAvailable, required: true),
                  const SizedBox(width: 12),
                  _buildServiceStatusIcon('Keycloak', gateway.isKeycloakAvailable, required: true),
                  const SizedBox(width: 12),
                  _buildServiceStatusIcon('Healthcare', gateway.isHealthcareAvailable, required: false),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildServiceStatusIcon(String serviceName, bool isAvailable, {bool required = true}) {
    // For optional services, show orange/warning color instead of red when unavailable
    final textColor = isAvailable
        ? Colors.green[700]
        : (required ? Colors.red[700] : Colors.orange[700]);
    final iconColor = isAvailable
        ? Colors.green
        : (required ? Colors.red : Colors.orange);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isAvailable
              ? Icons.check_circle_outline
              : (required ? Icons.cancel_outlined : Icons.warning_outlined),
          size: 16,
          color: iconColor,
        ),
        const SizedBox(width: 4),
        Text(
          serviceName,
          style: TextStyle(
            fontSize: 12,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildPresetRadioGroup() {
    // Get gateway configs for each preset
    final productionGateway = _availableGateways.firstWhere(
      (g) => g.isDefaultRelease,
      orElse: () => GatewayConfig(
        name: 'Production',
        keycloakUrl: '',
        dartWingUrl: '',
        healthcareUrl: '',
        isDartWingAvailable: true,
        isKeycloakAvailable: true,
        isHealthcareAvailable: true,
      ),
    );

    final qaGateway = _availableGateways.firstWhere(
      (g) => g.isDefaultDebug && !g.isLocalContainer,
      orElse: () => GatewayConfig(
        name: 'QA',
        keycloakUrl: '',
        dartWingUrl: '',
        healthcareUrl: '',
        isDartWingAvailable: true,
        isKeycloakAvailable: true,
        isHealthcareAvailable: true,
      ),
    );

    final localGateway = _availableGateways.firstWhere(
      (g) => g.isLocalContainer,
      orElse: () => GatewayConfig(
        name: 'Local Development',
        keycloakUrl: '',
        dartWingUrl: '',
        healthcareUrl: '',
        isLocalContainer: true,
        isDartWingAvailable: false,
        isKeycloakAvailable: false,
        isHealthcareAvailable: false,
      ),
    );

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Gateway Environment',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          _buildGatewayButton(
            title: 'Production',
            preset: GatewayPreset.production,
            isAvailable: _isProductionAvailable,
            gateway: productionGateway,
          ),
          const SizedBox(height: 8),
          _buildGatewayButton(
            title: 'QA',
            preset: GatewayPreset.qa,
            isAvailable: _isQAAvailable,
            gateway: qaGateway,
          ),
          const SizedBox(height: 8),
          _buildGatewayButton(
            title: 'Local',
            preset: GatewayPreset.local,
            isAvailable: _isLocalAvailable,
            gateway: localGateway,
          ),
          const SizedBox(height: 8),
          _buildGatewayButton(
            title: 'Custom',
            preset: GatewayPreset.custom,
            isAvailable: true,
          ),
        ],
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
        enableKeyboardListener: false, // Disable to allow touch events on gateway selector
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
            const SizedBox(height: 20),
            SvgPicture.asset(
              'lib/dart_wing/gui/images/dart_wing_icon.svg',
              alignment: Alignment.center,
              height: 120,
            ),
            const SizedBox(height: 20),
            if (kDebugMode && _availableGateways.isNotEmpty)
              _buildPresetRadioGroup(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    if (kDebugMode && _availableGateways.isNotEmpty && _selectedPreset == GatewayPreset.custom) ...[
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
                      const SizedBox(height: 20),
                    ],
                  ],
                ),
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
