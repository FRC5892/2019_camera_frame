import 'package:angular/angular.dart';

@Component(
  selector: "cf-bool",
  templateUrl: "bool_indicator.html",
  styleUrls: ["bool_indicator.css"],
)
class BoolIndicator {
  @Input()
  bool on;
}
