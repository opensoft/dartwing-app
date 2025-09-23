import 'dart:async';

import 'package:dart_wing_mobile/dart_wing_apps_routers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'dart_wing/core/globals.dart';
import 'dart_wing/core/persistent_storage.dart';
import 'dart_wing/network/network_clients.dart';
import 'dart_wing/network/paper_trail.dart';
import 'dart_wing_mobile_global.dart';

void main() async {
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();
    DartWingAppGlobals.keycloakWrapper.initialize();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // transparent status bar
      ),
    );

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
        .then((value) {
          return EasyLocalization.ensureInitialized();
        })
        .then((_) {
          runApp(
            EasyLocalization(
              supportedLocales: const [Locale('en'), Locale('de')],
              path: 'lib/dart_wing/localization',
              useFallbackTranslations: true,
              fallbackLocale: const Locale('en'),
              child: const MyApp(),
            ),
          );
        });
  }, (e, s) => PaperTrailClient.sendWarningMessageToPaperTrail(e.toString()));

  Globals.applicationInfo.appName = 'DartWing-Mobile';

  PackageInfo.fromPlatform()
      .then((PackageInfo packageInfo) {
        //NetworkClients.appSettings.defaultLocation = 'SGX';
        Globals.applicationInfo.version = packageInfo.version;
        NetworkClients.qaModeEnabled = !bool.fromEnvironment('dart.vm.product');

        return PersistentStorage.getAppId();
      })
      .then((appId) {
        if (appId.isEmpty) {
          appId = DateFormat('yyMMddhhmmSSS').format(DateTime.now());
          PersistentStorage.saveAppId(appId);
        }
        Globals.applicationInfo.appId = appId;
      });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //navigatorKey: navigatorKey,
      title: Globals.applicationInfo.appName,
      initialRoute: DartWingAppsRouters.loginPage,
      onGenerateRoute: DartWingAppsRouters().generateRouters,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        //colorScheme: ColorScheme.fromSeed(
        //  surface: const Color.fromRGBO(11, 32, 79, 110),
        //  seedColor: const Color.fromRGBO(11, 32, 79, 110),
        //),
        useMaterial3: true,
      ),
    );
  }
}
