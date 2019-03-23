import 'package:angular/angular.dart';

@Component(
  selector: "cf-pressure-gauge",
  templateUrl: "pressure_gauge_component.html",
  styleUrls: ["pressure_gauge_component.css"],
)
class PressureGaugeComponent {
  @Input()
  double fullness;

  String get width => "${(fullness * 300).round()}px";
}
