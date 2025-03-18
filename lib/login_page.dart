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
import 'dart_wing/network/network_clients.dart';
import 'dart_wing/network/paper_trail.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with WidgetsBindingObserver {
  bool _loadingOverlayEnabled = false;

  //String _redirectUrl = "http://localhost:3000";
  String _redirectUrl = "https://app-dev.ledgerlinc.com";

  Future<bool> _logout() {
    if (kIsWeb) {
      return Future.value(false); // TODO: ADDWEB
    }
    return Globals.keycloakWrapper.logout().then((success) {
      Globals.keycloakWrapper.tokenResponse = null;
      return success;
    });
  }

  Future<bool> _login() {
    if (kIsWeb) {
      // TODO: ADDWEB
    }
    setState(() {
      _loadingOverlayEnabled = true;
    });
    if (!Globals.keycloakWrapper.isInitialized) {
      Globals.keycloakWrapper.initialize();
    }
    return Globals.keycloakWrapper.login().then((success) {
      if (!success) {
        setState(() {
          _loadingOverlayEnabled = false;
        });
      }
      return success;
    });
  }

  void _goToHomePage() {
    Navigator.of(context)
        .pushNamed(DartWingAppsRouters.homePage, arguments: "")
        .then((value) {
      return _logout();
    }).then((_) {
      setState(() {
        _loadingOverlayEnabled = false;
      });
    }).catchError((e) {
      setState(() {
        _loadingOverlayEnabled = false;
      });
      showWarningNotification(context, e.toString());
    });
  }

  void _autologinIfPossible() {
    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      return;
    }
    Future<bool> future = Future<bool>.value(false);
    if (kIsWeb) {
    } else {
      future = Future.value(Globals.keycloakWrapper.accessToken == null
          ? false
          : Globals.keycloakWrapper.accessToken!.isNotEmpty);
    }
    future.then((valid) {
      if (valid) {
        _updateTokenAndUserInfo();
      }
    });
  }

  Future<void> _updateTokenAndUserInfo() {
    setState(() {
      _loadingOverlayEnabled = true;
    });
    return Globals.keycloakWrapper.getUserInfo().then((userInfo) {
      Globals.applicationInfo.username =
          userInfo != null && userInfo.containsKey('name')
              ? userInfo['name']
              : '';
      Globals.applicationInfo.userEmail =
          userInfo != null && userInfo.containsKey('email')
              ? userInfo['email']
              : '';

      String userId = Globals.applicationInfo.userEmail;
      if (userId.isEmpty && Globals.applicationInfo.username.isNotEmpty) {
        userId =
            Globals.applicationInfo.username.replaceAll(' ', '.').toLowerCase();
      }
      Globals.applicationInfo.deviceId =
          "${kIsWeb ? "web" : Platform.operatingSystem.toLowerCase()}-$userId";
    }).then((_) {
      return NetworkClients.init(token: Globals.keycloakWrapper.accessToken);
    }).then((_) {
      PaperTrailClient.sendInfoMessageToPaperTrail(
          "Token ${Globals.keycloakWrapper.accessToken.toString()}");
      PaperTrailClient.sendInfoMessageToPaperTrail(
          "New Token expires in ${DateTime.fromMillisecondsSinceEpoch(Globals.keycloakWrapper.tokenResponse!.accessTokenExpirationDateTime!.millisecondsSinceEpoch)}");
      return NetworkClients.dartWingApi.fetchUser().catchError((e) {
        return Navigator.of(context).pushNamed(DartWingAppsRouters.homePage);
      });

      Navigator.of(context)
          .pushNamed(DartWingAppsRouters.addUserInfoPage)
          .then((result) {
        if (result == null) {
          return _logout();
        } else {
          return Navigator.of(context).pushNamed(DartWingAppsRouters.homePage,
              arguments: "Some organization");
        }
      });
    }).then((user) {
      setState(() {
        _loadingOverlayEnabled = false;
      });
      Globals.user = user;
    }).then((_) {
      setState(() {
        _loadingOverlayEnabled = false;
      });
      if (ModalRoute.of(context)!.isCurrent) {
        _goToHomePage();
      }
    }).catchError((e) {
      //_logout();
      setState(() {
        _loadingOverlayEnabled = false;
      });
      if ((e is! CancelLoginException) && (e is! PlatformException)) {
        showWarningNotification(context, e.toString());
      }
      if (ModalRoute.of(context)!.isCurrent) {
        setState(() {});
      }
    });
  }

  @override
  void initState() {
    if (!Globals.keycloakWrapper.isInitialized) {
      Globals.keycloakWrapper.initialize();
    }
    NetworkClients.init(token: Globals.keycloakWrapper.accessToken);
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //_autologinIfPossible();
    });

    Globals.keycloakWrapper.authenticationStream.listen((success) {
      if (!success ||
          Globals.keycloakWrapper.accessToken == null ||
          Globals.keycloakWrapper.accessToken!.isEmpty) {
        return;
      }
      _updateTokenAndUserInfo();
    });
    Globals.keycloakWrapper.onError = (message, error, stackTrace) {
      PaperTrailClient.sendWarningMessageToPaperTrail(message);
      setState(() {
        _loadingOverlayEnabled = false;
      });
    };
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    //_autologinIfPossible();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.red,
                ),
              )),
            ),
            Expanded(
                child: SvgPicture.asset(
              'lib/dart_wing/gui/images/dart_wing_icon.svg',
              alignment: Alignment.center,
              //width: 50,
            )),
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
                child: const Text(
                  "Login",
                  style: TextStyle(fontSize: 18),
                ),
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
