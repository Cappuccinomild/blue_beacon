import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'dart:developer';
import 'package:perfect_volume_control/perfect_volume_control.dart';

/// filename: setting.dart
/// author: 강병오, 이도훈
/// date: 2023-12-11
/// description:
///     - 비컨 신호가 수신될 때 알람음 설정
///     - 기본 알람음 5개 제공
///     - 사용자 기기에서 음악 선택 가능

var logger = Logger(
  printer: PrettyPrinter(methodCount: 0),
);

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  String selectedOption = 'none'; // 초기 선택값 설정
  AudioPlayer player = AudioPlayer(); // 오디오 객체 생성
  late SharedPreferences prefs;
  late List<String> strList;
  late StreamSubscription<double> _subscription;

  @override
  void initState() {
    super.initState();
    initPrefs();
    _subscription = PerfectVolumeControl.stream.listen((value) {
      logger.d("listener: $value");
    });
  }

  @override
  void dispose() {
    // 페이지가 종료될 때 소리를 중지
    player.stop();
    super.dispose();
    _subscription.cancel();
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

    // 기기에서 선택한 음악인지 확인
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
  }

  /// 오디오 재생하는 함수
  Future<void> playSound(String audioAsset) async {
    logger.d("playSound() 호출");
    await player.setAsset(audioAsset); // 선택한 옵션에 따라 다른 mp3 파일 설정
    player.play();
  }

  /// 기기에서 음악 선택 후 재생하는 함수
  Future<void> pickAndPlayAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      String filePath = file.path!; // 선택한 파일의 경로
      strList = filePath.split('/');

      logger.d("splitedStr: ${strList}");
      logger.d("splitedStr[last]: ${strList.last}");

      await prefs.setBool('isUserFile', true);
      await prefs.setString('filePath', filePath);
      await prefs.setString('selectedSound', 'none');
      await player.stop(); // 기존 오디오 정지
      await player.setFilePath(filePath); // 새로운 파일 설정

      invokeMessage(filePath!, true);

      setState(() {
        selectedOption = strList.last;
      });
      player.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('알림 설정'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // const SizedBox(
            //   height: 150,
            // ),
            Container(
              margin: EdgeInsets.only(top: 50, bottom: 50),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12, width: 0.5),
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                // color: Colors.black12,
              ),

              // color: Colors.amberAccent,
              height: 300,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    RadioListTile(
                      title: Text('beep'),
                      value: 'beep',
                      groupValue: selectedOption,
                      onChanged: (value) {
                        setState(() {
                          selectedOption = value!;
                        });
                        prefs.setBool('isUserFile', false);
                        prefs.setString('selectedSound', 'beep');
                        prefs.setString('filePath', 'assets/audio/beep.mp3');
                        invokeMessage("assets/audio/beep.mp3", false);
                        playSound('assets/audio/beep.mp3');
                      },
                    ),
                    RadioListTile(
                      title: Text('beep2'),
                      value: 'beep2',
                      groupValue: selectedOption,
                      onChanged: (value) {
                        setState(() {
                          selectedOption = value!;
                        });
                        prefs.setBool('isUserFile', false);
                        prefs.setString('selectedSound', 'beep2');
                        prefs.setString('filePath', 'assets/audio/beep2.mp3');
                        invokeMessage("assets/audio/beep2.mp3", false);
                        playSound('assets/audio/beep2.mp3');
                      },
                    ),
                    RadioListTile(
                      title: Text('beep3'),
                      value: 'beep3',
                      groupValue: selectedOption,
                      onChanged: (value) {
                        setState(() {
                          selectedOption = value!;
                        });
                        prefs.setBool('isUserFile', false);
                        prefs.setString('selectedSound', 'beep3');
                        prefs.setString('filePath', 'assets/audio/beep3.mp3');
                        invokeMessage("assets/audio/beep3.mp3", false);
                        playSound('assets/audio/beep3.mp3');
                      },
                    ),
                    RadioListTile(
                      title: Text('chicken'),
                      value: 'chicken',
                      groupValue: selectedOption,
                      onChanged: (value) {
                        setState(() {
                          selectedOption = value!;
                        });
                        prefs.setBool('isUserFile', false);
                        prefs.setString('selectedSound', 'chicken');
                        prefs.setString('filePath', 'assets/audio/chicken.mp3');
                        invokeMessage("assets/audio/chicken.mp3", false);
                        playSound('assets/audio/chicken.mp3');
                      },
                    ),
                    RadioListTile(
                      title: Text('playtime'),
                      value: 'playtime',
                      groupValue: selectedOption,
                      onChanged: (value) {
                        setState(() {
                          selectedOption = value!;
                        });
                        prefs.setBool('isUserFile', false);
                        prefs.setString('selectedSound', 'playtime');
                        prefs.setString(
                            'filePath', 'assets/audio/playtime.mp3');
                        invokeMessage("assets/audio/playtime.mp3", false);
                        playSound('assets/audio/playtime.mp3');
                      },
                    ),
                  ],
                ),
              ),
            ),
            // const SizedBox(
            //   height: 100,
            // ),
            Text('선택한 옵션: $selectedOption'),
            ElevatedButton(
              onPressed: () {
                pickAndPlayAudio();
              },
              child: const Text("휴대전화에서 추가", style: TextStyle(fontSize: 24)),
            ),
          ],
        ),
      ),
    );
  }
}

void invokeMessage(String uri, bool isUserFile) {
  FlutterBackgroundService().invoke("setAlarmUri", {
    "uri": uri,
    'isUserFile': isUserFile,
  });
}
