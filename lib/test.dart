import 'dart:async';

import 'package:blue_beacon/beaconConnect.dart';
import 'package:blue_beacon/setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  void initState() {
    super.initState();
    initPrefs();
  }

  Future<void> initPrefs() async {
    // print("initPrefs() 호출");
    logger.d("initPrefs() 호출");
    // log('initPrefs() 호출');
    prefs = await SharedPreferences.getInstance();

    setState((){
      touchEvent = prefs.getBool("touchEvent")??false;
      screenEvent = prefs.getBool("screenEvent")??false;
      }
    );

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

    // 모든 키를 가져오고 각 키에 대한 값을 출력
    final allKeys = prefs.getKeys();
    for (final key in allKeys) {
      final value = prefs.get(key);
      logger.d('Key: $key, Value: $value');
    }
    // 나머지 초기화 작업 수행
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('아이콘 버튼 예제'),
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
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text(
                  '알람 미적용 조건 설정',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                title: Text('화면 사용여부'),
                subtitle: screenEvent
                    ? Text('화면이 켜져있을때 알람을 무시합니다.')
                    : Text('화면이 켜져있어도 알람을 울립니다.'),
                trailing: Switch(
                  value: screenEvent,
                  onChanged: (value) {
                    setState(() {
                      screenEvent = value;
                      prefs.setBool("screenEvent", screenEvent);
                      FlutterBackgroundService().invoke("setTouchEvent", {"value":screenEvent});
                    });
                  },
                ),
              ),
              ListTile(
                title: Text('터치 사용여부'),
                subtitle: touchEvent
                    ? Text('최근에 화면을 터치했다면 알람을 무시합니다.')
                    : Text('60초간 화면을 터치하지 않으면 알람을 울립니다.'),
                trailing: Switch(
                  value: touchEvent,
                  onChanged: (value) {
                    setState(() {
                      touchEvent = value;
                      prefs.setBool("touchEvent", touchEvent);
                      FlutterBackgroundService().invoke("setScreenEvent", {"value":touchEvent});
                    });
                  },
                ),
              ),
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
                String? uuid = data["uuid"];
                String? proximity = data["proximity"];
                String? distance = data["distance"];

                // 내용이 없을 경우
                if (uuid == "") {
                  isBluetoothOn = false;
                }
                else{
                  isBluetoothOn = true;
                }

                return Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 200, bottom: 30),
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
                            ? Image.asset("assets/image/bluetooth_on.png")
                            : Image.asset("assets/image/bluetooth_off.png"),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 100),
                      child: Column(
                        children: [
                          Text(
                            isBluetoothOn ? "비컨이 켜져있습니다" : "비컨이 꺼져있습니다",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            isBluetoothOn
                                ? "비컨의 전원을 꺼 알람을 해제하세요"
                                : "비컨의 전원을 켜 알람을 울려주세요",
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
                    child: const Text("비컨 재등록", style: TextStyle(fontSize: 24)),
                  ),
                  SizedBox(width: 16),
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
