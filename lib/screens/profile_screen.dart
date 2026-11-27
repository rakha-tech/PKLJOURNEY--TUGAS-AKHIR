import 'package:flutter/material.dart';

import '../models/pkl_models.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    this.user = const PklUser(
      accountId: 'ADM001',
      username: 'admin',
      name: 'Administrator PKL',
      role: UserRole.admin,
      address: 'SMK Negeri 1 Jakarta',
    ),
    required this.onLogout,
    this.onUpdateProfile,
    this.onOpenHistory,
  });

  final PklUser user;
  final VoidCallback onLogout;
  final ValueChanged<PklUser>? onUpdateProfile;
  final VoidCallback? onOpenHistory;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;

  Future<void> _openEditProfile() async {
    final updated = await showModalBottomSheet<PklUser>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditProfileSheet(user: widget.user),
    );
    if (updated != null) {
      widget.onUpdateProfile?.call(updated);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil diperbarui.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.logout_rounded, color: AppColors.maroon),
        title: const Text('Keluar dari akun?'),
        content: const Text('Kamu akan kembali ke halaman login.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.maroon),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (shouldLogout == true) widget.onLogout();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final initial = user.name.isEmpty ? '?' : user.name[0].toUpperCase();
    final details = switch (user.role) {
      UserRole.admin => <Widget>[
          _ProfileDetail(
            icon: Icons.badge_outlined,
            label: 'ID Admin / Username',
            value: '${user.accountId} (${user.username})',
          ),
          _ProfileDetail(
            icon: Icons.phone_outlined,
            label: 'No. Telepon',
            value: user.phoneNumber ?? '-',
          ),
          _ProfileDetail(
            icon: Icons.location_on_outlined,
            label: 'Alamat',
            value: user.address ?? 'SMK Negeri 1 Jakarta',
          ),
        ],
      UserRole.guru => <Widget>[
          _ProfileDetail(
            icon: Icons.badge_outlined,
            label: 'NIP / Username',
            value: '${user.accountId} (${user.username})',
          ),
          _ProfileDetail(
            icon: Icons.school_outlined,
            label: 'Sekolah',
            value: user.school ?? 'SMK Negeri 1 Jakarta',
          ),
          _ProfileDetail(
            icon: Icons.phone_outlined,
            label: 'No. Telepon',
            value: user.phoneNumber ?? '-',
          ),
          _ProfileDetail(
            icon: Icons.location_on_outlined,
            label: 'Alamat',
            value: user.address ?? '-',
          ),
        ],
      UserRole.iduka => <Widget>[
          _ProfileDetail(
            icon: Icons.badge_outlined,
            label: 'ID IDUKA / Username',
            value: '${user.accountId} (${user.username})',
          ),
          _ProfileDetail(
            icon: Icons.business_outlined,
            label: 'Perusahaan',
            value: user.companyName ?? 'PT Aksara Digital Nusantara',
          ),
          _ProfileDetail(
            icon: Icons.phone_outlined,
            label: 'No. Telepon',
            value: user.phoneNumber ?? '-',
          ),
          _ProfileDetail(
            icon: Icons.location_on_outlined,
            label: 'Alamat',
            value: user.address ?? 'Jakarta',
          ),
        ],
      UserRole.murid => <Widget>[
          _ProfileDetail(
            icon: Icons.badge_outlined,
            label: 'NISN / Username',
            value: '${user.accountId} (${user.username})',
          ),
          _ProfileDetail(
            icon: Icons.school_outlined,
            label: 'Sekolah',
            value: user.school ?? 'SMK Negeri 1 Jakarta',
          ),
          _ProfileDetail(
            icon: Icons.business_outlined,
            label: 'Tempat PKL',
            value: user.companyName ?? 'PT Aksara Digital Nusantara',
          ),
          _ProfileDetail(
            icon: Icons.phone_outlined,
            label: 'No. Telepon',
            value: user.phoneNumber ?? '-',
          ),
          _ProfileDetail(
            icon: Icons.location_on_outlined,
            label: 'Alamat',
            value: user.address ?? '-',
          ),
        ],
    };

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          PageHeading(
            title: 'Profil ${user.role.label}',
            subtitle: 'Informasi akun, ubah profil, dan riwayat aktivitas.',
            trailing: IconButton.filledTonal(
              onPressed: _openEditProfile,
              tooltip: 'Edit Profil',
              icon: const Icon(Icons.edit_outlined),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.cream,
                foregroundColor: AppColors.maroon,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.maroon,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.cream,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: AppColors.maroon,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        user.role.label,
                        style: const TextStyle(
                            color: AppColors.cream, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.verified_rounded,
                  color: AppColors.cream,
                  size: 21,
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          SectionLabel(
            'Informasi akun',
            action: 'Edit Profil',
            onAction: _openEditProfile,
          ),
          WhiteCard(padding: 0, child: Column(children: details)),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: _openEditProfile,
            icon: const Icon(Icons.edit_rounded, size: 18),
            label: const Text('Ubah / Edit Profil'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.maroon,
              minimumSize: const Size.fromHeight(48),
            ),
          ),
          if (widget.onOpenHistory != null) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: widget.onOpenHistory,
              icon: const Icon(Icons.history_rounded, size: 18),
              label: const Text('Lihat Riwayat Aktivitas'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.maroon,
                side: const BorderSide(color: AppColors.maroon),
                minimumSize: const Size.fromHeight(48),
                backgroundColor: Colors.white,
              ),
            ),
          ],
          const SizedBox(height: 22),
          const SectionLabel('Pengaturan'),
          WhiteCard(
            padding: 0,
            child: SwitchListTile(
              value: _notificationsEnabled,
              activeColor: AppColors.maroon,
              onChanged: (value) =>
                  setState(() => _notificationsEnabled = value),
              secondary: const CircleAvatar(
                radius: 19,
                backgroundColor: AppColors.cream,
                child: Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.maroon,
                  size: 19,
                ),
              ),
              title: const Text(
                'Pengingat kegiatan',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              subtitle: const Text(
                'Pengingat presensi dan jurnal',
                style: TextStyle(fontSize: 11),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 3,
              ),
            ),
          ),
          const SizedBox(height: 15),
          OutlinedButton.icon(
            onPressed: _confirmLogout,
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('Keluar dari akun'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.maroon,
              side: const BorderSide(color: AppColors.line),
              minimumSize: const Size.fromHeight(49),
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'PKLJOURNEY • Versi 1.1.0',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 10,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({required this.user});
  final PklUser user;

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _companyController;
  late final TextEditingController _passwordController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _usernameController = TextEditingController(text: widget.user.username);
    _phoneController =
        TextEditingController(text: widget.user.phoneNumber ?? '');
    _addressController = TextEditingController(text: widget.user.address ?? '');
    _companyController =
        TextEditingController(text: widget.user.companyName ?? '');
    _passwordController = TextEditingController(text: widget.user.password);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _companyController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final updated = widget.user.copyWith(
      name: _nameController.text.trim(),
      username: _usernameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      companyName: widget.user.role == UserRole.iduka
          ? _companyController.text.trim()
          : widget.user.companyName,
      password: _passwordController.text,
    );
    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 14, 20, 20 + bottom),
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
                  'Edit Profil ${widget.user.role.label}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                const Text('Perbarui data akun dan kontak Anda.'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: (v) => v == null || v.trim().length < 3
                      ? 'Nama minimal 3 karakter'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.alternate_email_rounded),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Username wajib diisi'
                      : null,
                ),
                if (widget.user.role == UserRole.iduka) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _companyController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Perusahaan / IDUKA',
                      prefixIcon: Icon(Icons.business_rounded),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Nama perusahaan wajib diisi'
                        : null,
                  ),
                ],
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'No. Telepon / WA',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Alamat',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Kata Sandi',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                  ),
                  validator: (v) => v == null || v.length < 3
                      ? 'Kata sandi minimal 3 karakter'
                      : null,
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_rounded),
                  label: const Text('Simpan Perubahan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileDetail extends StatelessWidget {
  const _ProfileDetail({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.paper,
            child: Icon(icon, color: AppColors.maroon, size: 18),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: AppColors.muted, fontSize: 10),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
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
