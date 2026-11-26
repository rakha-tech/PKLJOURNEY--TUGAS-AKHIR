import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/admin_accounts_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/admin_placement_screen.dart'
    hide PklUser, UserRole;
import 'screens/attendance_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/journal_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/teacher_attendance_screen.dart' as teacher_att;
import 'screens/teacher_dashboard_screen.dart' as teacher_dash;
import 'screens/teacher_reviews_screen.dart';
import 'screens/teacher_students_screen.dart' as teacher_students;
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
  bool _showSplash = true;
  PklUser? _loggedInUser;

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

    if (_loggedInUser == null) {
      return LoginScreen(
        onLogin: (user) {
          setState(() {
            _loggedInUser = user;
          });
        },
      );
    }

    return _RoleShell(
      user: _loggedInUser!,
      onLogout: () {
        setState(() {
          _loggedInUser = null;
        });
      },
    );
  }
}

class _RoleShell extends StatefulWidget {
  const _RoleShell({
    required this.user,
    required this.onLogout,
  });

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

  @override
  Widget build(BuildContext context) {
    final pages = _buildPages();
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

  List<Widget> _buildPages() {
    return switch (widget.user.role) {
      UserRole.admin => [
          AdminDashboardScreen(
            user: widget.user,
            onManageAccounts: () => _goToTab(1),
            onManageMentorship: () => _goToTab(2),
          ),
          AdminAccountsScreen(currentAdmin: widget.user),
          AdminPlacementScreen(
            onNavigateToAccounts: () => _goToTab(1),
          ),
          ProfileScreen(
            user: widget.user,
            onLogout: widget.onLogout,
          ),
        ],
      UserRole.murid => [
          DashboardScreen(
            studentName: widget.user.name,
            onOpenAttendance: () => _goToTab(1),
            onOpenJournal: () => _goToTab(2),
            onOpenProgress: () {},
          ),
          const AttendanceScreen(),
          JournalScreen(
            onAddEntry: (_) {},
          ),
          ProfileScreen(
            user: widget.user,
            onLogout: widget.onLogout,
          ),
        ],
      UserRole.guru => [
          teacher_dash.TeacherDashboardScreen(
            onOpenStudents: () => _goToTab(1),
            onOpenAttendance: () => _goToTab(2),
            onOpenReviews: () => _goToTab(3),
          ),
          const teacher_students.TeacherStudentsScreen(),
          teacher_att.TeacherAttendanceScreen(),
          const TeacherReviewsScreen(),
          ProfileScreen(
            user: widget.user,
            onLogout: widget.onLogout,
          ),
        ],
      UserRole.iduka => [
          teacher_att.TeacherAttendanceScreen(
            isIduka: true,
            idukaName: widget.user.name,
          ),
          const TeacherReviewsScreen(),
          ProfileScreen(
            user: widget.user,
            onLogout: widget.onLogout,
          ),
        ],
    };
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
