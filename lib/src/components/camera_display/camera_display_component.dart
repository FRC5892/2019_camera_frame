import 'package:angular/angular.dart';


@Component(
  selector: "cf-cam-display",
  templateUrl: "camera_display_component.html",
  styleUrls: ["camera_display_component.css"],
)
class CameraDisplayComponent implements OnInit {
  static const baseUrl = "http://10.58.92.2:1181/stream.mjpg";

  String timestamp;

  @override
  void ngOnInit() {
    resetTimestamp();
  }

  void resetTimestamp() {
    timestamp = DateTime.now().toIso8601String();
  }
}