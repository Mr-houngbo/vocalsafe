import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/voice_service.dart';
import '../../../../core/services/transaction_parser.dart';
import '../../../../core/services/transaction_data_service.dart';
import '../../../../core/services/payment_redirect_service.dart';

class VoiceConfirmationScreen extends StatefulWidget {
  final String transcribedText;
  final VoidCallback? onBack;
  final Function(String, [Map<String, dynamic>?])? onNavigateToTransaction;
  final Map<String, dynamic>? confirmationData;
  
  const VoiceConfirmationScreen({
    super.key,
    required this.transcribedText,
    this.onBack,
    this.onNavigateToTransaction,
    this.confirmationData,
  });

  @override
  State<VoiceConfirmationScreen> createState() => _VoiceConfirmationScreenState();
}

class _VoiceConfirmationScreenState extends State<VoiceConfirmationScreen>
    with TickerProviderStateMixin {
  late AnimationController _speakerController;
  late AnimationController _waveController;
  late ParsedTransaction _parsedTransaction;
  late String _transcription;
  bool _isPlaying = false;
  bool _isListening = false;
  
  // Champs modifiables depuis transaction_summary_screen
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _selectedOperator = 'Orange';
  String _transactionType = 'envoyer';
  
  @override
  void initState() {
    super.initState();
    
    // Récupérer la transcription depuis les données de confirmation ou GoRouter
    _transcription = widget.transcribedText;
    if (widget.transcribedText.isEmpty && widget.confirmationData != null) {
      _transcription = widget.confirmationData!['transcription'] ?? '';
    }
    if (_transcription.isEmpty) {
      // Dernier recours : essayer GoRouter
      try {
        final extra = GoRouterState.of(context).extra;
        if (extra != null && extra is String) {
          _transcription = extra;
        }
      } catch (e) {
        // Ignorer l'erreur
      }
    }
    
    // Parser avec le système amélioré (sans conflit)
    _parsedTransaction = _parseWithAdvancedLogic(_transcription);
    
    // Fallback vers l'ancien système si confiance faible
    if (_parsedTransaction.confidence == 'low') {
      _parsedTransaction = TransactionParser.validateAndCorrect(
        TransactionParser.parseTranscription(_transcription)
      );
    }
    
    // Pré-remplir les champs avec les données parsées
    _populateFieldsFromParsedData();
    
    _speakerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _playAudioConfirmation();
  }
  
  void _populateFieldsFromParsedData() {
    // Pré-remplir le montant
    if (_parsedTransaction.amount != null) {
      _amountController.text = '${_parsedTransaction.amount} F';
    }
    
    // Pré-remplir le destinataire
    if (_parsedTransaction.recipient != null) {
      _recipientController.text = _parsedTransaction.recipient!;
    }
    
    // Pré-remplir le numéro de téléphone
    if (_parsedTransaction.phoneNumber != null) {
      _phoneController.text = _parsedTransaction.phoneNumber!;
    }
    
    // Définir le type de transaction
    if (_parsedTransaction.type != null) {
      _transactionType = _parsedTransaction.type!;
    }
    
    // Définir l'opérateur
    if (_parsedTransaction.operator != null) {
      _selectedOperator = _parsedTransaction.operator!;
    }
  }
  
  @override
  void dispose() {
    _speakerController.dispose();
    _waveController.dispose();
    VoiceService.stopSpeaking();
    _amountController.dispose();
    _recipientController.dispose();
    _phoneController.dispose();
    
    // Nettoyer les données du fichier JSON après utilisation
    TransactionDataService.clearTransactionData();
    
    super.dispose();
  }
  
  Future<void> _playAudioConfirmation() async {
    setState(() {
      _isPlaying = true;
    });
    
    _waveController.repeat();
    
    // Simuler la lecture audio avec TTS
    await VoiceService.speak('Vous avez dit : $_transcription');
    
    setState(() {
      _isPlaying = false;
    });
    _waveController.stop();
  }
  
  void _confirm() async {
    // Sauvegarder les données modifiées dans le fichier JSON
    final Map<String, dynamic> finalData = {
      'amount': _amountController.text.replaceAll('F', '').replaceAll(' ', '').trim(),
      'recipient': _recipientController.text.trim(),
      'phoneNumber': _phoneController.text.trim(),
      'type': _transactionType,
      'operator': _selectedOperator,
      'confidence': _parsedTransaction.confidence,
    };
    
    await TransactionDataService.saveTransactionData(finalData);
    
    // Rediriger vers l'application de l'opérateur
    await _redirectToOperatorApp();
  }
  
  Future<void> _redirectToOperatorApp() async {
    // Récupérer les données de la transaction
    final amount = _amountController.text.replaceAll('F', '').replaceAll(' ', '').trim();
    final recipientName = _recipientController.text.trim();
    final phoneNumber = _phoneController.text.trim();
    
    // Vérifier si un opérateur est spécifié
    if (_selectedOperator.isEmpty) {
      _showOperatorSelectionDialog(amount, recipientName, phoneNumber);
      return;
    }
    
    // Pour le numéro de téléphone, si non fourni, utiliser un placeholder
    String finalPhoneNumber = phoneNumber.isNotEmpty ? phoneNumber : '00000000';
    
    // Rediriger vers l'application de l'opérateur
    final success = await PaymentRedirectService.redirectToOperator(
      operator: _selectedOperator,
      amount: amount,
      phoneNumber: finalPhoneNumber,
      recipientName: recipientName.isNotEmpty ? recipientName : 'Destinataire',
    );
    
    if (success) {
      // Naviguer vers la page de succès si la redirection a réussi
      context.go('/transaction-success');
    } else {
      _showErrorDialog('Impossible d\'ouvrir l\'application ${PaymentRedirectService.getOperatorDisplayName(_selectedOperator)}');
    }
  }
  
  void _showOperatorSelectionDialog(String amount, String recipientName, String phoneNumber) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sélectionner l\'opérateur'),
        content: const Text('Sur quel opérateur souhaitez-vous effectuer cette transaction ?'),
        actions: [
          // Afficher les opérateurs supportés
          ...PaymentRedirectService.getSupportedOperators().map((operator) => 
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _selectedOperator = operator;
                  setState(() {});
                  _redirectToOperatorApp();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getOperatorColor(operator),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: Text(PaymentRedirectService.getOperatorDisplayName(operator)),
              ),
            )
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }
  
  Color _getOperatorColor(String operator) {
    return PaymentRedirectService.getOperatorColor(operator);
  }
  
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erreur'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  String _calculateTotal() {
    // Extraire le montant du texte (ex: "200 F" -> "200")
    String amountText = _amountController.text;
    if (amountText.isEmpty) return 'Non spécifié';
    
    // Supprimer "F" et les espaces
    String cleanAmount = amountText.replaceAll('F', '').replaceAll(' ', '').trim();
    
    try {
      double amount = double.parse(cleanAmount);
      double fees = 50.0; // Frais fixes
      double total = amount + fees;
      return '${total.toInt()} F CFA';
    } catch (e) {
      return 'Non spécifié';
    }
  }
  
  void _retry() {
    context.go('/voice-listening');
  }
  
  // Parser amélioré avec contexte sénégalais
  ParsedTransaction _parseWithAdvancedLogic(String transcription) {
    final text = transcription.toLowerCase();
    
    // Types de transactions étendus
    String? type;
    if (text.contains('envoie') || text.contains('envoyer') || text.contains('donne') || 
        text.contains('fais') || text.contains('verse') || text.contains('transfère') || text.contains('dépose')) {
      type = 'envoyer';
    } else if (text.contains('reçois') || text.contains('recevoir') || text.contains('retire') || 
               text.contains('enlève') || text.contains('récupère')) {
      type = 'recevoir';
    } else if (text.contains('solde') || text.contains('compte') || text.contains('consulte') || 
               text.contains('vérifie') || text.contains('regarde') || text.contains('montant')) {
      type = 'solde';
    } else if (text.contains('recharge') || text.contains('recharger') || text.contains('charge') || 
               text.contains('topup') || text.contains('crédit')) {
      type = 'recharger';
    }
    
    // Extraction du montant améliorée
    String? amount;
    final amountPatterns = [
      RegExp(r'(\d+(?:\s*\d{3})*)(?:\s*(?:frs|fr|f|fcfa|xof|franc|francs))', caseSensitive: false),
      RegExp(r'(\d+)k', caseSensitive: false), // 5k = 5000
      RegExp(r'(\d+)\s*mille', caseSensitive: false), // 5 mille = 5000
      RegExp(r'(\d+)\s*$', caseSensitive: false), // 5000 seul
    ];
    
    // Montants écrits en lettres
    final Map<String, int> writtenAmounts = {
      'cent': 100, 'deux cents': 200, 'cinq cents': 500,
      'mille': 1000, 'deux mille': 2000, 'cinq mille': 5000,
      'dix mille': 10000, 'vingt mille': 20000, 'cinquante mille': 50000,
    };
    
    for (final pattern in amountPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        amount = match.group(1);
        // Nettoyer et convertir
        amount = amount!.replaceAll(RegExp(r'\s'), '');
        if (amount.contains('k')) {
          amount = amount.replaceAll('k', '000');
        }
        break;
      }
    }
    
    // Vérifier les montants écrits en lettres
    for (final entry in writtenAmounts.entries) {
      if (text.contains(entry.key)) {
        amount = entry.value.toString();
        break;
      }
    }
    
    // Extraction du destinataire améliorée
    String? recipient;
    final recipientPatterns = [
      RegExp(r'(?:à|chez|pour|sur|au|a|vers|direction)\s+([a-z]{3,})', caseSensitive: false),
      RegExp(r'numero\s+(\d{8,})', caseSensitive: false),
      RegExp(r'([a-z]{3,})(?=\s+(?:à|chez|sur|pour))', caseSensitive: false),
      RegExp(r'(\d{8,})', caseSensitive: false),
    ];
    
    // Noms sénégalais courants
    final List<String> senegaleseNames = [
      'mamadou', 'papa', 'ibrahima', 'abdoulaye', 'oumar', 'baba', 'moussa', 'aliou',
      'fatou', 'astou', 'adja', 'khady', 'ame', 'ndeye', 'marie', 'aïda', 'coumba',
      'diop', 'ba', 'fall', 'ndiaye', 'sarr', 'ka', 'mbaye', 'lo', 'gueye'
    ];
    
    for (final pattern in recipientPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        recipient = match.group(1);
        // Mettre en majuscule la première lettre
        if (recipient!.isNotEmpty) {
          recipient = recipient[0].toUpperCase() + recipient.substring(1);
        }
        break;
      }
    }
    
    // Détection de l'opérateur améliorée
    String? operator;
    if (text.contains('orange') || text.contains('om') || text.contains('omoney') || text.contains('orange money')) {
      operator = 'orange';
    } else if (text.contains('wave') || text.contains('wave senegal')) {
      operator = 'wave';
    } else if (text.contains('moov') || text.contains('moo') || text.contains('moov money') || text.contains('moovmoney')) {
      operator = 'moov';
    } else if (text.contains('free') || text.contains('free money') || text.contains('freemoney')) {
      operator = 'free';
    } else if (text.contains('etisalat') || text.contains('etisalat money')) {
      operator = 'etisalat';
    }
    
    // Si aucun opérateur détecté, essayer de deviner selon le contexte
    if (operator == null) {
      operator = _guessOperatorFromContext(text);
    }
    
    // Détection du numéro de téléphone
    String? phoneNumber;
    final phonePatterns = [
      RegExp(r'(7[7-8]\d{7})'), // 77xxxxxx, 78xxxxxx
      RegExp(r'(7[0,6,9]\d{7})'), // 70xxxxxx, 76xxxxxx, 79xxxxxx
      RegExp(r'(3[0-9]\d{7})'),  // 30xxxxxx (fixe)
      RegExp(r'(\d{8})'),        // 8 chiffres
      RegExp(r'(\d{9})'),        // 9 chiffres avec indicatif
    ];
    
    for (final pattern in phonePatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        phoneNumber = match.group(1);
        break;
      }
    }
    
    // Calcul de confiance amélioré
    String confidence = _calculateConfidence(amount, recipient, type, operator, phoneNumber);
    
    return ParsedTransaction(
      amount: amount,
      recipient: recipient,
      type: type,
      operator: operator,
      phoneNumber: phoneNumber,
      confidence: confidence,
    );
  }
  
  String _calculateConfidence(String? amount, String? recipient, String? type, String? operator, String? phoneNumber) {
    double score = 0.0;
    int totalChecks = 0;
    
    if (type != null) {
      score += 40;
      totalChecks++;
    }
    
    if (amount != null) {
      score += 30;
      totalChecks++;
    }
    
    if (recipient != null) {
      score += 20;
      totalChecks++;
    }
    
    if (operator != null) {
      score += 5;
      totalChecks++;
    }
    
    if (phoneNumber != null) {
      score += 5;
      totalChecks++;
    }
    
    double finalScore = totalChecks > 0 ? (score / (totalChecks * 40)) * 100 : 0;
    
    if (finalScore >= 85) return 'high';
    if (finalScore >= 60) return 'medium';
    return 'low';
  }
  
  // Deviner l'opérateur selon le contexte
  String? _guessOperatorFromContext(String text) {
    // Par défaut, au Sénégal, Orange est le plus courant
    // On peut aussi utiliser des heuristiques basées sur le numéro de téléphone
    
    // Si le montant est petit (<1000), c'est probablement Orange (plus populaire)
    final amountPatterns = [
      RegExp(r'(\d+)'),
      RegExp(r'(\d+)\s*k', caseSensitive: false),
    ];
    
    int? amount;
    for (final pattern in amountPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        amount = int.tryParse(match.group(1)!);
        break;
      }
    }
    
    // Si aucun opérateur spécifié, utiliser Orange par défaut
    // (car c'est l'opérateur le plus courant au Sénégal)
    return 'orange';
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
          'Confirmation',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section transcription
            _buildTranscriptionSection(context),
            const SizedBox(height: 24),
            
            // Section détails transaction (non modifiable)
            _buildTransactionDetails(context),
            const SizedBox(height: 24),
            
            // Section champs modifiables
            _buildEditableFields(context),
            const SizedBox(height: 24),
            
            // Section sélection opérateur
            _buildOperatorSelector(context),
            const SizedBox(height: 24),
            
            // Section calcul frais
            _buildFeesSection(context),
            const SizedBox(height: 24),
            
            // Section actions
            _buildActionButtons(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTranscriptionSection(BuildContext context) {
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
            'Vous avez dit :',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.transcribedText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textPrimary,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  
  Widget _buildTransactionDetails(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
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
            'Détails de la transaction :',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailRow('Type', _parsedTransaction.type ?? 'Non détecté'),
          _buildDetailRow('Montant', '${_parsedTransaction.amount ?? '0'} F'),
          _buildDetailRow('Destinataire', _parsedTransaction.recipient ?? 'Non détecté'),
          _buildDetailRow('Opérateur', _parsedTransaction.operator ?? 'Non détecté'),
          _buildDetailRow('Confiance', _parsedTransaction.confidence ?? 'Non évalué'),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _retry,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.textSecondary,
              side: const BorderSide(color: AppTheme.lightGray),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Réessayer'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _confirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: AppTheme.pureWhite,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Confirmer et payer'),
          ),
        ),
      ],
    );
  }
  
  Widget _buildEditableFields(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.lightGray, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Modifier si nécessaire :',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          // Champ montant
          TextField(
            controller: _amountController,
            decoration: const InputDecoration(
              labelText: 'Montant',
              hintText: 'Ex: 5000 F',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          
          // Champ destinataire
          TextField(
            controller: _recipientController,
            decoration: const InputDecoration(
              labelText: 'Destinataire',
              hintText: 'Nom du destinataire',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          
          // Champ téléphone
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Numéro de téléphone',
              hintText: '77xxxxxx',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }
  
  Widget _buildOperatorSelector(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: AppTheme.primaryGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Opérateur de paiement',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Opérateur actuel
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _getOperatorColor(_selectedOperator).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _getOperatorColor(_selectedOperator).withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getOperatorColor(_selectedOperator),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      PaymentRedirectService.getOperatorDisplayName(_selectedOperator),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _getOperatorColor(_selectedOperator),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    _showOperatorSelectionDialog(
                      _amountController.text.replaceAll('F', '').replaceAll(' ', '').trim(),
                      _recipientController.text.trim(),
                      _phoneController.text.trim(),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getOperatorColor(_selectedOperator),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Changer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFeesSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.lightGray, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Récapitulatif des frais :',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Montant', _amountController.text.isNotEmpty ? _amountController.text : 'Non spécifié'),
          _buildDetailRow('Frais de transaction', '50 F CFA'),
          _buildDetailRow('Total à payer', _calculateTotal()),
        ],
      ),
    );
  }
  
  Widget _buildSecurityBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '🛡️',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 8),
          Text(
            'Transaction sécurisée par IA',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              if (widget.onBack != null) {
                widget.onBack!();
              } else {
                context.go('/');
              }
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back,
                size: 20,
              ),
            ),
          ),
          Text(
            'VocaSafe',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
  
  Widget _buildMainContent(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16), // Réduit le padding horizontal
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20), // Ajoute un espace en haut
            // Icône haut-parleur animé
            _buildSpeakerIcon(),
            const SizedBox(height: 24), // Réduit l'espace
            
            // Label "Vous avez dit"
            Text(
              '📝 Vous avez dit :',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 14, // Réduit la taille
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 12), // Réduit l'espace
            
            // Bulle de dialogue
            _buildSpeechBubble(context),
            const SizedBox(height: 20), // Réduit l'espace
            
            // Indicateur de lecture audio
            _buildAudioPlayingIndicator(),
            const SizedBox(height: 32), // Réduit l'espace
            
            // Boutons de confirmation
            _buildButtons(context),
            const SizedBox(height: 20), // Ajoute un espace en bas
          ],
        ),
      ),
    );
  }
  
  Widget _buildSpeakerIcon() {
    return AnimatedBuilder(
      animation: _speakerController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_speakerController.value * 0.05),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppTheme.greenGradient,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGreen.withOpacity(0.4 * (1 - _speakerController.value)),
                  blurRadius: 20 * _speakerController.value,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: const Icon(
              Icons.volume_up,
              size: 40,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildSpeechBubble(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.all(20), // Réduit le padding
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Pointe de la bulle
          Positioned(
            top: -10,
            left: 0,
            right: 0,
            child: Center(
              child: CustomPaint(
                size: const Size(20, 10),
                painter: TrianglePainter(const Color(0xFFF3F4F6)),
              ),
            ),
          ),
          
          // Texte avec gestion du overflow
          SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 150, // Limite la hauteur maximale
                minHeight: 40,  // Hauteur minimale
              ),
              child: Center(
                child: Text(
                  '"$_transcription"',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 18, // Réduit la taille de police
                    fontWeight: FontWeight.w600,
                    height: 1.3, // Réduit l'interligne
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 5, // Limite le nombre de lignes
                  overflow: TextOverflow.ellipsis, // Ajoute "..." si trop long
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAudioPlayingIndicator() {
    if (!_isPlaying) return const SizedBox.shrink();
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _waveController,
          builder: (context, child) {
            return Row(
              children: List.generate(4, (index) {
                final delay = index * 0.1;
                final value = (_waveController.value - delay).clamp(0.0, 1.0);
                final height = 10.0 + (value * 10.0);
                
                return Container(
                  width: 3,
                  height: height,
                  margin: const EdgeInsets.only(right: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen,
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            );
          },
        ),
        const SizedBox(width: 8),
        const Text(
          'Lecture audio en cours...',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.primaryGreen,
          ),
        ),
      ],
    );
  }
  
  Widget _buildButtons(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      constraints: const BoxConstraints(maxWidth: 345),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _confirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Oui, c\'est ça',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _retry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorLight,
                foregroundColor: AppTheme.errorRed,
                padding: const EdgeInsets.symmetric(vertical: 20),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.close, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Non, recommencer',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  final Color color;
  
  const TrianglePainter(this.color);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
