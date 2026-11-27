import 'package:flutter/material.dart';

import '../models/pkl_models.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class MentorDashboardScreen extends StatelessWidget {
  const MentorDashboardScreen({
    super.key,
    required this.mentor,
    required this.students,
    required this.pendingAttendanceCount,
    required this.pendingJournalCount,
    required this.schedule,
    required this.onOpenAttendance,
    required this.onOpenJournals,
    this.onOpenHistory,
    this.notifications,
    this.unreadNotificationCount = 0,
    this.onNotificationsOpened,
  });

  final PklUser mentor;
  final List<PklUser> students;
  final int pendingAttendanceCount;
  final int pendingJournalCount;
  final InternshipSchedule schedule;
  final VoidCallback onOpenAttendance;
  final VoidCallback onOpenJournals;
  final VoidCallback? onOpenHistory;
  final List<PklNotificationItem>? notifications;
  final int unreadNotificationCount;
  final VoidCallback? onNotificationsOpened;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Row(
            children: [
              const BrandMark(compact: true),
              const Spacer(),
              const InfoPill(
                label: 'MENTOR IDUKA',
                color: AppColors.cream,
                textColor: AppColors.maroon,
                icon: Icons.business_center_outlined,
              ),
              if (onOpenHistory != null)
                PklHistoryButton(onTap: onOpenHistory!),
              PklNotificationButton(
                unreadCount: unreadNotificationCount,
                notifications: notifications,
                onOpened: onNotificationsOpened,
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Hero Banner
          Container(
            padding: const EdgeInsets.all(21),
            decoration: BoxDecoration(
              color: AppColors.maroon,
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [AppColors.maroon, AppColors.maroonDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (mentor.companyName ?? 'MITRA INDUSTRI PKL').toUpperCase(),
                  style: TextStyle(
                    color: AppColors.cream.withValues(alpha: 0.85),
                    fontSize: 10,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Halo, ${mentor.name.split(' ').first}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Validasi presensi harian dan berikan masukan pada jurnal kegiatan murid PKL di perusahaan Anda.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _MetricTile(
                        label: 'Murid PKL',
                        value: '${students.length}',
                        icon: Icons.groups_outlined,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MetricTile(
                        label: 'Presensi Pending',
                        value: '$pendingAttendanceCount',
                        icon: Icons.fact_check_outlined,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MetricTile(
                        label: 'Jurnal Pending',
                        value: '$pendingJournalCount',
                        icon: Icons.menu_book_outlined,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          const SectionLabel('Aksi Cepat Pembimbing Industri'),
          WhiteCard(
            padding: 0,
            child: Column(
              children: [
                ListTile(
                  onTap: onOpenAttendance,
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.cream,
                    child: Icon(Icons.fact_check_rounded,
                        color: AppColors.maroon, size: 20),
                  ),
                  title: const Text(
                    'Validasi Presensi Murid',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    pendingAttendanceCount > 0
                        ? '$pendingAttendanceCount presensi menunggu konfirmasi'
                        : 'Semua presensi sudah tervalidasi',
                    style:
                        const TextStyle(fontSize: 11, color: AppColors.muted),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: AppColors.muted),
                ),
                const Divider(height: 1, indent: 68, endIndent: 16),
                ListTile(
                  onTap: onOpenJournals,
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.paleAmber,
                    child: Icon(Icons.rate_review_rounded,
                        color: AppColors.amber, size: 20),
                  ),
                  title: const Text(
                    'Validasi & Masukan Jurnal Murid',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    pendingJournalCount > 0
                        ? '$pendingJournalCount jurnal menunggu validasi & masukan'
                        : 'Semua jurnal sudah divalidasi',
                    style:
                        const TextStyle(fontSize: 11, color: AppColors.muted),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: AppColors.muted),
                ),
                if (onOpenHistory != null) ...[
                  const Divider(height: 1, indent: 68, endIndent: 16),
                  ListTile(
                    onTap: onOpenHistory,
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.paleGreen,
                      child: Icon(Icons.history_rounded,
                          color: AppColors.green, size: 20),
                    ),
                    title: const Text(
                      'Riwayat Validasi & Aktivitas',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    subtitle: const Text(
                      'Lihat log persetujuan presensi dan masukan jurnal',
                      style: TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded,
                        size: 14, color: AppColors.muted),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 22),

          SectionLabel(
            'Murid Bimbingan PKL (${schedule.durationMonths} Bulan)',
            action: '${students.length} murid',
          ),
          if (students.isEmpty)
            const WhiteCard(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Belum ada murid yang ditempatkan.',
                    style: TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                ),
              ),
            )
          else
            ...students.map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: WhiteCard(
                  padding: 14,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.cream,
                        child: Text(
                          s.name.isEmpty ? '?' : s.name[0].toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.maroon,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.name,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'NISN: ${s.accountId} • ${s.kelas ?? "Peserta PKL"}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const InfoPill(
                        label: 'Aktif',
                        color: AppColors.paleGreen,
                        textColor: AppColors.green,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.cream, size: 17),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
