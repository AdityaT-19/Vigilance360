import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shake/shake.dart';
import 'package:vigilance_360/app/controllers/mqtt_controller.dart';
import 'package:vigilance_360/app/views/emergency_sos.dart';
import 'package:vigilance_360/app/views/splash_screen.dart';

const kColorPrimary = Color.fromARGB(255, 233, 30, 30);
const kColorPrimaryDark = Color.fromARGB(255, 95, 45, 45);

void main() {
  Get.put(MqttController(), permanent: true);
  ShakeDetector.autoStart(onPhoneShake: () {
    Get.to(() => EmergencySosScreen());
  });
  runApp(
    GetMaterialApp(
      title: 'Vigilance 360',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: kColorPrimary,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: kColorPrimaryDark,
          brightness: Brightness.dark,
        ),
      ),
      defaultTransition: Transition.zoom,
      home: SplashScreen(),
    ),
  );
}
