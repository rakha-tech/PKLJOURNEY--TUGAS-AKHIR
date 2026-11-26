import 'package:flutter/material.dart';

// ============================================================
// DUMMY DATA & MODEL (self-contained)
// ============================================================

enum UserRole { guru, murid, iduka }

class PklUser {
  const PklUser({
    required this.username,
    required this.password,
    required this.name,
    required this.role,
    required this.accountId,
    this.mentorAccountId,
    this.idukaAccountId,
    this.companyName,
    this.address,
    this.phoneNumber,
    this.school,
  });

  final String username;
  final String password;
  final String name;
  final UserRole role;
  final String accountId;
  final String? mentorAccountId;
  final String? idukaAccountId;
  final String? companyName;
  final String? address;
  final String? phoneNumber;
  final String? school;
}

// ============================================================
// THEME COLORS (dummy, self-contained)
// ============================================================

class AppColors {
  AppColors._();

  static const Color maroon = Color(0xFF7A1F2B);
  static const Color cream = Color(0xFFF7E9D7);
  static const Color paleGreen = Color(0xFFDDF3E1);
  static const Color green = Color(0xFF2E7D32);
  static const Color amber = Color(0xFFB8860B);
  static const Color ink = Color(0xFF1F1F1F);
  static const Color muted = Color(0xFF8A8A8A);
}

// ============================================================
// SHARED WIDGETS (dummy, self-contained)
// ============================================================

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.compact = false});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 30 : 38,
          height: compact ? 30 : 38,
          decoration: BoxDecoration(
            color: AppColors.maroon,
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Icon(Icons.school, color: Colors.white, size: 18),
        ),
        if (!compact) ...[
          const SizedBox(width: 8),
          const Text(
            'PKL Journey',
            style: TextStyle(
              color: AppColors.ink,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ],
      ],
    );
  }
}

class InfoPill extends StatelessWidget {
  const InfoPill({
    super.key,
    required this.label,
    required this.color,
    required this.textColor,
    this.icon,
  });

  final String label;
  final Color color;
  final Color textColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: textColor, size: 11),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class PklNotificationButton extends StatelessWidget {
  const PklNotificationButton({super.key, this.unreadCount = 0});
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.maroon,
            size: 18,
          ),
        ),
        if (unreadCount > 0)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.maroon,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                '$unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.action, this.onAction});
  final String text;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                action!,
                style: const TextStyle(
                  color: AppColors.maroon,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class WhiteCard extends StatelessWidget {
  const WhiteCard({
    super.key,
    required this.child,
    this.padding = 16,
  });

  final Widget child;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }
}

// ============================================================
// MAIN SCREEN
// ============================================================

class TeacherDashboardScreen extends StatelessWidget {
  const TeacherDashboardScreen({
    super.key,
    this.user,
    this.users,
    this.pendingJournalCount,
    this.onOpenStudents,
    this.onOpenReviews,
    this.onOpenAttendance,
  });

  final PklUser? user;
  final List<PklUser>? users;
  final int? pendingJournalCount;
  final VoidCallback? onOpenStudents;
  final VoidCallback? onOpenReviews;
  final VoidCallback? onOpenAttendance;

  static const PklUser _defaultTeacher = PklUser(
    username: 'guru',
    password: '123',
    name: 'Danang Dwi Gusti Fajar Yudha, S.Kom.',
    role: UserRole.guru,
    accountId: '19820109940201',
    address: 'Jl. Rawamangun Muka No. 12, Jakarta Timur',
    phoneNumber: '081398765432',
    school: 'SMK Negeri 1 Jakarta',
  );

  static const List<PklUser> _defaultStudents = [
    PklUser(
      username: 'frida',
      password: '123',
      name: 'Frida Awan',
      role: UserRole.murid,
      accountId: '007812121134',
      mentorAccountId: '19820109940201',
      idukaAccountId: 'IDUKA-001',
      companyName: 'PT Aksara Digital Nusantara',
      address: 'Jl. Tebet Barat Dalam No. 15, Jakarta Selatan',
      phoneNumber: '085711223344',
    ),
    PklUser(
      username: 'rakha',
      password: '123',
      name: 'Muhammad Rakha',
      role: UserRole.murid,
      accountId: '008127658190',
      mentorAccountId: '19820109940201',
      idukaAccountId: 'IDUKA-001',
      companyName: 'PT Aksara Digital Nusantara',
      address: 'Jl. Kebon Jeruk Raya No. 8, Jakarta Barat',
      phoneNumber: '087855667788',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final activeUser = user ?? _defaultTeacher;
    final activeUsers = users ?? _defaultStudents;
    final activePendingCount = pendingJournalCount ?? 2;

    final studentCount = activeUsers
        .where(
          (account) =>
              account.role == UserRole.murid &&
              account.mentorAccountId == activeUser.accountId,
        )
        .length;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          const Row(
            children: [
              BrandMark(compact: true),
              Spacer(),
              InfoPill(
                label: 'GURU PEMBIMBING',
                color: AppColors.paleGreen,
                textColor: AppColors.green,
                icon: Icons.person_pin_outlined,
              ),
              SizedBox(width: 6),
              PklNotificationButton(unreadCount: 2),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(21),
            decoration: BoxDecoration(
              color: AppColors.maroon,
              borderRadius: BorderRadius.circular(23),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RUANG PEMBIMBING',
                  style: TextStyle(
                    color: AppColors.cream.withOpacity(0.8),
                    fontSize: 10,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 11),
                Text(
                  'Halo, ${activeUser.name.split(' ').first}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Pantau perkembangan siswa dan beri arahan untuk langkah berikutnya.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _TeacherMetric(
                        value: '$studentCount',
                        label: 'Murid dibimbing',
                        icon: Icons.school_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _TeacherMetric(
                        value: '$activePendingCount',
                        label: 'Jurnal menunggu',
                        icon: Icons.rate_review_outlined,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const SectionLabel('Akses cepat'),
          WhiteCard(
            padding: 0,
            child: Column(
              children: [
                _TeacherAction(
                  icon: Icons.groups_2_outlined,
                  color: AppColors.maroon,
                  title: 'Daftar murid bimbingan',
                  subtitle: '$studentCount akun murid terdaftar',
                  onTap: onOpenStudents ?? () {},
                ),
                const Divider(height: 1, indent: 66, endIndent: 15),
                _TeacherAction(
                  icon: Icons.menu_book_outlined,
                  color: AppColors.amber,
                  title: 'Tinjau jurnal kegiatan',
                  subtitle: 'Periksa catatan dan beri tindak lanjut',
                  onTap: onOpenReviews ?? () {},
                ),
                const Divider(height: 1, indent: 66, endIndent: 15),
                _TeacherAction(
                  icon: Icons.fact_check_outlined,
                  color: AppColors.green,
                  title: 'Riwayat kehadiran',
                  subtitle: 'Lihat presensi murid bimbingan',
                  onTap: onOpenAttendance ?? () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          SectionLabel(
            'Murid terbaru',
            action: 'Lihat semua',
            onAction: onOpenStudents,
          ),
          ...activeUsers
              .where(
                (account) =>
                    account.role == UserRole.murid &&
                    account.mentorAccountId == activeUser.accountId,
              )
              .take(3)
              .map(
                (student) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: WhiteCard(
                    padding: 14,
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 21,
                          backgroundColor: AppColors.cream,
                          child: Icon(
                            Icons.school_outlined,
                            color: AppColors.maroon,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.ink,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'NISN ${student.accountId}',
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 10,
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
          const SizedBox(height: 5),
          const Text(
            'Status jurnal dan presensi pada ringkasan merupakan data contoh.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PRIVATE WIDGETS
// ============================================================

class _TeacherMetric extends StatelessWidget {
  const _TeacherMetric({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.11),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.cream, size: 19),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    color: Colors.white.withOpacity(0.78),
                    fontSize: 9,
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

class _TeacherAction extends StatelessWidget {
  const _TeacherAction({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

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
              radius: 21,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.muted,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}