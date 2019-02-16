import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../models/status_message.dart';
import '../repositories/status_repository.dart';

class ConnectRequest {
  String address;

  ConnectRequest({this.address = "ws://10.58.92.2:5800"});
}

class StatusPacket {
  String connectionMessage;

  String matchTime;
  String batteryVoltage;
  double pressureFullness;

  Infos infos;
  Warnings warnings;

  StatusPacket({
    this.connectionMessage = "Disconnected",
    this.matchTime = "",
    this.batteryVoltage = "",
    this.pressureFullness = 0,

    this.infos = const Infos(),
    this.warnings = const Warnings(),
  });
}

class StatusBloc extends Bloc<ConnectRequest, StatusPacket> {
  final StatusPacket initialState = StatusPacket();

  final WebSocketConnector connector;
  StatusBloc({@required this.connector});

  StreamSubscription _lastSubscription;

  @override
  Stream<StatusPacket> mapEventToState(
      StatusPacket currentState, ConnectRequest event) {
    _lastSubscription?.cancel();
    var repo = StatusRepository(connector: connector);
    StreamController<StatusPacket> controller = StreamController();

    repo.connect(event.address).listen((message) {
      if (message is DisconnectMessage) {
        controller.add(StatusPacket());
      } else if (message is PacketMessage) {
        controller.add(StatusPacket(
          connectionMessage: "Connected",
          matchTime: message.matchTime.toString(),
          batteryVoltage: message.batteryVoltage.toStringAsFixed(2) + " V",
          pressureFullness: clamp((message.pressureReading - 400) / 2800),

          infos: message.infos,
          warnings: message.warnings,
        ));
      }
    });
    return controller.stream;
  }

  static double clamp(double number) {
    if (number < 0) return 0;
    if (number > 1) return 1;
    return number;
  }
}
