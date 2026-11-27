import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

// Model pendukung & Data Dummy lokal khusus DashboardScreen
class InternshipLocation {
  const InternshipLocation({
    required this.companyName,
    required this.address,
  });

  final String companyName;
  final String address;
}

class JournalEntry {
  const JournalEntry({
    required this.title,
    required this.description,
    required this.date,
    required this.tag,
    this.imageUrl,
    this.isReviewed = false,
  });

  final String title;
  final String description;
  final String date;
  final String tag;
  final String? imageUrl;
  final bool isReviewed;
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    this.studentName = 'Rakha Pratama',
    this.hasCheckedIn = true,
    this.hasCheckedOut = false,
    this.checkInTime = '07.55',
    this.checkOutTime,
    this.journalCount = 14,
    this.workplaceLocation = const InternshipLocation(
      companyName: 'PT Aksara Digital Nusantara',
      address:
          'Gedung Menara Sudirman Lt. 12, Jl. Jend. Sudirman Kav. 28, Jakarta Pusat',
    ),
    this.idukaMentorName = 'Hendro Prasetyo, S.T.',
    this.idukaMentorPhone = '081398765432',
    this.idukaMentorEmail = 'hendro.prasetyo@aksara.id',
    this.teacherMentorName = 'Budi Santoso, M.Pd.',
    this.teacherMentorPhone = '081234567891',
    this.teacherMentorEmail = 'budisantoso@guru.smkn1jakarta.sch.id',
    this.latestJournal = const JournalEntry(
      title: 'Implementasi Slicing UI Dashboard & Integrasi Tema',
      description:
          'Menyelesaikan slicing antarmuka dashboard siswa PKL serta merapikan komponen tema maroon dan cream.',
      date: 'Hari ini, 09.30 WIB',
      tag: 'Proyek',
      imageUrl: PklPhotoPresets.coding,
      isReviewed: true,
    ),
    this.onOpenAttendance,
    this.onOpenJournal,
    this.onOpenProgress,
  });

  final String studentName;
  final bool hasCheckedIn;
  final bool hasCheckedOut;
  final String? checkInTime;
  final String? checkOutTime;
  final int journalCount;
  final InternshipLocation? workplaceLocation;
  final String idukaMentorName;
  final String idukaMentorPhone;
  final String idukaMentorEmail;
  final String teacherMentorName;
  final String teacherMentorPhone;
  final String teacherMentorEmail;
  final JournalEntry? latestJournal;
  final VoidCallback? onOpenAttendance;
  final VoidCallback? onOpenJournal;
  final VoidCallback? onOpenProgress;

  String _greetingTime() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  void _showContactOptions(
    BuildContext context, {
    required String name,
    required String roleTitle,
    required String phone,
    required String email,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.line,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.paleGreen,
                    child: Icon(Icons.support_agent_rounded, color: AppColors.green),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          roleTitle,
                          style: const TextStyle(fontSize: 11, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                tileColor: AppColors.paper,
                leading: const CircleAvatar(
                  backgroundColor: AppColors.green,
                  radius: 18,
                  child: Icon(Icons.chat_rounded, color: Colors.white, size: 18),
                ),
                title: const Text('WhatsApp / Chat', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                subtitle: Text(phone, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.muted),
                onTap: () {
                  Navigator.pop(sheetContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Menghubungkan ke WhatsApp: $phone'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                tileColor: AppColors.paper,
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF2E6B8B),
                  radius: 18,
                  child: Icon(Icons.mail_rounded, color: Colors.white, size: 18),
                ),
                title: const Text('Kirim Email', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                subtitle: Text(email, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.muted),
                onTap: () {
                  Navigator.pop(sheetContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Membuka email ke: $email'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Row(
            children: const [
              BrandMark(compact: true),
              Spacer(),
              PklNotificationButton(unreadCount: 2),
            ],
          ),
          const SizedBox(height: 18),

          // Main Welcome Banner
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
            child: Stack(
              children: [
                Positioned(
                  right: -8,
                  top: -5,
                  child: Icon(
                    Icons.school_rounded,
                    color: Colors.white.withValues(alpha: 0.08),
                    size: 110,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          currentDateLabel().toUpperCase(),
                          style: TextStyle(
                            color: AppColors.cream.withValues(alpha: 0.85),
                            fontSize: 10,
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        const InfoPill(
                          label: 'AKTIF PKL',
                          color: Color(0x33FFFFFF),
                          textColor: Colors.white,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '${_greetingTime()}, ${studentName.split(' ').first}!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Satu langkah kecil hari ini, pengalaman besar untuk masa depan industrimu.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: const [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.cream,
                          child: Icon(
                            Icons.badge_rounded,
                            color: AppColors.maroon,
                            size: 18,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'XI RPL 2  •  Rekayasa Perangkat Lunak',
                            style: TextStyle(
                              color: AppColors.cream,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // Ringkasan PKL Metric Cards
          const SectionLabel('Ringkasan Kehadiran & Jurnal'),
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  icon: Icons.fact_check_rounded,
                  value: '98%',
                  label: 'Kehadiran Terverifikasi',
                  accent: AppColors.green,
                  onTap: onOpenAttendance,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  icon: Icons.camera_alt_rounded,
                  value: '$journalCount',
                  label: 'Jurnal & Foto Kegiatan',
                  accent: AppColors.amber,
                  onTap: onOpenJournal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Aksi Hari Ini
          const SectionLabel('Aktivitas Hari Ini'),
          WhiteCard(
            padding: 0,
            child: Column(
              children: [
                _ActionRow(
                  icon: Icons.camera_alt_rounded,
                  iconColor: AppColors.maroon,
                  iconBg: AppColors.cream,
                  title: 'Presensi PKL & Foto Kegiatan',
                  subtitle: hasCheckedIn
                      ? 'Tercatat masuk pukul ${checkInTime ?? '--:--'} WIB'
                      : 'Unggah foto bukti kehadiran masuk',
                  trailing: Icon(
                    hasCheckedIn
                        ? Icons.check_circle_rounded
                        : Icons.arrow_forward_ios_rounded,
                    size: hasCheckedIn ? 20 : 14,
                    color: hasCheckedIn ? AppColors.green : AppColors.muted,
                  ),
                  onTap: onOpenAttendance,
                ),
                const Divider(height: 1, indent: 68, endIndent: 16),
                _ActionRow(
                  icon: Icons.add_a_photo_rounded,
                  iconColor: AppColors.amber,
                  iconBg: AppColors.paleAmber,
                  title: 'Tulis Jurnal & Dokumentasi',
                  subtitle: 'Catat tugas dan lampirkan foto kegiatan hari ini',
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: AppColors.muted,
                  ),
                  onTap: onOpenJournal,
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // Latest Journal Preview
          if (latestJournal != null) ...[
            SectionLabel(
              'Jurnal Terbaru',
              action: 'Lihat Semua',
              onAction: onOpenJournal,
            ),
            WhiteCard(
              padding: 14,
              onTap: onOpenJournal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      InfoPill(
                        label: latestJournal!.tag,
                        color: AppColors.paper,
                        textColor: AppColors.taupe,
                      ),
                      const SizedBox(width: 6),
                      InfoPill(
                        label: latestJournal!.isReviewed
                            ? 'Disetujui'
                            : 'Menunggu Review',
                        color: latestJournal!.isReviewed
                            ? AppColors.paleGreen
                            : AppColors.paleAmber,
                        textColor: latestJournal!.isReviewed
                            ? AppColors.green
                            : AppColors.amber,
                        icon: latestJournal!.isReviewed
                            ? Icons.check_circle_rounded
                            : Icons.hourglass_top_rounded,
                      ),
                      const Spacer(),
                      Text(
                        latestJournal!.date,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    latestJournal!.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    latestJournal!.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                  if (latestJournal!.imageUrl != null) ...[
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        latestJournal!.imageUrl!,
                        height: 90,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 22),
          ],

          // Tempat Praktik & Pembimbing IDUKA
          const SectionLabel('Tempat Praktik & Pembimbing IDUKA'),
          WhiteCard(
            padding: 16,
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.paleGreen,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.business_center_rounded,
                    color: AppColors.green,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              workplaceLocation?.companyName ??
                                  'PT Aksara Digital Nusantara',
                              style: const TextStyle(
                                color: AppColors.ink,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.verified_rounded,
                            color: AppColors.green,
                            size: 16,
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        workplaceLocation?.address ??
                            'Gedung Menara Sudirman Lt. 12, Jl. Jend. Sudirman Kav. 28, Jakarta Pusat',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Pembimbing IDUKA: $idukaMentorName',
                              style: const TextStyle(
                                color: AppColors.maroon,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => _showContactOptions(
                              context,
                              name: idukaMentorName,
                              roleTitle: 'Pembimbing IDUKA (Industri)',
                              phone: idukaMentorPhone,
                              email: idukaMentorEmail,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.cream,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.chat_bubble_outline_rounded, size: 12, color: AppColors.maroon),
                                  SizedBox(width: 4),
                                  Text(
                                    'Hubungi IDUKA',
                                    style: TextStyle(
                                      color: AppColors.maroon,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Guru Pembimbing: $teacherMentorName',
                              style: const TextStyle(
                                color: AppColors.green,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => _showContactOptions(
                              context,
                              name: teacherMentorName,
                              roleTitle: 'Guru Pembimbing Sekolah',
                              phone: teacherMentorPhone,
                              email: teacherMentorEmail,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.paleGreen,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.chat_bubble_outline_rounded, size: 12, color: AppColors.green),
                                  SizedBox(width: 4),
                                  Text(
                                    'Hubungi Guru',
                                    style: TextStyle(
                                      color: AppColors.green,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.accent,
    this.onTap,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: WhiteCard(
        padding: 14,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: accent, size: 22),
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.muted, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: iconBg,
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
