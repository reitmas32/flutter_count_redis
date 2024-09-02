import 'package:flutter/material.dart';
import 'package:redis/redis.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  int count = 0;

  Future<void> readData() async {

    // Create Conection
    Command cmd = await RedisConnection().connect('localhost', 6379);
    final pubsub = PubSub(cmd);

    // Susbribe to topic
    pubsub.subscribe(["count"]);
    final stream = pubsub.getStream();
    var streamWithoutErrors =
        stream.handleError((e) => print("$e"));

    // read Messages
    await for (final msg in streamWithoutErrors) {
      //var kind = msg[0];
      var food = msg[2];

      // Change Value of count
      setState(() {
        count = int.parse(food.toString());
      });
    }
  }

  Future<void> writeData(int count) async {
    Command cmd = await RedisConnection().connect('localhost', 6379);
    await cmd.send_object(["PUBLISH", "count", count]);
    cmd.get_connection().close();
  }

  @override
  void initState() {
    super.initState();
    readData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Counter with Redis'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$count',
                style: const TextStyle(fontSize: 45),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            var ftx = writeData(count + 1);
            await ftx;
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
