import 'package:go_router/go_router.dart';

import '../../features/voice/screens/voice_listening_screen.dart';
import '../../features/voice/screens/voice_confirmation_screen.dart';
import '../../features/transaction/screens/transaction_success_screen.dart';
import '../../features/history/screens/history_screen.dart';
import '../../features/alerts/screens/alerts_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/navigation/screens/main_navigation_screen.dart';
import '../../features/home/screens/home_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // Route principale avec navigation
      GoRoute(
        path: '/',
        builder: (context, state) => const MainNavigationScreen(),
        routes: [
          // Sous-routes pour les pages vocales (remplacent l'écran principal)
          GoRoute(
            path: 'voice-listening',
            builder: (context, state) => const VoiceListeningScreen(),
          ),
          GoRoute(
            path: 'voice-confirmation',
            builder: (context, state) => VoiceConfirmationScreen(
              transcribedText: state.extra as String? ?? '',
            ),
          ),
          GoRoute(
            path: 'transaction-success',
            builder: (context, state) => const TransactionSuccessScreen(),
          ),
        ],
      ),
      // Routes directes pour les autres pages
      GoRoute(
        path: '/history',
        builder: (context, state) => const MainNavigationScreen(
          initialIndex: 1,
        ),
      ),
      GoRoute(
        path: '/alerts',
        builder: (context, state) => const MainNavigationScreen(
          initialIndex: 2,
        ),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const MainNavigationScreen(
          initialIndex: 3,
        ),
      ),
    ],
  );
}
