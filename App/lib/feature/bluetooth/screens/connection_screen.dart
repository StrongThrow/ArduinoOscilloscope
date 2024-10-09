import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:lottie/lottie.dart';
import 'package:oscilloscope_guide/feature/home/screens/home_screen.dart';
import 'package:oscilloscope_guide/widgets/macbarWidget.dart';

import '../bloc/bluetooth_cubit.dart';
import '../bloc/bluetooth_state.dart';

class ConnectionScreen extends StatefulWidget {

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> with TickerProviderStateMixin {
  late final AnimationController _controller;
  int seleced_index = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> cards = [
      CardWidget1(),
      CardWidget2(),
      CardWidget3(),
      CardWidget4(),
      CardWidget5(),
      CardWidget6(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<BluetoothCubit, BluetoothCustomState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    child: CardSwiper(
                      scale: 0.9,
                      cardsCount: cards.length,
                      cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
                        return cards[index];
                      },
                      onSwipe: _onSwipe,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
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
                          MacOSBar(height: 28, color: Colors.black54),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: state.scanState == ScanState.scanning
                                      ? Lottie.asset('assets/lottie/bluetooth_lottie.json', width: 200, height: 200)
                                      : state.devices.isEmpty
                                      ? Center(child: Icon(Icons.delete_forever_outlined, size: 150, color: Colors.grey))
                                      : ListView.builder(
                                          itemCount: state.devices.length,
                                          itemBuilder: (context, index) {
                                            // 디바이스 리스트를 정렬 (이름이 없는 기기를 아래로 보냄)
                                            final sortedDevices = state.devices..sort((a, b) {
                                              if ((a.name == null || a.name!.isEmpty) && (b.name == null || b.name!.isEmpty)) {
                                                return 0;
                                              } else if (a.name == null || a.name!.isEmpty) {
                                                return 1; // a가 이름이 없을 경우 b보다 아래로
                                              } else if (b.name == null || b.name!.isEmpty) {
                                                return -1; // b가 이름이 없을 경우 a보다 위로
                                              } else {
                                                return 0; // 이름이 모두 있을 경우 정렬하지 않음
                                              }
                                            });

                                            final device = sortedDevices[index];
                                            return ListTile(
                                                title: Text(device.name ?? '알 수 없는 기기'),
                                                subtitle: Text(device.address),
                                                onTap: () {
                                                  context.read<BluetoothCubit>().connectToDevice(device);
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(builder: (context) => HomeScreen()),
                                                    );
                                                }
                                            );
                                          },
                                        ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        color: Colors.grey,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: GestureDetector(
                                          onTap: state.scanState == ScanState.idle
                                              ? () => context.read<BluetoothCubit>().startScan()
                                              : null,
                                          child: Container(
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              border: Border(
                                                right: BorderSide(
                                                  color: Colors.grey,
                                                  width: 1,
                                                ),
                                              ),
                                            ),
                                              child: Center(
                                                child: Text(state.scanState == ScanState.scanning
                                                    ? '스캔 중...'
                                                    : '스캔 시작'),
                                              ),
                                          ),
                                        )
                                      ),
                                      Expanded(
                                          flex: 1,
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => HomeScreen()),
                                              );
                                            },
                                            child: Container(
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: Colors.transparent,
                                                border: Border(
                                                  left: BorderSide(
                                                    color: Colors.grey,
                                                    width: 1,
                                                  ),
                                                ),
                                              ),
                                              child: Center(child: Text('연결 스킵'))
                                            ),
                                          )
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  bool _onSwipe(
      int previousIndex,
      int? currentIndex,
      CardSwiperDirection direction,
      ) {
    setState(() {
      seleced_index = currentIndex ?? 0;
    });
    debugPrint(
      'The card $previousIndex was swiped to the ${direction.name}. Now the card $currentIndex is on top',
    );
    return true;
  }

  Widget CardWidget1() {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        color: Colors.white,
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
          Flexible(
            child: Center(child: Image.asset('assets/intro/main.png')),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('이 앱에 대하여', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'SpoqaHanSansNeo')),
                Text('스와이프해서 읽어보세요', style: TextStyle(fontSize: 15, fontFamily: 'SpoqaHanSansNeo')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget CardWidget2() {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        color: Colors.white,
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
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('이 가이드는 다음 모듈을 사용합니다.'
                  , style: TextStyle(fontSize: 13, fontFamily: 'SpoqaHanSansNeo', fontWeight: FontWeight.bold), textAlign: TextAlign.center,
                ),
                Text('- 아두이노 우노 \n - 128x64oled 디스플레이, \n - hc-06 블루투스 모듈', style: TextStyle(fontSize: 13, fontFamily: 'SpoqaHanSansNeo'), textAlign: TextAlign.center,),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('사용 모듈 리스트'
                    , style: TextStyle(fontSize: 13, fontFamily: 'SpoqaHanSansNeo', fontWeight: FontWeight.bold), textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget CardWidget3() {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        color: Colors.white,
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
          Flexible(
            child: Center(child: Image.asset('assets/intro/arduino.png')),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('파형은 아두이노의 ADC0, ADC1 핀을 사용합니다.', style: TextStyle(fontSize: 13, fontFamily: 'SpoqaHanSansNeo'), textAlign: TextAlign.center,),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget CardWidget4() {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.8),
            blurRadius: 3,
            offset: Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Center(child: Image.asset('assets/intro/hc06.png')),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('HC-06의 TX를 10번핀에, RX를 11번핀에 연결하세요', style: TextStyle(fontSize: 13, fontFamily: 'SpoqaHanSansNeo'), textAlign: TextAlign.center,),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget CardWidget5() {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.8),
            blurRadius: 3,
            offset: Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Center(child: Image.asset('assets/intro/oled.png')),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('OLED의 SDA는 핀 A4, SCL은 핀 A5를 사용합니다.', style: TextStyle(fontSize: 13, fontFamily: 'SpoqaHanSansNeo'), textAlign: TextAlign.center,),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget CardWidget6() {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.8),
            blurRadius: 3,
            offset: Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Lottie.asset(
                'assets/lottie/bluetooth_lottie.json', width: 200, height: 200,
              animate: false
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('블루투스를 연결해서 시작해보세요!', style: TextStyle(fontSize: 15, fontFamily: 'SpoqaHanSansNeo', fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
