import 'package:blue_beacon/setting.dart';
import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:ui';

import 'package:beacons_plugin/beacons_plugin.dart';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:restart_app/restart_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:device_info_plus/device_info_plus.dart';


import 'package:blue_beacon/test.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await authInitialize();
  runApp(MyApp());
}

Future<void> authInitialize() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  var release = int.parse(androidInfo.version.release);

  logger.d("Running on: ${release}");

  // Permission Handle
  if (Platform.isAndroid) {

    // Prominent disclosure
    final permissionsToRequest = [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.notification,
      Permission.locationWhenInUse,
      // Permission.scheduleExactAlarm,
    ];

    if (release >= 12) {
      permissionsToRequest.add(Permission.scheduleExactAlarm);
    }

    Map<Permission, PermissionStatus> statusesElement = await permissionsToRequest.request();
    Map<Permission, PermissionStatus> statusesAdvanced = await [Permission.locationAlways
      , Permission.ignoreBatteryOptimizations].request();
    // Map<Permission, PermissionStatus> statusesAdvanced = await [Permission.locationAlways].request();

    // Check if all permissions are granted
    bool allElementGranted = statusesElement.values.every((status) => status.isGranted);
    bool allAdvancedGranted = statusesAdvanced.values.every((status) => status.isGranted);

    if (allElementGranted) {
      // All permissions are granted, runApp

      if (allAdvancedGranted){
        await initializeService();
        logger.d('All permissions are granted!');
      }
      else{
        if (statusesElement[Permission.locationAlways] != PermissionStatus.granted) {
          print('locationAlways permission is denied');
        }
        // if (statusesElement[Permission.ignoreBatteryOptimizations] != PermissionStatus.granted) {
        //   print('ignoreBatteryOptimizations permission is denied');
        // }
        Restart.restartApp();
      }

    } else {
      // 권한 상태를 개별적으로 확인하고 처리할 수도 있습니다.
      if (statusesElement[Permission.bluetoothScan] != PermissionStatus.granted) {
        print('Bluetooth Scan permission is denied');
      }
      if (statusesElement[Permission.bluetoothConnect] != PermissionStatus.granted) {
        print('Bluetooth Connect permission is denied');
      }
      if (statusesElement[Permission.notification] != PermissionStatus.granted) {
        print('Bluetooth notification permission is denied');
      }
      if (statusesElement[Permission.locationWhenInUse] != PermissionStatus.granted) {
        print('Bluetooth locationAlways permission is denied');
      }
      if (statusesElement[Permission.ignoreBatteryOptimizations] != PermissionStatus.granted) {
        print('Bluetooth ignoreBatteryOptimizations permission is denied');
      }
      // if (statusesElement[Permission.scheduleExactAlarm] != PermissionStatus.granted) {
      //   print('scheduleExactAlarm permission is denied');
      // }
      Restart.restartApp();
    }
  }
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  // 이미 프로세스가 실행중인 경우 앱 재실행시
  // 프로세스 재실행을 막음 -> 재실행될 경우 통신이 불가능함
  // 통신관련 문제해결 필요
  /*
  if( await service.isRunning() ){

    print("already running");
    return;
  }
   */
  /// OPTIONAL, using custom notification channel id
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'my_foreground', // id
      'MY FOREGROUND SERVICE', // title
      description:
      'This channel is used for important notifications.', // description
      importance: Importance.low, // importance must be at low or higher level
      enableVibration: false
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  if (Platform.isIOS || Platform.isAndroid) {
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        iOS: DarwinInitializationSettings(),
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
  }


  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,

      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'AWESOME SERVICE',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will be executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );

  service.startService();
  service.invoke("setAsForeground");
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();
  final StreamController<String> beaconEventsController =
  StreamController<String>.broadcast();

  // init player
  AudioPlayer player = AudioPlayer();
  player.setVolume(1);
  player.setSpeed(1);

  // Beacon Initialize
  BeaconsPlugin.listenToBeacons(beaconEventsController);

  BeaconsPlugin.addBeaconLayoutForAndroid(
      "m:2-3=beac,i:4-19,i:20-21,i:22-23,p:24-24,d:25-25");

  // BeaconsPlugin.setForegroundScanPeriodForAndroid(
  //      foregroundScanPeriod: 1100, foregroundBetweenScanPeriod: 10);

  //BeaconsPlugin.setBackgroundScanPeriodForAndroid(
  //    backgroundScanPeriod: 1100, backgroundBetweenScanPeriod: 10);

  BeaconsPlugin.startMonitoring();

  // For flutter prior to version 3.0.0
  // We have to register the plugin manually

  SharedPreferences pref = await SharedPreferences.getInstance();
  await pref.setString("beacon", "init");

  String? alarmUri = pref.getString('filePath');
  alarmUri ??= 'assets/audio/beep.mp3';

  bool? isUserFile = pref.getBool("isUserFile"); // 유저파일 여부 확인
  isUserFile ??= false;

  /// OPTIONAL when use custom notification
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // 비콘 이름 등록
  // FlutterBackgroundService().invoke("addRegion", {
  // "name" : "myRegion",
  // "uuid" : uuid,
  // });

  // 비콘 이름 수신
  service.on('addRegion').listen((event) {
    print(event);
    BeaconsPlugin.addRegion(event?['name'], event?['uuid']);
  });

  //비콘 이름 초기화
  service.on('resetRegion').listen((event) {
    BeaconsPlugin.clearRegions();
  });

  service.on('setAlarmUri').listen((event) {

    alarmUri = event!['uri'];
    isUserFile = event['isUserFile'];
    print("alarmUri : $alarmUri");
  });



  final timeoutDuration = Duration(seconds: 3);

  final event_stream = beaconEventsController.stream;
  if (service is AndroidServiceInstance) {
    if (await service.isForegroundService()) {
      event_stream.timeout(timeoutDuration, onTimeout:(event) {

        print("time_out : $event");

        service.setForegroundNotificationInfo(
          title: "비콘 감지되지 않음",
          content: "비콘 신호가 감지되지 않습니다.",
        );

        service.invoke('update',{
          "uuid": "",
          "proximity": "",
          "distance": "",
        });

        flutterLocalNotificationsPlugin.cancel(888);
        player.stop();

      }).listen((data) {

        if (data.isNotEmpty) {
          print("data_recevie : $data");

          Map<String, dynamic> jsonData = jsonDecode(data);

          service.setForegroundNotificationInfo(
            title: "비콘 감지됨",
            content: "비콘 신호를 수신했습니다.",
          );

          service.invoke(
            'update',
            {
              "name" : jsonData['name'],
              "uuid" : jsonData['uuid'],
              "proximity" : jsonData['proximity'],
              "distance" : jsonData['distance'],
            },
          );

          // 비콘이 등록된 경우 알람을 발생시킴
          if (jsonData['name'] == "myRegion") {
            print("alarmURI : $alarmUri");

            // 진동을 울리기위한 프로세스
            var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
              'your channel id', 'your channel name',
              importance: Importance.high,
              priority: Priority.high,
              enableVibration: true,
            );
            var iOSPlatformChannelSpecifics = DarwinNotificationDetails();

            var platformChannelSpecifics = NotificationDetails(
                android: androidPlatformChannelSpecifics,
                iOS: iOSPlatformChannelSpecifics);

            // 비콘 신호수신 알람을 발생시킴
            flutterLocalNotificationsPlugin.show(
                888, "알람", "등록된 비콘 신호를 수신했습니다.", platformChannelSpecifics,
                payload: '');

            // 현재 음악이 재생중이 아닐 경우에
            if(!player.playing){
              //유저가 선택한 파일일 경우
              if(isUserFile!){
                // 새로운 파일 설정
                player.setFilePath(alarmUri!);
              }
              else{
                // mp3 파일 설정
                player.setAsset(alarmUri!);
              }
              // 선택한 파일 무한반복
              player.setLoopMode(LoopMode.one);
              player.play();
            }

          }

          // 비콘이 등록되지 않은 경우 비콘 등록안내 메세지를 발생시킴
          else{
            service.setForegroundNotificationInfo(
              title: "비콘 신호 감지",
              content: "비콘을 등록해주세요",
            );
            player.stop();
          }
        }
      },
          onDone: () {
            print("listen_done");
          },
          onError: (error) {
            print("Error: $error");
          });

    }
  }
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.reload();
  final log = preferences.getStringList('log') ?? <String>[];
  log.add(DateTime.now().toIso8601String());
  await preferences.setStringList('log', log);

  return true;
}

class MyApp extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '\one',
      routes: {
        '\one': (context) => TestApp(),
      },
    );
  }
}

