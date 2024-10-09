import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oscilloscope_guide/feature/home/screens/oscilloscope_screen.dart';

import '../../../widgets/AnimationHomeWidget.dart';
import '../../bluetooth/bloc/bluetooth_cubit.dart';
import '../../bluetooth/bloc/bluetooth_state.dart';
import '../../menu/arduino/arduino_screen.dart';
import '../../menu/dcmotor/dcmotor_screen.dart';
import '../../menu/dht11/dht11_screen.dart';
import '../../menu/led/led_screen.dart';
import '../../menu/sg90/sg90_screen.dart';
import '../../menu/sr04/sr04_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {

  final List<Map<String, dynamic>> items = [
    {
      'image': 'assets/arduino/000.png',
      'color': Color(0xffFFFFA5),
      'route': ArduinoScreen(),
    },
    {
      'image': 'assets/sg90/000000.png',
      'color': Color(0xffFFC5D4),
      'route': SG90Screen(),
    },
    {
      'image': 'assets/sr04/000.png',
      'color': Color(0xff7CE6FF),
      'route': SR04Screen(),
    },
    {
      'image': 'assets/led/000000.png',
      'color': Colors.white,
      'route': LEDScreen(),
    },
    {
      'image': 'assets/dcmotor/000000.png',
      'color': Color(0xffB7FFD9),
      'route': DCMotorScreen(),
    },
    {
      'image': 'assets/dht11/000.png',
      'color': Color(0xffD9DFFD),
      'route': DHT11Screen(),
    },
    {
      'image': 'assets/setting/000.png',
      'color': Color(0xff293F49),
      'route': OscilloscopeScreen(),
    }
  ];

  final List<String> _titles = ['아두이노', '서보모터', '초음파센서', 'LED','DC모터','온습도센서', '설정'];

  late final AnimationController _controller;
  final StreamController<int> _selectedIndexController = StreamController<int>();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    Future.delayed(Duration(seconds: 2), () {
      context.read<BluetoothCubit>().sendMessage('a*');
    });
  }

  @override
  void dispose() {
    _selectedIndexController.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    context.read<BluetoothCubit>().sendMessage('a*');
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: BlocBuilder<BluetoothCubit, BluetoothCustomState> (
          builder: (context, state) {
            return StreamBuilder<int>(
              stream: _selectedIndexController.stream,
              initialData: _selectedIndex,
              builder: (context, snapshot) {
                return Column(
                  children: [
                    Expanded(
                      flex: 8,
                      child: Center(
                        child: ListView.builder(
                          itemCount: items.length,
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 56),
                          addRepaintBoundaries: true,
                          itemBuilder: (context, index) {
                            final item = items[index % items.length];
                            return Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: SimpleAnimatedCardItem(
                                image: item['image'],
                                animation: _controller, // Animation 전달
                                isSelected: _selectedIndex == index,
                                onTap: () => onExpand(index),
                                maxWidth: 300,
                                minWidth: 50,
                                height: height,
                                color: item['color'],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            state.connectState == ConnectState.connected
                                ? IconButton(
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                        return AlertDialog(
                                          title: Text('블루투스'),
                                          content: Text('블루투스를 해제하시겠습니까?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text('취소'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                context.read<BluetoothCubit>().disconnect(); // 블루투스 연결 해제
                                              },
                                              child: Text('확인'),
                                            ),
                                          ],
                                        );
                                      });
                                    },
                                    color: Colors.blue,
                                    icon: Icon(Icons.bluetooth_connected),
                                  )
                                : Icon(Icons.bluetooth_disabled),
                            Text(
                              _titles[_selectedIndex],
                              style: const TextStyle(
                                fontSize: 30,
                                fontFamily: 'SpoqaHanSansNeo',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                context.read<BluetoothCubit>().sendMessage('a*');
                              },
                              icon: Icon(Icons.refresh),
                            )
                          ],
                        ),
                      )
                    )
                  ],
                );
              }
            );
          },
        ),
      ),
    );
  }

  void onExpand(int index) {
    if (_selectedIndex == index) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => items[index]['route']),
      ).then((value) {
        setState(() {}); // 다른 페이지에서 돌아왔을 때 UI를 리프레시하기 위해 충분함
      });
    } else {
      _selectedIndex = index;
      _selectedIndexController.add(_selectedIndex); // 인덱스가 변경될 때만 스트림에 알림
      _controller.forward(from: 0);
    }
  }
}