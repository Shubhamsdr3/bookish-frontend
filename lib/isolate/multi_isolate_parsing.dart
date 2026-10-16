import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

class MultiIsolateParsing {

  late List<SendPort> availableSendPorts;
  final sendPortStream = StreamController<void>.broadcast();

  Future<SendPort> intialize() async {
    final receivePort = ReceivePort();

    await Isolate.spawn(
      isolateCallback,
      receivePort.sendPort,
    );

    return await receivePort.first;
  }

  void isolateCallback(SendPort sendPort) {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    receivePort.listen((dynamic message) {
      final incomingMessage = message as JsonIsolateMessage;
      incomingMessage.sender.send(json.decode(incomingMessage.text));
    });
  }

  Future<void> initParsing() async {
    availableSendPorts = await Future.wait([
      intialize(),
      intialize(),
      intialize(),
      intialize(),
      intialize(),
      intialize(),
      intialize(),
      intialize(),
    ]);
  }

  Future<void> parseJson() async {
    if (availableSendPorts.isEmpty) {
      await sendPortStream.stream.first;
    }

    final sendPort = availableSendPorts.removeAt(0);

    final receivePort = ReceivePort();

    final jsonToParse = "{}";

    sendPort.send(JsonIsolateMessage(receivePort.sendPort,  jsonToParse));

    await receivePort.first;

    availableSendPorts.add(sendPort);
    sendPortStream.add(null);
  }
}

class JsonIsolateMessage {
  final SendPort sender;
  final String text;

  JsonIsolateMessage(this.sender, this.text);
}