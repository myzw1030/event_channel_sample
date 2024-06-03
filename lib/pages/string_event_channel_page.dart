import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StringEventChannelPage extends StatefulWidget {
  const StringEventChannelPage({super.key});

  @override
  State<StringEventChannelPage> createState() => _StringEventChannelPageState();
}

class _StringEventChannelPageState extends State<StringEventChannelPage> {
  static const eventChannel =
      EventChannel('com.example.eventChannel.stringEventChannel');

  String _messageFromNative = 'Not received';

  StreamSubscription<dynamic>? _stringSubscription;

  void _streamStringFromNative() {
    _stringSubscription = eventChannel.receiveBroadcastStream().listen((event) {
      if (!mounted) return;
      setState(() {
        print('Received message: $event');
        _messageFromNative = event.toString();
      });
    }, onError: (error) {
      print('Error: $error');
    });
  }

  @override
  void dispose() {
    _stringSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Message from native: $_messageFromNative',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _streamStringFromNative,
              child: const Text('Receive message from native'),
            ),
          ],
        ),
      ),
    );
  }
}
