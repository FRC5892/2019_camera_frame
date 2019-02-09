import 'dart:async';
import 'dart:convert';
import 'dart:html';

WebSocket socket;
StreamController<String> streamController = StreamController();

void main() {
  Timer.periodic(const Duration(seconds: 1), tryConnect);
  streamController.stream.listen(handleMessage);
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

var timeDiv = document.querySelector("#time");
void handleMessage(String msg) {
  print(msg);
  var json = jsonDecode(msg);
  timeDiv.text = json["matchTime"].toString();
}