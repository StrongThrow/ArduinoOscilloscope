import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../widgets/macbarWidget.dart';
import '../../home/screens/note_screen.dart';



class ArduinoScreen extends StatefulWidget {
  const ArduinoScreen({super.key});

  @override
  State<ArduinoScreen> createState() => _ArduinoScreenState();
}

class _ArduinoScreenState extends State<ArduinoScreen> {
  bool isLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // MediaQuery를 사용할 수 있는 안전한 시점
    preCacheImages();
  }

  Future<void> preCacheImages() async {
    await precacheImage(AssetImage('assets/arduino/000.png'), context);
    // 모든 이미지 캐싱이 완료된 후 다른 동작 수행 가능
    setState(() {
      isLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Color(0xffFFFFA5),
      body: isLoaded
          ? buildMainContent(width, height) // 이미지가 로드되면 메인 화면을 표시
          : Center(
        child: LoadingAnimationWidget.prograssiveDots(
          color: Colors.white,
          size: 100,
        ), // 로딩 스크린 표시
      ),
    );
  }

  Widget buildMainContent(double width, double height) {
    return Row(
      children: [
        Container(
          width: 50,
          height: height,
          color: Colors.transparent,
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  height: height / 2,
                  child: Icon(Icons.arrow_back_ios_new),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey,
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NoteScreen(assetsPath: 'assets/md/arduino.md',)));
                },
                child: Container(
                  height: height / 2,
                  child: Icon(Icons.search),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey,
                        width: 1,
                      ),
                    ),
                  ),
                ),
              )
            ],
          )
        ),
        Container(
          width: height,
          height: height,
          child: FittedBox(
            fit: BoxFit.contain,
            child: Image.asset('assets/arduino/000.png'),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              clipBehavior: Clip.antiAlias,
              height: double.maxFinite,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.all(Radius.circular(15)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.8),
                    blurRadius: 3,
                    offset: Offset(2, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  MacOSBar(height: 28, color: Colors.black54,),
                  Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Text('아두이노 세팅 정보', style: TextStyle(fontSize: 20, fontFamily: 'SpoqaHanSansNeo', fontWeight: FontWeight.bold),),
                                Divider(),
                              ],
                            ),

                            Column(
                              children: [
                                Text('HC-06 ', style: TextStyle(fontSize: 15, fontFamily: 'SpoqaHanSansNeo', fontWeight: FontWeight.bold),),
                                Text('TX : 10번핀 \n RX : 11번핀', style: TextStyle(fontSize: 15, fontFamily: 'SpoqaHanSansNeo'),),
                              ],
                            ),

                            Column(
                              children: [
                                Text('SSD1306 128x64 I2C OLED', style: TextStyle(fontSize: 15, fontFamily: 'SpoqaHanSansNeo', fontWeight: FontWeight.bold),),
                                Text('SDA : 핀 A4 \n SCL : 핀 A5', style: TextStyle(fontSize: 15, fontFamily: 'SpoqaHanSansNeo'),),
                              ],
                            ),

                            Column(
                              children: [
                                Text('파형 분석', style: TextStyle(fontSize: 15, fontFamily: 'SpoqaHanSansNeo', fontWeight: FontWeight.bold),),
                                Text('ADC0, ADC1 사용', style: TextStyle(fontSize: 15, fontFamily: 'SpoqaHanSansNeo'),)
                              ],
                            ),
                          ],
                        ),
                      )
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}