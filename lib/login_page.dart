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
import 'dart_wing/gui/notification.dart';
import 'dart_wing/gui/widgets/base_scaffold.dart';
import 'dart_wing/network/dart_wing/data/user.dart';
import 'dart_wing/network/network_clients.dart';
import 'dart_wing/network/paper_trail.dart';
import 'dart_wing_mobile_global.dart';

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
                //width: 50,
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
