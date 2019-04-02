import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:json_annotation/json_annotation.dart';

import '../models/status_message.dart';
import '../repositories/status_repository.dart';

part 'status_bloc.g.dart';

const pressureReading0Psi = 400;
const pressureReading120Psi = 1200;

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
  @override
  final initialState = _wrapStream(StatusPacket());

  final WebSocketConnector connector;
  StatusBloc({@required this.connector})
      : _repository = StatusRepository(
            connector: connector, url: "ws://10.58.92.2:5800") {
    print("StatusBloc constructor called");
    final delegateStream = _repository.startConnecting();
    delegateStream.listen((delegate) {
      // all the stream closing is handled in StatusRepository
      _currentDelegate = delegate;
      delegate.messageStream.listen(_handleMessage);
    });
  }

  void _handleMessage(StatusMessage message) {
    if (message is DisconnectMessage) {
      _controller.add(StatusPacket());
    } else if (message is PacketMessage) {
      _controller.add(StatusPacket(
        connectionMessage: processConnectionMessage(message.matchData),
        matchTime: message.matchTime.toString(),
        batteryVoltage: message.batteryVoltage.toStringAsFixed(2) + " V",
        pressureFullness: clamp(
            (message.pressureReading - pressureReading0Psi) /
                (pressureReading120Psi - pressureReading0Psi)),
        infos: message.infos,
        warnings: message.warnings,
        settings: message.settings,
      ));
    }
  }

  static String processConnectionMessage(MatchData matchData) {
    const elimNames = [
      "QF 1-1",
      "QF 2-1",
      "QF 3-1",
      "QF 4-1",
      "QF 1-2",
      "QF 2-2",
      "QF 3-2",
      "QF 4-2",
      "QF 1-3",
      "QF 2-3",
      "QF 3-3",
      "QF 4-3",
      "SF 1-1",
      "SF 2-1",
      "SF 1-2",
      "SF 2-2",
      "SF 1-3",
      "SF 2-3",
      "Final 1",
      "Final 2",
      "Final 3",
    ];
    switch (matchData.matchType) {
      case 0:
        return "Connected";
      case 1:
        return "${matchData.eventName} Practice";
      case 2:
        if (matchData.replayNumber > 1) {
          return "${matchData.eventName} "
              "Q${matchData.matchNumber}:${matchData.replayNumber}";
        }
        return "${matchData.eventName} "
            "Q${matchData.matchNumber}";
      case 3:
        if (matchData.matchNumber > elimNames.length) {
          if (matchData.replayNumber > 1) {
            return "${matchData.eventName} "
                "E${matchData.matchNumber}:${matchData.replayNumber}";
          }
          return "${matchData.eventName} "
              "E${matchData.matchNumber}";
        }
        if (matchData.replayNumber > 1) {
          return "${matchData.eventName} "
              "${elimNames[matchData.matchNumber]}:${matchData.replayNumber}";
        }
        return "${matchData.eventName} "
            "${elimNames[matchData.matchNumber]}";
      default:
        return "???";
    }
  }

  final StreamController<StatusPacket> _controller =
      StreamController.broadcast();
  final StatusRepository _repository;

  SocketDelegate _currentDelegate;

  @override
  Stream<Stream<StatusPacket>> mapEventToState(_, StatusEvent event) {
    if (event is RobotMessage) {
      _currentDelegate.returnMessage((jsonEncode(event)));
    }

    return _wrapStream(_controller.stream);
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }

  static Stream<T> _wrapStream<T>(T value) =>
      Stream.fromFuture(Future.value(value));

  static double clamp(double number) {
    if (number < 0) return 0;
    if (number > 1) return 1;
    return number;
  }
}
