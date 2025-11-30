import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pureWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.pureWhite,
        elevation: 0,
        title: const Text(
          'Profil',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(context),
            const SizedBox(height: 32),
            
            // Stats Cards
            _buildStatsCards(context),
            const SizedBox(height: 32),
            
            // Menu Items
            _buildMenuItems(context),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.orangeGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.pureWhite,
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.person,
              size: 40,
              color: AppTheme.primaryOrange,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Amadou Diop',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.pureWhite,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '+221 77 123 45 67',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.pureWhite,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatsCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            title: 'Transactions',
            value: '156',
            icon: Icons.swap_horiz,
            color: AppTheme.primaryOrange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            title: 'Ce mois',
            value: '45.2K F',
            icon: Icons.trending_up,
            color: AppTheme.primaryOrange,
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
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
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMenuItems(BuildContext context) {
    return Column(
      children: [
        _buildMenuItem(
          context,
          title: 'Informations personnelles',
          icon: Icons.person_outline,
          onTap: () {},
        ),
        _buildMenuItem(
          context,
          title: 'Sécurité',
          icon: Icons.security,
          onTap: () {},
        ),
        _buildMenuItem(
          context,
          title: 'Notifications',
          icon: Icons.notifications_outlined,
          onTap: () {},
        ),
        _buildMenuItem(
          context,
          title: 'Aide et support',
          icon: Icons.help_outline,
          onTap: () {},
        ),
        _buildMenuItem(
          context,
          title: 'À propos',
          icon: Icons.info_outline,
          onTap: () {},
        ),
        _buildMenuItem(
          context,
          title: 'Déconnexion',
          icon: Icons.logout,
          iconColor: Colors.red,
          onTap: () {},
        ),
      ],
    );
  }
  
  Widget _buildMenuItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: iconColor ?? AppTheme.primaryOrange,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: AppTheme.textPrimary,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppTheme.textLight,
        ),
        onTap: onTap,
      ),
    );
  }
}
