import 'dart:async';
import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/status_message.dart';

typedef WebSocketConnector = WebSocketChannel Function(String url);

class StatusRepository {
  final WebSocketConnector connector;

  StatusRepository({@required this.connector});

  StreamChannel<dynamic> connect(String url) {
    return _Connector(connector, url).start();
  }
}

class _Connector {
  final WebSocketConnector connector;
  final String url;
  _Connector(this.connector, this.url);

  StreamChannel<dynamic> start() {
    /*final controller = StreamController(
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
    return controller.stream;*/
    final controller = StreamChannelController();
    localChannel = controller.local;
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (failAfter != null && DateTime.now().isAfter(failAfter)) {
        print("failAfter is ${failAfter.toIso8601String()} time to FAIL");
        subscription?.cancel();
        handleSubscriptionEnd();
      }
    });
    final connection = connector(url);
    localChannel.stream.listen((data) {
      connection.sink.add(data);
    }).onDone(() {
      retry = false;
      subscription.cancel();
      timer.cancel();
    });
    subscription = connection.stream.listen(handleMessage);
    return controller.foreign;
  }

  bool retry = true;
  StreamChannel<dynamic> localChannel;
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
      localChannel.sink.add(PacketMessage.fromJson(jsonDecode(msg)));
      failAfter = DateTime.now().add(const Duration(seconds: 1));
    }
  }

  void handleSubscriptionEnd() {
    if (!retry) return;
    localChannel.sink.add(const DisconnectMessage());
    subscription = connector(url).stream.listen(handleMessage);
  }
}
