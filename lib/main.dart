import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/pkl_models.dart';
import 'screens/admin_accounts_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/admin_placement_screen.dart';
import 'screens/attendance_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/history_screen.dart';
import 'screens/journal_screen.dart';
import 'screens/login_screen.dart';
import 'screens/mentor_dashboard_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/teacher_attendance_screen.dart' as teacher_att;
import 'screens/teacher_dashboard_screen.dart' as teacher_dash;
import 'screens/teacher_reviews_screen.dart';
import 'screens/teacher_students_screen.dart' as teacher_students;
import 'services/pkl_store.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    publishableKey: const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'),
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PKLJOURNEY',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AppEntryFlow(),
    );
  }
}

class AppEntryFlow extends StatefulWidget {
  const AppEntryFlow({super.key});

  @override
  State<AppEntryFlow> createState() => _AppEntryFlowState();
}

class _AppEntryFlowState extends State<AppEntryFlow> {
  final PklStore _store = PklStore();
  bool _showSplash = true;

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return SplashScreen(
        onFinished: () {
          setState(() {
            _showSplash = false;
          });
        },
      );
    }

    return AnimatedBuilder(
      animation: _store,
      builder: (context, _) {
        final loggedInUser = _store.currentUser;
        if (loggedInUser == null) {
          return LoginScreen(
            users: _store.users,
            onLogin: _store.login,
          );
        }

        return _RoleShell(
          store: _store,
          user: loggedInUser,
          onLogout: _store.logout,
        );
      },
    );
  }
}

class _RoleShell extends StatefulWidget {
  const _RoleShell({
    required this.store,
    required this.user,
    required this.onLogout,
  });

  final PklStore store;
  final PklUser user;
  final VoidCallback onLogout;

  @override
  State<_RoleShell> createState() => _RoleShellState();
}

class _RoleShellState extends State<_RoleShell> {
  int _currentIndex = 0;

  void _goToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _openHistory(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AnimatedBuilder(
          animation: widget.store,
          builder: (_, __) => HistoryScreen(
            user: widget.user,
            entries: widget.store.historyForUser(widget.user),
          ),
        ),
      ),
    );
  }

  void _updateOwnProfile(PklUser updated) {
    widget.store.updateUser(
      originalAccountId: widget.user.accountId,
      originalRole: widget.user.role,
      updated: updated,
      isSelfProfileEdit: true,
    );
  }

  Map<String, List<teacher_att.AttendanceRecord>> _buildTeacherAttendanceMap(
    List<PklUser> students,
  ) {
    final map = <String, List<teacher_att.AttendanceRecord>>{};
    for (final s in students) {
      final list = widget.store.attendanceForStudent(s.accountId);
      map[s.accountId] = list
          .map(
            (r) => teacher_att.AttendanceRecord(
              date: r.date,
              checkInTime: r.checkInTime,
              checkOutTime: r.checkOutTime,
              checkInPhoto: r.checkInPhoto,
              checkOutPhoto: r.checkOutPhoto,
              checkInPhotoBytes: r.checkInPhotoBytes,
              checkOutPhotoBytes: r.checkOutPhotoBytes,
              isApprovedByIduka: r.isApprovedByIduka,
              idukaApproverName: r.idukaApproverName,
              idukaApprovalTime: r.idukaApprovalTime,
            ),
          )
          .toList();
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final pages = _buildPages(context);
    final items = _buildNavItems();
    final safeIndex = _currentIndex.clamp(0, pages.length - 1);

    return Scaffold(
      body: IndexedStack(
        index: safeIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: safeIndex,
        onTap: _goToTab,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.maroon,
        unselectedItemColor: AppColors.muted,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: items,
      ),
    );
  }

  List<Widget> _buildPages(BuildContext context) {
    final store = widget.store;
    final user = widget.user;
    final roleNotifications = store.notificationsForRole(user.role);
    final unreadCount = store.unreadNotificationCount(user.role);

    switch (user.role) {
      case UserRole.admin:
        return [
          AdminDashboardScreen(
            user: user,
            users: store.users,
            onManageAccounts: () => _goToTab(1),
            onManageMentorship: () => _goToTab(2),
            onOpenHistory: () => _openHistory(context),
            notifications: roleNotifications,
            unreadNotificationCount: unreadCount,
            onNotificationsOpened: () =>
                store.markAllNotificationsRead(user.role),
          ),
          AdminAccountsScreen(
            currentAdmin: user,
            users: store.users,
            onRegisterAccount: store.addUser,
            onUpdateAccount: (original, updated) => store.updateUser(
              originalAccountId: original.accountId,
              originalRole: original.role,
              updated: updated,
            ),
            onDeleteAccount: store.deleteUser,
          ),
          AdminPlacementScreen(
            users: store.users,
            onAssignMentor: store.assignMentor,
            onNavigateToAccounts: () => _goToTab(1),
          ),
          ProfileScreen(
            user: user,
            onLogout: widget.onLogout,
            onUpdateProfile: _updateOwnProfile,
            onOpenHistory: () => _openHistory(context),
          ),
        ];

      case UserRole.murid:
        final myAttendance = store.attendanceForStudent(user.accountId);
        final todayAtt = store.todayAttendanceForStudent(user.accountId);
        final myJournals = store.journalsForStudent(user.accountId);
        final mentor = store.users
            .where((u) => u.role == UserRole.iduka)
            .firstOrNull;
        return [
          DashboardScreen(
            studentName: user.name,
            studentClass: user.kelas ?? 'XI RPL 2  •  Rekayasa Perangkat Lunak',
            hasCheckedIn: todayAtt?.checkInTime != null,
            hasCheckedOut: todayAtt?.checkOutTime != null,
            checkInTime: todayAtt?.checkInTime,
            checkOutTime: todayAtt?.checkOutTime,
            journalCount: myJournals.length,
            presentDays: myAttendance.length + 99,
            schedule: store.schedule,
            workplaceLocation: InternshipLocation(
              companyName:
                  user.companyName ?? 'PT Aksara Digital Nusantara',
              address: mentor?.address ??
                  'Gedung Menara Sudirman Lt. 12, Jl. Jend. Sudirman Kav. 28, Jakarta Pusat',
            ),
            idukaMentorName: mentor?.name ?? 'Hendro Prasetyo, S.T.',
            latestJournal: myJournals.firstOrNull,
            notifications: roleNotifications,
            unreadNotificationCount: unreadCount,
            onNotificationsOpened: () =>
                store.markAllNotificationsRead(user.role),
            onOpenHistory: () => _openHistory(context),
            onOpenAttendance: () => _goToTab(1),
            onOpenJournal: () => _goToTab(2),
          ),
          AttendanceScreen(
            student: user,
            idukaMentorName: mentor?.name ?? 'Hendro Prasetyo, S.T.',
            schedule: store.schedule,
            records: myAttendance,
            notifications: roleNotifications,
            unreadNotificationCount: unreadCount,
            onNotificationsOpened: () =>
                store.markAllNotificationsRead(user.role),
            onCheckIn: (bytes) =>
                store.recordCheckIn(student: user, photoBytes: bytes),
            onCheckOut: (bytes) =>
                store.recordCheckOut(student: user, photoBytes: bytes),
          ),
          JournalScreen(
            student: user,
            entries: myJournals,
            onAddEntry: (entry) => store.addJournal(
              student: user,
              title: entry.title,
              description: entry.description,
              tag: entry.tag,
              imageBytes: entry.imageBytes,
            ),
          ),
          ProfileScreen(
            user: user,
            onLogout: widget.onLogout,
            onUpdateProfile: _updateOwnProfile,
            onOpenHistory: () => _openHistory(context),
          ),
        ];

      case UserRole.guru:
        final students =
            store.users.where((u) => u.role == UserRole.murid).toList();
        final teacherStudents = students
            .map(
              (s) => teacher_att.PklUser(
                accountId: s.accountId,
                name: s.name,
                role: teacher_att.UserRole.murid,
                username: s.username,
                mentorAccountId: s.mentorAccountId,
                companyName: s.companyName,
                address: s.address,
                phoneNumber: s.phoneNumber,
              ),
            )
            .toList();
        return [
          teacher_dash.TeacherDashboardScreen(
            pendingJournalCount:
                store.journals.where((j) => !j.isReviewedByTeacher).length,
            onOpenStudents: () => _goToTab(1),
            onOpenAttendance: () => _goToTab(2),
            onOpenReviews: () => _goToTab(3),
            onOpenHistory: () => _openHistory(context),
          ),
          const teacher_students.TeacherStudentsScreen(),
          teacher_att.TeacherAttendanceScreen(
            students: teacherStudents,
            attendanceRecords: _buildTeacherAttendanceMap(students),
          ),
          TeacherReviewsScreen(
            isIduka: false,
            reviewerName: user.name,
            initialReviews: store.journals,
            notifications: roleNotifications,
            unreadNotificationCount: unreadCount,
            onNotificationsOpened: () =>
                store.markAllNotificationsRead(user.role),
            onReviewTeacher: (journalId, {note}) =>
                store.reviewJournalByTeacher(
              journalId: journalId,
              teacher: user,
              note: note,
            ),
          ),
          ProfileScreen(
            user: user,
            onLogout: widget.onLogout,
            onUpdateProfile: _updateOwnProfile,
            onOpenHistory: () => _openHistory(context),
          ),
        ];

      case UserRole.iduka:
        final students =
            store.users.where((u) => u.role == UserRole.murid).toList();
        final idukaStudents = students
            .map(
              (s) => teacher_att.PklUser(
                accountId: s.accountId,
                name: s.name,
                role: teacher_att.UserRole.murid,
                username: s.username,
                mentorAccountId: s.mentorAccountId,
                companyName: s.companyName,
                address: s.address,
                phoneNumber: s.phoneNumber,
              ),
            )
            .toList();
        final pendingAttCount = store.attendanceRecords
            .where((a) => !a.isApprovedByIduka && !a.isRejectedByIduka)
            .length;
        final pendingJournalCount = store.journals
            .where((j) => !j.isValidatedByMentor && !j.isRejectedByMentor)
            .length;
        return [
          MentorDashboardScreen(
            mentor: user,
            students: students,
            pendingAttendanceCount: pendingAttCount,
            pendingJournalCount: pendingJournalCount,
            schedule: store.schedule,
            onOpenAttendance: () => _goToTab(1),
            onOpenJournals: () => _goToTab(2),
            onOpenHistory: () => _openHistory(context),
            notifications: roleNotifications,
            unreadNotificationCount: unreadCount,
            onNotificationsOpened: () =>
                store.markAllNotificationsRead(user.role),
          ),
          teacher_att.TeacherAttendanceScreen(
            isIduka: true,
            idukaName: user.name,
            students: idukaStudents,
            attendanceRecords: _buildTeacherAttendanceMap(students),
            onApproveAttendance: (studentAccountId, recordDate, approve) {
              final matched = store.attendanceRecords.where((r) =>
                  r.studentAccountId == studentAccountId &&
                  r.date.year == recordDate.year &&
                  r.date.month == recordDate.month &&
                  r.date.day == recordDate.day);
              for (final rec in matched) {
                store.validateAttendance(
                  recordId: rec.id,
                  approve: approve,
                  mentor: user,
                );
              }
            },
          ),
          TeacherReviewsScreen(
            isIduka: true,
            reviewerName: user.name,
            initialReviews: store.journals,
            notifications: roleNotifications,
            unreadNotificationCount: unreadCount,
            onNotificationsOpened: () =>
                store.markAllNotificationsRead(user.role),
            onValidateMentor: (journalId, {required approve, note}) =>
                store.validateJournalByMentor(
              journalId: journalId,
              mentor: user,
              approve: approve,
              note: note,
            ),
          ),
          ProfileScreen(
            user: user,
            onLogout: widget.onLogout,
            onUpdateProfile: _updateOwnProfile,
            onOpenHistory: () => _openHistory(context),
          ),
        ];
    }
  }

  List<BottomNavigationBarItem> _buildNavItems() {
    return switch (widget.user.role) {
      UserRole.admin => const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard_rounded),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_accounts_outlined),
            activeIcon: Icon(Icons.manage_accounts_rounded),
            label: 'Akun',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_ind_outlined),
            activeIcon: Icon(Icons.assignment_ind_rounded),
            label: 'Bimbingan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      UserRole.murid => const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fact_check_outlined),
            activeIcon: Icon(Icons.fact_check_rounded),
            label: 'Presensi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book_rounded),
            label: 'Jurnal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      UserRole.guru => const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_outlined),
            activeIcon: Icon(Icons.groups_rounded),
            label: 'Murid',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fact_check_outlined),
            activeIcon: Icon(Icons.fact_check_rounded),
            label: 'Presensi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rate_review_outlined),
            activeIcon: Icon(Icons.rate_review_rounded),
            label: 'Jurnal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      UserRole.iduka => const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fact_check_outlined),
            activeIcon: Icon(Icons.fact_check_rounded),
            label: 'Presensi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rate_review_outlined),
            activeIcon: Icon(Icons.rate_review_rounded),
            label: 'Jurnal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
    };
  }
}
