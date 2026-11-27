import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/admin_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class AdminAccountsScreen extends StatefulWidget {
  const AdminAccountsScreen({
    super.key,
    required this.currentAdmin,
  });

  final AppUser currentAdmin;

  @override
  State<AdminAccountsScreen> createState() => _AdminAccountsScreenState();
}

class _AdminAccountsScreenState extends State<AdminAccountsScreen> {
  final _adminService = AdminService();

  bool _isLoading = true;
  final List<AppUser> _userList = [];
  AppRole? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await _adminService.fetchAllUsers();
      if (mounted) {
        setState(() {
          _userList
            ..clear()
            ..addAll(users);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat daftar pengguna: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, AppUser account) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus akun?'),
        content: Text(
          'Akun ${account.fullName} (${account.role.label}) akan dihapus dari sistem PKLJOURNEY.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.maroon,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus Akun'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _adminService.deleteUser(account.userId);
      if (!context.mounted) return;
      setState(() {
        _userList.removeWhere((u) => u.userId == account.userId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Akun ${account.fullName} berhasil dihapus.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus akun: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.maroon,
        ),
      );
    }
  }

  Future<void> _openRegistrationForm(BuildContext context) async {
    final created = await showModalBottomSheet<AppUser>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) =>
          _RegistrationForm(adminService: _adminService),
    );
    if (created == null || !mounted) return;

    setState(() {
      _userList.insert(0, created);
    });

    ScaffoldMessenger.of(this.context).showSnackBar(
      SnackBar(
        content: Text(
          'Akun ${created.role.label.toLowerCase()} (${created.fullName}) berhasil didaftarkan.',
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final guruCount = _userList.where((u) => u.role == AppRole.guru).length;
    final mentorCount = _userList.where((u) => u.role == AppRole.mentor).length;
    final siswaCount = _userList.where((u) => u.role == AppRole.siswa).length;

    final filteredUsers = _selectedFilter == null
        ? _userList
        : _userList.where((u) => u.role == _selectedFilter).toList();

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadUsers,
        color: AppColors.maroon,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            PageHeading(
              title: 'Kelola Akun',
              subtitle:
                  'Daftarkan akun guru, murid, dan pembimbing IDUKA secara langsung.',
              trailing: IconButton.filled(
                onPressed: () => _openRegistrationForm(context),
                tooltip: 'Tambah akun',
                icon: const Icon(Icons.person_add_alt_1_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.maroon,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AppColors.paleAmber,
                borderRadius: BorderRadius.circular(17),
                border: Border.all(color: AppColors.cream),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: AppColors.amber),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Pembuatan akun baru menggunakan Edge Function create-user di Supabase. Tarik ke bawah untuk memuat ulang data terbaru.',
                      style: TextStyle(
                        color: AppColors.taupe,
                        fontSize: 11,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _CountBox(
                    title: 'Guru',
                    count: guruCount,
                    icon: Icons.person_pin_outlined,
                    selected: _selectedFilter == AppRole.guru,
                    onTap: () => setState(() {
                      _selectedFilter = _selectedFilter == AppRole.guru
                          ? null
                          : AppRole.guru;
                    }),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _CountBox(
                    title: 'Mentor',
                    count: mentorCount,
                    icon: Icons.business_rounded,
                    selected: _selectedFilter == AppRole.mentor,
                    onTap: () => setState(() {
                      _selectedFilter = _selectedFilter == AppRole.mentor
                          ? null
                          : AppRole.mentor;
                    }),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _CountBox(
                    title: 'Murid',
                    count: siswaCount,
                    icon: Icons.school_outlined,
                    selected: _selectedFilter == AppRole.siswa,
                    onTap: () => setState(() {
                      _selectedFilter = _selectedFilter == AppRole.siswa
                          ? null
                          : AppRole.siswa;
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            SectionLabel(
              _selectedFilter == null
                  ? 'Daftar pengguna'
                  : 'Pengguna (${_selectedFilter!.label})',
              action: '${filteredUsers.length} akun',
            ),
            if (_isLoading && _userList.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.maroon),
                ),
              )
            else if (filteredUsers.isEmpty)
              WhiteCard(
                child: Column(
                  children: [
                    const Icon(
                      Icons.group_off_outlined,
                      color: AppColors.muted,
                      size: 36,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Tidak ada pengguna ditemukan',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _selectedFilter != null
                          ? 'Ketuk ulang kartu filter atau tarik ke bawah untuk refresh.'
                          : 'Belum ada pengguna yang terdaftar di tabel users.',
                      textAlign: TextAlign.center,
                      style:
                          const TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                  ],
                ),
              )
            else
              ...filteredUsers.map(
                (account) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _AccountTile(
                    account: account,
                    onDelete: account.userId == widget.currentAdmin.userId
                        ? null
                        : () => _confirmDelete(context, account),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _openRegistrationForm(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Daftarkan akun baru'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.maroon,
                side: const BorderSide(color: AppColors.maroon),
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegistrationForm extends StatefulWidget {
  const _RegistrationForm({required this.adminService});

  final AdminService adminService;

  @override
  State<_RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<_RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  AppRole _role = AppRole.siswa;
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSubmitting = true);
    try {
      final created = await widget.adminService.createUser(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        fullName: _nameCtrl.text.trim(),
        username: _usernameCtrl.text.trim(),
        role: _role,
        phone: _phoneCtrl.text.trim(),
      );
      if (mounted) {
        Navigator.pop(context, created);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mendaftarkan akun: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.maroon,
          ),
        );
      }
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
        child: Form(
          key: _formKey,
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
                  'Daftarkan Akun Baru',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Buat akun pengguna baru langsung ke sistem Supabase.',
                  style: TextStyle(color: AppColors.muted, fontSize: 12),
                ),
                const SizedBox(height: 16),
                const _FieldLabel('ROLE PENGGUNA'),
                const SizedBox(height: 6),
                DropdownButtonFormField<AppRole>(
                  value: _role,
                  items: AppRole.values
                      .map(
                        (r) => DropdownMenuItem(
                          value: r,
                          child: Text(r.label),
                        ),
                      )
                      .toList(),
                  onChanged: _isSubmitting
                      ? null
                      : (v) => setState(() => _role = v ?? AppRole.siswa),
                ),
                const SizedBox(height: 12),
                const _FieldLabel('NAMA LENGKAP'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameCtrl,
                  enabled: !_isSubmitting,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Contoh: Ahmad Fauzi',
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Nama lengkap wajib diisi'
                      : null,
                ),
                const SizedBox(height: 12),
                const _FieldLabel('USERNAME'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _usernameCtrl,
                  enabled: !_isSubmitting,
                  decoration: const InputDecoration(
                    hintText: 'Contoh: ahmadfauzi',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Username wajib diisi';
                    }
                    if (v.trim().contains(' ')) {
                      return 'Username tidak boleh mengandung spasi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                const _FieldLabel('EMAIL'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emailCtrl,
                  enabled: !_isSubmitting,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'contoh@email.com',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Email wajib diisi';
                    }
                    if (!v.contains('@') || !v.contains('.')) {
                      return 'Format email tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                const _FieldLabel('NOMOR TELEPON (OPSIONAL)'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _phoneCtrl,
                  enabled: !_isSubmitting,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: '081234567890',
                  ),
                ),
                const SizedBox(height: 12),
                const _FieldLabel('PASSWORD'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passwordCtrl,
                  enabled: !_isSubmitting,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Minimal 6 karakter',
                    suffixIcon: IconButton(
                      onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword,
                      ),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  validator: (v) => v == null || v.length < 6
                      ? 'Password minimal 6 karakter'
                      : null,
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submit,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.person_add_alt_1_rounded),
                  label: Text(
                    _isSubmitting ? 'Mendaftarkan...' : 'Simpan Akun Baru',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.taupe,
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _CountBox extends StatelessWidget {
  const _CountBox({
    required this.title,
    required this.count,
    required this.icon,
    this.selected = false,
    this.onTap,
  });

  final String title;
  final int count;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: WhiteCard(
        padding: 13,
        child: Row(
          children: [
            CircleAvatar(
              radius: 17,
              backgroundColor: selected ? AppColors.maroon : AppColors.cream,
              child: Icon(
                icon,
                color: selected ? Colors.white : AppColors.maroon,
                size: 17,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$count',
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    title,
                    style: const TextStyle(color: AppColors.muted, fontSize: 10),
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

class _AccountTile extends StatelessWidget {
  const _AccountTile({required this.account, this.onDelete});

  final AppUser account;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final color = switch (account.role) {
      AppRole.admin => AppColors.maroon,
      AppRole.guru => AppColors.green,
      AppRole.mentor => const Color(0xFF2E6B8B),
      AppRole.siswa => AppColors.amber,
    };
    final icon = switch (account.role) {
      AppRole.admin => Icons.admin_panel_settings_outlined,
      AppRole.guru => Icons.person_pin_outlined,
      AppRole.mentor => Icons.business_rounded,
      AppRole.siswa => Icons.school_outlined,
    };

    return WhiteCard(
      padding: 14,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        account.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    InfoPill(
                      label: account.role.label,
                      color: color.withValues(alpha: 0.12),
                      textColor: color,
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Username: ${account.username}',
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  account.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.taupe,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (account.phone != null && account.phone!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Telp: ${account.phone}',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onDelete != null)
            IconButton(
              onPressed: onDelete,
              tooltip: 'Hapus akun',
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.muted,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}
