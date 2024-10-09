import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'feature/bluetooth/bloc/bluetooth_cubit.dart';
import 'feature/bluetooth/bloc/bluetooth_state.dart';
import 'feature/bluetooth/screens/connection_screen.dart';
import 'feature/home/screens/home_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BluetoothCubit(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Bluetooth App',
        home: BlocListener<BluetoothCubit, BluetoothCustomState>(
          listener: (context, state) {
            if(state.connectState == ConnectState.disconnected) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => ConnectionScreen()),
              );
            }
          },
          child: ConnectionScreen(),  // 초기 페이지
        ),
      ),
    );
  }
}