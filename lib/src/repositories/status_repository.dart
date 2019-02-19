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
    return _Connector(connector, url).start();
  }
}

class _Connector {
  final WebSocketConnector connector;
  final String url;
  _Connector(this.connector, this.url);

  Stream<StatusMessage> start() {
    controller = StreamController(
      onPause: () => subscription.pause(),
      onResume: () => subscription.resume(),
      onCancel: () {
        retry = false;
        subscription.cancel();
        timer.cancel();
      },
    );
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (failAfter != null && DateTime.now().isAfter(failAfter)) {
        print("failAfter is ${failAfter.toIso8601String()} time to FAIL");
        subscription?.cancel();
        handleSubscriptionEnd();
      }
    });
    subscription = connector(url).stream.listen(handleMessage);
    return controller.stream;
  }

  bool retry = true;
  StreamController<StatusMessage> controller;
  Timer timer;

  DateTime failAfter;

  StreamSubscription _subscription;
  StreamSubscription get subscription => _subscription;
  set subscription(StreamSubscription sub) {
    _subscription = sub;
    failAfter = DateTime.now().add(const Duration(seconds: 1));
    sub.onDone(handleSubscriptionEnd);
  }

  void handleMessage(msg) {
    if (msg is String) {
      //print(msg);
      controller.add(PacketMessage.fromJson(jsonDecode(msg)));
      failAfter = DateTime.now().add(const Duration(seconds: 1));
    }
  }

  void handleSubscriptionEnd() {
    if (!retry) return;
    controller.add(const DisconnectMessage());
    subscription = connector(url).stream.listen(handleMessage);
  }
}