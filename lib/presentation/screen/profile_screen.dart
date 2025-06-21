import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 정보'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          _buildProfileHeader(context),
          const SizedBox(height: 20),
          _buildMenuList(context),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(
                'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?q=80&w=1780&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '홍길동 님',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'gildong.hong@example.com',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuList(BuildContext context) {
    return Column(
      children: [
        _buildMenuListItem(
            context, Icons.campaign_outlined, '공지사항', () => _showSnackBar(context, '공지사항')),
        _buildMenuListItem(
            context, Icons.event_available_outlined, '이벤트', () => _showSnackBar(context, '이벤트')),
        _buildMenuListItem(
            context, Icons.headset_mic_outlined, '고객센터', () => _showSnackBar(context, '고객센터')),
        const Divider(),
        _buildMenuListItem(
            context, Icons.settings_outlined, '설정', () => _showSnackBar(context, '설정')),
        _buildMenuListItem(
            context, Icons.logout_outlined, '로그아웃', () => _showSnackBar(context, '로그아웃')),
      ],
    );
  }

  Widget _buildMenuListItem(
      BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[800]),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$message 페이지로 이동합니다.'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
} 