import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../models/status_message.dart';
import '../repositories/status_repository.dart';

class ConnectRequest {
  String address; // should always be ws://10.58.92.2:5800

  ConnectRequest({this.address = "ws://10.58.92.2:5800"});
}

class StatusPacket {
  bool connected;

  String matchTime;
  String batteryVoltage;
  List<String> warnings;

  StatusPacket({
    this.connected = false,
    this.matchTime = "",
    this.batteryVoltage = "",
    this.warnings = const [],
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
        controller.add(initialState);
      } else if (message is PacketMessage) {
        controller.add(StatusPacket(
          connected: true,
          matchTime: message.matchTime.toString(),
          batteryVoltage: message.batteryVoltage.toStringAsFixed(2) + " V",
          warnings: warningsToStringList(message.warnings),
        ));
      }
    });
    return controller.stream;
  }

  static List<String> warningsToStringList(Warnings warnings) {
    var ret = <String>[];
    if (warnings?.isBrownedOut ?? false) ret.add("Browned out");
    //ret.add("Test Warning");
    return ret;
  }
}
