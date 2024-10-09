import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bluetooth_serial_ble/flutter_bluetooth_serial_ble.dart';
import 'bluetooth_state.dart';

List<double> processData(Uint8List data) {
  int chunkSize = 20;
  List<double> result = [];

  // 데이터를 chunkSize 크기로 분할
  for (int i = 0; i < data.length; i += chunkSize) {
    // 범위를 초과하지 않도록 sublist로 분할
    var chunk = data.sublist(i, i + chunkSize > data.length ? data.length : i + chunkSize);

    // 각 chunk의 int 값을 0~1.0 사이로 변환하여 결과에 추가
    result.addAll(chunk.map((value) => value / 255.0));
  }
  return result;
}

class BluetoothCubit extends Cubit<BluetoothCustomState> {
  BluetoothCubit() : super(BluetoothCustomState());

  void startScan() async {
    emit(state.copyWith(scanState: ScanState.scanning));
    try {
      final results = await FlutterBluetoothSerial.instance.startDiscovery().toList();
      final devices = results.map((result) => result.device).toList();
      emit(state.copyWith(devices: devices, scanState: ScanState.idle));
    } catch (e) {
      print('Scan error: $e');
      emit(state.copyWith(scanState: ScanState.idle));
    }
  }

  void connectToDevice(BluetoothDevice device) async {
    emit(state.copyWith(connectState: ConnectState.connecting));
    try {
      final connection = await BluetoothConnection.toAddress(device.address);
      emit(state.copyWith(
          connection: connection,
          connectState: ConnectState.connected // 연결 성공 시 상태 변경
      ));

      connection.input!.listen(
            (data) {
              processData(data);
              // 데이터가 9개 이상인 경우에는 2채널 오실로스코프 데이터로 간주
              if(data.length > 9) {
                var samples = processData(data);
                emit(state.copyWith(samples: samples));
              } else {
                // 그 외에는 문자열로 간주
                final receivedMessage = utf8.decode(data);
                print('Received message: $receivedMessage');
                emit(state.copyWith(receivedMessage: receivedMessage));
              }
        },
        onError: (error) {
          print('Error: $error');
          disconnect();
        },
      );
    } catch (e) {
      print('Connection error: $e');
      disconnect();
    }
  }

  void sendMessage(String message) async {
    if (state.connection != null && state.connectState == ConnectState.connected) {
      try {
        state.connection!.output.add(Uint8List.fromList(utf8.encode(message)));
        await state.connection!.output.allSent;
        print('Message sent: $message');
      } catch (e) {
        print('Failed to send message: $e');
        disconnect();  // 문제가 생기면 연결 해제
      }
    } else {
      print('No active connection to send message.');
    }
  }

  void disconnect() {
    state.connection?.finish();
    emit(state.copyWith(
        connection: null,
        connectState: ConnectState.disconnected,
        receivedMessage: ''
    ));
    print('Disconnect method called, new state emitted');
  }
}
