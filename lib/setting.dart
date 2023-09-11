import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  late String selectedOption = 'none'; // 초기 선택값 설정
  AudioPlayer player = AudioPlayer(); // 오디오 객체 생성
  late SharedPreferences prefs;
  late List<String> splitedStr;

  @override
  void initState() {
    super.initState();
    initPrefs();
  }

  Future<void> initPrefs() async {
    print("initPrefs() 호출");
    prefs = await SharedPreferences.getInstance();

    if (prefs.getBool('isUserFile') == false) {
      setState(() {
        selectedOption = prefs.getString('selectedSound')!;
      });
    } else {
      setState(() {
        // selectedOption = prefs.getString('filePath')!;
        var filePath = prefs.getString('filePath');
        splitedStr = filePath!.split('/');
        selectedOption = splitedStr.last;
      });
    }

    // 모든 키를 가져오고 각 키에 대한 값을 출력
    final allKeys = prefs.getKeys();
    for (final key in allKeys) {
      final value = prefs.get(key);
      print('Key: $key, Value: $value');
    }
    // 나머지 초기화 작업 수행
  }

  // Future audioPlayer() async {
  //   print("audioPlayer() 호출");
  //   await player.setVolume(10);
  //   await player.setSpeed(1);
  //   await player.setAsset('assets/audio/sample.mp3');
  //   player.play();
  // }

  Future<void> audioPlayer(String audioAsset) async {
    print("audioPlayer() 호출");
    await player.setVolume(1);
    await player.setSpeed(1);
    await player.setAsset(audioAsset); // 선택한 옵션에 따라 다른 mp3 파일 설정

    // await initPrefs();

    player.play();
  }

  Future<void> pickAndPlayAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      String filePath = file.path!; // 선택한 파일의 경로
      // List<String> splitedStr = filePath.split('/');
      splitedStr = filePath.split('/');

      print("splitedStr: ${splitedStr}");
      print("splitedStr[last]: ${splitedStr.last}");

      await prefs.setBool('isUserFile', true);
      await prefs.setString('filePath', filePath);
      await prefs.setString('selectedSound', 'none');
      await player.stop(); // 기존 오디오 정지
      await player.setFilePath(filePath); // 새로운 파일 설정

      setState(() {
        selectedOption = splitedStr.last;
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
                        prefs.setString('filePath', 'none');
                        audioPlayer('assets/audio/beep.mp3');
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
                        prefs.setString('filePath', 'none');
                        audioPlayer('assets/audio/beep2.mp3');
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
                        prefs.setString('filePath', 'none');
                        audioPlayer('assets/audio/beep3.mp3');
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
                        prefs.setString('filePath', 'none');
                        audioPlayer('assets/audio/chicken.mp3');
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
                        prefs.setString('filePath', 'none');
                        audioPlayer('assets/audio/playtime.mp3');
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
