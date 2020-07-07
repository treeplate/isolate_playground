
// Example of bi-directional communication between a main thread and isolate.

import 'dart:async';
import 'dart:isolate';

Future<SendPort> initIsolate() async {
  Completer completer = new Completer<SendPort>();
  ReceivePort isolateToMainStream = ReceivePort();
  SendPort mainToIsolateStream;
  isolateToMainStream.listen((data) {
    if (data is SendPort) {
      mainToIsolateStream = data;
      completer.complete(mainToIsolateStream);
    } else {
      print('isolate > $data');
      if("$data".startsWith("Got ")) {
        print("ACK > isolate");
        mainToIsolateStream.send("ACK");
      } else if (data == "ACK") {} else {
        print("Got $data > isolate");
        mainToIsolateStream.send("Got $data");
      }
    }
  });

  Isolate myIsolateInstance = await Isolate.spawn(myIsolate, isolateToMainStream.sendPort);
  return completer.future;
}

void myIsolate(SendPort isolateToMainStream) {
  ReceivePort mainToIsolateStream = ReceivePort();
  isolateToMainStream.send(mainToIsolateStream.sendPort);

  mainToIsolateStream.listen((data) {
    print('main > $data');
    if("$data".startsWith("Got ")) {
        print("ACK > main");
        isolateToMainStream.send("ACK");
      } else if (data == "ACK") {} else {
        print("Got $data > main");
        isolateToMainStream.send("Got $data");
      }
  });
  print("This is from myIsolate() > main");
  isolateToMainStream.send('This is from myIsolate()');
}

void main() async {
  SendPort mainToIsolateStream = await initIsolate();
  print("This is from main() > isolate");
  mainToIsolateStream.send('This is from main()');
}