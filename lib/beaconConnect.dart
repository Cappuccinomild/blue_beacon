import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:beacons_plugin/beacons_plugin.dart';
import 'package:blue_beacon/setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BeaconConnectScreen extends StatefulWidget {
  @override
  _BeaconConnectScreenState createState() => _BeaconConnectScreenState();
}

class _BeaconConnectScreenState extends State<BeaconConnectScreen> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool isConnected = false;
  bool isNear = false;
  int remainingSeconds = 5;
  late Timer timer; // 타이머 선언

  static void updateID(String ID) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    preferences.setString("ID", ID);
  }

  @override
  void initState() {
    super.initState();

    FlutterBackgroundService().invoke("resetRegion");

    // 1초마다 타이머를 체크하여 남은 시간을 갱신
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      if (isConnected && remainingSeconds > 0) {
        setState(() {
          remainingSeconds--;
        });
      }

      // 5초가 경과하면 이전 화면으로 돌아가기
      if (remainingSeconds == 0) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(
                bottom: 30,
              ),
              child: Text(
                isConnected ? "연결이 완료되었습니다!" : "기기를 검색 중입니다",
                style: const TextStyle(
                    fontSize: 24,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
            ),
            StreamBuilder<Map<String, dynamic>?>(
              stream: FlutterBackgroundService().on('update'),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 4),
                  );
                }

                final data = snapshot.data!;
                String? uuid = data["uuid"];
                String? proximity = data["proximity"];
                String? distance = data["distance"];

                // 내용이 없을 경우
                if (uuid == "") {
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 4),
                  );
                }

                // proximity == "Immediate" || proximity == "Near"
                if (proximity == "Immediate") {
                  // 버튼을 활성화
                  print("isNear $isNear");
                  isNear = true;
                } else {
                  // 버튼을 비활성화
                  print("isNear $isNear");
                  isNear = false;
                }

                return Column(
                  children: [
                    Text(
                      isNear ? (uuid ?? 'Unknown') : ("비콘에 가까이 가 주세요"),
                      style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF9BAEC8),
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      proximity ?? 'Unknown',
                      style: const TextStyle(
                          fontSize: 23,
                          color: Color(0xFF2b90d9),
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '비콘과의 거리: ${distance} M' ?? 'Unknown',
                      style: const TextStyle(
                          fontSize: 20,
                          color: Color(0xFFd9e1e8),
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(200, 80),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          )),
                      onPressed: !isNear
                          ? null
                          : () {
                              setState(() {
                                FlutterBackgroundService().invoke("addRegion", {
                                  "name": "myRegion",
                                  "uuid": uuid,
                                });

                                if (isConnected) Navigator.of(context).pop();
                                isConnected = !isConnected;
                                if (isConnected == false) {
                                  remainingSeconds = 5;
                                }
                              });
                            },
                      child: Text(
                        isConnected ? "메인 화면으로" : "연결하기",
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ],
                );
              },
            ),
            if (isConnected)
              Text(
                "남은 시간: $remainingSeconds 초",
                style: const TextStyle(fontSize: 24),
              ),
          ],
        ),
      ),
    );
  }
}
