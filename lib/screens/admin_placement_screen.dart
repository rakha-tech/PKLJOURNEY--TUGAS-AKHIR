import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/admin_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

enum _MentorshipFilter { all, unassigned, assigned, byTeacher }

class AdminPlacementScreen extends StatefulWidget {
  const AdminPlacementScreen({
    super.key,
    this.onNavigateToAccounts,
  });

  final VoidCallback? onNavigateToAccounts;

  @override
  State<AdminPlacementScreen> createState() => _AdminPlacementScreenState();
}

class _AdminPlacementScreenState extends State<AdminPlacementScreen> {
  final _adminService = AdminService();
  final _searchController = TextEditingController();

  bool _isLoading = true;
  List<AppUser> _users = [];
  List<Placement> _placements = [];
  Map<String, StudentAssignment> _assignmentByStudent = {};

  _MentorshipFilter _currentFilter = _MentorshipFilter.all;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _adminService.fetchAllUsers(),
        _adminService.fetchPlacements(),
        _adminService.fetchAssignments(),
      ]);
      if (!mounted) return;
      final assignments = results[2] as List<StudentAssignment>;
      setState(() {
        _users = results[0] as List<AppUser>;
        _placements = results[1] as List<Placement>;
        _assignmentByStudent = {
          for (final a in assignments) a.studentId: a,
        };
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data bimbingan: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  List<AppUser> get _teachers =>
      _users.where((u) => u.role == AppRole.guru).toList();

  List<AppUser> get _mentors =>
      _users.where((u) => u.role == AppRole.mentor).toList();

  List<AppUser> get _students =>
      _users.where((u) => u.role == AppRole.siswa).toList();

  AppUser? _findUser(String? userId) {
    if (userId == null) return null;
    final idx = _users.indexWhere((u) => u.userId == userId);
    return idx != -1 ? _users[idx] : null;
  }

  Placement? _findPlacement(String? placementId) {
    if (placementId == null) return null;
    final idx = _placements.indexWhere((p) => p.placementId == placementId);
    return idx != -1 ? _placements[idx] : null;
  }

  List<AppUser> _studentsForTeacher(String teacherId) {
    return _students
        .where((s) => _assignmentByStudent[s.userId]?.teacherId == teacherId)
        .toList();
  }

  List<AppUser> get _filteredStudents {
    final query = _searchQuery.trim().toLowerCase();
    return _students.where((student) {
      final matchesQuery = query.isEmpty ||
          student.fullName.toLowerCase().contains(query) ||
          student.username.toLowerCase().contains(query) ||
          student.email.toLowerCase().contains(query);
      if (!matchesQuery) return false;

      final isAssigned = _assignmentByStudent.containsKey(student.userId);
      switch (_currentFilter) {
        case _MentorshipFilter.all:
          return true;
        case _MentorshipFilter.unassigned:
          return !isAssigned;
        case _MentorshipFilter.assigned:
          return isAssigned;
        case _MentorshipFilter.byTeacher:
          return true;
      }
    }).toList();
  }

  Future<void> _showAssignSheet(AppUser student) async {
    if (_teachers.isEmpty || _mentors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _teachers.isEmpty
                ? 'Belum ada akun Guru di database.'
                : 'Belum ada akun Mentor (IDUKA) di database.',
          ),
          action: widget.onNavigateToAccounts != null
              ? SnackBarAction(
                  label: 'Kelola Akun',
                  textColor: AppColors.cream,
                  onPressed: widget.onNavigateToAccounts!,
                )
              : null,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final current = _assignmentByStudent[student.userId];
    final result = await showModalBottomSheet<_AssignmentResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _AssignPlacementSheet(
        student: student,
        teachers: _teachers,
        mentors: _mentors,
        placements: _placements,
        currentAssignment: current,
        adminService: _adminService,
        onPlacementCreated: (newPlacement) {
          setState(() {
            _placements.add(newPlacement);
          });
        },
      ),
    );

    if (result == null || !mounted) return;

    if (result.unassign) {
      try {
        await _adminService.deleteAssignment(student.userId);
        if (!mounted) return;
        setState(() {
          _assignmentByStudent.remove(student.userId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Penetapan bimbingan ${student.fullName} dilepaskan.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal melepas bimbingan: $e'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
      return;
    }

    try {
      final saved = await _adminService.upsertAssignment(
        studentId: student.userId,
        teacherId: result.teacherId!,
        mentorId: result.mentorId!,
        placementId: result.placementId!,
      );
      if (!mounted) return;
      setState(() {
        _assignmentByStudent[student.userId] = saved;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Penetapan PKL untuk ${student.fullName} berhasil disimpan.',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.green,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan penetapan: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.maroon,
          ),
        );
      }
    }
  }

  Future<void> _confirmRemoveAssignment(AppUser student) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Lepas penetapan PKL?'),
        content: Text(
          'Lepaskan penetapan guru, mentor, dan tempat PKL untuk ${student.fullName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.maroon,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Lepaskan'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await _adminService.deleteAssignment(student.userId);
      if (!mounted) return;
      setState(() {
        _assignmentByStudent.remove(student.userId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Penetapan ${student.fullName} telah dilepaskan.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal melepas penetapan: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final allStudents = _students;
    final allTeachers = _teachers;
    final assignedCount = allStudents
        .where((s) => _assignmentByStudent.containsKey(s.userId))
        .length;
    final unassignedCount = allStudents.length - assignedCount;
    final filtered = _filteredStudents;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.maroon,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const PageHeading(
              title: 'Penetapan Bimbingan',
              subtitle:
                  'Hubungkan murid dengan guru pembimbing, mentor IDUKA, dan tempat PKL.',
            ),

            // Overview Metrics Row
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Total Siswa',
                    count: _isLoading ? '-' : '${allStudents.length}',
                    icon: Icons.school_outlined,
                    color: AppColors.maroon,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricCard(
                    title: 'Belum Ditetapkan',
                    count: _isLoading ? '-' : '$unassignedCount',
                    icon: Icons.person_off_outlined,
                    color: unassignedCount > 0
                        ? AppColors.amber
                        : AppColors.muted,
                    isAlert: unassignedCount > 0,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricCard(
                    title: 'Guru Pembimbing',
                    count: _isLoading ? '-' : '${allTeachers.length}',
                    icon: Icons.person_pin_outlined,
                    color: AppColors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Search Box
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Cari nama atau username murid...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        icon: const Icon(Icons.close_rounded, size: 18),
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 14),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChipButton(
                    label: 'Semua (${allStudents.length})',
                    selected: _currentFilter == _MentorshipFilter.all,
                    onTap: () =>
                        setState(() => _currentFilter = _MentorshipFilter.all),
                  ),
                  const SizedBox(width: 8),
                  _FilterChipButton(
                    label: 'Belum ($unassignedCount)',
                    selected: _currentFilter == _MentorshipFilter.unassigned,
                    highlight: unassignedCount > 0,
                    onTap: () => setState(
                      () => _currentFilter = _MentorshipFilter.unassigned,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _FilterChipButton(
                    label: 'Sudah ($assignedCount)',
                    selected: _currentFilter == _MentorshipFilter.assigned,
                    onTap: () => setState(
                      () => _currentFilter = _MentorshipFilter.assigned,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _FilterChipButton(
                    label: 'Per Guru',
                    selected: _currentFilter == _MentorshipFilter.byTeacher,
                    onTap: () => setState(
                      () => _currentFilter = _MentorshipFilter.byTeacher,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            if (_isLoading && _users.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.maroon),
                ),
              )
            else if (_currentFilter == _MentorshipFilter.byTeacher)
              ..._buildByTeacherView()
            else ...[
              SectionLabel(
                _currentFilter == _MentorshipFilter.unassigned
                    ? 'Siswa belum ditetapkan'
                    : _currentFilter == _MentorshipFilter.assigned
                        ? 'Siswa sudah ditetapkan'
                        : 'Daftar seluruh siswa',
                action: '${filtered.length} siswa',
              ),
              if (filtered.isEmpty)
                const WhiteCard(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'Tidak ada siswa yang sesuai filter.',
                        style: TextStyle(color: AppColors.muted),
                      ),
                    ),
                  ),
                )
              else
                ...filtered.map((student) {
                  final assignment = _assignmentByStudent[student.userId];
                  final teacher = _findUser(assignment?.teacherId);
                  final mentor = _findUser(assignment?.mentorId);
                  final placement = _findPlacement(assignment?.placementId);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _StudentMentorshipCard(
                      student: student,
                      teacher: teacher,
                      mentor: mentor,
                      placement: placement,
                      onAssign: () => _showAssignSheet(student),
                      onRemove: assignment != null
                          ? () => _confirmRemoveAssignment(student)
                          : null,
                    ),
                  );
                }),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildByTeacherView() {
    if (_teachers.isEmpty) {
      return [
        const WhiteCard(
          child: Center(
            child: Text(
              'Belum ada akun Guru terdaftar.',
              style: TextStyle(color: AppColors.muted),
            ),
          ),
        ),
      ];
    }

    return _teachers.map((teacher) {
      final bimbingan = _studentsForTeacher(teacher.userId);
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: WhiteCard(
          padding: 15,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.cream,
                    child: Icon(
                      Icons.person_pin_outlined,
                      color: AppColors.maroon,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          teacher.fullName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        Text(
                          teacher.email,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InfoPill(
                    label: '${bimbingan.length} siswa',
                    color: AppColors.cream,
                    textColor: AppColors.maroon,
                  ),
                ],
              ),
              if (bimbingan.isEmpty) ...[
                const SizedBox(height: 10),
                const Text(
                  'Belum ada siswa bimbingan.',
                  style: TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ] else ...[
                const SizedBox(height: 10),
                const Divider(height: 1, color: AppColors.line),
                const SizedBox(height: 8),
                ...bimbingan.map((s) {
                  final assignment = _assignmentByStudent[s.userId];
                  final placement = _findPlacement(assignment?.placementId);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.subdirectory_arrow_right_rounded,
                          size: 15,
                          color: AppColors.muted,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            placement != null
                                ? '${s.fullName} • ${placement.companyName}'
                                : s.fullName,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => _showAssignSheet(s),
                          child: const Text('Ubah'),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      );
    }).toList();
  }
}

class _StudentMentorshipCard extends StatelessWidget {
  const _StudentMentorshipCard({
    required this.student,
    required this.onAssign,
    this.teacher,
    this.mentor,
    this.placement,
    this.onRemove,
  });

  final AppUser student;
  final AppUser? teacher;
  final AppUser? mentor;
  final Placement? placement;
  final VoidCallback onAssign;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final isAssigned = teacher != null && mentor != null && placement != null;

    return WhiteCard(
      padding: 15,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 19,
                backgroundColor:
                    isAssigned ? AppColors.paleGreen : AppColors.paleAmber,
                child: Icon(
                  isAssigned
                      ? Icons.verified_user_outlined
                      : Icons.pending_outlined,
                  color: isAssigned ? AppColors.green : AppColors.amber,
                  size: 19,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.fullName,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '@${student.username} • ${student.email}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              InfoPill(
                label: isAssigned ? 'Ditetapkan' : 'Belum',
                color: isAssigned ? AppColors.paleGreen : AppColors.paleAmber,
                textColor: isAssigned ? AppColors.green : AppColors.amber,
              ),
            ],
          ),
          if (isAssigned) ...[
            const SizedBox(height: 11),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.paper,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AssignmentLine(
                    icon: Icons.person_pin_outlined,
                    label: 'Guru',
                    value: teacher!.fullName,
                  ),
                  const SizedBox(height: 4),
                  _AssignmentLine(
                    icon: Icons.badge_outlined,
                    label: 'Mentor',
                    value: mentor!.fullName,
                  ),
                  const SizedBox(height: 4),
                  _AssignmentLine(
                    icon: Icons.business_rounded,
                    label: 'Tempat PKL',
                    value: placement!.companyName,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 11),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onAssign,
                  icon: Icon(
                    isAssigned
                        ? Icons.swap_horiz_rounded
                        : Icons.assignment_ind_outlined,
                    size: 17,
                  ),
                  label: Text(
                    isAssigned ? 'Ubah Penetapan' : 'Tetapkan Pembimbing',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.maroon,
                    side: const BorderSide(color: AppColors.maroon),
                    minimumSize: const Size.fromHeight(42),
                  ),
                ),
              ),
              if (onRemove != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onRemove,
                  tooltip: 'Lepas penetapan',
                  icon: const Icon(
                    Icons.link_off_rounded,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _AssignmentLine extends StatelessWidget {
  const _AssignmentLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.taupe),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 11, color: AppColors.muted),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        ),
      ],
    );
  }
}

class _AssignmentResult {
  const _AssignmentResult({
    this.teacherId,
    this.mentorId,
    this.placementId,
    this.unassign = false,
  });

  final String? teacherId;
  final String? mentorId;
  final String? placementId;
  final bool unassign;
}

class _AssignPlacementSheet extends StatefulWidget {
  const _AssignPlacementSheet({
    required this.student,
    required this.teachers,
    required this.mentors,
    required this.placements,
    required this.adminService,
    required this.onPlacementCreated,
    this.currentAssignment,
  });

  final AppUser student;
  final List<AppUser> teachers;
  final List<AppUser> mentors;
  final List<Placement> placements;
  final StudentAssignment? currentAssignment;
  final AdminService adminService;
  final ValueChanged<Placement> onPlacementCreated;

  @override
  State<_AssignPlacementSheet> createState() => _AssignPlacementSheetState();
}

class _AssignPlacementSheetState extends State<_AssignPlacementSheet> {
  String? _teacherId;
  String? _mentorId;
  String? _placementId;
  late List<Placement> _placements;

  @override
  void initState() {
    super.initState();
    _placements = List.from(widget.placements);
    _teacherId = widget.currentAssignment?.teacherId ??
        (widget.teachers.isNotEmpty ? widget.teachers.first.userId : null);
    _mentorId = widget.currentAssignment?.mentorId ??
        (widget.mentors.isNotEmpty ? widget.mentors.first.userId : null);
    _placementId = widget.currentAssignment?.placementId ??
        (_placements.isNotEmpty ? _placements.first.placementId : null);
  }

  Future<void> _addNewCompany() async {
    final nameCtrl = TextEditingController();
    final addrCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final created = await showDialog<Placement>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Tambah Tempat PKL'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nama Perusahaan',
                  hintText: 'PT Aksara Digital Nusantara',
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Nama perusahaan wajib diisi'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: addrCtrl,
                decoration: const InputDecoration(
                  labelText: 'Alamat (opsional)',
                  hintText: 'Jl. Sudirman No. 10, Jakarta',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.maroon),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              try {
                final p = await widget.adminService.createPlacement(
                  companyName: nameCtrl.text.trim(),
                  companyAddress: addrCtrl.text.trim(),
                );
                if (dialogCtx.mounted) Navigator.pop(dialogCtx, p);
              } catch (e) {
                if (dialogCtx.mounted) {
                  ScaffoldMessenger.of(dialogCtx).showSnackBar(
                    SnackBar(content: Text('Gagal menambah tempat PKL: $e')),
                  );
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    nameCtrl.dispose();
    addrCtrl.dispose();

    if (created != null && mounted) {
      setState(() {
        _placements.add(created);
        _placementId = created.placementId;
      });
      widget.onPlacementCreated(created);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 14, 20, 22 + bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
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
              const SizedBox(height: 16),
              Text(
                'Penetapan PKL',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Siswa: ${widget.student.fullName}',
                style: const TextStyle(color: AppColors.muted, fontSize: 12),
              ),
              const SizedBox(height: 18),

              const Text(
                'GURU PEMBIMBING',
                style: TextStyle(
                  color: AppColors.taupe,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _teacherId,
                items: widget.teachers
                    .map(
                      (t) => DropdownMenuItem(
                        value: t.userId,
                        child: Text(t.fullName),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _teacherId = v),
              ),
              const SizedBox(height: 14),

              const Text(
                'MENTOR IDUKA',
                style: TextStyle(
                  color: AppColors.taupe,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _mentorId,
                items: widget.mentors
                    .map(
                      (m) => DropdownMenuItem(
                        value: m.userId,
                        child: Text(m.fullName),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _mentorId = v),
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'TEMPAT PKL / PERUSAHAAN',
                      style: TextStyle(
                        color: AppColors.taupe,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _addNewCompany,
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Tambah Baru'),
                  ),
                ],
              ),
              if (_placements.isEmpty)
                OutlinedButton.icon(
                  onPressed: _addNewCompany,
                  icon: const Icon(Icons.add_business_outlined),
                  label: const Text('Tambah Tempat PKL Pertama'),
                )
              else
                DropdownButtonFormField<String>(
                  value: _placementId,
                  items: _placements
                      .map(
                        (p) => DropdownMenuItem(
                          value: p.placementId,
                          child: Text(p.companyName),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _placementId = v),
                ),

              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: (_teacherId != null &&
                        _mentorId != null &&
                        _placementId != null)
                    ? () => Navigator.pop(
                          context,
                          _AssignmentResult(
                            teacherId: _teacherId,
                            mentorId: _mentorId,
                            placementId: _placementId,
                          ),
                        )
                    : null,
                icon: const Icon(Icons.check_rounded),
                label: const Text('Simpan Penetapan'),
              ),
              if (widget.currentAssignment != null) ...[
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => Navigator.pop(
                    context,
                    const _AssignmentResult(unassign: true),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                    side: BorderSide(color: Colors.red.shade200),
                    minimumSize: const Size.fromHeight(44),
                  ),
                  child: const Text('Lepaskan Penetapan'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    this.isAlert = false,
  });

  final String title;
  final String count;
  final IconData icon;
  final Color color;
  final bool isAlert;

  @override
  Widget build(BuildContext context) {
    return WhiteCard(
      padding: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isAlert ? color : AppColors.ink,
            ),
          ),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
    this.highlight = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? AppColors.maroon
        : (highlight ? AppColors.paleAmber : Colors.white);
    final fg = selected
        ? Colors.white
        : (highlight ? AppColors.amber : AppColors.ink);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.maroon
                : (highlight ? AppColors.amber : AppColors.line),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: fg,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
