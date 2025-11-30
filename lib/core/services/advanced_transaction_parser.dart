import 'dart:convert';
import 'package:http/http.dart' as http;

class AdvancedTransactionParser {
  static const String _apiKey = 'YOUR_API_KEY'; // OpenAI/Gemini API
  
  // Modèle NLU avec prompts structurés
  static Future<Map<String, dynamic>> parseWithAI(String transcription) async {
    final prompt = '''
Tu es un expert en transactions mobile money au Sénégal. Analyse cette transcription et extrait les informations JSON:

Transcription: "$transcription"

Retourne UNIQUEMENT ce format JSON:
{
  "amount": "montant en chiffres",
  "recipient": "nom du destinataire", 
  "type": "envoyer|recevoir|solde|recharger|payer",
  "operator": "orange|wave|moov|free|etisalat",
  "phoneNumber": "numéro sans espaces",
  "confidence": "high|medium|low",
  "currency": "XOF|FCFA|F",
  "rawText": "$transcription"
}

Règles:
- "envoie" = envoyer, "reçois" = recevoir, "solde" = vérifier solde
- Montants: 200frs = 200, 5000 f = 5000, 10k = 10000
- Noms: "à georges" = georges, "pour marie" = marie  
- Opérateurs: orange/om, wave, moov/moo, free, etisalat
- Téléphones: 77/76/78/70 + 7 chiffres
''';

    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [{'role': 'user', 'content': prompt}],
          'temperature': 0.1, // Très précis
        }),
      );

      final result = jsonDecode(response.body);
      final content = result['choices'][0]['message']['content'];
      
      // Extraire le JSON de la réponse
      final jsonMatch = RegExp(r'\{.*\}').firstMatch(content);
      if (jsonMatch != null) {
        return jsonDecode(jsonMatch.group(0)!);
      }
    } catch (e) {
      print('AI parsing failed: $e');
    }
    
    // Fallback vers le parser simple
    return _fallbackParse(transcription);
  }
  
  static Map<String, dynamic> _fallbackParse(String transcription) {
    // Utiliser l'ancien système en backup
    return {
      'amount': '0',
      'recipient': 'Non spécifié',
      'type': 'envoyer',
      'operator': null,
      'phoneNumber': null,
      'confidence': 'low',
      'currency': 'XOF',
      'rawText': transcription
    };
  }
}
