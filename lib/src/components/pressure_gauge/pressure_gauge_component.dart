import 'package:angular/angular.dart';

@Component(
  selector: "cf-pressure-gauge",
  templateUrl: "pressure_gauge_component.html",
  styleUrls: ["pressure_gauge_component.css"],
)
class PressureGaugeComponent {
  @Input()
  double fullness;

  static const maxWidth = 320 - 50 - 10;

  String get width => "${(fullness * maxWidth).round()}px";
}
