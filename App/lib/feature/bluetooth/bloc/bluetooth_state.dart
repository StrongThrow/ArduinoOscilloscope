import 'package:equatable/equatable.dart';
import 'package:flutter_bluetooth_serial_ble/flutter_bluetooth_serial_ble.dart';

//////여기는 상태, 즉 모드라고 생각하면 됨
enum ConnectState { disconnected, connecting, connected }
enum ScanState { idle, scanning }

class BluetoothCustomState extends Equatable {
  final List<BluetoothDevice> devices;
  final BluetoothConnection? connection;
  final ConnectState connectState;
  final ScanState scanState;
  final String receivedMessage;
  final List<double> samples;

  const BluetoothCustomState({
    this.devices = const [],
    this.connection,
    this.connectState = ConnectState.disconnected,
    this.scanState = ScanState.idle,
    this.receivedMessage = '',
    this.samples = const [],
  });

  BluetoothCustomState copyWith({
    List<BluetoothDevice>? devices,
    BluetoothConnection? connection,
    ConnectState? connectState,
    ScanState? scanState,
    String? receivedMessage,
    List<double>? samples,
  }) {
    return BluetoothCustomState(
      devices: devices ?? this.devices,
      connection: connection ?? this.connection,
      connectState: connectState ?? this.connectState,
      scanState: scanState ?? this.scanState,
      receivedMessage: receivedMessage ?? this.receivedMessage,
      samples: samples ?? this.samples,
    );
  }

  @override
  List<Object?> get props => [devices, connection, connectState, scanState, receivedMessage, samples];
}