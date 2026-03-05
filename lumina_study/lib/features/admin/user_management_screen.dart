import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lumina_study/core/theme/app_theme.dart';
import 'package:lumina_study/shared/services/database_service.dart';
import 'package:lumina_study/shared/widgets/lumina_widgets.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = DatabaseService();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: const Text('User Management'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: db.getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) return const Center(child: Text('No users found'));

          final users = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index].data() as Map<String, dynamic>;
              final bool isPro = user['plan'] == 'Pro';
              final String email = user['email'] ?? 'No Email';
              final String name = user['displayName'] ?? 'Unknown';

              return LuminaCard(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: isPro ? AppColors.warning : AppColors.primary,
                      radius: 20,
                      child: Text(name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                          Text(email, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isPro ? AppColors.warning : AppColors.secondary).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: (isPro ? AppColors.warning : AppColors.secondary).withOpacity(0.4)),
                      ),
                      child: Text(
                        isPro ? 'PRO' : 'FREE',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isPro ? AppColors.warning : AppColors.secondary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.more_vert_rounded, size: 20),
                      onPressed: () {
                        // Logic to block user or upgrade to pro
                        _showUserActions(context, users[index].id, name, isPro);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showUserActions(BuildContext context, String uid, String name, bool isPro) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.edit_rounded, color: AppColors.secondary),
                title: Text(isPro ? 'Downgrade to Free' : 'Upgrade to Pro'),
                onTap: () {
                  FirebaseFirestore.instance.collection('users').doc(uid).update({
                    'plan': isPro ? 'Free' : 'Pro',
                    'credits': isPro ? 20 : 99999,
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.block_rounded, color: AppColors.error),
                title: const Text('Block User'),
                onTap: () {
                  // Logic to block
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_rounded, color: AppColors.textMuted),
                title: const Text('Delete Account Data'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
