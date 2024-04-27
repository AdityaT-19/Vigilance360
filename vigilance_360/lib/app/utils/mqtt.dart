import 'package:get/get.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:vigilance_360/app/utils/constants.dart';

class MQTTManager {
  static final MQTTManager _instance = MQTTManager._internal();
  final client = MqttServerClient(kMqttUrl, DateTime.now().toUtc().toString());
  bool isConnected = false;

  factory MQTTManager() {
    return _instance;
  }

  MQTTManager._internal();

  static MQTTManager get instance => _instance;

  void setup() {
    client.logging(on: true);
    client.logging(on: true);
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onUnsubscribed = onUnsubscribed;
    client.onSubscribed = onSubscribed;
    client.onSubscribeFail = onSubscribeFail;
    client.pongCallback = pong;
    client.keepAlivePeriod = 60;
    client.logging(on: true);
    client.setProtocolV311();
  }

  Future connect() async {
    final connMessage = MqttConnectMessage()
        .withWillTopic('willtopic')
        .withWillMessage('Will message')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    print('MQTT_LOGS::Mosquitto client connecting....');

    client.connectionMessage = connMessage;
    try {
      await client.connect();
    } catch (e) {
      Get.snackbar('Error', 'Failed to connect to MQTT broker - $e');
      print('Exception: $e');
      client.disconnect();
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('MQTT_LOGS::Mosquitto client connected');
      isConnected = true;
    } else {
      Get.snackbar('Error', 'Failed to connect to MQTT broker');
      print(
          'MQTT_LOGS::ERROR Mosquitto client connection failed - disconnecting, status is ${client.connectionStatus}');
      client.disconnect();
    }
  }

  void disconnect() {
    client.disconnect();
    isConnected = false;
  }

  void publishMessageAlarm(String message) {
    const pubTopic = kMqttTopicAlarm;
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);

    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      client.publishMessage(pubTopic, MqttQos.atMostOnce, builder.payload!);
    }
  }

  void publishMessagePass(String message) {
    const pubTopic = kMqttTopicPass;
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);

    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      client.publishMessage(pubTopic, MqttQos.atMostOnce, builder.payload!);
    }
  }

  void subscribeToAlarm() {
    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      client.subscribe(kMqttTopicAlarm, MqttQos.atMostOnce);
    }
  }

  void onConnected() {
    print('MQTT_LOGS:: Connected');
  }

  void onDisconnected() {
    print('MQTT_LOGS:: Disconnected');
  }

  void onSubscribed(String topic) {
    print('MQTT_LOGS:: Subscribed topic: $topic');
  }

  void onSubscribeFail(String topic) {
    print('MQTT_LOGS:: Failed to subscribe $topic');
  }

  void onUnsubscribed(String? topic) {
    print('MQTT_LOGS:: Unsubscribed topic: $topic');
  }

  void pong() {
    print('MQTT_LOGS:: Ping response client callback invoked');
  }
}
