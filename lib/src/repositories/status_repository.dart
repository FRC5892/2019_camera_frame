import 'dart:async';
import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/status_message.dart';

typedef WebSocketConnector = WebSocketChannel Function(String url);

class SocketDelegate {
  final Stream<StatusMessage> messageStream;
  final void Function(dynamic) returnMessage;

  SocketDelegate(this.messageStream, this.returnMessage);
}

class StatusRepository {
  final WebSocketConnector connector;
  final String url;

  StatusRepository({@required this.connector, @required this.url});

  DateTime _failAfter;
  Timer _timer;

  final StreamController<SocketDelegate> _delegateController =
      StreamController();
  WebSocketChannel _currentChannel;
  StreamController<StatusMessage> _currentDelegateStreamController;

  Stream<SocketDelegate> startConnecting() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_failAfter != null && DateTime.now().isAfter(_failAfter)) {
        _establishNewConnection();
      }
    });
    _establishNewConnection();
    return _delegateController.stream;
  }

  void _establishNewConnection() {
    _currentChannel?.sink?.close();
    _currentDelegateStreamController?.add(DisconnectMessage());
    _currentDelegateStreamController?.close();

    _currentChannel = connector(url);
    _currentDelegateStreamController = StreamController();
    _currentChannel.stream.listen((msg) {
      if (msg is String) {
        try {
          _currentDelegateStreamController
              .add(PacketMessage.fromJson(jsonDecode(msg)));
          _failAfter = DateTime.now().add(const Duration(milliseconds: 500));
        } on FormatException {}
      }
    }).onDone(_establishNewConnection);
    _delegateController.add(SocketDelegate(
        _currentDelegateStreamController.stream, _currentChannel.sink.add));

    _failAfter = DateTime.now().add(const Duration(seconds: 2));
  }

  void dispose() {
    _delegateController.close();
    _currentChannel.sink.close();
    _currentDelegateStreamController.close();
    _timer.cancel();
  }
}
