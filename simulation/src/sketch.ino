#include <FastLED.h>
#include <WiFi.h>
#include "PubSubClient.h"
#include <LiquidCrystal_I2C.h>
#include <ESP32Servo.h>
#include <Keypad.h>

#define NOLED 10
#define LEDPIN 2
#define BUZZPIN 23
#define MDPIN 19
#define SERVOPIN 18

char CLEAR = '*';

const int lcdColumns = 20;
const int lcdRows = 4;

LiquidCrystal_I2C lcd(0x27, lcdColumns, lcdRows);

const char *ssid = "Wokwi-GUEST";
const char *password = "";
const char *mqttServer = "broker.emqx.io";
int port = 1883;
char clientId[50];

CRGB leds[NOLED];

WiFiClient espClient;
PubSubClient client(espClient);

Servo servo;

#define ROW_NUM 4    // four rows
#define COLUMN_NUM 4 // four columns

char keys[ROW_NUM][COLUMN_NUM] = {
    {'1', '2', '3', 'A'},
    {'4', '5', '6', 'B'},
    {'7', '8', '9', 'C'},
    {'*', '0', '#', 'D'}};

byte pin_rows[ROW_NUM] = {5, 17, 16, 4};
byte pin_column[COLUMN_NUM] = {12, 14, 27, 26};
Keypad keypad = Keypad(makeKeymap(keys), pin_rows, pin_column, ROW_NUM, COLUMN_NUM);
String PASSCODE = "1234";
String ipPass = "";

bool alarmOn = false;

unsigned long previousTimeLed = millis();
unsigned long previousTimeBuzz = millis();
long timeIntervalLed = 50;
long timeIntervalBuzz = 500;

void wifiConnect()
{
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED)
  {
    delay(500);
    Serial.print(".");
  }
}

void mqttReconnect()
{
  while (!client.connected())
  {
    Serial.print("Attempting MQTT connection...");
    long r = random(1000);
    sprintf(clientId, "clientId-%ld", r);
    if (client.connect(clientId))
    {
      Serial.print(clientId);
      Serial.println(" connected");
      client.subscribe("vigilance360/lock/alarm");
      client.subscribe("vigilance360/lock/pass");
    }
    else
    {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
      delay(5000);
    }
  }
}

void callback(char *topic, byte *message, unsigned int length)
{
  Serial.print("Message arrived on topic: ");
  Serial.print(topic);
  Serial.print(". Message: ");
  String stMessage;

  for (int i = 0; i < length; i++)
  {
    Serial.print((char)message[i]);
    stMessage += (char)message[i];
  }
  Serial.println();

  if (String(topic) == "vigilance360/lock/alarm")
  {
    Serial.print("Changing output to ");
    if (stMessage == "on")
    {
      Serial.println("on");
      triggerAlarm();
    }
    else if (stMessage == "off")
    {
      Serial.println("off");
      offAlarm();
    }
  }
  if (String(topic) == "vigilance360/lock/pass")
  {
    Serial.print("Changing pass to ");
    Serial.print(stMessage);
    PASSCODE = stMessage;
  }
}

void offAlarm()
{
  servo.write(0);
  delay(55);
  stopBlink();
  stopBuzz();
  alarmOn = false;
  printLCD("   Systems Online", "   SAFE No Motion");
}
void triggerAlarm()
{
  printLCD("! Motion  Detected !", "!! THEFT !! ALERT !!");
  servo.write(180);
  delay(45);
  alarmOn = true;
}

void alarm()
{
  if (alarmOn)
    blinkRing();
  if (alarmOn)
    startBuzz();
  if (alarmOn)
    checkPass();
  if (alarmOn)
    servo.write(90);

  if (digitalRead(MDPIN) == HIGH)
  {
    client.publish("vigilance360/lock/alarm", "on");
  }
}

void setup()
{
  // put your setup code here, to run once:
  Serial.begin(115200);
  lcd.init();
  lcd.backlight();
  printLCD("   Systems Online", "   SAFE No Motion");
  FastLED.addLeds<NEOPIXEL, LEDPIN>(leds, NOLED);
  FastLED.setBrightness(200);
  servo.attach(SERVOPIN);
  servo.write(0);
  delay(45);
  pinMode(BUZZPIN, OUTPUT);
  pinMode(MDPIN, INPUT);
  randomSeed(analogRead(0));
  wifiConnect();
  Serial.println("WiFi connected");
  client.setServer(mqttServer, port);
  client.setCallback(callback);
  previousTimeLed = millis();
  previousTimeBuzz = millis();
}

void blinkRing()
{
  unsigned long currentTime = millis();
  if (currentTime - previousTimeLed > timeIntervalLed)
  {
    previousTimeLed = currentTime;
    if (leds[0] == CRGB::Red)
      fill_solid(leds, NOLED, CRGB::Black);
    else
      fill_solid(leds, NOLED, CRGB::Red);
    FastLED.show();
  }
}

void stopBlink()
{
  FastLED.clear();
  FastLED.show();
}

void startBuzz()
{
  unsigned long currentTime = millis();
  if (currentTime - previousTimeBuzz > timeIntervalBuzz)
  {
    previousTimeBuzz = currentTime;
    digitalWrite(BUZZPIN, HIGH);
    tone(BUZZPIN, 300, 250);
  }
  else
  {
    digitalWrite(BUZZPIN, LOW);
    noTone(BUZZPIN);
  }
}

void stopBuzz()
{
  digitalWrite(BUZZPIN, LOW);
  noTone(BUZZPIN);
}

void printLCD(String mes1, String mes2)
{
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Anti - Theft System");
  lcd.setCursor(0, 1);
  lcd.print(mes1);
  lcd.setCursor(0, 2);
  lcd.print(mes2);
}

void checkPass()
{
  char c = keypad.getKey();
  if (c == NO_KEY)
    return;
  if (c == CLEAR)
  {
    ipPass = "";
    return;
    lcd.setCursor(8, 3);
    lcd.print(ipPass);
    Serial.println(ipPass);
  }
  ipPass += c;
  lcd.setCursor(8, 3);
  lcd.print(ipPass);
  Serial.println(ipPass);
  if (ipPass == PASSCODE)
  {
    ipPass = "";
    client.publish("vigilance360/lock/alarm", "off");
  }
  else if (ipPass.length() >= 4)
  {
    ipPass = "";
    lcd.setCursor(8, 3);
    lcd.print("    ");
    Serial.println(ipPass);
  }
}

void loop()
{
  if (!client.connected())
  {
    mqttReconnect();
  }
  alarm();
  client.loop();
}
