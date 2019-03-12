import 'package:angular/angular.dart';
import 'package:angular_bloc/angular_bloc.dart';
import 'package:web_socket_channel/html.dart';

import 'src/blocs/status_bloc.dart';
import 'src/components/dashboard/dashboard_component.dart';

@Component(
  selector: 'cf-app',
  styleUrls: ['app_component.css'],
  templateUrl: 'app_component.html',
  directives: [coreDirectives, DashboardComponent],
  pipes: [BlocPipe, AsyncPipe],
)
class AppComponent implements OnInit {
  StatusBloc statusBloc =
      StatusBloc(connector: (url) => HtmlWebSocketChannel.connect(url));

  StatusPacket state;

  @override
  ngOnInit() {
    statusBloc.dispatch(ConnectRequest());
    statusBloc.state.listen((stream) async {
      await for (final state in stream) {
        this.state = state;
      }
    });
  }

  void dispatch(StatusEvent evt) {
    print("trying to dispatch $evt");
    statusBloc.dispatch(evt);
  }
}
