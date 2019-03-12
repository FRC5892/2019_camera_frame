import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:stream_channel/stream_channel.dart';

import '../models/status_message.dart';
import '../repositories/status_repository.dart';

part 'status_bloc.g.dart';

abstract class StatusEvent {}

class ConnectRequest extends StatusEvent {}

@JsonSerializable(createFactory: false)
class RobotMessage extends StatusEvent {
  final String name;
  final String data;

  RobotMessage({
    this.name,
    this.data,
  });

  Map<String, dynamic> toJson() => _$RobotMessageToJson(this);
}

class StatusPacket {
  String connectionMessage;

  String matchTime;
  String batteryVoltage;
  double pressureFullness;

  Infos infos;
  Warnings warnings;

  Settings settings;

  StatusPacket({
    this.connectionMessage = "Disconnected",
    this.matchTime = "",
    this.batteryVoltage = "",
    this.pressureFullness = 0,
    this.infos = const Infos(),
    this.warnings = const Warnings(),
    this.settings = const Settings(),
  });
}

class StatusBloc extends Bloc<StatusEvent, Stream<StatusPacket>> {
  final initialState = _makeStream(StatusPacket());

  final WebSocketConnector connector;
  StatusBloc({@required this.connector})
      : channel =
            StatusRepository(connector: connector).connect("ws://10.58.92.2:5800") {
    channel.stream.listen((message) {
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
          settings: message.settings,
        ));
      }
    });
  }

  final StreamController<StatusPacket> controller =
      StreamController.broadcast();
  final StreamChannel channel;

  @override
  Stream<Stream<StatusPacket>> mapEventToState(
      Stream<StatusPacket> currentState, StatusEvent event) {
    print("got an event");
    if (event is RobotMessage) {
      print("sending a message to the robot where name is ${event.name} and data is ${event.data}");
      channel.sink.add(jsonEncode(event));
    }

    return _makeStream(controller.stream);
  }

  static Stream<T> _makeStream<T>(T input) => Stream.fromFuture(Future.value(input));

  @override
  void dispose() {
    channel.sink.close();
  }

  static double clamp(double number) {
    if (number < 0) return 0;
    if (number > 1) return 1;
    return number;
  }
}
