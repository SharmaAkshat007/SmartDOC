import 'package:app_new/src/presentation/screens/splash_screen/redirect_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void redirect() async {
    await Future.delayed(
      const Duration(seconds: 2),
      () => Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const Redirect(),
        ),
        (route) => false,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    redirect();
  }

  @override
  Widget build(BuildContext context) {
    return Wrapper(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: WillPopScope(
          onWillPop: () => Future.value(false),
          child: const Center(
            child: Text('SPLASH SCREEN'),
          ),
        ),
      ),
    );
  }
}
