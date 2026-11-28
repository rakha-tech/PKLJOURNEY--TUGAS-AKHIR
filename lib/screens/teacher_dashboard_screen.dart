import 'package:flutter/material.dart';

import '../models/attendance_record.dart';
import '../services/teacher_mentor_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({
    super.key,
    this.teacherName = 'Guru Pembimbing',
    required this.onOpenStudents,
    required this.onOpenAttendance,
    required this.onOpenReviews,
  });

  final String teacherName;
  final VoidCallback onOpenStudents;
  final VoidCallback onOpenAttendance;
  final VoidCallback onOpenReviews;

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  final _service = TeacherMentorService();

  bool _isLoading = true;
  List<SupervisedStudent> _students = [];
  List<StudentAttendanceItem> _attendances = [];
  List<StudentJournalItem> _journals = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _service.fetchMyStudents(),
        _service.fetchStudentsAttendances(),
        _service.fetchStudentsJournals(),
      ]);
      if (!mounted) return;
      setState(() {
        _students = results[0] as List<SupervisedStudent>;
        _attendances = results[1] as List<StudentAttendanceItem>;
        _journals = results[2] as List<StudentJournalItem>;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayAttendances = _attendances.where((a) {
      final d = a.record.attendanceDate;
      return d.year == now.year && d.month == now.month && d.day == now.day;
    }).length;
    final pendingJournals = _journals
        .where((j) => j.entry.status == ApprovalStatus.pending)
        .length;
    final firstName = widget.teacherName.trim().isEmpty
        ? 'Guru'
        : widget.teacherName.trim().split(' ').first;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.maroon,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Row(
              children: [
                const BrandMark(compact: true),
                const Spacer(),
                PklNotificationButton(unreadCount: pendingJournals),
              ],
            ),
            const SizedBox(height: 18),

            // Welcome Banner
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
                        label: 'GURU PEMBIMBING',
                        color: Color(0x33FFFFFF),
                        textColor: Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Halo, $firstName!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pantau kehadiran, lokasi PKL, dan jurnal kegiatan siswa bimbingan Anda.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.82),
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _TeacherMetric(
                          label: 'Murid Bimbingan',
                          value: _isLoading ? '-' : '${_students.length}',
                          icon: Icons.groups_outlined,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _TeacherMetric(
                          label: 'Presensi Hari Ini',
                          value: _isLoading ? '-' : '$todayAttendances',
                          icon: Icons.fact_check_outlined,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _TeacherMetric(
                          label: 'Jurnal Pending',
                          value: _isLoading ? '-' : '$pendingJournals',
                          icon: Icons.rate_review_outlined,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),
            const SectionLabel('Menu Monitoring'),
            WhiteCard(
              padding: 0,
              child: Column(
                children: [
                  _NavActionTile(
                    icon: Icons.groups_outlined,
                    iconColor: AppColors.maroon,
                    iconBg: AppColors.cream,
                    title: 'Daftar Murid Bimbingan',
                    subtitle: '${_students.length} siswa aktif dalam bimbingan',
                    onTap: widget.onOpenStudents,
                  ),
                  const Divider(height: 1, indent: 68, endIndent: 16),
                  _NavActionTile(
                    icon: Icons.fact_check_outlined,
                    iconColor: AppColors.green,
                    iconBg: AppColors.paleGreen,
                    title: 'Monitoring Presensi',
                    subtitle:
                        '${_attendances.length} catatan presensi tercatat',
                    onTap: widget.onOpenAttendance,
                  ),
                  const Divider(height: 1, indent: 68, endIndent: 16),
                  _NavActionTile(
                    icon: Icons.menu_book_outlined,
                    iconColor: AppColors.amber,
                    iconBg: AppColors.paleAmber,
                    title: 'Jurnal Kegiatan Siswa',
                    subtitle: '${_journals.length} jurnal (${pendingJournals} menunggu review)',
                    onTap: widget.onOpenReviews,
                  ),
                ],
              ),
            ),

            if (_students.isNotEmpty) ...[
              const SizedBox(height: 22),
              SectionLabel(
                'Murid Bimbingan Terbaru',
                action: 'Lihat Semua',
                onAction: widget.onOpenStudents,
              ),
              ..._students.take(3).map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: WhiteCard(
                        padding: 14,
                        onTap: widget.onOpenStudents,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.cream,
                              child: Text(
                                s.student.fullName.isEmpty
                                    ? '?'
                                    : s.student.fullName[0].toUpperCase(),
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
                                    s.student.fullName,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    s.companyName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: AppColors.muted,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TeacherMetric extends StatelessWidget {
  const _TeacherMetric({
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.cream, size: 18),
          const SizedBox(height: 8),
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
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavActionTile extends StatelessWidget {
  const _NavActionTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
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
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.muted,
            ),
          ],
        ),
      ),
    );
  }
}
