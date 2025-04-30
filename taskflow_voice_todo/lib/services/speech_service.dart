import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;

  // Public getters
  bool get isListening => _isListening;
  bool get isAvailable => _isInitialized;

  // Initialize the speech recognition service
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    debugPrint('Initializing speech recognition...');
    _isInitialized = await _speech.initialize(
      onError: (error) => debugPrint('Speech recognition error: $error'),
      onStatus: (status) => debugPrint('Speech recognition status: $status'),
      debugLogging: true,
    );
    
    debugPrint('Speech recognition initialized: $_isInitialized');
    return _isInitialized;
  }

  // Start listening for voice input
  Future<void> startListening({
    required Function(String text) onResult,
    required VoidCallback onComplete,
  }) async {
    if (!_isInitialized) {
      debugPrint('Speech recognition not initialized, attempting initialization...');
      final initialized = await initialize();
      if (!initialized) {
        debugPrint('Failed to initialize speech recognition');
        onComplete();
        return;
      }
    }

    if (_speech.isAvailable && !_isListening) {
      debugPrint('Starting speech recognition...');
      _isListening = true;
      
      // Get available locales and log them for debugging
      final locales = await _speech.locales();
      debugPrint('Available locales: ${locales.map((e) => e.localeId).join(', ')}');
      
      await _speech.listen(
        onResult: (SpeechRecognitionResult result) {
          debugPrint('Speech result: ${result.recognizedWords}, final: ${result.finalResult}');
          
          if (result.finalResult) {
            onResult(result.recognizedWords);
            _isListening = false;
            onComplete();
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5),
        partialResults: true,
        localeId: 'en_US',
        cancelOnError: false,
        listenMode: stt.ListenMode.confirmation,
      );
    } else {
      debugPrint('Cannot start speech recognition. Available: ${_speech.isAvailable}, Already listening: $_isListening');
    }
  }

  // Stop listening before the timeout
  Future<void> stopListening() async {
    if (_isListening) {
      debugPrint('Stopping speech recognition');
      await _speech.stop();
      _isListening = false;
    }
  }

  // Get available locales for speech recognition
  Future<List<stt.LocaleName>> getAvailableLocales() async {
    if (!_isInitialized) {
      await initialize();
    }
    final locales = await _speech.locales();
    debugPrint('Available locales: ${locales.map((e) => e.localeId).join(', ')}');
    return locales;
  }

  // Dispose the service
  void dispose() {
    _speech.cancel();
    _isListening = false;
    debugPrint('Speech recognition disposed');
  }
} 