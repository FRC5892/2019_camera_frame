import 'package:json_annotation/json_annotation.dart';

part 'status_message.g.dart';

abstract class StatusMessage {}

class DisconnectMessage extends StatusMessage {}

@JsonSerializable(createToJson: false)
class PacketMessage extends StatusMessage {
  int matchTime;
  double batteryVoltage;

  Warnings warnings;

  PacketMessage({
    this.matchTime,
    this.batteryVoltage,
    this.warnings,
  });

  factory PacketMessage.fromJson(Map<String, dynamic> json) =>
      _$PacketMessageFromJson(json);
}

@JsonSerializable(createToJson: false)
class Warnings {
  bool isBrownedOut;

  Warnings({
    this.isBrownedOut,
  });

  factory Warnings.fromJson(Map<String, dynamic> json) =>
      _$WarningsFromJson(json);
}
