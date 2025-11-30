import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pureWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            
            // Barre de recherche vocale
            _buildSearchBar(context),
            
            // Filtres
            _buildFilters(context),
            
            // Liste des transactions
            Expanded(
              child: _buildTransactionList(context),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Historique',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontSize: 28,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '12 transactions',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 20),
            Icon(
              Icons.search,
              color: AppTheme.primaryOrange,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Rechercher vocalement...',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ),
            Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                gradient: AppTheme.orangeGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.mic,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFilters(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(context, 'Tous', true),
            const SizedBox(width: 12),
            _buildFilterChip(context, 'Envoyés', false),
            const SizedBox(width: 12),
            _buildFilterChip(context, 'Reçus', false),
            const SizedBox(width: 12),
            _buildFilterChip(context, 'Recharges', false),
            const SizedBox(width: 12),
            _buildFilterChip(context, 'Paiements', false),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFilterChip(BuildContext context, String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primaryGreen : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isActive ? Colors.white : const Color(0xFF6B7280),
        ),
      ),
    );
  }
  
  Widget _buildTransactionList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _mockTransactions.length,
      itemBuilder: (context, index) {
        final transaction = _mockTransactions[index];
        return _buildTransactionItem(context, transaction);
      },
    );
  }
  
  Widget _buildTransactionItem(BuildContext context, Map<String, dynamic> transaction) {
    final isSent = transaction['type'] == 'sent';
    final isSuccess = transaction['status'] == 'success';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icône de transaction
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSent ? AppTheme.errorLight : const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              isSent ? Icons.arrow_upward : Icons.arrow_downward,
              color: isSent ? AppTheme.errorRed : AppTheme.primaryGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          
          // Détails
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['title'],
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction['date'],
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          
          // Montant et statut
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isSent ? '-' : '+'}${transaction['amount']} F',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isSent ? AppTheme.errorRed : AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isSuccess ? const Color(0xFFF0FDF4) : AppTheme.errorLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isSuccess ? 'Succès' : 'Échec',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isSuccess ? AppTheme.primaryGreen : AppTheme.errorRed,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // Données mock pour la démo
  static const List<Map<String, dynamic>> _mockTransactions = [
    {
      'type': 'sent',
      'title': 'Destinataire inconnu',
      'amount': '0',
      'date': 'Aujourd\'hi, 14:32',
      'status': 'success',
    },
    {
      'type': 'received',
      'title': 'Mamadou Ba',
      'amount': '10 000',
      'date': 'Aujourd\'hui, 11:15',
      'status': 'success',
    },
    {
      'type': 'sent',
      'title': 'Orange Money',
      'amount': '2 000',
      'date': 'Hier, 18:45',
      'status': 'success',
    },
    {
      'type': 'sent',
      'title': 'Aminata Fall',
      'amount': '3 500',
      'date': 'Hier, 09:20',
      'status': 'failed',
    },
    {
      'type': 'received',
      'title': 'Cheikh Sow',
      'amount': '7 500',
      'date': '28 nov, 16:30',
      'status': 'success',
    },
    {
      'type': 'sent',
      'title': 'Free Senegal',
      'amount': '1 500',
      'date': '28 nov, 12:10',
      'status': 'success',
    },
  ];
}
