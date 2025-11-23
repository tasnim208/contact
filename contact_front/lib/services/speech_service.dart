import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  Future<void> initialize() async {
    await _speech.initialize();
  }

  Future<String?> startListening({
    required Function(String text) onResult,
    required Function() onError,
  }) async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      
      if (available) {
        _isListening = true;
        _speech.listen(
          onResult: (result) {
            if (result.finalResult) {
              onResult(result.recognizedWords);
              _isListening = false;
            }
          },
          listenFor: Duration(seconds: 30),
          cancelOnError: true,
          partialResults: true,
        );
      } else {
        onError();
        return "Reconnaissance vocale non disponible";
      }
    }
    return null;
  }

  void stopListening() {
    if (_isListening) {
      _speech.stop();
      _isListening = false;
    }
  }

  bool get isListening => _isListening;

  void dispose() {
    stopListening();
  }
}