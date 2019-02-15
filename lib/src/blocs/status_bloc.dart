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
        controller.add(initialState);
      } else if (message is PacketMessage) {
        controller.add(StatusPacket(
          connectionMessage: "Connected",
          matchTime: message.matchTime.toString(),
          batteryVoltage: message.batteryVoltage.toStringAsFixed(2) + " V",
          pressureFullness: (message.pressureReading - 100) / 700.0,

          infos: message.infos,
          warnings: message.warnings,
        ));
      }
    });
    return controller.stream;
  }

  static List<String> infosToStringList(Infos infos) {
    var ret = <String>[];
    if (infos?.slowDrive ?? false) ret.add("Slow-mode drive");
    //ret.add("Test Info");
    return ret;
  }

  static List<String> warningsToStringList(Warnings warnings) {
    var ret = <String>[];
    if (warnings?.isBrownedOut ?? false) ret.add("Browned out");
    //ret.add("Test Warning");
    return ret;
  }
}
