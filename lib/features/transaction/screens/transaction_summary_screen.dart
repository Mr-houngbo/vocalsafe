import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/voice_service.dart';
import '../../../../core/services/transaction_data_service.dart';
import '../../../../core/services/payment_redirect_service.dart';

class TransactionSummaryScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final Map<String, dynamic>? transactionData;
  
  const TransactionSummaryScreen({
    super.key,
    this.onBack,
    this.transactionData,
  });

  @override
  State<TransactionSummaryScreen> createState() => _TransactionSummaryScreenState();
}

class _TransactionSummaryScreenState extends State<TransactionSummaryScreen>
    with TickerProviderStateMixin {
  late AnimationController _voiceButtonController;
  bool _isListening = false;
  
  // Champs de la transaction
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _selectedOperator = 'Orange';
  String _transactionType = 'envoyer';
  
  @override
  void initState() {
    super.initState();
    _voiceButtonController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _voiceButtonController.repeat();
    
    // Charger les données depuis le fichier JSON
    _loadTransactionDataFromJson();
  }
  
  Future<void> _loadTransactionDataFromJson() async {
    // D'abord essayer les données du widget
    Map<String, dynamic>? data = widget.transactionData;
    
    // Si aucune donnée, essayer depuis le fichier JSON
    if (data == null) {
      data = await TransactionDataService.getTransactionData();
    }
    
    // Pré-remplir les champs avec les données parsées
    if (data != null) {
      _populateFieldsFromParsedData(data);
    }
    
    _playSummaryAudio();
  }
  
  void _populateFieldsFromParsedData(Map<String, dynamic>? data) {
    if (data != null) {
      // Pré-remplir le montant
      if (data['amount'] != null) {
        _amountController.text = '${data['amount']} F';
      }
      
      // Pré-remplir le destinataire
      if (data['recipient'] != null) {
        _recipientController.text = data['recipient'];
      }
      
      // Pré-remplir le numéro de téléphone
      if (data['phoneNumber'] != null) {
        _phoneController.text = data['phoneNumber'];
      }
      
      // Définir le type de transaction
      if (data['type'] != null) {
        _transactionType = data['type'];
      }
      
      // Définir l'opérateur
      if (data['operator'] != null) {
        _selectedOperator = data['operator'];
      }
    }
  }
  
  @override
  void dispose() {
    _voiceButtonController.dispose();
    _amountController.dispose();
    _recipientController.dispose();
    _phoneController.dispose();
    VoiceService.stopSpeaking();
    
    // Nettoyer les données du fichier JSON après utilisation
    TransactionDataService.clearTransactionData();
    
    super.dispose();
  }
  
  Future<void> _playSummaryAudio() async {
    String summary = 'Récapitulatif de votre transaction : ';
    
    // Construire le résumé dynamiquement
    if (_transactionType.isNotEmpty) {
      summary += _transactionType == 'envoyer' ? 'Envoyer' : _transactionType;
    }
    
    if (_amountController.text.isNotEmpty) {
      summary += ' ${_amountController.text}';
    }
    
    if (_recipientController.text.isNotEmpty) {
      summary += ' à ${_recipientController.text}';
    }
    
    if (_phoneController.text.isNotEmpty) {
      summary += ', numéro ${_phoneController.text}';
    }
    
    if (_selectedOperator.isNotEmpty) {
      summary += ' via ${_selectedOperator}';
    }
    
    summary += '. Confirmez-vous cette transaction ?';
    
    await VoiceService.speak(summary);
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
  
  void _startVoiceConfirmation() async {
    setState(() {
      _isListening = true;
    });
    
    // Simuler la reconnaissance vocale
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _isListening = false;
    });
    
    // Simuler confirmation "Je confirme"
    // Rediriger vers l'opérateur approprié
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
    // car les applications de paiement nécessitent généralement un numéro
    String finalPhoneNumber = phoneNumber.isNotEmpty ? phoneNumber : '00000000';
    
    // Rediriger vers l'application de l'opérateur
    final success = await PaymentRedirectService.redirectToOperator(
      operator: _selectedOperator,
      amount: amount,
      phoneNumber: finalPhoneNumber,
      recipientName: recipientName.isNotEmpty ? recipientName : 'Destinataire',
    );
    
    if (!success) {
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
              context.go('/voice-confirmation');
            }
          },
        ),
        title: const Text(
          'Récapitulatif',
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
            // Section principale
            _buildMainSection(context),
            const SizedBox(height: 24),
            
            // Section détails
            _buildDetailsSection(context),
            const SizedBox(height: 24),
            
            // Section actions
            _buildActionButtons(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMainSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(16),
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
            'Récapitulatif de la transaction',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Type', _transactionType == 'envoyer' ? 'Envoi d\'argent' : _transactionType),
          _buildDetailRow('Destinataire', _recipientController.text.isNotEmpty ? _recipientController.text : 'Non spécifié'),
          _buildDetailRow('Montant', _amountController.text.isNotEmpty ? _amountController.text : 'Non spécifié'),
          _buildDetailRow('Opérateur', _selectedOperator.isNotEmpty ? _selectedOperator : 'Non spécifié'),
        ],
      ),
    );
  }
  
  Widget _buildDetailsSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(16),
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
            'Détails supplémentaires',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Frais', '50 F CFA'),
          _buildDetailRow('Total', _calculateTotal()),
        ],
      ),
    );
  }
  
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _startVoiceConfirmation,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryOrange,
              foregroundColor: AppTheme.pureWhite,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(_isListening ? 'Écoute en cours...' : 'Confirmer avec la voix'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => context.go('/voice-confirmation'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.textSecondary,
              side: const BorderSide(color: AppTheme.lightGray),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Modifier'),
          ),
        ),
      ],
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w500,
            ),
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
}
