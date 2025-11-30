import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pureWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            
            // Liste des alertes
            Expanded(
              child: _buildAlertsList(context),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Alertes',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '3 nouvelles',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.primaryOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildAlertsList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), // Réduit les padding
      itemCount: _mockAlerts.length,
      itemBuilder: (context, index) {
        final alert = _mockAlerts[index];
        return _buildAlertItem(context, alert);
      },
    );
  }
  
  Widget _buildAlertItem(BuildContext context, Map<String, dynamic> alert) {
    final category = alert['category'] as String;
    final isRead = alert['isRead'] as bool;
    
    Color categoryColor;
    IconData categoryIcon;
    
    switch (category) {
      case 'security':
        categoryColor = AppTheme.errorRed;
        categoryIcon = Icons.security;
        break;
      case 'transaction':
        categoryColor = AppTheme.primaryGreen;
        categoryIcon = Icons.receipt_long;
        break;
      case 'promotion':
        categoryColor = AppTheme.primaryOrange;
        categoryIcon = Icons.local_offer;
        break;
      default:
        categoryColor = const Color(0xFF6B7280);
        categoryIcon = Icons.info;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8), // Réduit la marge
      padding: const EdgeInsets.all(12), // Réduit le padding
      decoration: BoxDecoration(
        color: isRead ? Colors.white : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10), // Réduit le radius
        border: isRead 
            ? null 
            : Border.all(color: AppTheme.primaryGreen.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6, // Réduit le blur
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icône de catégorie
          Container(
            width: 36, // Réduit la taille
            height: 36,
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              categoryIcon,
              color: categoryColor,
              size: 18, // Réduit la taille
            ),
          ),
          const SizedBox(width: 12), // Réduit l'espacement
          
          // Contenu
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        alert['title'],
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                          color: isRead ? const Color(0xFF111827) : AppTheme.primaryGreen,
                          fontSize: 14, // Réduit la taille
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    if (!isRead) ...[
                      const SizedBox(width: 6),
                      Container(
                        width: 6, // Réduit la taille
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3), // Réduit l'espacement
                Text(
                  alert['message'],
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6B7280),
                    fontSize: 13, // Réduit la taille
                  ),
                  maxLines: 2, // Limite le nombre de lignes
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6), // Réduit l'espacement
                Text(
                  alert['time'],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF9CA3AF),
                    fontSize: 11, // Réduit la taille
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Données mock pour la démo
  static const List<Map<String, dynamic>> _mockAlerts = [
    {
      'category': 'security',
      'title': 'Alerte de sécurité',
      'message': 'Transaction inhabituelle détectée. Vérification IA requise.',
      'time': 'Il y a 5 min',
      'isRead': false,
    },
    {
      'category': 'transaction',
      'title': 'Transaction réussie',
      'message': 'Transaction effectuée avec succès.',
      'time': 'Il y a 2 heures',
      'isRead': false,
    },
    {
      'category': 'promotion',
      'title': 'Offre spéciale',
      'message': 'Frais de transaction réduits à 0% ce week-end !',
      'time': 'Il y a 4 heures',
      'isRead': false,
    },
    {
      'category': 'transaction',
      'title': 'Reçu disponible',
      'message': '10 000 F reçus de Mamadou Ba.',
      'time': 'Hier',
      'isRead': true,
    },
    {
      'category': 'security',
      'title': 'Mise à jour de sécurité',
      'message': 'Nouvelle protection anti-fraude activée.',
      'time': 'Hier',
      'isRead': true,
    },
    {
      'category': 'promotion',
      'title': 'Cashback disponible',
      'message': 'Gagnez 5% de cashback sur vos 3 prochaines transactions.',
      'time': '28 nov',
      'isRead': true,
    },
    {
      'category': 'transaction',
      'title': 'Échec de transaction',
      'message': 'La transaction vers Aminata Fall a échoué.',
      'time': '28 nov',
      'isRead': true,
    },
  ];
}
