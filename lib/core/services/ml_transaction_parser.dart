import 'dart:math';
import 'senegal_context.dart';

class MLTransactionParser {
  static ParsedTransaction parseWithML(String transcription) {
    // 1. Normalisation contextuelle
    final normalizedText = SenegalContext.normalizeText(transcription);
    
    // 2. Extraction avec scoring probabiliste
    final result = _extractWithScoring(normalizedText, transcription);
    
    // 3. Validation et correction
    final validated = _validateAndCorrect(result);
    
    // 4. Calcul de confiance avancé
    validated.confidence = _calculateAdvancedConfidence(validated, normalizedText);
    
    return validated;
  }
  
  static ParsedTransaction _extractWithScoring(String normalizedText, String originalText) {
    final Map<String, double> typeScores = {};
    final Map<String, double> amountScores = {};
    final Map<String, double> recipientScores = {};
    final Map<String, double> operatorScores = {};
    
    // Types de transactions avec scoring
    typeScores['envoyer'] = _calculateTypeScore(normalizedText, [
      'envoie', 'envoyer', 'donne', 'fais', 'verse', 'transfère', 'dépose'
    ]);
    typeScores['recevoir'] = _calculateTypeScore(normalizedText, [
      'reçois', 'recevoir', 'retire', 'enlève', 'récupère'
    ]);
    typeScores['solde'] = _calculateTypeScore(normalizedText, [
      'solde', 'compte', 'consulte', 'vérifie', 'regarde', 'montant'
    ]);
    typeScores['recharger'] = _calculateTypeScore(normalizedText, [
      'recharge', 'recharger', 'charge', 'topup', 'crédit'
    ]);
    
    // Montants avec scoring
    amountScores.addAll(_extractAmountsWithScoring(normalizedText));
    
    // Destinataires avec scoring
    recipientScores.addAll(_extractRecipientsWithScoring(normalizedText));
    
    // Opérateurs avec scoring
    operatorScores.addAll(_extractOperatorsWithScoring(normalizedText));
    
    // Extraire téléphone
    final phoneNumber = _extractPhoneNumber(normalizedText);
    
    return ParsedTransaction(
      amount: _getBestScore(amountScores),
      recipient: _getBestScore(recipientScores),
      type: _getBestKey(typeScores),
      operator: _getBestKey(operatorScores),
      phoneNumber: phoneNumber,
      confidence: 'medium', // Sera recalculé après
    );
  }
  
  static double _calculateTypeScore(String text, List<String> keywords) {
    double score = 0.0;
    for (String keyword in keywords) {
      if (text.contains(keyword)) {
        score += 1.0;
        // Bonus si le mot est au début
        if (text.startsWith(keyword)) score += 0.5;
        // Bonus si le mot est exact
        if (text == keyword) score += 2.0;
      }
    }
    return score;
  }
  
  static Map<String, double> _extractAmountsWithScoring(String text) {
    final Map<String, double> scores = {};
    
    // Patterns avancés avec scoring
    final patterns = [
      {'pattern': RegExp(r'(\d+(?:\s*\d{3})*)(?:\s*(?:frs|fr|f|fcfa|xof))', caseSensitive: false), 'score': 1.0},
      {'pattern': RegExp(r'(\d+)k', caseSensitive: false), 'score': 0.8}, // 5k = 5000
      {'pattern': RegExp(r'(\d+)\s*mille', caseSensitive: false), 'score': 0.9},
      {'pattern': RegExp(r'(\d+)(?=\s|$)', caseSensitive: false), 'score': 0.6},
    ];
    
    // Montants écrits en lettres
    SenegalContext.typicalAmounts.forEach((word, value) {
      if (text.contains(word)) {
        scores[value.toString()] = 0.7;
      }
    });
    
    for (final patternData in patterns) {
      final matches = (patternData['pattern'] as RegExp).allMatches(text);
      for (final match in matches) {
        String amount = match.group(1)!;
        
        // Nettoyer et convertir
        amount = amount.replaceAll(RegExp(r'\s'), '');
        if (amount.contains('k')) {
          amount = amount.replaceAll('k', '000');
        }
        
        // Ajouter le score
        scores[amount] = (scores[amount] ?? 0.0) + (patternData['score'] as double);
      }
    }
    
    return scores;
  }
  
  static Map<String, double> _extractRecipientsWithScoring(String text) {
    final Map<String, double> scores = {};
    
    // Patterns avec scoring
    final patterns = [
      {'pattern': RegExp(r'(?:à|chez|pour|sur|au|a|vers)\s+([a-z]{3,})', caseSensitive: false), 'score': 1.0},
      {'pattern': RegExp(r'numero\s+(\d{8,})', caseSensitive: false), 'score': 0.9},
      {'pattern': RegExp(r'([a-z]{3,})(?=\s+(?:à|chez|sur))', caseSensitive: false), 'score': 0.8},
    ];
    
    for (final patternData in patterns) {
      final matches = (patternData['pattern'] as RegExp).allMatches(text);
      for (final match in matches) {
        final recipient = match.group(1)!;
        
        // Bonus si c'est un nom sénégalais courant
        double score = patternData['score'] as double;
        if (SenegalContext.commonNames.contains(recipient.toLowerCase())) {
          score += 0.3;
        }
        
        scores[recipient] = (scores[recipient] ?? 0.0) + score;
      }
    }
    
    return scores;
  }
  
  static Map<String, double> _extractOperatorsWithScoring(String text) {
    final Map<String, double> scores = {};
    
    SenegalContext.expressions.forEach((key, value) {
      if (['orange', 'wave', 'moov', 'free', 'etisalat'].contains(value)) {
        if (text.contains(key)) {
          scores[value] = (scores[value] ?? 0.0) + 0.8;
        }
      }
    });
    
    return scores;
  }
  
  static String? _extractPhoneNumber(String text) {
    for (final pattern in SenegalContext.phonePatterns) {
      final match = RegExp(pattern).firstMatch(text);
      if (match != null) {
        return match.group(1);
      }
    }
    return null;
  }
  
  static String? _getBestScore(Map<String, double> scores) {
    if (scores.isEmpty) return null;
    
    double maxScore = 0.0;
    String? bestKey;
    
    scores.forEach((key, value) {
      if (value > maxScore) {
        maxScore = value;
        bestKey = key;
      }
    });
    
    return maxScore > 0.3 ? bestKey : null; // Seuil minimum
  }
  
  static String? _getBestKey(Map<String, double> scores) {
    if (scores.isEmpty) return null;
    
    double maxScore = 0.0;
    String? bestKey;
    
    scores.forEach((key, value) {
      if (value > maxScore) {
        maxScore = value;
        bestKey = key;
      }
    });
    
    return maxScore > 0.2 ? bestKey : null; // Seuil plus bas pour les types
  }
  
  static ParsedTransaction _validateAndCorrect(ParsedTransaction transaction) {
    // Correction du montant
    if (transaction.amount != null) {
      int? amount = int.tryParse(transaction.amount!);
      if (amount != null) {
        // Validation des montants réalistes au Sénégal
        if (amount < 100) {
          transaction.amount = '100'; // Minimum 100 F
        } else if (amount > 500000) {
          transaction.amount = '500000'; // Maximum 500k F
        }
      }
    }
    
    // Correction du destinataire
    if (transaction.recipient != null) {
      String recipient = transaction.recipient!;
      // Mettre en majuscule la première lettre
      if (recipient.isNotEmpty) {
        transaction.recipient = recipient[0].toUpperCase() + recipient.substring(1);
      }
    }
    
    return transaction;
  }
  
  static String _calculateAdvancedConfidence(ParsedTransaction transaction, String normalizedText) {
    double score = 0.0;
    int totalChecks = 0;
    
    // Type de transaction
    if (transaction.type != null) {
      score += 40;
      totalChecks++;
    }
    
    // Montant
    if (transaction.amount != null) {
      score += 30;
      totalChecks++;
    }
    
    // Destinataire
    if (transaction.recipient != null) {
      score += 20;
      totalChecks++;
    }
    
    // Opérateur
    if (transaction.operator != null) {
      score += 5;
      totalChecks++;
    }
    
    // Téléphone
    if (transaction.phoneNumber != null) {
      score += 5;
      totalChecks++;
    }
    
    // Bonus contexte sénégalais
    if (SenegalContext.isSenegalContext(normalizedText)) {
      score += 10;
    }
    
    // Calcul final
    double finalScore = totalChecks > 0 ? (score / (totalChecks * 40)) * 100 : 0;
    
    if (finalScore >= 85) return 'high';
    if (finalScore >= 60) return 'medium';
    return 'low';
  }
}

class ParsedTransaction {
  String? amount;
  String? recipient;
  String? type;
  String? operator;
  String? phoneNumber;
  String confidence;
  
  ParsedTransaction({
    this.amount,
    this.recipient,
    this.type,
    this.operator,
    this.phoneNumber,
    this.confidence = 'medium',
  });
  
  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'recipient': recipient,
      'type': type,
      'operator': operator,
      'phoneNumber': phoneNumber,
      'confidence': confidence,
    };
  }
}
