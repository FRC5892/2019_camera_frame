import 'package:angular/angular.dart';

import '../../blocs/status_bloc.dart';
import '../dashboard/dashboard_component.dart';

@Component(
  selector: "cf-auto-chooser",
  templateUrl: "auton_triple_chooser_component.html",
  styleUrls: ["auton_triple_chooser_component.css"],
  directives: [coreDirectives],
)
class AutonTripleChooserComponent {
  @Input()
  String name;

  @Input()
  String data;

  @Input()
  List<String> dataLabels;

  @Input()
  MessageDispatcher dispatcher;

  void dispatch(String name, String data) {
    print("dispatching with name is $name and data is $data");
    dispatcher(RobotMessage(name: name, data: data));
  }

  static DataLabel dl(String toParse) {
    final list = toParse.split(":");
    return DataLabel(list[0], list[1]);
  }
}

class DataLabel {
  final String data;
  final String label;

  DataLabel(this.data, this.label);
}
