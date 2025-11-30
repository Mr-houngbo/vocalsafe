import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../home/screens/home_screen.dart';
import '../../history/screens/history_screen.dart';
import '../../alerts/screens/alerts_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../voice/screens/voice_listening_screen.dart';
import '../../voice/screens/voice_confirmation_screen.dart';
import '../../transaction/screens/transaction_success_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;
  
  const MainNavigationScreen({
    super.key, 
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;
  String? _currentRoute;
  Map<String, dynamic>? _currentTransactionData;
  late List<Widget> _screens;
  
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _screens = [
      HomeScreen(
        onNavigateToVoice: () => _navigateToRoute('/voice-listening'),
      ),
      const HistoryScreen(),
      const AlertsScreen(),
      const ProfileScreen(),
    ];
  }
  
  void _navigateToRoute(String route, [Map<String, dynamic>? data]) {
    setState(() {
      _currentRoute = route;
      if (route == '/voice-confirmation') {
        // Stocker les données de confirmation pour la page de confirmation
        _currentTransactionData = data;
      }
    });
    context.go(route, extra: data);
  }
  
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    // Navigation vers les différentes pages
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/history');
        break;
      case 2:
        context.go('/alerts');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pureWhite,
      body: Column(
        children: [
          // Contenu principal
          Expanded(
            child: _currentRoute != null 
                ? _buildVoiceFlowScreen()
                : _screens[_currentIndex],
          ),
          
          // Bottom Navigation minimaliste
          _buildMinimalBottomNav(context),
        ],
      ),
    );
  }
  
  Widget _buildVoiceFlowScreen() {
    // Afficher les écrans du flux vocal
    switch (_currentRoute) {
      case '/voice-listening':
        return VoiceListeningScreen(
          onTranscriptionReceived: (transcription) {
            _navigateToRoute('/voice-confirmation', {
              'transcription': transcription,
            });
          },
          onBack: () {
            setState(() {
              _currentRoute = null;
            });
            context.go('/');
          },
        );
      case '/voice-confirmation':
        return VoiceConfirmationScreen(
          transcribedText: _currentTransactionData?['transcription'] ?? '',
          onBack: () {
            setState(() {
              _currentRoute = null;
              _currentTransactionData = null;
            });
            context.go('/');
          },
          onNavigateToTransaction: (route, [data]) {
            _navigateToRoute(route, data);
          },
        );
      case '/transaction-success':
        return TransactionSuccessScreen(
          onBack: () {
            setState(() {
              _currentRoute = null;
              _currentTransactionData = null;
            });
            context.go('/');
          },
        );
      default:
        return _screens[_currentIndex];
    }
  }
  
  Widget _buildMinimalBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        border: Border(
          top: BorderSide(
            color: AppTheme.lightGray,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                index: 0,
                label: 'Accueil',
              ),
              _buildNavItem(
                context,
                icon: Icons.history_outlined,
                selectedIcon: Icons.history,
                index: 1,
                label: 'Historique',
              ),
              _buildNavItem(
                context,
                icon: Icons.notifications_outlined,
                selectedIcon: Icons.notifications,
                index: 2,
                label: 'Alertes',
              ),
              _buildNavItem(
                context,
                icon: Icons.person_outline,
                selectedIcon: Icons.person,
                index: 3,
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData selectedIcon,
    required int index,
    required String label,
  }) {
    final isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected ? AppTheme.primaryOrange : AppTheme.textLight,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppTheme.primaryOrange : AppTheme.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
