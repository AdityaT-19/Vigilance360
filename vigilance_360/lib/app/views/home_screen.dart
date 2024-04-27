import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:vigilance_360/app/controllers/mqtt_controller.dart';
import 'package:vigilance_360/app/views/change_pass.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final cont = Get.find<MqttController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home',
          style: TextStyle(
            color: Get.theme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: Get.theme.colorScheme.primary,
        iconTheme: IconThemeData(
          color: Get.theme.colorScheme.onPrimary,
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.primary,
              ),
              child: Text(
                'Vigilance 360',
                style: Get.theme.textTheme.titleLarge!.copyWith(
                  color: Get.theme.colorScheme.onPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.lock,
                color: Get.theme.colorScheme.primary,
              ),
              title: Text(
                'Change Password',
                style: Get.theme.textTheme.titleMedium!.copyWith(
                  color: Get.theme.colorScheme.primary,
                ),
              ),
              onTap: () {
                Get.to(ChangePass());
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Obx(
              () => !cont.alarmState.value
                  ? Image.asset(
                      'assets/images/alarm.png',
                      width: Get.width * 0.5,
                      color: Get.isDarkMode ? Colors.white : Colors.black,
                    )
                  : Image.asset(
                      'assets/animations/alarmbg.gif',
                      width: Get.width * 0.5,
                    ),
            ),
            Obx(
              () => cont.alarmState.value
                  ? Text(
                      '!! Motion Detected !!\nAlarm is ON\n!!Possible Intruder!!',
                      textAlign: TextAlign.center,
                      style: Get.theme.textTheme.displayMedium!.copyWith(
                        color: Colors.red,
                      ),
                    )
                      .animate(
                        onPlay: (controller) => controller.repeat(),
                      )
                      .scale()
                      .then(delay: 20.ms)
                      .elevation(
                        color: Get.theme.colorScheme.primaryContainer,
                      )
                  : Text(
                      'Safe\nAlarm is OFF',
                      textAlign: TextAlign.center,
                      style: Get.theme.textTheme.displayMedium!.copyWith(
                        color: Colors.green,
                      ),
                    )
                      .animate(
                        onPlay: (controller) => controller.repeat(),
                      )
                      .fadeIn()
                      .then(delay: 1000.ms)
                      .fadeOut()
                      .then(delay: 500.ms),
            ),
            Obx(
              () => cont.alarmState.value
                  ? ElevatedButton.icon(
                      onPressed: () {
                        cont.stopAlarm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Get.theme.colorScheme.primary,
                        foregroundColor: Get.theme.colorScheme.onPrimary,
                        padding: EdgeInsets.all(Get.width * 0.1),
                      ),
                      label: Text(
                        'Turn Off Alarm',
                        style: Get.theme.textTheme.displaySmall!.copyWith(
                          color: Get.theme.colorScheme.onPrimary,
                        ),
                      ),
                      icon: Icon(
                        Icons.report_off_outlined,
                        color: Get.theme.colorScheme.onPrimary,
                        size: Get.width * 0.1,
                      ),
                    )
                  : Text(
                      'Shake the device to enter SOS mode',
                      style: Get.theme.textTheme.titleLarge!.copyWith(
                        color: Get.theme.colorScheme.secondary,
                      ),
                    )
                      .animate(
                        onPlay: (controller) => controller.repeat(),
                      )
                      .shake(
                        rotation: 0.01,
                      )
                      .then(delay: 1000.ms),
            ),
          ],
        ),
      ),
    );
  }
}
