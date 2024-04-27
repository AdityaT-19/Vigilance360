import 'dart:developer';

import 'package:get/get.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:vigilance_360/app/utils/constants.dart';
import 'package:vigilance_360/app/utils/mqtt.dart';

class MqttController extends GetxController {
  final _instance = MQTTManager.instance;
  RxBool isLoaded = false.obs;
  RxBool isConnected = false.obs;
  RxBool alarmState = false.obs;
  bool _alarmStateInternal = false;

  Future connect() async {
    isLoaded.value = true;
    _instance.setup();
    await _instance.connect();
    _instance.subscribeToAlarm();
    getAlarmState();
    isConnected.value = _instance.isConnected;
    isLoaded.value = false;
  }

  @override
  void onInit() {
    isConnected.value = _instance.isConnected;
    connect();
    super.onInit();
  }

  void getAlarmState() {
    _instance.client.updates!.listen((messages) {
      final message = messages[0];
      final payload = MqttPublishPayload.bytesToStringAsString(
        (message.payload as MqttPublishMessage).payload.message,
      );
      log(message.topic);
      log(message.payload.toString());

      log('Received message: $payload from topic: ${message.topic}');
      if (message.topic == kMqttTopicAlarm) {
        if (payload == 'on') {
          _alarmStateInternal = true;
          alarmState.value = _alarmStateInternal;
        } else if (payload == 'off') {
          _alarmStateInternal = false;
          alarmState.value = _alarmStateInternal;
        }
        print('Alarm state: ${alarmState.value}');
      }
    });
  }

  void triggerAlarm() {
    _instance.publishMessageAlarm('on');
  }

  void stopAlarm() {
    _instance.publishMessageAlarm('off');
  }

  void changePassword(String password) {
    _instance.publishMessagePass(password);
  }
}
