import 'dart:async';
import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/status_message.dart';

typedef WebSocketChannel WebSocketConnector(String url);

class StatusRepository {
  final WebSocketConnector connector;

  StatusRepository({@required this.connector});

  // TODO maybe make this logic its own class. this is getting stupid.
  Stream<StatusMessage> connect(String url) {
    bool retry = true;
    StreamSubscription subscription;

    DateTime failAfter;

    Timer timer;

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

    void Function() handleSubscriptionEnd;

    void setSubscription(StreamSubscription sub) {
      subscription = sub;
      failAfter = DateTime.now().add(const Duration(seconds: 1));
      sub.onDone(handleSubscriptionEnd);
    }

    handleSubscriptionEnd = () {
      if (!retry) return;
      controller.add(DisconnectMessage());
      setSubscription(connector(url).stream.listen(handleMessage));
    };

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (failAfter != null && DateTime.now().isAfter(failAfter)) {
        print("oh MAN failAfter is ${failAfter.toIso8601String()} better FAIL");
        subscription?.cancel();
        handleSubscriptionEnd();
      }
    });
    
    setSubscription(connector(url).stream.listen(handleMessage));
    return controller.stream;
  }
}
