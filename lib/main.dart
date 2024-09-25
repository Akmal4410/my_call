import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'dart:async';
import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  List<FileSystemEntity> _recordings = [];
  late String _storagePath;
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    var status = await Permission.microphone.request();
    if (status.isGranted) {
      status = await Permission.phone.request();
      if (status.isGranted) {
        status = await Permission.storage.request();
        if (status.isGranted) {
          _loadRecordings();
        } else {
          print('Storage permission not granted');
        }
      } else {
        print('Phone permission not granted');
      }
    } else {
      print('Microphone permission not granted');
    }
  }

  Future<void> _loadRecordings() async {
    final directory = await getExternalStorageDirectory();
    setState(() {
      _storagePath = directory!.path;
      _recordings = Directory(_storagePath).listSync();
    });
  }

  void _makeCall(String phoneNumber) async {
    await FlutterPhoneDirectCaller.callNumber(phoneNumber);
  }

  void _playRecording(String filePath) async {
    await _audioPlayer.setFilePath(filePath);
    _audioPlayer.play();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Call Recorder')),
        body: Column(
          children: [
            ElevatedButton(
              onPressed: () => _makeCall('1234567890'),
              child: const Text('Make a Call'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _recordings.length,
                itemBuilder: (context, index) {
                  final file = _recordings[index];
                  return ListTile(
                    title: Text(file.path.split('/').last),
                    onTap: () => _playRecording(file.path),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
