import 'package:angular/angular.dart';

import '../../blocs/status_bloc.dart';
import '../auton_triple_chooser/auton_triple_chooser_component.dart';
import '../bool_indicator/bool_indicator.dart';
import '../pressure_gauge/pressure_gauge_component.dart';

typedef MessageDispatcher = void Function(RobotMessage message);

@Component(
  selector: "cf-dashboard",
  templateUrl: "dashboard_component.html",
  styleUrls: ["dashboard_component.css"],
  directives: [coreDirectives, PressureGaugeComponent, BoolIndicator, AutonTripleChooserComponent],
)
class DashboardComponent {
  @Input()
  StatusPacket state;

  @Input()
  MessageDispatcher dispatch;
}
