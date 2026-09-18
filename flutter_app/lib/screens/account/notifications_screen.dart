import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/app_notification.dart';
import '../../services/api_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<AppNotification> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.get('/users/me/notifications');
      _items = (data as List).map((e) => AppNotification.fromJson(e)).toList();
    } catch (_) {
      // abaikan secara halus
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markRead(AppNotification n) async {
    if (n.isRead) return;
    await ApiService.put('/users/me/notifications/${n.id}/read', {});
    _load();
  }

  String _timeAgo(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifikasi')),
      body: RefreshIndicator(
        color: AppColors.brand,
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.brand))
            : _items.isEmpty
                ? ListView(children: [
                    const SizedBox(height: 140),
                    Center(
                      child: Column(
                        children: [
                          Icon(Icons.notifications_none_rounded, size: 52, color: AppColors.plumLight.withValues(alpha: 0.4)),
                          const SizedBox(height: 12),
                          const Text('Belum ada notifikasi', style: TextStyle(color: AppColors.plumLight)),
                        ],
                      ),
                    ),
                  ])
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final n = _items[i];
                      return GestureDetector(
                        onTap: () => _markRead(n),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: n.isRead ? Theme.of(context).cardTheme.color : AppColors.brand.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(14),
                            border: n.isRead ? null : Border.all(color: AppColors.brand.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 36, height: 36,
                                decoration: BoxDecoration(color: AppColors.brand.withValues(alpha: 0.12), shape: BoxShape.circle),
                                child: const Icon(Icons.local_shipping_outlined, size: 17, color: AppColors.brand),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(n.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                                    const SizedBox(height: 3),
                                    Text(n.body, style: const TextStyle(fontSize: 12.5, color: AppColors.plumLight, height: 1.4)),
                                    const SizedBox(height: 6),
                                    Text(_timeAgo(n.createdAt), style: const TextStyle(fontSize: 11, color: AppColors.plumLight)),
                                  ],
                                ),
                              ),
                              if (!n.isRead)
                                Container(width: 8, height: 8, margin: const EdgeInsets.only(top: 4),
                                    decoration: const BoxDecoration(color: AppColors.brand, shape: BoxShape.circle)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
