import 'dart:async';

import 'package:blue_beacon/setting.dart';
import 'package:flutter/material.dart';

class BeaconConnectScreen extends StatefulWidget {
  @override
  _BeaconConnectScreenState createState() => _BeaconConnectScreenState();
}

class _BeaconConnectScreenState extends State<BeaconConnectScreen> {
  bool isConnected = false;
  int remainingSeconds = 5;
  late Timer timer; // 타이머 선언

  @override
  void initState() {
    super.initState();

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
              margin: EdgeInsets.only(
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
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isConnected ? Colors.blue : Colors.transparent,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (!isConnected)
                    CircularProgressIndicator(
                      strokeWidth: 4,
                    )
                  else
                    Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 80, // 아이콘 크기 조절
                    ),
                ], // 로딩 애니메이션 표시],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 30),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    isConnected = !isConnected;
                    if (isConnected == false) {
                      remainingSeconds = 5;
                    }
                  });
                },
                child: Text(
                  isConnected ? "연결 해제" : "연결하기",
                  style: const TextStyle(fontSize: 24),
                ),
              ),
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
