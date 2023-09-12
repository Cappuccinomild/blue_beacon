import 'dart:async';

import 'package:blue_beacon/beaconConnect.dart';
import 'package:blue_beacon/setting.dart';
import 'package:flutter/material.dart';
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
        // appBar: AppBar(
        //   title: Text('아이콘 버튼 예제'),
        // ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // IconButton(
              //   onPressed: () {
              //     // 버튼이 클릭될 때 수행할 작업을 여기에 추가
              //   },
              //   icon: Image.asset(
              //     'assets/bluetoothButton.png', // 사용할 이미지 파일 경로
              //     width: 500, // 이미지의 너비 설정
              //     height: 500, // 이미지의 높이 설정
              //   ), // 아이콘 색상 설정
              // ),
              Container(
                margin: EdgeInsets.only(top: 200, bottom: 30),
                child: InkWell(
                  highlightColor: Colors.transparent, // 모서리로 퍼져나가는 이펙트 제거
                  splashColor: Colors.transparent, // 클릭시 원형 이펙트 제거

                  onTap: () {
                    setState(() {
                      isBluetoothOn = !isBluetoothOn;
                    });
                    initPrefs();
                  },
                  child: isBluetoothOn
                      ? Image.asset(
                          "assets/image/bluetooth_on.png") // Bluetooth 켜짐 상태 이미지
                      : Image.asset(
                          "assets/image/bluetooth_off.png"), // Bluetooth 꺼짐 상태 이미지
                ),
              ), // 아이콘 버튼
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
              ), // 설명 텍스트
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
