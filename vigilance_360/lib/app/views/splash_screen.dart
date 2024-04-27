import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vigilance_360/app/controllers/mqtt_controller.dart';
import 'package:vigilance_360/app/views/home_screen.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({super.key});
  final cont = Get.find<MqttController>();
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => cont.isLoaded.value
          ? Scaffold(
              appBar: AppBar(
                title: Text(
                  'Vigilance 360',
                  style: TextStyle(
                    color: Get.theme.colorScheme.onPrimary,
                  ),
                ),
                backgroundColor: Get.theme.colorScheme.primary,
              ),
            )
          : cont.isConnected.value
              ? HomeScreen()
              : Scaffold(
                  appBar: AppBar(
                    title: Text(
                      'Vigilance 360',
                      style: TextStyle(
                        color: Get.theme.colorScheme.onPrimary,
                      ),
                    ),
                    backgroundColor: Get.theme.colorScheme.primary,
                  ),
                  body: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text('Connecting to MQTT Broker...'),
                        CircularProgressIndicator(),
                      ],
                    ),
                  ),
                ),
    );
  }
}
