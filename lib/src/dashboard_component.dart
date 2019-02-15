import 'package:angular/angular.dart';

import 'blocs/status_bloc.dart';

@Component(
  selector: "cf-dashboard",
  templateUrl: "dashboard_component.html",
  styleUrls: ["dashboard_component.css"],
  directives: [coreDirectives],
)
class DashboardComponent {
  @Input()
  StatusPacket state;
}
