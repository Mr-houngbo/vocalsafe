import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/voice_service.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onNavigateToVoice;
  
  const HomeScreen({
    super.key,
    this.onNavigateToVoice,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    
    // Animation de pulsation pour attirer l'attention
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    VoiceService.stopListening();
    super.dispose();
  }

  Future<void> _startListeningDirectly() async {
    setState(() {
      _isListening = true;
    });

    try {
      await VoiceService.startListening(
        onResult: (text) {
          // Navigation directe vers la page de confirmation avec le résultat
          if (text.isNotEmpty) {
            VoiceService.stopListening();
            context.go('/voice-confirmation', extra: text);
          }
        },
        onPartialResult: (text) {
          // Optionnel: afficher le résultat partiel si nécessaire
        },
        onListeningStarted: () {
          print("Écoute démarrée");
        },
        onListeningComplete: () {
          setState(() {
            _isListening = false;
          });
        },
      ).catchError((error) {
        print("Erreur d'écoute: $error");
        setState(() {
          _isListening = false;
        });
      });
    } catch (e) {
      print("Exception: $e");
      setState(() {
        _isListening = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pureWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Header ultra-minimal
            _buildMinimalHeader(),
            
            // Zone principale centrée
            Expanded(
              child: _buildCenterContent(context),
            ),
            
            // Texte en bas
            _buildBottomText(context),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMinimalHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppTheme.orangeGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.mic,
              size: 20,
              color: AppTheme.pureWhite,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Vocalsafe',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCenterContent(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // BOUTON VOCAL GÉANT
            _buildGiantVoiceButton(context),
            
            const SizedBox(height: 24),
            
            Text(
              _isListening ? 'Écoute en cours...' : 'Appuyez pour parler',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: _isListening ? AppTheme.primaryOrange : AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 48),
            
            // Exemple visuel simple
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.lightGray.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.pureWhite,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.mic,
                      size: 18,
                      color: AppTheme.primaryOrange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Exemple :',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '"Envoie 500 F à Mamadou"',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildGiantVoiceButton(BuildContext context) {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: GestureDetector(
        onTap: _isListening ? null : _startListeningDirectly,
        child: Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            gradient: _isListening 
                ? AppTheme.orangeGradient 
                : AppTheme.orangeGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryOrange.withOpacity(_isListening ? 0.5 : 0.3),
                blurRadius: _isListening ? 50 : 40,
                spreadRadius: _isListening ? 2 : 0,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Cercle d'animation externe
              if (_isListening) ...[
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.pureWhite.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                ),
                // Vagues sonores pendant l'écoute
                for (int i = 0; i < 3; i++)
                  Positioned.fill(
                    child: Container(
                      margin: EdgeInsets.all(20.0 * (i + 1)),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.pureWhite.withOpacity(0.2 - (i * 0.05)),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ] else ...[
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.pureWhite.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                ),
              ],
              
              // Icône micro
              Icon(
                _isListening ? Icons.mic : Icons.mic,
                size: 72,
                color: AppTheme.pureWhite,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildBottomText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Text(
        'Vocalsafe • Transactions vocales',
        style: TextStyle(
          fontSize: 12,
          color: AppTheme.textLight,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
