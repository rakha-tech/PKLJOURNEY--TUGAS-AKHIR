import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.user,
    required this.onLogout,
    this.onUserUpdated,
  });

  final AppUser user;
  final VoidCallback onLogout;
  final ValueChanged<AppUser>? onUserUpdated;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  late AppUser _user;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.user != oldWidget.user) {
      _user = widget.user;
    }
  }

  Future<void> _showEditProfileDialog() async {
    final nameController = TextEditingController(text: _user.fullName);
    final phoneController = TextEditingController(text: _user.phone ?? '');
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    final updated = await showModalBottomSheet<AppUser>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (ctx, setModal) => Container(
            padding: EdgeInsets.fromLTRB(
              22,
              16,
              22,
              24 + MediaQuery.of(bottomSheetContext).viewInsets.bottom,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
            ),
            child: SafeArea(
              top: false,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
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
                            radius: 18,
                            backgroundColor: AppColors.cream,
                            child: Icon(
                              Icons.edit_outlined,
                              color: AppColors.maroon,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Edit Profil',
                              style: Theme.of(bottomSheetContext)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Perbarui data diri akun Anda di sistem PKLJOURNEY.',
                        style: TextStyle(color: AppColors.muted, fontSize: 12),
                      ),
                      const SizedBox(height: 18),

                      // Field Nama
                      const Text(
                        'NAMA LENGKAP',
                        style: TextStyle(
                          color: AppColors.taupe,
                          fontSize: 10,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: nameController,
                        enabled: !isSaving,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          hintText: 'Masukkan nama lengkap',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Nama tidak boleh kosong'
                                : null,
                      ),
                      const SizedBox(height: 14),

                      // Field Email (read-only)
                      const Text(
                        'EMAIL',
                        style: TextStyle(
                          color: AppColors.taupe,
                          fontSize: 10,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        initialValue: _user.email,
                        readOnly: true,
                        enabled: false,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.mail_outline_rounded),
                          helperText: 'Email terhubung dengan akun autentikasi',
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Field Nomor Telepon
                      const Text(
                        'NOMOR TELEPON / WHATSAPP',
                        style: TextStyle(
                          color: AppColors.taupe,
                          fontSize: 10,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: phoneController,
                        enabled: !isSaving,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          hintText: '081234567890',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Nomor telepon tidak boleh kosong'
                                : null,
                      ),
                      const SizedBox(height: 22),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isSaving
                                  ? null
                                  : () => Navigator.pop(bottomSheetContext),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.line),
                                minimumSize: const Size.fromHeight(48),
                              ),
                              child: const Text('Batal'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: isSaving
                                  ? null
                                  : () async {
                                      if (!formKey.currentState!.validate()) {
                                        return;
                                      }
                                      setModal(() => isSaving = true);
                                      try {
                                        final result =
                                            await _authService.updateProfile(
                                          userId: _user.userId,
                                          fullName: nameController.text.trim(),
                                          phone: phoneController.text.trim(),
                                        );
                                        if (ctx.mounted) {
                                          Navigator.pop(
                                              bottomSheetContext, result);
                                        }
                                      } catch (e) {
                                        setModal(() => isSaving = false);
                                        if (ctx.mounted) {
                                          ScaffoldMessenger.of(ctx)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Gagal memperbarui profil: $e'),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ),
                                          );
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.maroon,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(48),
                              ),
                              child: isSaving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Simpan Perubahan'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    nameController.dispose();
    phoneController.dispose();

    if (updated != null && mounted) {
      setState(() {
        _user = updated;
      });
      widget.onUserUpdated?.call(updated);
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
    final user = _user;
    final initial =
        user.fullName.isEmpty ? '?' : user.fullName[0].toUpperCase();
    final email = user.email;
    final phone =
        (user.phone != null && user.phone!.isNotEmpty) ? user.phone! : '-';

    final details = switch (user.role) {
      AppRole.admin => <Widget>[
          _ProfileDetail(
            icon: Icons.badge_outlined,
            label: 'Username admin',
            value: user.username,
          ),
          _ProfileDetail(
            icon: Icons.mail_outline_rounded,
            label: 'Email',
            value: email,
          ),
          _ProfileDetail(
            icon: Icons.phone_outlined,
            label: 'Nomor telepon',
            value: phone,
          ),
          const _ProfileDetail(
            icon: Icons.admin_panel_settings_outlined,
            label: 'Akses',
            value: 'Kelola akun dan monitoring PKL',
          ),
        ],
      AppRole.guru => <Widget>[
          _ProfileDetail(
            icon: Icons.badge_outlined,
            label: 'Username',
            value: user.username,
          ),
          _ProfileDetail(
            icon: Icons.mail_outline_rounded,
            label: 'Email',
            value: email,
          ),
          _ProfileDetail(
            icon: Icons.phone_outlined,
            label: 'Nomor telepon',
            value: phone,
          ),
          const _ProfileDetail(
            icon: Icons.school_outlined,
            label: 'Sekolah',
            value: 'SMK Negeri 1 Jakarta',
          ),
          const _ProfileDetail(
            icon: Icons.work_outline_rounded,
            label: 'Peran',
            value: 'Guru pembimbing PKL',
          ),
        ],
      AppRole.mentor => <Widget>[
          _ProfileDetail(
            icon: Icons.badge_outlined,
            label: 'Username',
            value: user.username,
          ),
          _ProfileDetail(
            icon: Icons.mail_outline_rounded,
            label: 'Email',
            value: email,
          ),
          _ProfileDetail(
            icon: Icons.phone_outlined,
            label: 'Nomor telepon',
            value: phone,
          ),
          const _ProfileDetail(
            icon: Icons.work_outline_rounded,
            label: 'Peran',
            value: 'Pembimbing Lapangan (IDUKA)',
          ),
        ],
      AppRole.siswa => <Widget>[
          _ProfileDetail(
            icon: Icons.badge_outlined,
            label: 'Username',
            value: user.username,
          ),
          _ProfileDetail(
            icon: Icons.mail_outline_rounded,
            label: 'Email',
            value: email,
          ),
          _ProfileDetail(
            icon: Icons.phone_outlined,
            label: 'Nomor telepon',
            value: phone,
          ),
          const _ProfileDetail(
            icon: Icons.school_outlined,
            label: 'Sekolah',
            value: 'SMK Negeri 1 Jakarta',
          ),
        ],
    };

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          PageHeading(
            title: 'Profil ${user.role.label}',
            subtitle: 'Informasi akun dan akses PKLJOURNEY.',
            trailing: IconButton.filled(
              onPressed: _showEditProfileDialog,
              tooltip: 'Edit Profil',
              icon: const Icon(Icons.edit_outlined, size: 18),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.maroon,
                foregroundColor: Colors.white,
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
                        user.fullName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        user.role.label,
                        style:
                            const TextStyle(color: AppColors.cream, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _showEditProfileDialog,
                  tooltip: 'Edit profil',
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: AppColors.cream,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Tombol Edit Profil Cepat
          OutlinedButton.icon(
            onPressed: _showEditProfileDialog,
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Edit Profil'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.maroon,
              side: const BorderSide(color: AppColors.maroon),
              minimumSize: const Size.fromHeight(46),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

          const SizedBox(height: 22),
          const SectionLabel('Informasi akun'),
          WhiteCard(padding: 0, child: Column(children: details)),
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
              'PKLJOURNEY • Versi 1.0.0',
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
