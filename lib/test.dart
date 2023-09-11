import 'package:blue_beacon/setting.dart';
import 'package:flutter/material.dart';

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
                      isBluetoothOn ? "블루투스가 켜져있습니다" : "블루투스가 꺼져있습니다",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      isBluetoothOn
                          ? "버튼을 누르면 블루투스 연결이 해제됩니다"
                          : "버튼을 눌러 블루투스를 켜세요",
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
                    onPressed: () {},
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
