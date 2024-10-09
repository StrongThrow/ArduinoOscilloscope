import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../widgets/WaveformWidget.dart';
import '../../bluetooth/bloc/bluetooth_cubit.dart';
import '../../bluetooth/bloc/bluetooth_state.dart';

class OscilloscopeScreen extends StatefulWidget {
  const OscilloscopeScreen({super.key});

  @override
  State<OscilloscopeScreen> createState() => _OscilloscopeScreenState();
}

class _OscilloscopeScreenState extends State<OscilloscopeScreen> with TickerProviderStateMixin{
  late AnimationController _controller;
  late StreamController<List<double>> _streamController;
  double frequency = 1.0;  // 주기를 제어하는 변수
  bool isAnimating = true; // 애니메이션 상태를 추적하는 변수
  bool isChannelTwo = false; // 채널 2의 상태를 추적하는 변수
  List<double> messageBuffer = []; // 메시지를 저장할 버퍼

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: Duration(seconds: 1))
      ..repeat();

    // StreamController 생성
    _streamController = StreamController<List<double>>();

    // AnimationController의 값이 변할 때마다 스트림에 데이터를 추가
    context.read<BluetoothCubit>().sendMessage('b0*');
  }

  void _toggleAnimation() {
    if (isAnimating) {
      _controller.stop(); // 애니메이션 멈춤
    }
    setState(() {
      isAnimating = !isAnimating; // 애니메이션 상태 토글
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _streamController.close();  // StreamController 닫기
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<BluetoothCubit, BluetoothCustomState> (
        builder: (context, state) {
          return Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  width: 50,
                  height: height,
                  color: Colors.transparent,
                  child: Icon(Icons.arrow_back_ios_new),
                ),
              ),
              Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Row(
                        children: [
                          Container(
                            width: 300,
                            height: 250,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.8),
                                  blurRadius: 3,
                                  offset: Offset(2, 4),
                                ),
                              ],
                            ),
                            child: BlocListener<BluetoothCubit, BluetoothCustomState>(
                              listener: (context, state) {
                                if (state.samples.isNotEmpty) {
                                  for (int i = 0; i < state.samples.length; i++) {
                                    messageBuffer.add(state.samples[i]);
                                    if (messageBuffer.length > 100) {
                                      messageBuffer.removeAt(0);
                                    }
                                  }
                                  _streamController.add(messageBuffer);
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 280,
                                      height: 180,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.8),
                                        borderRadius: BorderRadius.all(Radius.circular(10)),
                                      ),
                                      child: FittedBox(
                                        fit: BoxFit.contain,
                                        child: Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: StreamBuilder<List<double>>(
                                            stream: _streamController.stream,
                                            builder: (context, snapshot) {
                                              if(isChannelTwo) {
                                                if (snapshot.hasData) {
                                                  return CustomPaint(
                                                    painter: WaveformPainter(snapshot.data!),
                                                    size: Size(300, 200),
                                                  );
                                                } else {
                                                  return Center(child: CircularProgressIndicator());
                                                }
                                              } else {
                                                return Center (child: Column(
                                                  children: [
                                                    Text('2 Channel', style: TextStyle(fontSize: 20, color: Colors.cyan),),
                                                    Text('OFF', style: TextStyle(fontSize: 20, color: Colors.cyan),),
                                                  ],
                                                ));
                                              }

                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        child: Center(
                                          child: CupertinoSwitch(
                                            value: isChannelTwo,
                                            activeColor: Colors.cyan,
                                            trackColor: Colors.black45,
                                            onChanged: (value) {
                                              setState(() {
                                                isChannelTwo = value;
                                              });
                                              if(isChannelTwo) {
                                                context.read<BluetoothCubit>().sendMessage('b9*');
                                              } else {
                                                context.read<BluetoothCubit>().sendMessage('b0*');
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                          ),
                          SizedBox(width: 20),
                          Container(
                            width: 120,
                            height: 250,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.8),
                                  blurRadius: 3,
                                  offset: Offset(2, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      OscilloscopeButton('b1*', 'b1', 1.0),
                                      OscilloscopeButton('b2*', 'b2', 1.5),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      OscilloscopeButton('b3*', 'b3', 2.0),
                                      OscilloscopeButton('b4*', 'b4', 2.5),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      OscilloscopeButton('b5*', 'b5', 3.0),
                                      OscilloscopeButton('b6*', 'b6', 3.5),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      OscilloscopeButton('b7*', 'b7', 4.0),
                                      OscilloscopeStopButton()
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
              ),
            ],
          );
        },
      )
    );
  }

  Widget OscilloscopeButton(message, buttonText, double value) {
    return GestureDetector(
      onTap: () {
        context.read<BluetoothCubit>().sendMessage(message);
        setState(() {
          frequency = value;
        });
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.8),
              blurRadius: 3,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: Center(child: Text(buttonText)),
      ),
    );
  }

  Widget OscilloscopeStopButton() {
    return GestureDetector(
      onTap: () {
        context.read<BluetoothCubit>().sendMessage('b8*');
        _toggleAnimation();
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.8),
              blurRadius: 3,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: Center(child: Text('Stop')),
      ),
    );
  }
}