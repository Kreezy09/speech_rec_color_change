import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

void main() => runApp(const ColorChangeApp());

class ColorChangeApp extends StatefulWidget {
  const ColorChangeApp({super.key});

  @override
  State<ColorChangeApp> createState() => _ColorChangeAppState();
}

class _ColorChangeAppState extends State<ColorChangeApp> {
  bool _hasSpeech = false;
  String lastWords = '';
  String lastError = '';
  Color backgroundColor = Colors.white;
  final SpeechToText speech = SpeechToText();

  @override
  void initState() {
    super.initState();
    initSpeechState();
  }

  Future<void> initSpeechState() async {
    // Try to initialize the speech-to-text plugin
    try {
      bool hasSpeech = await speech.initialize(
        onError: errorListener,
        onStatus: statusListener,
      );
      setState(() {
        _hasSpeech = hasSpeech;
      });
    } catch (e) {
      setState(() {
        lastError = 'Initialization failed: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: const Text('Color Change with Speech'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Say "blue" or "red" to change the background color',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'Recognized Words: $lastWords',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              Text(
                'Error: $lastError',
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _hasSpeech ? startListening : null,
                child: const Text('Start Listening'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: stopListening,
                child: const Text('Stop Listening'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void startListening() {
    lastWords = '';
    lastError = '';
    speech.listen(
      onResult: resultListener,
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
      localeId: 'en_US',
      cancelOnError: true,
      partialResults: true,
    );
    setState(() {});
  }

  void stopListening() {
    speech.stop();
  }

  void resultListener(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords.toLowerCase();

      // Check if the recognized words include "blue" or "red" and change color
      if (lastWords.contains("blue")) {
        backgroundColor = Colors.blue;
      } else if (lastWords.contains("red")) {
        backgroundColor = Colors.red;
      }
    });
  }

  void errorListener(SpeechRecognitionError error) {
    setState(() {
      lastError = 'Error: ${error.errorMsg} - permanent: ${error.permanent}';
    });
  }

  void statusListener(String status) {
    setState(() {
      lastError = 'Status: $status';
    });
    if (status == 'done' && !_hasSpeech) {
      // Try to reinitialize if initialization wasn't successful
      initSpeechState();
    }
  }
}
