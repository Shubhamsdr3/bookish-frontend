import 'app_routes.dart';
import 'splash/splash_screen.dart';
import 'uikit/bookish_size_impl.dart';
import 'uikit/dark_bookish_color.dart';
import 'uikit/light_bookish_color.dart';
import 'uikit/light_text_style.dart';
import 'util/dimensions.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:network_service/base_api_service.dart';
import 'package:network_service/util/constants.dart';
import 'package:permission_handler/permission_handler.dart';

import 'firebase_options.dart';
import 'notification/notification_service.dart';

Future main() async {
  final WidgetsBinding widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();
  // Keep native splash visible until Flutter SplashScreen is ready.
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  _handleUncaughtErrors();
  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });
  await FirebaseAppCheck.instance.activate(
    androidProvider:
        kReleaseMode ? AndroidProvider.playIntegrity : AndroidProvider.debug,
  );
  if (kDebugMode) {
    debugPrint(
      'App Check: using debug provider. If phone auth fails with '
      '"App attestation failed" (403), run ./scripts/setup_app_check_debug.sh '
      'and register .appcheck_debug_token in Firebase Console '
      '(project bookish-debug-58f4c, package com.newaura.bookish.dev).',
    );
  }
  await PushNotificationService().setupInteractedMessage();
  Constants.setEnvironment(Environment.PROD);
  // if (AppEnvironment().isDebugMode) {
  //   Constants.setEnvironment(Environment.DEV);
  // } else {
  //   Constants.setEnvironment(Environment.PROD);
  // }
  await ApiService().initialize(
    onSessionExpired: () {
      // Handle session expiry — e.g., navigate to login screen
      debugPrint('Session expired! Redirecting to login...');
      // Get.offAllNamed(AppRoutes.login);
    },
  );
  runApp(MyApp());
  // NativeMethodHandler.shared.setMessageHandler();
  // NativeMethodHandler.shared.invokeNative("launchActivity", {});
  RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();

  if (initialMessage != null) {
    // App received a notification when it was killed
  }
}

void _handleUncaughtErrors() {
  FlutterError.onError = (flutterErrorDetails) {
    if (flutterErrorDetails.silent) {
      FirebaseCrashlytics.instance.recordFlutterError(flutterErrorDetails);
    } else {
      FirebaseCrashlytics.instance.recordFlutterFatalError(flutterErrorDetails);
    }
  };
  PlatformDispatcher.instance.onError = ((exception, stackTrace) {
    FirebaseCrashlytics.instance
        .recordError(exception, stackTrace, fatal: false);
    return true;
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: ScreenUtilInit(
        child: GetMaterialApp(
          getPages: appRoutes,
          title: 'Bookish',
          navigatorKey: ApiService().aliceNavigatorKey,
          home: SplashScreen(),
          theme: ThemeData(
              useMaterial3: true,
              primaryColor: Colors.white,
              appBarTheme: const AppBarTheme(
                color: Colors.white,
                titleTextStyle: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: Dimensions.dimen20),
              ),
              extensions: <ThemeExtension<dynamic>>[
                BookishSizeImpl(),
                LightTextStyle(),
                LightBookishColor(),
              ]),
          darkTheme: ThemeData().copyWith(
            extensions: <ThemeExtension<dynamic>>[
              BookishSizeImpl(),
              LightTextStyle(),
              DarkBookishColor(),
            ],
          ),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
