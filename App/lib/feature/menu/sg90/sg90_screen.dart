import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_sequence_animator/image_sequence_animator.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../widgets/macbarWidget.dart';
import '../../bluetooth/bloc/bluetooth_cubit.dart';
import '../../bluetooth/bloc/bluetooth_state.dart';
import '../../home/screens/note_screen.dart';


class SG90Screen extends StatefulWidget {
  @override
  _SG90ScreenState createState() => _SG90ScreenState();
}

class _SG90ScreenState extends State<SG90Screen> {
  ImageSequenceAnimatorState? _animatorState;
  bool isLoaded = false;
  double SG90Value = 0;
  double angle = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // MediaQuery를 사용할 수 있는 안전한 시점
    preCacheImages();
    context.read<BluetoothCubit>().sendMessage('c*');
  }


  Future<void> preCacheImages() async {
    for (int i = 0; i < 31; i++) {
      String imagePath = 'assets/sg90/${i.toString().padLeft(6, '0')}.png';
      await precacheImage(AssetImage(imagePath), context);
    }
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
      backgroundColor: Color(0xffFFC5D4),
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
                        MaterialPageRoute(builder: (context) => NoteScreen(assetsPath: 'assets/md/sg90.md',)));
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
            child: ImageSequenceAnimator(
              "assets/sg90",
              "",
              0,
              6,
              "png",
              24,
              isAutoPlay: false,
              isLooping: false,
              onReadyToPlay: (state) {
                Future.delayed(Duration.zero, () {
                  setState(() {
                    _animatorState = state;
                  });
                });
              },
            ),
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('서보모터 애니메이션', style: TextStyle(fontSize: 20, fontFamily: 'SpoqaHanSansNeo', fontWeight: FontWeight.bold),),
                            Divider(),
                            Expanded(
                              child: Center(
                                child: BlocListener<BluetoothCubit, BluetoothCustomState> (
                                  listener: (context, state) {
                                    if (state.receivedMessage.isNotEmpty) {
                                      var message = state.receivedMessage;
                                      final receivedValue = double.parse(message.substring(1, 4));

                                      // 0, 90, 180 각도만 허용
                                      if (receivedValue == 0 || receivedValue == 90 || receivedValue == 180) {
                                        setState(() {
                                          angle = receivedValue;
                                        });
                                        final targetProgress = (receivedValue / 180.0) * _animatorState!.totalProgress;
                                        _smoothTransition(targetProgress);
                                      }
                                    }
                                  },
                                  child: Column(
                                    children: [
                                      CustomPaint(
                                        size: Size(200, 100),
                                        painter: SemiCirclePainter(angle),
                                      ),
                                      Text(
                                        '현재 각도: ${angle.toInt()}도',
                                        style: TextStyle(fontFamily: 'SpoqaHanSansNeo', fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Text('* ADC1 : PWM', style: TextStyle(fontSize: 15, fontFamily: 'SpoqaHanSansNeo', fontWeight: FontWeight.bold),)
                          ],
                        ),
                      ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _smoothTransition(double targetProgress) {
    const duration = Duration(milliseconds: 500);
    final startProgress = _animatorState!.currentProgress;

    Timer.periodic(const Duration(milliseconds: 16), (timer) {
      final elapsed = timer.tick * 16;
      final t = elapsed / duration.inMilliseconds;

      if (t >= 1.0) {
        timer.cancel();
        _animatorState?.skip(targetProgress);
      } else {
        final newProgress = startProgress + (targetProgress - startProgress) * t;
        _animatorState?.skip(newProgress);
      }
    });
  }
}

class SemiCirclePainter extends CustomPainter {
  final double angle; // 각도는 도 단위

  SemiCirclePainter(this.angle);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final radius = min(size.width / 2, size.height / 2);

    // 반원 그리기
    final rect = Rect.fromCircle(center: Offset(size.width / 2, size.height), radius: radius);
    canvas.drawArc(rect, pi, pi, false, paint);

    // 각도 표시
    final anglePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 4;

    // 각도에 따른 선의 끝점 계산
    double angleX, angleY;
    if (angle == 0) {
      angleX = size.width / 2;
      angleY = size.height;
    } else if (angle == 90) {
      angleX = size.width / 2;
      angleY = size.height - radius;
    } else if (angle == 180) {
      angleX = size.width;
      angleY = size.height;
    } else {
      return; // 0, 90, 180도 외의 각도에 대해서는 아무것도 그리지 않음
    }

    // 중심에서 각도까지 선을 그림
    canvas.drawLine(Offset(size.width / 2, size.height), Offset(angleX, angleY), anglePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}