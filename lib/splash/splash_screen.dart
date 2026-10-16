import 'package:bookish/util/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';

import '../native/native_android_plugin.dart';

/// Flutter splash must match native splash (white + centered logo).
/// Native assets are generated from [flutter_native_splash.yaml].
class SplashScreen extends StatefulWidget {
  static String routeName = '/splash-screen';

  const SplashScreen({
    super.key,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Hand off from native splash to this identical Flutter frame.
      FlutterNativeSplash.remove();
      _navigateToHome();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) {
          Utility.showToast('On pop invoked');
        }
      },
      child: const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: FractionallySizedBox(
            widthFactor: 0.55,
            child: Image(
              image: AssetImage('assets/image/logo.png'),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToHome() async {
    if (!mounted) {
      return;
    }
    Get.offNamed(NativeAndroidPlugin.routeName);
    // final userLogged = await UserStore.isUserLoggedIn();
    // if (!mounted) return;
    // if (userLogged) {
    //   Get.offNamed(HomeScreen.routeName);
    // } else {
    //   Get.offNamed(LoginScreen.routeName);
    // }
  }
}
