import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../widgets/macbarWidget.dart';
import '../../bluetooth/bloc/bluetooth_cubit.dart';
import '../../home/screens/note_screen.dart';

class SR04Screen extends StatefulWidget {
  const SR04Screen({super.key});

  @override
  State<SR04Screen> createState() => _SR04ScreenState();
}

class _SR04ScreenState extends State<SR04Screen> {
  bool isLoaded = false;
  double SR04Value = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // MediaQuery를 사용할 수 있는 안전한 시점
    preCacheImages();
    context.read<BluetoothCubit>().sendMessage('d10*');
  }

  Future<void> preCacheImages() async {
    await precacheImage(AssetImage('assets/sr04/000.png'), context);
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
      backgroundColor: Color(0xff7CE6FF),
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
                        MaterialPageRoute(builder: (context) => NoteScreen(assetsPath: 'assets/md/sr04.md',)));
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
            child: Image.asset('assets/sr04/000.png'),
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
                          children: [
                            Text('초음파 데이터 설정', style: TextStyle(fontSize: 20, fontFamily: 'SpoqaHanSansNeo', fontWeight: FontWeight.bold),),
                            Divider(),
                            Expanded(
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: CupertinoSlider(
                                          value: SR04Value,
                                          min: 0.0,
                                          max: 99.0,
                                          onChanged: (value) {
                                            setState(() {
                                              SR04Value = value;
                                            });
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 10,),
                                      Text('${SR04Value.toInt()} cm', style: TextStyle(fontFamily: 'SpoqaHanSansNeo'),),
                                    ],
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                    ),
                                    onPressed: () {
                                      String message = 'd' + SR04Value.toInt().toString().padLeft(2, '0') + '*';
                                      context.read<BluetoothCubit>().sendMessage(message);
                                    },
                                    child: Text('초음파 데이터 보내기', style: TextStyle(fontFamily: 'SpoqaHanSansNeo'),),
                                  ),
                                ],
                              ),
                            ),
                            Text('* ADC0 : eco, ADC1 : trigger', style: TextStyle(fontSize: 15, fontFamily: 'SpoqaHanSansNeo', fontWeight: FontWeight.bold),)
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
