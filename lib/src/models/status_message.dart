import 'package:json_annotation/json_annotation.dart';

part 'status_message.g.dart';

abstract class StatusMessage {
  const StatusMessage();
}

class DisconnectMessage extends StatusMessage {
  const DisconnectMessage();
}

@JsonSerializable(createToJson: false)
class PacketMessage extends StatusMessage {
  final int matchTime;
  final double batteryVoltage;
  final int pressureReading;

  final Infos infos;
  final Warnings warnings;

  const PacketMessage({
    this.matchTime,
    this.batteryVoltage,
    this.pressureReading,

    this.infos,
    this.warnings,
  });

  factory PacketMessage.fromJson(Map<String, dynamic> json) =>
      _$PacketMessageFromJson(json);
}

@JsonSerializable(createToJson: false)
class Infos {
  final bool slowDrive;
  final bool hasHatch;
  final bool hasCargo;

  const Infos({
    this.slowDrive = false,
    this.hasHatch = false,
    this.hasCargo = false,
  });

  factory Infos.fromJson(Map<String, dynamic> json) => _$InfosFromJson(json);
}

@JsonSerializable(createToJson: false)
class Warnings {
  final bool isBrownedOut;

  const Warnings({
    this.isBrownedOut = false,
  });

  factory Warnings.fromJson(Map<String, dynamic> json) =>
      _$WarningsFromJson(json);
}
