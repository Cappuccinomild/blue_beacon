import 'dart:async';

import 'package:blue_beacon/beaconConnect.dart';
import 'package:blue_beacon/setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_svg/svg.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// filename: test.dart
/// author: 강병오, 이도훈
/// date: 2023-12-11
/// description:
///     - 앱 실행 시 처음 표시되는 화면
///     - 비컨 신호 여부 표시
///     - 알람 미적용 조건 설정 가능
///     - '비컨 등록' 버튼: BeaconConnectScreen(beaconConnect.dart)으로 이동
///     - '알림 설정' 버튼: SettingScreen(setting.dart)으로 이동

// void main() {
//   // runApp(TestApp());
//
//   runApp(MaterialApp(
//     home: TestApp(),
//   ));
// }

class TestApp extends StatefulWidget {
  @override
  _TestAppState createState() => _TestAppState();
}

class _TestAppState extends State<TestApp> {
  bool isBluetoothOn = false;
  String selectedOption = 'none';
  late SharedPreferences prefs;
  late List<String> strList;

  bool touchEvent = false;
  bool screenEvent = false;
  bool isMine = false;
  bool isRegistered = false;

  @override
  void initState() {
    super.initState();
    initPrefs();
  }

  double selectedSeconds = 300.0; // 초 단위로 초기 선택값 (5분)

  /// 초를 분으로 변환하는 함수
  int secondsToMinutes(double seconds) {
    return (seconds / 60).floor();
  }

  /// 분을 초로 변환하는 함수
  double remainMinute(double seconds) {
    return seconds % 60;
  }

  /// 각종 사용자 설정 불러와서 초기화
  Future<void> initPrefs() async {
    logger.d("initPrefs() 호출");
    prefs = await SharedPreferences.getInstance();

    setState(() {
      touchEvent = prefs.getBool("touchEvent") ?? false;
      screenEvent = prefs.getBool("screenEvent") ?? false;
      selectedSeconds = prefs.getDouble("selectedSeconds") ?? 1;
      isRegistered = prefs.getBool("isRegistered") ?? false;
    });

    // if (prefs.getBool('isUserFile') == false) {
    //   setState(() {
    //     selectedOption = prefs.getString('selectedSound')!;
    //   });
    // } else {
    //   setState(() {
    //     // selectedOption = prefs.getString('filePath')!;
    //     var filePath = prefs.getString('filePath');
    //     strList = filePath!.split('/');
    //     selectedOption = strList.last;
    //   });
    // }

    if (prefs.getBool('isUserFile') == false) {
      setState(() {
        selectedOption = prefs.getString('selectedSound') ?? 'none';
      });
    } else {
      var filePath = prefs.getString('filePath');
      if (filePath != null) {
        strList = filePath.split('/');
        setState(() {
          selectedOption = strList.last;
        });
      }
    }

    // sharedPrefs 내용 출력
    final allKeys = prefs.getKeys();
    for (final key in allKeys) {
      final value = prefs.get(key);
      logger.d('Key: $key, Value: $value');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('블루알리미'),
          // 메뉴 아이콘 추가
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
        ),
        drawer: Drawer(
          // Drawer 위젯 추가
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const SizedBox(
                height: 140,
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '알람 미적용 조건 설정',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
              ),
              ListTile(
                minVerticalPadding: 10,
                title: const Padding(
                  padding: EdgeInsets.only(bottom: 5),
                  child: Text(
                    '화면이 켜져있을 때 알람 무시',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                subtitle: screenEvent
                    ? const Text('화면이 켜져있을때 알람을 무시합니다.')
                    : const Text('화면이 켜져있어도 알람을 울립니다.'),
                trailing: Switch(
                  value: screenEvent,
                  onChanged: (value) {
                    setState(() {
                      screenEvent = value;
                      prefs.setBool("screenEvent", screenEvent);
                      FlutterBackgroundService()
                          .invoke("setScreenEvent", {"value": screenEvent});
                    });
                  },
                ),
              ),
              const Divider(),
              ListTile(
                minVerticalPadding: 10,
                title: const Padding(
                  padding: EdgeInsets.only(bottom: 5),
                  child: Text(
                    '터치 사용 시 알람 무시',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                subtitle: touchEvent
                    ? const Text('최근에 화면을 터치했다면 알람을 무시합니다.')
                    : const Text('60초간 화면을 터치하지 않으면 알람을 울립니다.'),
                trailing: Switch(
                  value: touchEvent,
                  onChanged: (value) {
                    setState(() {
                      touchEvent = value;
                      prefs.setBool("touchEvent", touchEvent);
                      FlutterBackgroundService()
                          .invoke("setTouchEvent", {"value": touchEvent});
                    });
                  },
                ),
              ),
              const Divider(),
              ListTile(
                title: const Padding(
                  padding: EdgeInsets.only(bottom: 5),
                  child: Text(
                    '시간 선택',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                subtitle: Text(
                    '선택된 시간: ${secondsToMinutes(selectedSeconds)} 분 ${remainMinute(selectedSeconds)}초'),
              ),
              Slider(
                value: selectedSeconds,
                min: 0,
                max: 600,
                // 10분을 초로 변환
                divisions: 600,
                // 1초 간격으로 분할
                onChanged: (value) {
                  setState(() {
                    selectedSeconds = value;
                    prefs.setDouble("selectedSeconds", selectedSeconds);
                    FlutterBackgroundService()
                        .invoke("setDuration", {"seconds": selectedSeconds});
                  });
                },
              ),
              const Divider(),
              // 필요한 만큼 메뉴 항목을 추가할 수 있습니다.
            ],
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              StreamBuilder<Map<String, dynamic>?>(
                  stream: FlutterBackgroundService().on('update'),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(strokeWidth: 4),
                      );
                    }
                    final data = snapshot.data!;
                    String? name = data['name'];
                    String? uuid = data["uuid"];
                    String? proximity = data["proximity"];
                    String? distance = data["distance"];

                    // 내용이 없을 경우
                    if (uuid == "") {
                      isBluetoothOn = false;
                    }
                    else {
                      isBluetoothOn = true;
                      if(name == "myRegion"){
                        isMine = true;
                      }
                      else{
                        isMine = false;
                      }

                    }
                    initPrefs();

                    return Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 180, bottom: 30),
                          child: InkWell(
                              highlightColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              onTap: () {
                                setState(() {
                                  isBluetoothOn = !isBluetoothOn;
                                });
                                initPrefs();
                              },
                              child: isBluetoothOn
                                  ? SvgPicture.asset(
                                      'assets/image/bluetooth_on.svg',
                                      height: 170,
                                      width: 170,
                                    )
                                  : SvgPicture.asset(
                                      'assets/image/bluetooth_off.svg',
                                      height: 170,
                                      width: 170,
                                    )),
                        ),
                        Container(
                          margin: const EdgeInsets.only(bottom: 80),
                          child: Column(
                            children: [
                              Text(
                                isBluetoothOn ? "비컨 신호 수신중" : "비컨 신호가 없습니다.",
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                isBluetoothOn && isMine
                                    ? "등록된 비컨에서 신호가 발생했습니다."
                                    : isBluetoothOn ? "등록되지 않은 비컨입니다." : "비컨 신호 수신 대기중.",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black26,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BeaconConnectScreen()));
                    },
                    child: Text(isRegistered ? "비컨 재등록" : "비컨 등록", style: TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SettingScreen()));
                    },
                    child: const Text("알림 설정", style: TextStyle(fontSize: 24)),
                  )
                ],
              ), // 버튼 2개
            ],
          ),
        ),
      ),
    );
  }
}
