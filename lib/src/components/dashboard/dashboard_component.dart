import 'package:angular/angular.dart';

import '../../blocs/status_bloc.dart';
import '../pressure_gauge/pressure_gauge_component.dart';

@Component(
  selector: "cf-dashboard",
  templateUrl: "dashboard_component.html",
  styleUrls: ["dashboard_component.css"],
  directives: [coreDirectives, PressureGaugeComponent],
)
class DashboardComponent {
  @Input()
  StatusPacket state;
}
