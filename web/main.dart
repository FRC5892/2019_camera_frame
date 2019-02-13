import 'dart:async';
import 'dart:convert';
import 'dart:html';

WebSocket socket;
StreamController<String> streamController = StreamController();

bool debug = window.origin.contains("localhost");

void main() {
  Timer.periodic(const Duration(seconds: 1), tryConnect);
  streamController.stream.listen(handleMessage);
  if (debug) {
    (querySelector("#stream") as ImageElement)
      ..style.transform = "initial"
      // image from placeholder.com
      // need it self-served bcuz I probz will be connected to robot wifi while testing
      ..src = "360x240.png";
  }
}

void tryConnect([_]) {
  if (socket != null) return;
  socket = WebSocket("ws://10.58.92.2:5800");
  var msgListen = socket.onMessage.listen((message) {
    if (message.data is String) {
      streamController.add(message.data);
    }
  });
  socket.onClose.first.then((_) {
    socket = null;
    msgListen.cancel();
  });
}

var timeSpan = querySelector("#time-put");
var batterySpan = querySelector("#battery-put");
var brownoutWarning = querySelector("#warn-brownout");
void handleMessage(String msg) {
  if (debug) {
    print(msg);
  }
  var json = jsonDecode(msg);
  timeSpan.text = json["matchTime"].toString();
  batterySpan.text = json["batteryVoltage"].toStringAsFixed(2);
  brownoutWarning.style.display =
      json["warnings"]["brownedOut"] ? "initial" : "none";
}
