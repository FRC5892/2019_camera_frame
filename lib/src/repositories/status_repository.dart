import 'dart:async';
import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/status_message.dart';

typedef WebSocketChannel WebSocketConnector(String url);

class StatusRepository {
  final WebSocketConnector connector;

  StatusRepository({@required this.connector});

  Stream<StatusMessage> connect(String url) {
    bool retry = true;
    StreamSubscription subscription;

    DateTime failAfter;

    var timer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (failAfter != null && DateTime.now().isAfter(failAfter)) {
        subscription?.cancel();
      }
    });

    var controller = StreamController<StatusMessage>(
        onPause: () => subscription.pause(),
        onResume: () => subscription.resume(),
        onCancel: () {
          retry = false;
          subscription.cancel();
          timer.cancel();
        });
    
    void handleMessage(msg) {
      if (msg is String) {
        //print(msg);
        controller.add(PacketMessage.fromJson(jsonDecode(msg)));
        failAfter = DateTime.now().add(const Duration(seconds: 1));
      }
    }

    void setSubscription(StreamSubscription sub) {
      subscription = sub;
      failAfter = DateTime.now().add(const Duration(seconds: 5));
      sub.onDone(() {
        if (!retry) return;
        controller.add(DisconnectMessage());
        setSubscription(connector(url).stream.listen(handleMessage));
      });
    }
    
    setSubscription(connector(url).stream.listen(handleMessage));
    return controller.stream;
  }
}
