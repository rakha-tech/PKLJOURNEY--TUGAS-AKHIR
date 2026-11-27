import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import 'admin_accounts_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    this.user = const PklUser(
      accountId: 'ADM001',
      username: 'admin',
      name: 'Administrator PKL',
      role: UserRole.admin,
      email: 'admin@smkn1jakarta.sch.id',
      phoneNumber: '081234567890',
      address: 'SMK Negeri 1 Jakarta',
    ),
    required this.onLogout,
    this.onUserUpdated,
  });

  final PklUser user;
  final VoidCallback onLogout;
  final ValueChanged<PklUser>? onUserUpdated;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late PklUser _user;
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

  String _getDefaultEmail(PklUser user) {
    if (user.email != null && user.email!.isNotEmpty) {
      return user.email!;
    }
    return switch (user.role) {
      UserRole.admin => 'admin@smkn1jakarta.sch.id',
      UserRole.guru => '${user.username.replaceAll(' ', '').toLowerCase()}@guru.smkn1jakarta.sch.id',
      UserRole.iduka => '${user.username.replaceAll(' ', '').toLowerCase()}@aksara.id',
      UserRole.murid => '${user.username.replaceAll(' ', '').toLowerCase()}@siswa.smkn1jakarta.sch.id',
    };
  }

  String _getDefaultPhone(PklUser user) {
    if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) {
      return user.phoneNumber!;
    }
    return '081234567890';
  }

  Future<void> _showEditProfileDialog() async {
    final nameController = TextEditingController(text: _user.name);
    final emailController = TextEditingController(text: _getDefaultEmail(_user));
    final phoneController = TextEditingController(text: _getDefaultPhone(_user));
    final formKey = GlobalKey<FormState>();

    final updated = await showModalBottomSheet<PklUser>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return Container(
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

                    // Field Email
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
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'contoh@email.com',
                        prefixIcon: Icon(Icons.mail_outline_rounded),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email tidak boleh kosong';
                        }
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Format email tidak valid';
                        }
                        return null;
                      },
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
                            onPressed: () => Navigator.pop(bottomSheetContext),
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
                            onPressed: () {
                              if (!formKey.currentState!.validate()) return;
                              final updatedUser = _user.copyWith(
                                name: nameController.text.trim(),
                                email: emailController.text.trim(),
                                phoneNumber: phoneController.text.trim(),
                              );
                              Navigator.pop(bottomSheetContext, updatedUser);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.maroon,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(48),
                            ),
                            child: const Text('Simpan Perubahan'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    nameController.dispose();
    emailController.dispose();
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
    final initial = user.name.isEmpty ? '?' : user.name[0].toUpperCase();
    final email = _getDefaultEmail(user);
    final phone = _getDefaultPhone(user);

    final details = switch (user.role) {
      UserRole.admin => <Widget>[
          _ProfileDetail(
            icon: Icons.badge_outlined,
            label: 'Username admin',
            value: user.accountId,
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
      UserRole.guru => <Widget>[
          _ProfileDetail(
            icon: Icons.badge_outlined,
            label: 'NIP',
            value: user.accountId,
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
      UserRole.iduka => <Widget>[
          _ProfileDetail(
            icon: Icons.badge_outlined,
            label: 'ID IDUKA',
            value: user.accountId,
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
          _ProfileDetail(
            icon: Icons.business_outlined,
            label: 'Perusahaan',
            value: user.companyName ?? 'PT Aksara Digital Nusantara',
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
            label: 'NISN',
            value: user.accountId,
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
            icon: Icons.business_outlined,
            label: 'Tempat PKL',
            value: 'PT Aksara Digital Nusantara',
          ),
          const _ProfileDetail(
            icon: Icons.person_outline_rounded,
            label: 'Pembimbing',
            value: 'Hendro Prasetyo, S.T.',
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
                        style: const TextStyle(color: AppColors.cream, fontSize: 12),
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
              'PKLJOURNEY • Versi demo 1.0.0',
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
