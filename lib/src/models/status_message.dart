import 'package:json_annotation/json_annotation.dart';

part 'status_message.g.dart';

abstract class StatusMessage {
  const StatusMessage();
}

class DisconnectMessage extends StatusMessage {
  const DisconnectMessage();
}

const jsonRead = JsonSerializable(createToJson: false);

@jsonRead
class PacketMessage extends StatusMessage {
  final int matchTime;
  final double batteryVoltage;
  final int pressureReading;

  final MatchData matchData;

  final Infos infos;
  final Warnings warnings;

  final Settings settings;

  const PacketMessage({
    this.matchTime,
    this.batteryVoltage,
    this.pressureReading,
    this.matchData,
    this.infos,
    this.warnings,
    this.settings,
  });

  factory PacketMessage.fromJson(Map<String, dynamic> json) =>
      _$PacketMessageFromJson(json);
}

@jsonRead
class MatchData {
  final String eventName;
  final int matchType;
  final int matchNumber;
  final int replayNumber;

  const MatchData({
    this.eventName,
    this.matchType,
    this.matchNumber,
    this.replayNumber,
  });

  factory MatchData.fromJson(Map<String, dynamic> json) =>
      _$MatchDataFromJson(json);
}

@jsonRead
class Infos {
  final bool slowDrive;
  final bool killDrive;
  final bool slowElevator;

  const Infos({
    this.slowDrive = false,
    this.killDrive = false,
    this.slowElevator = false,
  });

  factory Infos.fromJson(Map<String, dynamic> json) => _$InfosFromJson(json);
}

@jsonRead
class Warnings {
  final bool brownedOut;

  const Warnings({
    this.brownedOut = false,
  });

  factory Warnings.fromJson(Map<String, dynamic> json) =>
      _$WarningsFromJson(json);
}

@jsonRead
class Settings {
  final String autonSide;

  const Settings({
    this.autonSide,
  });

  factory Settings.fromJson(Map<String, dynamic> json) =>
      _$SettingsFromJson(json);
}
