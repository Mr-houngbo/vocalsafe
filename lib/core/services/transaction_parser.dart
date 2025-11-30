import 'dart:core';

class ParsedTransaction {
  final String? amount;
  final String? recipient;
  final String? type; // 'envoyer', 'recevoir', 'solde', 'recharger'
  final String? operator; // 'orange', 'wave', 'moov', etc.
  final String? phoneNumber;
  final String confidence;
  
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

class TransactionParser {
  static ParsedTransaction parseTranscription(String transcription) {
    final text = transcription.toLowerCase();
    
    // Types de transactions
    String? type;
    if (text.contains('envoie') || text.contains('envoyer') || text.contains('transfère') || text.contains('transférer')) {
      type = 'envoyer';
    } else if (text.contains('reçois') || text.contains('recevoir')) {
      type = 'recevoir';
    } else if (text.contains('solde') || text.contains('compte')) {
      type = 'solde';
    } else if (text.contains('recharge') || text.contains('recharger')) {
      type = 'recharger';
    }
    
    // Extraction du montant
    String? amount;
    final amountPatterns = [
      RegExp(r'(\d+)\s*f', caseSensitive: false), // 5000f, 5000 f
      RegExp(r'(\d+)\s*franc', caseSensitive: false), // 5000 franc
      RegExp(r'(\d+)\s*fcfa', caseSensitive: false), // 5000 fcfa
      RegExp(r'(\d+)\s*xof', caseSensitive: false), // 5000 xof
      RegExp(r'(\d+)\s*$', caseSensitive: false), // 5000 (à la fin)
      RegExp(r'(\d+)\s*(?=frs|francs)', caseSensitive: false), // 5000 frs
    ];
    
    for (final pattern in amountPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        amount = match.group(1);
        break;
      }
    }
    
    // Extraction du destinataire
    String? recipient;
    final recipientPatterns = [
      RegExp(r'à\s+([a-z]{3,})', caseSensitive: false), // à georges
      RegExp(r'pour\s+([a-z]{3,})', caseSensitive: false), // pour georges
      RegExp(r'([a-z]{3,})\s*(?=$|\s+au|\s+à)', caseSensitive: false), // georges à
      RegExp(r'numero\s+(\d+)', caseSensitive: false), // numero 12345678
      RegExp(r'(\d{8,})', caseSensitive: false), // numéro de téléphone
    ];
    
    for (final pattern in recipientPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        recipient = match.group(1);
        break;
      }
    }
    
    // Détection de l'opérateur
    String? operator;
    if (text.contains('orange') || text.contains('om')) {
      operator = 'orange';
    } else if (text.contains('wave') || text.contains('wave')) {
      operator = 'wave';
    } else if (text.contains('moov') || text.contains('moo')) {
      operator = 'moov';
    }
    
    // Détection du numéro de téléphone
    String? phoneNumber;
    final phonePattern = RegExp(r'(\d{8,})');
    final phoneMatch = phonePattern.firstMatch(text);
    if (phoneMatch != null) {
      phoneNumber = phoneMatch.group(1);
    }
    
    return ParsedTransaction(
      amount: amount,
      recipient: recipient,
      type: type,
      operator: operator,
      phoneNumber: phoneNumber,
      confidence: _calculateConfidence(amount, recipient, type),
    );
  }
  
  static String _calculateConfidence(String? amount, String? recipient, String? type) {
    int score = 0;
    if (amount != null) score += 30;
    if (recipient != null) score += 30;
    if (type != null) score += 40;
    
    if (score >= 80) return 'high';
    if (score >= 50) return 'medium';
    return 'low';
  }
  
  // Validation et correction
  static ParsedTransaction validateAndCorrect(ParsedTransaction transaction) {
    // Corriger les montants (ajouter 'f' si manquant)
    if (transaction.amount != null && !transaction.amount!.contains('f')) {
      // Le montant est valide, on garde tel quel
    }
    
    // Corriger les noms propres (première lettre majuscule)
    String? correctedRecipient = transaction.recipient;
    if (correctedRecipient != null && correctedRecipient.length > 2) {
      correctedRecipient = correctedRecipient[0].toUpperCase() + correctedRecipient.substring(1);
    }
    
    return ParsedTransaction(
      amount: transaction.amount,
      recipient: correctedRecipient,
      type: transaction.type,
      operator: transaction.operator,
      phoneNumber: transaction.phoneNumber,
      confidence: transaction.confidence,
    );
  }
}
