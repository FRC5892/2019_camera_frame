import 'package:json_annotation/json_annotation.dart';

part 'status_message.g.dart';

@JsonSerializable(generateToJsonFunction: false)
class StatusMessage {
  int matchTime;
  double batteryVoltage;

  Warnings warnings;

  StatusMessage({
    this.matchTime,
    this.batteryVoltage,
    this.warnings,
  });

  factory StatusMessage.fromJson(Map<String, dynamic> json) =>
      _$StatusMessageFromJson(json);
}

@JsonSerializable(generateToJsonFunction: false)
class Warnings {
  bool isBrownedOut;

  Warnings({
    this.isBrownedOut,
  });

  factory Warnings.fromJson(Map<String, dynamic> json) =>
      _$WarningsFromJson(json);
}
