import 'package:flutter/material.dart';
import '../services/speech_service.dart';
import '../utils/constants.dart'; 

class VoiceSearchButton extends StatefulWidget {
  final Function(String) onTextRecognized;
  final Function(String) onError;

  const VoiceSearchButton({
    Key? key,
    required this.onTextRecognized,
    required this.onError,
  }) : super(key: key);

  @override
  _VoiceSearchButtonState createState() => _VoiceSearchButtonState();
}

class _VoiceSearchButtonState extends State<VoiceSearchButton> {
  final SpeechService _speechService = SpeechService();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speechService.initialize();
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      _speechService.stopListening();
      setState(() => _isListening = false);
    } else {
      final error = await _speechService.startListening(
        onResult: (text) {
          widget.onTextRecognized(text);
          setState(() => _isListening = false);
        },
        onError: () {
          widget.onError('Erreur de reconnaissance vocale');
          setState(() => _isListening = false);
        },
      );

      if (error == null) {
        setState(() => _isListening = true);
      } else {
        widget.onError(error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: _isListening ? Colors.red : Color(AppConstants.primaryColor),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          _isListening ? Icons.mic_off : Icons.mic,
          color: Colors.white,
          size: 24,
        ),
        onPressed: _toggleListening,
        padding: EdgeInsets.zero,
      ),
    );
  }

  @override
  void dispose() {
    _speechService.dispose();
    super.dispose();
  }
}