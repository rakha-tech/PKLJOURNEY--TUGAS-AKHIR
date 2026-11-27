import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/app_user.dart';
import 'screens/admin_accounts_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/admin_placement_screen.dart';
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
import 'services/auth_service.dart';
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
  final _authService = AuthService();

  bool _showSplash = true;
  bool _checkingSession = true;
  AppUser? _loggedInUser;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final user = await _authService.currentUser();
    if (mounted) {
      setState(() {
        _loggedInUser = user;
        _checkingSession = false;
      });
    }
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

    if (_checkingSession) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.maroon),
        ),
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
      onLogout: () async {
        await _authService.signOut();
        if (mounted) {
          setState(() {
            _loggedInUser = null;
          });
        }
      },
      onUserUpdated: (updatedUser) {
        setState(() {
          _loggedInUser = updatedUser;
        });
      },
    );
  }
}

class _RoleShell extends StatefulWidget {
  const _RoleShell({
    required this.user,
    required this.onLogout,
    this.onUserUpdated,
  });

  final AppUser user;
  final VoidCallback onLogout;
  final ValueChanged<AppUser>? onUserUpdated;

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
    switch (widget.user.role) {
      case AppRole.admin:
        return [
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
            onUserUpdated: widget.onUserUpdated,
          ),
        ];
      case AppRole.siswa:
        return [
          DashboardScreen(
            studentName: widget.user.fullName,
            onOpenAttendance: () => _goToTab(1),
            onOpenJournal: () => _goToTab(2),
            onOpenProgress: () {},
          ),
          const AttendanceScreen(),
          const JournalScreen(),
          ProfileScreen(
            user: widget.user,
            onLogout: widget.onLogout,
            onUserUpdated: widget.onUserUpdated,
          ),
        ];
      case AppRole.guru:
        return [
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
            onUserUpdated: widget.onUserUpdated,
          ),
        ];
      case AppRole.mentor:
        return [
          teacher_att.TeacherAttendanceScreen(
            isIduka: true,
            idukaName: widget.user.fullName,
          ),
          const TeacherReviewsScreen(),
          ProfileScreen(
            user: widget.user,
            onLogout: widget.onLogout,
            onUserUpdated: widget.onUserUpdated,
          ),
        ];
    }
  }

  List<BottomNavigationBarItem> _buildNavItems() {
    return switch (widget.user.role) {
      AppRole.admin => const [
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
      AppRole.siswa => const [
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
      AppRole.guru => const [
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
      AppRole.mentor => const [
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
