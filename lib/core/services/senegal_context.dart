class SenegalContext {
  // Dictionnaire des expressions sénégalaises
  static const Map<String, String> expressions = {
    // Types de transactions
    'donne': 'envoyer',
    'fais': 'envoyer', 
    'verse': 'envoyer',
    'transfère': 'envoyer',
    'dépose': 'envoyer',
    'retire': 'recevoir',
    'enlève': 'recevoir',
    'consulte': 'solde',
    'vérifie': 'solde',
    'regarde': 'solde',
    'charge': 'recharger',
    'recharge': 'recharger',
    'topup': 'recharger',
    
    // Opérateurs et leurs variations
    'orange': 'orange',
    'om': 'orange',
    'omoney': 'orange',
    'orange money': 'orange',
    'wave': 'wave',
    'wave senegal': 'wave',
    'moov': 'moov',
    'moov money': 'moov',
    'moo': 'moov',
    'free': 'free',
    'free money': 'free',
    'etisalat': 'etisalat',
    'etisalat money': 'etisalat',
    
    // Prépositions et connecteurs
    'chez': 'à',
    'sur': 'à',
    'pour': 'à',
    'au': 'à',
    'a': 'à',
    'vers': 'à',
    'direction': 'à',
    
    // Unités monétaires sénégalaises
    'frs': 'F',
    'fr': 'F', 
    'franc': 'F',
    'francs': 'F',
    'fcfa': 'F',
    'xof': 'F',
    'k': '000', // 5k = 5000
    'mille': '000',
    'millier': '000',
    'million': '000000',
    
    // Noms communs sénégalais
    'papa': 'personne',
    'maman': 'personne', 
    'frère': 'personne',
    'soeur': 'personne',
    'cousin': 'personne',
    'tonton': 'personne',
    'tata': 'personne',
    'ami': 'personne',
    'amie': 'personne',
    'voisin': 'personne',
    'collègue': 'personne',
    'patron': 'personne',
    'boss': 'personne',
  };
  
  // Patterns téléphoniques sénégalais
  static const List<String> phonePatterns = [
    r'(7[7-8]\d{7})', // 77xxxxxx, 78xxxxxx
    r'(7[0,6,9]\d{7})', // 70xxxxxx, 76xxxxxx, 79xxxxxx  
    r'(3[0-9]\d{7})',  // 30xxxxxx (fixe)
    r'(\d{8})',        // 8 chiffres
    r'(\d{9})',        // 9 chiffres avec indicatif
  ];
  
  // Noms propres sénégalais courants
  static const List<String> commonNames = [
    'mamadou', 'papa', 'ibrahima', 'abdoulaye', 'oumar',
    'baba', 'moussa', 'aliou', 'talla', 'modou',
    'fatou', 'astou', 'adja', 'khady', 'ame', 'ndeye',
    'marie', 'aïda', 'coumba', 'rokhaya', 'bineta',
    'diop', 'ba', 'fall', 'ndiaye', 'sarr', 'ka', 'mbaye',
    'lo', 'gueye', 'seck', 'dieng', 'faye', 'sy', 'sow'
  ];
  
  // Montants typiques au Sénégal
  static const Map<String, int> typicalAmounts = {
    'cent': 100,
    'deux cents': 200,
    'cinq cents': 500,
    'mille': 1000,
    'deux mille': 2000,
    'cinq mille': 5000,
    'dix mille': 10000,
    'vingt mille': 20000,
    'cinquante mille': 50000,
    'cent mille': 100000,
  };
  
  // Normaliser le texte sénégalais
  static String normalizeText(String text) {
    String normalized = text.toLowerCase();
    
    // Remplacer les expressions locales
    expressions.forEach((key, value) {
      normalized = normalized.replaceAll(key, value);
    });
    
    // Gérer les abréviations de montants
    normalized = normalized.replaceAll(RegExp(r'(\d+)k'), '${RegExp(r'(\d+)')}000');
    normalized = normalized.replaceAll(RegExp(r'(\d+) mil'), '${RegExp(r'(\d+)')}000');
    
    // Nettoyer les caractères spéciaux
    normalized = normalized.replaceAll(RegExp(r'[^\w\sàâäéèêëïîôöùûüÿç]'), ' ');
    
    return normalized.trim();
  }
  
  // Détecter si c'est du contexte sénégalais
  static bool isSenegalContext(String text) {
    final lowerText = text.toLowerCase();
    
    // Vérifier les mots-clés sénégalais
    final senegalKeywords = [
      'orange', 'wave', 'moov', 'franc', 'fcfa', 'xof',
      'senegal', 'dakar', 'thiès', 'kaolack'
    ];
    
    return senegalKeywords.any((keyword) => lowerText.contains(keyword)) ||
           commonNames.any((name) => lowerText.contains(name));
  }
}
