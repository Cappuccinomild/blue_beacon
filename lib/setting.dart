import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  String selectedOption = 'Option 1'; // 초기 선택값 설정
  AudioPlayer player = AudioPlayer(); // 오디오 객체 생성

  @override
  void initState() {
    super.initState();
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
    player.play();
  }

  // Future playEffectAudio() async {
  //   final duration = await player.setAsset("assets/audio/sample.mp3");
  //   await player.play();
  //   print("오디오 재생 성공");
  // }

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
                          audioPlayer('assets/audio/beep2.mp3');
                        });
                      },
                    ),
                    RadioListTile(
                      title: Text('beep3'),
                      value: 'beep3',
                      groupValue: selectedOption,
                      onChanged: (value) {
                        setState(() {
                          selectedOption = value!;
                          audioPlayer('assets/audio/beep3.mp3');
                        });
                      },
                    ),
                    RadioListTile(
                      title: Text('chicken'),
                      value: 'chicken',
                      groupValue: selectedOption,
                      onChanged: (value) {
                        setState(() {
                          selectedOption = value!;
                          audioPlayer('assets/audio/chicken.mp3');
                        });
                      },
                    ),
                    RadioListTile(
                      title: Text('playtime'),
                      value: 'playtime',
                      groupValue: selectedOption,
                      onChanged: (value) {
                        setState(() {
                          selectedOption = value!;
                          audioPlayer('assets/audio/playtime.mp3');
                        });
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
              onPressed: () {},
              child: const Text("휴대전화에서 추가", style: TextStyle(fontSize: 24)),
            ),
          ],
        ),
      ),
    );
  }
}