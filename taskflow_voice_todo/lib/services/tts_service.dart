import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;
  
  bool get isInitialized => _isInitialized;
  bool _isSpeaking = false;
  
  TtsService() {
    _initTts();
  }
  
  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      
      _tts.setCompletionHandler(() {
        _isSpeaking = false;
      });
      
      _isInitialized = true;
    } catch (e) {
      debugPrint('TTS initialization error: $e');
      _isInitialized = false;
    }
  }
  
  // Speak a given message
  Future<bool> speak(String message) async {
    if (!_isInitialized) {
      await _initTts();
      if (!_isInitialized) return false;
    }
    
    if (_isSpeaking) {
      await _tts.stop();
    }
    
    _isSpeaking = true;
    await _tts.speak(message);
    return true;
  }
  
  // Stop speaking
  Future<bool> stop() async {
    if (!_isInitialized) return false;
    
    if (_isSpeaking) {
      await _tts.stop();
      _isSpeaking = false;
      return true;
    }
    
    return false;
  }
  
  // Dispose the service
  void dispose() {
    _tts.stop();
    _isSpeaking = false;
  }
  
  // Get supported languages
  Future<List<String>> getLanguages() async {
    if (!_isInitialized) {
      await _initTts();
    }
    return _tts.getLanguages.then((value) => value.cast<String>());
  }
  
  // Set a specific voice
  Future<void> setVoice(Map<String, String> voice) async {
    if (!_isInitialized) {
      await _initTts();
    }
    await _tts.setVoice(voice);
  }
  
  // Get available voices
  Future<List<Map<String, String>>> getVoices() async {
    if (!_isInitialized) {
      await _initTts();
    }
    
    final voices = await _tts.getVoices;
    return voices is List ? voices.cast<Map<String, String>>() : [];
  }
} 