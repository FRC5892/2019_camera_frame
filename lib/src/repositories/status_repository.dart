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
    var controller = StreamController<StatusMessage>(
        onPause: () => subscription.pause(),
        onResume: () => subscription.resume(),
        onCancel: () {
          retry = false;
          subscription.cancel();
        });
    void setSubscription(StreamSubscription sub) {
      subscription = sub;
      sub.onDone(() {
        if (!retry) return;
        controller.add(null); // not the most elegant notification but hey
        setSubscription(connector(url).stream.listen((msg) {
          if (msg is String) {
            controller.add(StatusMessage.fromJson(jsonDecode(msg)));
          }
        }));
      });
    }

    setSubscription(connector(url).stream.listen((msg) {
      if (msg is String) {
        controller.add(StatusMessage.fromJson(jsonDecode(msg)));
      }
    }));
    return controller.stream;
  }
}
