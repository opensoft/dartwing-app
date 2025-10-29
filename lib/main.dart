import 'dart:async';

import 'package:dart_wing_mobile/dart_wing_apps_routers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'dart_wing/core/globals.dart';
import 'dart_wing/core/persistent_storage.dart';
import 'dart_wing/network/network_clients.dart';
import 'dart_wing/network/paper_trail.dart';
import 'dart_wing_mobile_global.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      await DartWingAppGlobals.authService.initialize();
    } catch (error, stackTrace) {
      PaperTrailClient.sendWarningMessageToPaperTrail(
        'Auth init failed: $error',
      );
      debugPrint('Auth init failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // transparent status bar
      ),
    );

    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await EasyLocalization.ensureInitialized();

    await SentryFlutter.init(
    (options) {
      options.dsn = 'https://f1cdc172a791f976c197b2da752313a5@o4510245301583872.ingest.us.sentry.io/4510245303222272';
      // Adds request headers and IP for users, for more info visit:
      // https://docs.sentry.io/platforms/dart/guides/flutter/data-management/data-collected/
      options.sendDefaultPii = true;
      options.enableLogs = true;
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for tracing.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
      // The sampling rate for profiling is relative to tracesSampleRate
      // Setting to 1.0 will profile 100% of sampled transactions:
      options.profilesSampleRate = 1.0;
      // Configure Session Replay
      options.replay.sessionSampleRate = 0.1;
      options.replay.onErrorSampleRate = 1.0;
    },
    appRunner: () => runApp(SentryWidget(child: 
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('de')],
        path: 'lib/dart_wing/localization',
        useFallbackTranslations: true,
        fallbackLocale: const Locale('en'),
        child: const MyApp(),
      ),
    )),
  );
  // TODO: Remove this line after sending the first sample event to sentry.
  await Sentry.captureException(StateError('This is a sample exception.'));
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
