import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vigilance_360/app/controllers/mqtt_controller.dart';
import 'package:vigilance_360/app/views/home_screen.dart';

class EmergencySosScreen extends StatelessWidget {
  EmergencySosScreen({super.key});
  final cont = Get.find<MqttController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Emergency SOS',
          style: TextStyle(
            color: Get.theme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: Get.theme.colorScheme.primary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
              onTap: () async {
                cont.triggerAlarm();
                await Future.delayed(const Duration(seconds: 1));
                Get.off(HomeScreen());
              },
              child: Image.asset(
                'assets/animations/sos.gif',
                width: Get.width * 0.8,
              ),
            ),
            Text(
              'Tap on the SOS button to trigger an alarm',
              style: Get.theme.textTheme.bodyLarge!.copyWith(
                color: Get.theme.colorScheme.primary,
              ),
            )
          ],
        ),
      ),
    );
  }
}
