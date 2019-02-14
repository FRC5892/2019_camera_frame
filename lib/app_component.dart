import 'package:angular/angular.dart';
import 'package:angular_bloc/angular_bloc.dart';
import 'package:web_socket_channel/html.dart';

import 'src/blocs/status_bloc.dart';
import 'src/dashboard_component.dart';

@Component(
  selector: 'cf-app',
  styleUrls: ['app_component.css'],
  templateUrl: 'app_component.html',
  directives: [DashboardComponent],
  pipes: [BlocPipe],
)
class AppComponent implements OnInit {
  StatusBloc statusBloc = StatusBloc(connector: (url) => HtmlWebSocketChannel.connect(url));

  @override
  ngOnInit() {
    statusBloc.dispatch(ConnectRequest());
  }
}
