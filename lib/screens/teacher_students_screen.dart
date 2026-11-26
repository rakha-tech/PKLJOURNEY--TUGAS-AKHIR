import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

// Model pendukung & Data Dummy lokal
enum UserRole {
  murid,
  guru,
  admin,
}

class PklUser {
  const PklUser({
    required this.accountId,
    required this.name,
    required this.role,
    this.mentorAccountId,
  });

  final String accountId;
  final String name;
  final UserRole role;
  final String? mentorAccountId;
}

class InternshipLocation {
  const InternshipLocation({
    required this.companyName,
    required this.address,
  });

  final String companyName;
  final String address;
}

class TeacherStudentsScreen extends StatefulWidget {
  const TeacherStudentsScreen({
    super.key,
    this.teacher = const PklUser(
      accountId: 'GURU001',
      name: 'Budi Santoso, M.Pd.',
      role: UserRole.guru,
    ),
    this.users = const [
      PklUser(
        accountId: 'GURU001',
        name: 'Budi Santoso, M.Pd.',
        role: UserRole.guru,
      ),
      PklUser(
        accountId: '0054321980',
        name: 'Ahmad Fauzi',
        role: UserRole.murid,
        mentorAccountId: 'GURU001',
      ),
      PklUser(
        accountId: '0054321981',
        name: 'Siti Nurhaliza',
        role: UserRole.murid,
        mentorAccountId: 'GURU001',
      ),
      PklUser(
        accountId: '0054321982',
        name: 'Dimas Anggara',
        role: UserRole.murid,
        mentorAccountId: 'GURU001',
      ),
      PklUser(
        accountId: '0054321983',
        name: 'Rizky Pratama',
        role: UserRole.murid,
        mentorAccountId: 'GURU001',
      ),
    ],
    this.location = const InternshipLocation(
      companyName: 'PT Aksara Digital Nusantara',
      address:
          'Gedung Menara Sudirman Lt. 12, Jl. Jend. Sudirman Kav. 28, Jakarta Pusat',
    ),
    this.onAddStudent,
    this.onSaveLocation,
  });

  final PklUser teacher;
  final List<PklUser> users;
  final InternshipLocation? location;
  final ValueChanged<PklUser>? onAddStudent;
  final ValueChanged<InternshipLocation>? onSaveLocation;

  @override
  State<TeacherStudentsScreen> createState() => _TeacherStudentsScreenState();
}

class _TeacherStudentsScreenState extends State<TeacherStudentsScreen> {
  late InternshipLocation? _currentLocation;

  @override
  void initState() {
    super.initState();
    _currentLocation = widget.location;
  }

  @override
  void didUpdateWidget(covariant TeacherStudentsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.location != oldWidget.location) {
      _currentLocation = widget.location;
    }
  }

  List<PklUser> get _students => widget.users
      .where(
        (account) =>
            account.role == UserRole.murid &&
            account.mentorAccountId == widget.teacher.accountId,
      )
      .toList();

  Future<void> _editLocation(BuildContext context) async {
    final companyController = TextEditingController(
      text: _currentLocation?.companyName ?? '',
    );
    final addressController = TextEditingController(
      text: _currentLocation?.address ?? '',
    );
    final formKey = GlobalKey<FormState>();
    final saved = await showDialog<InternshipLocation>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Atur lokasi PKL'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: companyController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nama perusahaan / lokasi',
                    prefixIcon: Icon(Icons.business_outlined),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Nama lokasi wajib diisi'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: addressController,
                  minLines: 2,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Alamat lengkap',
                    prefixIcon: Icon(Icons.location_on_outlined),
                    alignLabelWithHint: true,
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Alamat wajib diisi'
                      : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (!(formKey.currentState?.validate() ?? false)) return;
              Navigator.pop(
                dialogContext,
                InternshipLocation(
                  companyName: companyController.text.trim(),
                  address: addressController.text.trim(),
                ),
              );
            },
            child: const Text('Simpan lokasi'),
          ),
        ],
      ),
    );
    companyController.dispose();
    addressController.dispose();
    if (saved != null) {
      setState(() {
        _currentLocation = saved;
      });
      widget.onSaveLocation?.call(saved);
    }
  }

  @override
  Widget build(BuildContext context) {
    final students = _students;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const PageHeading(
            title: 'Murid bimbingan',
            subtitle: 'Daftar murid yang ditugaskan oleh admin dan lokasi PKL.',
          ),

          // Admin Assignment Notice Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: AppColors.paleGreen,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppColors.line),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.admin_panel_settings_outlined,
                  color: AppColors.green,
                  size: 18,
                ),
                SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Penetapan murid bimbingan dikelola oleh Administrator sekolah.',
                    style: TextStyle(
                      color: AppColors.green,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Location Card
          WhiteCard(
            padding: 15,
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.paleGreen,
                  child: Icon(
                    Icons.location_on_outlined,
                    color: AppColors.green,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentLocation?.companyName ??
                            'Lokasi PKL belum ditetapkan',
                        style: const TextStyle(
                          color: AppColors.ink,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _currentLocation?.address ??
                            'Tetapkan lokasi agar alamat yang sama digunakan seluruh murid bimbingan Anda.',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 10,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _editLocation(context),
                  tooltip: _currentLocation == null
                      ? 'Atur lokasi'
                      : 'Ubah lokasi',
                  icon: const Icon(Icons.edit_location_alt_outlined),
                  color: AppColors.maroon,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SectionLabel('Daftar murid', action: '${students.length} murid'),
          if (students.isEmpty)
            const WhiteCard(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                child: Column(
                  children: [
                    Icon(
                      Icons.person_search_outlined,
                      color: AppColors.maroon,
                      size: 40,
                    ),
                    SizedBox(height: 11),
                    Text(
                      'Belum ada murid bimbingan',
                      style: TextStyle(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Administrator belum menetapkan murid untuk akun ini. Silakan hubungi admin sekolah.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...students.map(
              (student) => Padding(
                padding: const EdgeInsets.only(bottom: 11),
                child: WhiteCard(
                  padding: 15,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 23,
                        backgroundColor: AppColors.cream,
                        child: Text(
                          student.name.isEmpty
                              ? '?'
                              : student.name[0].toUpperCase(),
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
                              student.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.ink,
                                fontSize: 13,
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
                            const SizedBox(height: 4),
                            Text(
                              _currentLocation?.companyName ??
                                  'Lokasi belum ditetapkan',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.green,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        color: AppColors.green,
                        size: 20,
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
