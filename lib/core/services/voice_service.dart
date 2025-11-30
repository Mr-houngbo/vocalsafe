import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'permission_service.dart';

class VoiceService {
  static final SpeechToText _speech = SpeechToText();
  static final FlutterTts _tts = FlutterTts();
  
  static bool _isInitialized = false;
  static bool _isCurrentlySpeaking = false;
  
  static Future<void> init() async {
    if (_isInitialized) return;
    
    // Vérifier et demander les permissions microphone
    final hasPermission = await PermissionService.checkMicrophonePermission();
    if (!hasPermission) {
      final granted = await PermissionService.requestMicrophonePermission();
      if (!granted) {
        debugPrint('Microphone permission denied');
        return;
      }
    }
    
    // Initialiser la reconnaissance vocale
    bool available = await _speech.initialize(
      onError: (error) => debugPrint('Speech error: $error'),
      onStatus: (status) => debugPrint('Speech status: $status'),
    );
    
    if (!available) {
      debugPrint('Speech recognition not available');
    }
    
    // Configurer la synthèse vocale
    await _tts.setLanguage('fr-FR');
    await _tts.setSpeechRate(0.8);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    
    // Configurer les callbacks pour suivre l'état
    _tts.setCompletionHandler(() {
      _isCurrentlySpeaking = false;
    });
    
    _tts.setErrorHandler((msg) {
      debugPrint('TTS Error: $msg');
      _isCurrentlySpeaking = false;
    });
    
    _isInitialized = true;
  }
  
  // Vérifier si la reconnaissance vocale est disponible
  static bool get isAvailable => _speech.isAvailable;
  
  // Démarrer l'écoute
  static Future<String> startListening({
    Function(String)? onResult,
    Function(String)? onPartialResult,
    VoidCallback? onListeningStarted,
    VoidCallback? onListeningComplete,
  }) async {
    if (!_isInitialized) await init();
    
    if (!_speech.isAvailable) {
      debugPrint('Speech recognition not available');
      return 'Speech recognition not available';
    }
    
    await _speech.listen(
      onResult: (result) {
        final words = result.recognizedWords;
        if (result.finalResult) {
          onResult?.call(words);
          onListeningComplete?.call();
        } else {
          onPartialResult?.call(words);
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      localeId: 'fr_FR',
    );
    
    onListeningStarted?.call();
    return '';
  }
  
  // Arrêter l'écoute
  static Future<void> stopListening() async {
    await _speech.stop();
  }
  
  // Annuler l'écoute
  static Future<void> cancelListening() async {
    await _speech.cancel();
  }
  
  // Parler du texte
  static Future<void> speak(String text) async {
    if (!_isInitialized) await init();
    
    if (text.isEmpty) return;
    
    try {
      _isCurrentlySpeaking = true;
      await _tts.speak(text);
    } catch (e) {
      debugPrint('TTS Error: $e');
      _isCurrentlySpeaking = false;
    }
  }
  
  // Arrêter la parole
  static Future<void> stopSpeaking() async {
    try {
      await _tts.stop();
    } catch (e) {
      debugPrint('TTS Stop Error: $e');
    }
    _isCurrentlySpeaking = false;
  }
  
  // Vérifier si en train de parler
  static bool get isSpeaking => _isCurrentlySpeaking;
  
  // Stream pour les résultats de reconnaissance
  static Stream<String>? get recognitionStream => null;
}
