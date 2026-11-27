import 'package:flutter/material.dart';

import '../models/attendance_record.dart';
import '../models/journal_entry.dart';
import '../services/attendance_service.dart';
import '../services/journal_service.dart';
import '../services/student_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.studentName,
    this.onOpenAttendance,
    this.onOpenJournal,
    this.onOpenProgress,
  });

  final String studentName;
  final VoidCallback? onOpenAttendance;
  final VoidCallback? onOpenJournal;
  final VoidCallback? onOpenProgress;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _attendanceService = AttendanceService();
  final _journalService = JournalService();
  final _studentService = StudentService();

  bool _isLoading = true;
  AttendanceRecord? _todayRecord;
  List<AttendanceRecord> _attendances = [];
  List<JournalEntry> _journals = [];
  StudentPlacementInfo? _assignment;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _attendanceService.fetchTodayAttendance(),
        _attendanceService.fetchMyAttendances(),
        _journalService.fetchMyJournals(),
        _studentService.fetchMyAssignment(),
      ]);
      if (!mounted) return;
      setState(() {
        _todayRecord = results[0] as AttendanceRecord?;
        _attendances = results[1] as List<AttendanceRecord>;
        _journals = results[2] as List<JournalEntry>;
        _assignment = results[3] as StudentPlacementInfo?;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _greetingTime() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  String _formatTime(DateTime? t) {
    if (t == null) return '--.--';
    return '${t.hour.toString().padLeft(2, '0')}.${t.minute.toString().padLeft(2, '0')}';
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
                    child: Icon(
                      Icons.support_agent_rounded,
                      color: AppColors.green,
                    ),
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
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (phone.isNotEmpty) ...[
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  tileColor: AppColors.paper,
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.green,
                    radius: 18,
                    child: Icon(
                      Icons.chat_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  title: const Text(
                    'WhatsApp / Chat',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    phone,
                    style: const TextStyle(fontSize: 11, color: AppColors.muted),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: AppColors.muted,
                  ),
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
              ],
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                tileColor: AppColors.paper,
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF2E6B8B),
                  radius: 18,
                  child: Icon(
                    Icons.mail_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                title: const Text(
                  'Kirim Email',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  email,
                  style: const TextStyle(fontSize: 11, color: AppColors.muted),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.muted,
                ),
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
    final hasCheckedIn = _todayRecord?.checkIn != null;
    final hasCheckedOut = _todayRecord?.checkOut != null;
    final approvedCount = _attendances
        .where((a) => a.status == ApprovalStatus.approved)
        .length;
    final attendanceMetric = _attendances.isEmpty
        ? '0 hari'
        : '${((approvedCount / _attendances.length) * 100).round()}%';
    final latestJournal = _journals.isNotEmpty ? _journals.first : null;
    final firstName = widget.studentName.trim().isEmpty
        ? 'Siswa'
        : widget.studentName.trim().split(' ').first;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadDashboard,
        color: AppColors.maroon,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            const Row(
              children: [
                BrandMark(compact: true),
                Spacer(),
                PklNotificationButton(unreadCount: 0),
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
                        '${_greetingTime()}, $firstName!',
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
                      if (_assignment != null) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.cream,
                              child: Icon(
                                Icons.business_rounded,
                                color: AppColors.maroon,
                                size: 17,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _assignment!.companyName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.cream,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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
                    value: _isLoading ? '-' : attendanceMetric,
                    label: 'Kehadiran Disetujui',
                    accent: AppColors.green,
                    onTap: widget.onOpenAttendance,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.camera_alt_rounded,
                    value: _isLoading ? '-' : '${_journals.length}',
                    label: 'Jurnal & Foto Kegiatan',
                    accent: AppColors.amber,
                    onTap: widget.onOpenJournal,
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
                    subtitle: hasCheckedOut
                        ? 'Masuk ${_formatTime(_todayRecord?.checkIn)} • Pulang ${_formatTime(_todayRecord?.checkOut)} WIB'
                        : hasCheckedIn
                            ? 'Tercatat masuk pukul ${_formatTime(_todayRecord?.checkIn)} WIB'
                            : 'Unggah foto bukti kehadiran masuk',
                    trailing: Icon(
                      hasCheckedIn
                          ? Icons.check_circle_rounded
                          : Icons.arrow_forward_ios_rounded,
                      size: hasCheckedIn ? 20 : 14,
                      color: hasCheckedIn ? AppColors.green : AppColors.muted,
                    ),
                    onTap: widget.onOpenAttendance,
                  ),
                  const Divider(height: 1, indent: 68, endIndent: 16),
                  _ActionRow(
                    icon: Icons.add_a_photo_rounded,
                    iconColor: AppColors.amber,
                    iconBg: AppColors.paleAmber,
                    title: 'Tulis Jurnal & Dokumentasi',
                    subtitle:
                        'Catat tugas dan lampirkan foto kegiatan hari ini',
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: AppColors.muted,
                    ),
                    onTap: widget.onOpenJournal,
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
                onAction: widget.onOpenJournal,
              ),
              WhiteCard(
                padding: 14,
                onTap: widget.onOpenJournal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        InfoPill(
                          label: latestJournal.statusLabel,
                          color: latestJournal.status == ApprovalStatus.approved
                              ? AppColors.paleGreen
                              : latestJournal.status == ApprovalStatus.rejected
                                  ? const Color(0xFFFDE8E8)
                                  : AppColors.paleAmber,
                          textColor:
                              latestJournal.status == ApprovalStatus.approved
                                  ? AppColors.green
                                  : latestJournal.status ==
                                          ApprovalStatus.rejected
                                      ? Colors.red.shade700
                                      : AppColors.amber,
                          icon: latestJournal.status == ApprovalStatus.approved
                              ? Icons.check_circle_rounded
                              : Icons.hourglass_top_rounded,
                        ),
                        const Spacer(),
                        Text(
                          latestJournal.dateLabel,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      latestJournal.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      latestJournal.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                    if (latestJournal.documentPhoto != null &&
                        latestJournal.documentPhoto!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          latestJournal.documentPhoto!,
                          height: 90,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 22),
            ],

            // Tempat Praktik & Pembimbing IDUKA
            const SectionLabel('Tempat Praktik & Pembimbing'),
            if (_isLoading)
              const WhiteCard(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: CircularProgressIndicator(color: AppColors.maroon),
                  ),
                ),
              )
            else if (_assignment == null)
              const WhiteCard(
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: AppColors.amber),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Penempatan PKL dan pembimbing belum ditetapkan oleh Admin.',
                        style: TextStyle(fontSize: 12, color: AppColors.muted),
                      ),
                    ),
                  ],
                ),
              )
            else
              WhiteCard(
                padding: 16,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                  _assignment!.companyName,
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
                          if (_assignment!.companyAddress != null &&
                              _assignment!.companyAddress!.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              _assignment!.companyAddress!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Pembimbing IDUKA: ${_assignment!.mentorName}',
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
                                  name: _assignment!.mentorName,
                                  roleTitle: 'Pembimbing IDUKA (Industri)',
                                  phone: _assignment!.mentorPhone ?? '',
                                  email: _assignment!.mentorEmail,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.cream,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.chat_bubble_outline_rounded,
                                        size: 12,
                                        color: AppColors.maroon,
                                      ),
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
                                  'Guru Pembimbing: ${_assignment!.teacherName}',
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
                                  name: _assignment!.teacherName,
                                  roleTitle: 'Guru Pembimbing Sekolah',
                                  phone: _assignment!.teacherPhone ?? '',
                                  email: _assignment!.teacherEmail,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.paleGreen,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.chat_bubble_outline_rounded,
                                        size: 12,
                                        color: AppColors.green,
                                      ),
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
