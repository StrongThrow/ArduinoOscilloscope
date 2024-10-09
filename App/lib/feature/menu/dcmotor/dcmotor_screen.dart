import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_sequence_animator/image_sequence_animator.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';

import '../../../widgets/macbarWidget.dart';
import '../../bluetooth/bloc/bluetooth_cubit.dart';
import '../../bluetooth/bloc/bluetooth_state.dart';
import '../../home/screens/note_screen.dart';

class DCMotorScreen extends StatefulWidget {
  const DCMotorScreen({super.key});

  @override
  State<DCMotorScreen> createState() => _DCMotorScreenState();
}

class _DCMotorScreenState extends State<DCMotorScreen> {
  ImageSequenceAnimatorState? _animatorState;
  bool isLoaded = false;
  double _animationSpeed = 5.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // MediaQuery를 사용할 수 있는 안전한 시점
    preCacheImages();
    context.read<BluetoothCubit>().sendMessage('f*');
  }

  Future<void> preCacheImages() async {
    for (int i = 0; i < 27; i++) {
      String imagePath = 'assets/dcmotor/${i.toString().padLeft(6, '0')}.png';
      await precacheImage(AssetImage(imagePath), context);
    }
    // 모든 이미지 캐싱이 완료된 후 다른 동작 수행 가능
    setState(() {
      isLoaded = true;
    });
  }

  void changeAnimationSpeed(double speed) {
    setState(() {
      _animationSpeed = speed < 1.0 ? 1.0 : speed;
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color(0xffB7FFD9),
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
                        MaterialPageRoute(builder: (context) => NoteScreen(assetsPath: 'assets/md/dcmotor.md',)));
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
              "assets/dcmotor",
              "",
              0,
              6,
              "png",
              _animationSpeed,
              isAutoPlay: true,
              isLooping: true,
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
                          Text('DC Motor 애니메이션', style: TextStyle(fontSize: 20, fontFamily: 'SpoqaHanSansNeo', fontWeight: FontWeight.bold),),
                          Divider(),
                          SizedBox(height: 20,),
                          Text('전압 범위 0.0V ~ 5.0V', style: TextStyle(fontFamily: 'SpoqaHanSansNeo', fontWeight: FontWeight.bold),),
                          Expanded(
                            child: Center(
                              child: BlocListener<BluetoothCubit, BluetoothCustomState>(
                                listener: (context, state) {
                                  if (state.receivedMessage.isNotEmpty) {
                                    // 수신된 메시지를 0.0에서 5.0 사이의 값으로 변환
                                    var message = state.receivedMessage;
                                    double? receivedValue = double.tryParse(message.substring(1, 5));
                                    print('Changed: $receivedValue');
                                    if (receivedValue != null) {
                                      changeAnimationSpeed(receivedValue);
                                    }
                                  }
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('⚡현재 전압: ${_animationSpeed}V', style: TextStyle(fontFamily: 'SpoqaHanSansNeo', fontWeight: FontWeight.bold),),
                                    SizedBox(height: 10,),
                                    progressBar(_animationSpeed),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Text('* ADC1 : input', style: TextStyle(fontSize: 15, fontFamily: 'SpoqaHanSansNeo', fontWeight: FontWeight.bold),)
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

  Widget progressBar(double volte) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.8),
                blurRadius: 3,
                offset: Offset(1, 2),
              ),
            ],
          ),
          child: SimpleAnimationProgressBar(
              height: 20,
              width: 200,
              direction: Axis.horizontal,
              backgroundColor: Colors.grey.shade800,
              foregrondColor: Colors.white,
              ratio: volte > 5.0 ? 1 : volte / 5,
              curve: Curves.fastLinearToSlowEaseIn,
              duration: const Duration(seconds: 3),
              borderRadius: BorderRadius.circular(30),
              gradientColor: LinearGradient(
                colors: [Colors.white, Color(0xffB7FFD9)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
          ),
        ),
      ],
    );
  }
}
