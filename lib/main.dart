import 'package:blue_beacon/setting.dart';
import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:ui';

import 'package:beacons_plugin/beacons_plugin.dart';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';



import 'package:blue_beacon/test.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await authInitialize();
  runApp(MyApp());
}

Future<void> authInitialize() async {
  // Permission Handle
  if (Platform.isAndroid) {
    // Prominent disclosure
    final permissionsToRequest = [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.notification,
      Permission.locationWhenInUse,
      Permission.bluetoothAdvertise,
    ];

    Map<Permission, PermissionStatus> statuses = await permissionsToRequest.request();

    // Check if all permissions are granted
    bool allPermissionsGranted = statuses.values.every((status) => status.isGranted);

    if (allPermissionsGranted) {
      // All permissions are granted, runApp
      await initializeService();
      logger.d('All permissions are granted!');
    } else {
      // 권한 상태를 개별적으로 확인하고 처리할 수도 있습니다.
      if (statuses[Permission.bluetoothScan] != PermissionStatus.granted) {
        print('Bluetooth Scan permission is denied');
        return;
      }
      if (statuses[Permission.bluetoothConnect] != PermissionStatus.granted) {
        print('Bluetooth Connect permission is denied');
        return;
      }
      if (statuses[Permission.notification] != PermissionStatus.granted) {
        print('Bluetooth notification permission is denied');
        return;
      }
      if (statuses[Permission.locationWhenInUse] != PermissionStatus.granted) {
        print('Bluetooth locationWhenInUse permission is denied');
        return;
      }
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

  // Beacon Initialize
  BeaconsPlugin.listenToBeacons(beaconEventsController);

  BeaconsPlugin.addBeaconLayoutForAndroid(
      "m:2-3=beac,i:4-19,i:20-21,i:22-23,p:24-24,d:25-25");

  // ??? 이거 없어짐
  await BeaconsPlugin.runInBackground(false);

  // BeaconsPlugin.setForegroundScanPeriodForAndroid(
  //      foregroundScanPeriod: 1100, foregroundBetweenScanPeriod: 10);

  //BeaconsPlugin.setBackgroundScanPeriodForAndroid(
  //    backgroundScanPeriod: 1100, backgroundBetweenScanPeriod: 10);

  BeaconsPlugin.startMonitoring();

  // For flutter prior to version 3.0.0
  // We have to register the plugin manually

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setString("beacon", "init");

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

  // ???
  service.on('initScan').listen((event) {

    final StreamController<String> beaconEventsController =
    StreamController<String>.broadcast();

    // Beacon Initialize
    BeaconsPlugin.listenToBeacons(beaconEventsController);

    BeaconsPlugin.addBeaconLayoutForAndroid(
        "m:2-3=beac,i:4-19,i:20-21,i:22-23,p:24-24,d:25-25");

    BeaconsPlugin.startMonitoring();

  });


  final timeoutDuration = Duration(seconds: 3);

  final event_stream = beaconEventsController.stream;
  if (service is AndroidServiceInstance) {
    if (await service.isForegroundService()) {
      event_stream.timeout(timeoutDuration, onTimeout:(event) {

        print("time_out : $event");

        service.setForegroundNotificationInfo(
          title: "STATE",
          content: "OFF",
        );

        service.invoke('update',{
          "uuid": "",
          "proximity": "",
          "distance": "",
        });



      }).listen((data) {

        if (data.isNotEmpty) {
          print("data_recevie : $data");

          Map<String, dynamic> jsonData = jsonDecode(data);

          service.setForegroundNotificationInfo(
            title: "STATE",
            content: jsonData['distance'],
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

