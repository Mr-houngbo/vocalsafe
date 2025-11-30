import 'package:flutter/material.dart';
import 'dart:math';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/voice_service.dart';
import '../../../../core/services/permission_service.dart';

class VoiceListeningScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final Function(String, [Map<String, dynamic>?])? onNavigateToConfirmation;
  final Function(String)? onTranscriptionReceived;
  
  const VoiceListeningScreen({
    super.key,
    this.onBack,
    this.onNavigateToConfirmation,
    this.onTranscriptionReceived,
  });

  @override
  State<VoiceListeningScreen> createState() => _VoiceListeningScreenState();
}

class _VoiceListeningScreenState extends State<VoiceListeningScreen>
    with TickerProviderStateMixin {
  bool _isListening = false;
  String _partialText = '';
  bool _permissionGranted = false;
  bool _permissionChecked = false;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _checkPermissionsAndStart();
  }
  
  Future<void> _checkPermissionsAndStart() async {
    final hasPermission = await PermissionService.checkMicrophonePermission();
    setState(() {
      _permissionChecked = true;
      _permissionGranted = hasPermission;
    });
    
    if (!hasPermission) {
      await _requestPermission();
    }
  }
  
  Future<void> _requestPermission() async {
    final granted = await PermissionService.requestMicrophonePermission();
    setState(() {
      _permissionGranted = granted;
    });
    
    if (granted) {
      _startListening();
    }
  }
  
  void _startListening() async {
    if (!_permissionGranted) return;
    
    setState(() {
      _isListening = true;
      _partialText = '';
    });
    
    _waveController.repeat();
    
    await VoiceService.startListening(
      onResult: (text) {
        setState(() {
          _partialText = text;
        });
      },
    ).then((text) {
      setState(() {
        _isListening = false;
        _partialText = text;
      });
      _waveController.stop();
      _handleTranscription(text);
    }).catchError((error) {
      setState(() {
        _isListening = false;
      });
      _waveController.stop();
      _showErrorDialog(error.toString());
    });
  }
  
  void _stopListening() async {
    await VoiceService.stopListening();
    setState(() {
      _isListening = false;
    });
    _waveController.stop();
  }
  
  void _handleTranscription(String text) {
    if (text.trim().isNotEmpty) {
      if (widget.onTranscriptionReceived != null) {
        widget.onTranscriptionReceived!(text);
      } else if (widget.onNavigateToConfirmation != null) {
        widget.onNavigateToConfirmation!(text);
      } else {
        context.go('/voice-confirmation', extra: text);
      }
    }
  }
  
  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erreur'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    VoiceService.stopListening();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pureWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.pureWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryOrange),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else {
              context.go('/');
            }
          },
        ),
        title: const Text(
          'Assistant Vocal',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // Header minimaliste
              _buildMinimalHeader(context),
              
              const SizedBox(height: 40),
              
              // Animation d'écoute
              _buildListeningAnimation(context),
              
              const SizedBox(height: 32),
              
              // Texte transcrit
              _buildTranscriptionText(context),
              
              const SizedBox(height: 32),
              
              // Boutons d'action
              _buildActionButtons(context),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildMinimalHeader(BuildContext context) {
    return Column(
      children: [
        Text(
          'Dites votre transaction',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Ex: "Envoie 5000 F à Marie via Orange"',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  Widget _buildListeningAnimation(BuildContext context) {
    return Column(
      children: [
        // Cercle d'animation
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.orangeGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryOrange.withOpacity(0.3),
                    blurRadius: 15 + 8 * _pulseController.value,
                    spreadRadius: 1.5 * _pulseController.value,
                  ),
                ],
              ),
              child: Container(
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.pureWhite,
                ),
                child: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  size: 40,
                  color: _isListening ? AppTheme.primaryOrange : AppTheme.textLight,
                ),
              ),
            );
          },
        ),
        
        const SizedBox(height: 16),
        
        // Vagues d'animation
        if (_isListening)
          AnimatedBuilder(
            animation: _waveController,
            builder: (context, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final height = 16.0 + 24.0 * 
                      (0.5 + 0.5 * sin((_waveController.value * 2 * pi + index * 0.5)));
                  return Container(
                    width: 3,
                    height: height,
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryOrange.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  );
                }),
              );
            },
          ),
      ],
    );
  }
  
  Widget _buildTranscriptionText(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.offWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightGray,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isListening ? 'Écoute en cours...' : 'Transcription',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _partialText.isNotEmpty ? _partialText : 'En attente...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: _partialText.isNotEmpty ? AppTheme.textPrimary : AppTheme.textLight,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButtons(BuildContext context) {
    if (!_permissionChecked) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryOrange,
        ),
      );
    }
    
    if (!_permissionGranted) {
      return Column(
        children: [
          const Icon(
            Icons.mic_off,
            size: 48,
            color: AppTheme.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            'Permission du microphone requise',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _requestPermission,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                foregroundColor: AppTheme.pureWhite,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Autoriser le microphone'),
            ),
          ),
        ],
      );
    }
    
    return Column(
      children: [
        // Bouton principal
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isListening ? _stopListening : _startListening,
            icon: Icon(_isListening ? Icons.stop : Icons.mic),
            label: Text(_isListening ? 'Arrêter' : 'Commencer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isListening ? AppTheme.textLight : AppTheme.primaryOrange,
              foregroundColor: _isListening ? AppTheme.textPrimary : AppTheme.pureWhite,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        
        if (_partialText.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _handleTranscription(_partialText),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.primaryOrange),
                foregroundColor: AppTheme.primaryOrange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Continuer'),
            ),
          ),
        ],
      ],
    );
  }
}
