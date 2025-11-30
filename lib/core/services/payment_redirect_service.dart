import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


// IMPORTANT : Les schémas d'URI des deep links ('orangemoney://', 'wave://', etc.) 
// et leurs paramètres exacts ne sont généralement pas publics et doivent être vérifiés 
// ou déterminés par rétro-ingénierie sur chaque application opérateur.
// Le code ci-dessous utilise des schémas hypothétiques basés sur les standards.


class PaymentRedirectService {
  // Deep links des opérateurs. Nous utilisons 'phone' comme paramètre générique
  // pour le numéro du destinataire, car c'est le plus commun.
  static const Map<String, String> operatorDeepLinks = {
    'orange': 'orangemoney://transfer?amount={amount}&phone={phone}&recipient={recipientName}',
    'wave': 'wave://send?amount={amount}&phone={phone}&recipient={recipientName}',
    'moov': 'moovmoney://transfer?amount={amount}&phone={phone}&recipient={recipientName}',
    'free': 'freemoney://send?amount={amount}&phone={phone}&recipient={recipientName}',
  };


  // URLs de fallback (Play Store/App Store)
  static const Map<String, String> operatorStoreUrls = {
    'orange': 'https://play.google.com/store/apps/details?id=com.orange.om.omwallet',
    'wave': 'https://play.google.com/store/apps/details?id=com.wave.android',
    'moov': 'https://play.google.com/store/apps/details?id=com.moovmoney.moovmoney',
    'free': 'https://play.google.com/store/apps/details?id=com.free.money.app',
  };


  // Patterns de détection pour la normalisation de l'opérateur à partir du NLU
  static Map<String, List<String>> get operatorPatterns => {
    'orange': ['orange', 'om', 'omoney', 'orange money'],
    'wave': ['wave', 'wave senegal', 'wave money'],
    'moov': ['moov', 'moo', 'moov money', 'moovmoney'],
    'free': ['free', 'free money', 'freemoney'],
  };


  /// Redirige vers l'application de l'opérateur en utilisant le Deep Link,
  /// ou bascule vers le Play Store si l'application n'est pas installée.
  static Future<bool> redirectToOperator({
    required String operator,
    required String amount,
    required String phoneNumber, // Numéro réel du destinataire
    required String recipientName, // Nom résolu (pour l'affichage/contexte)
  }) async {
    try {
      final normalizedOperator = _normalizeOperator(operator);
      
      if (normalizedOperator == null || !operatorDeepLinks.containsKey(normalizedOperator)) {
        debugPrint('Opérateur non supporté: $operator');
        return false;
      }


      // 1. Construction du Deep Link
      String deepLink = _buildDeepLink(
        normalizedOperator, 
        amount, 
        phoneNumber, 
        recipientName,
      );
      debugPrint('Tentative d\'ouverture du deep link: $deepLink');
      
      final uri = Uri.parse(deepLink);
      
      // 2. Vérification et Lancement du Deep Link
      if (await canLaunchUrl(uri)) {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        debugPrint('Résultat du lancement: $launched');
        return launched;
      } else {
        debugPrint('Deep link ne peut pas être lancé, fallback vers le Play Store');
        // 3. Fallback vers le Store si l'app n'est pas installée
        return await _redirectToStore(normalizedOperator);
      }
    } catch (e) {
      debugPrint('Erreur lors de la redirection vers $operator: $e');
      return false;
    }
  }


  /// Normalise le nom de l'opérateur (ex: "omoney" -> "orange").
  static String? _normalizeOperator(String operator) {
    final lowerOperator = operator.toLowerCase();
    
    for (final entry in operatorPatterns.entries) {
      for (final pattern in entry.value) {
        if (lowerOperator.contains(pattern)) {
          return entry.key;
        }
      }
    }
    return null;
  }


  /// Construit l'URL du Deep Link à partir du template.
  static String _buildDeepLink(
    String operator, 
    String amount, 
    String phoneNumber, 
    String recipientName,
  ) {
    String template = operatorDeepLinks[operator]!;
    
    // Remplacer les placeholders
    return template
        .replaceAll('{amount}', amount)
        .replaceAll('{phone}', phoneNumber)
        .replaceAll('{recipientName}', recipientName);
  }


  /// Ouvre la page de l'application sur le Play Store ou l'App Store.
  static Future<bool> _redirectToStore(String operator) async {
    final storeUrl = operatorStoreUrls[operator];
    if (storeUrl != null) {
      final uri = Uri.parse(storeUrl);
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  // Méthodes utilitaires pour la compatibilité avec le code existant
  static String getOperatorDisplayName(String operator) {
    final displayNames = {
      'orange': 'Orange Money',
      'wave': 'Wave',
      'moov': 'Moov Money',
      'free': 'Free Money',
      'etisalat': 'Etisalat Money',
    };
    
    final normalized = _normalizeOperator(operator);
    return displayNames[normalized] ?? operator;
  }
  
  static Color getOperatorColor(String operator) {
    final colors = {
      'orange': Colors.orange,
      'wave': Colors.blue,
      'moov': Colors.green,
      'free': Colors.red,
      'etisalat': Colors.purple,
    };
    
    final normalized = _normalizeOperator(operator);
    return colors[normalized] ?? Colors.grey;
  }

  static bool isOperatorSupported(String operator) {
    final normalized = _normalizeOperator(operator);
    return normalized != null && operatorDeepLinks.containsKey(normalized);
  }

  static List<String> getSupportedOperators() {
    return operatorDeepLinks.keys.toList();
  }
}
