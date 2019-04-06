import 'package:angular/angular.dart';

@Component(
  selector: "cf-cam-display",
  templateUrl: "camera_display_component.html",
  styleUrls: ["camera_display_component.css"],
)
class CameraDisplayComponent implements OnInit {
  static const baseUrl = "http://10.58.92.2:1181/stream.mjpg";

  @Input()
  bool sideways = false;

  @Input()
  bool placeholder = false;

  @Input()
  String wsTimestamp;

  String timestamp;

  String get imageSrc {
    if (placeholder) {
      return "images/cam_placeholder.png";
    }
    return "$baseUrl?$timestamp$wsTimestamp";
  }

  @override
  void ngOnInit() {
    resetTimestamp();
  }

  void resetTimestamp() {
    if (Uri.base.queryParameters["resetCamera"] == "false") {
      return;
    }
    timestamp = DateTime.now().toIso8601String();
  }
}
