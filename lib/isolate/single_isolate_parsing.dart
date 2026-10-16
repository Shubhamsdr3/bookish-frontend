import 'dart:convert';
import 'dart:isolate';

class SingleIsolateParsing {

  late SendPort sendPort;

  void isolateCallback(SendPort sendPort) {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    receivePort.listen((dynamic message) {
      final incomingMessage = message as JsonIsolateMessage;
      incomingMessage.sender.send(json.decode(incomingMessage.text));
    });
  }

  Future<void> initParsing() async {
    final receivePort = ReceivePort();

    await Isolate.spawn(
      isolateCallback,
      receivePort.sendPort,
    );

    sendPort = await receivePort.first;
  }

  Future<void> parseJson() async {
    if (sendPort == null) {
      await initParsing();
    }

    final receivePort = ReceivePort();

    final jsonToParse = json.encode({'key': 'value'});

    sendPort.send(JsonIsolateMessage(receivePort.sendPort, jsonToParse));

    await receivePort.first;
  }
}

class JsonIsolateMessage {
  final SendPort sender;
  final String text;

  JsonIsolateMessage(this.sender, this.text);
}