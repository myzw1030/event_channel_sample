import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TimeEventChannelPage extends StatefulWidget {
  const TimeEventChannelPage({super.key});

  @override
  State<TimeEventChannelPage> createState() => _TimeEventChannelPageState();
}

class _TimeEventChannelPageState extends State<TimeEventChannelPage> {
  static const eventChannel =
      EventChannel('com.example.eventChannel.timeEventChannel');

  Stream<String> streamTimeFromNative() {
    return eventChannel
        .receiveBroadcastStream()
        .map((event) => event.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder<String>(
              stream: streamTimeFromNative(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    '現在時刻：${snapshot.data}',
                    style: const TextStyle(fontSize: 24),
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
