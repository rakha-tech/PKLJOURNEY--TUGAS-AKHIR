import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

// Model pendukung & Data Dummy lokal
enum UserRole {
  admin,
  guru,
  iduka,
  murid;

  String get label => switch (this) {
        UserRole.admin => 'Admin',
        UserRole.guru => 'Guru',
        UserRole.iduka => 'IDUKA',
        UserRole.murid => 'Murid',
      };

  String get accountIdLabel => switch (this) {
        UserRole.admin => 'ID Admin',
        UserRole.guru => 'NIP',
        UserRole.iduka => 'ID IDUKA',
        UserRole.murid => 'NISN',
      };
}

class PklUser {
  const PklUser({
    required this.accountId,
    required this.username,
    required this.name,
    required this.role,
    this.password = '123456',
    this.companyName,
    this.address,
    this.phoneNumber,
    this.mentorAccountId,
  });

  final String accountId;
  final String username;
  final String name;
  final UserRole role;
  final String password;
  final String? companyName;
  final String? address;
  final String? phoneNumber;
  final String? mentorAccountId;
}

class AdminAccountsScreen extends StatefulWidget {
  const AdminAccountsScreen({
    super.key,
    this.currentAdmin = const PklUser(
      accountId: 'ADM001',
      username: 'admin',
      name: 'Administrator PKL',
      role: UserRole.admin,
      address: 'SMK Negeri 1 Jakarta',
    ),
    this.users = const [
      PklUser(
        accountId: 'ADM001',
        username: 'admin',
        name: 'Administrator PKL',
        role: UserRole.admin,
        address: 'SMK Negeri 1 Jakarta',
      ),
      PklUser(
        accountId: '19820109940201',
        username: 'budisantoso',
        name: 'Budi Santoso, M.Pd.',
        role: UserRole.guru,
        address: 'Jl. Merdeka No. 45, Jakarta Pusat',
        phoneNumber: '081234567891',
      ),
      PklUser(
        accountId: '19790512200312',
        username: 'sitinurbaya',
        name: 'Siti Nurbaya, S.Pd.',
        role: UserRole.guru,
        address: 'Jl. Cempaka Putih No. 12, Jakarta Pusat',
        phoneNumber: '081234567892',
      ),
      PklUser(
        accountId: 'IDUKA-001',
        username: 'hendro_aksara',
        name: 'Hendro Prasetyo, S.T.',
        role: UserRole.iduka,
        companyName: 'PT Aksara Digital Nusantara',
        address: 'Gedung Menara Sudirman Lt. 12, Jakarta',
        phoneNumber: '081398765432',
      ),
      PklUser(
        accountId: '0054321980',
        username: 'ahmadfauzi',
        name: 'Ahmad Fauzi',
        role: UserRole.murid,
        address: 'Jl. Kebon Jeruk No. 8, Jakarta Barat',
        phoneNumber: '085712345678',
        mentorAccountId: '19820109940201',
      ),
      PklUser(
        accountId: '0054321981',
        username: 'sitinurhaliza',
        name: 'Siti Nurhaliza',
        role: UserRole.murid,
        address: 'Jl. Rawamangun Muka No. 19, Jakarta Timur',
        phoneNumber: '085712345679',
        mentorAccountId: '19820109940201',
      ),
    ],
    this.onRegisterAccount,
    this.onDeleteAccount,
  });

  final PklUser currentAdmin;
  final List<PklUser> users;
  final ValueChanged<PklUser>? onRegisterAccount;
  final ValueChanged<PklUser>? onDeleteAccount;

  @override
  State<AdminAccountsScreen> createState() => _AdminAccountsScreenState();
}

class _AdminAccountsScreenState extends State<AdminAccountsScreen> {
  late List<PklUser> _userList;

  @override
  void initState() {
    super.initState();
    _userList = List.from(widget.users);
  }

  @override
  void didUpdateWidget(covariant AdminAccountsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.users != oldWidget.users) {
      _userList = List.from(widget.users);
    }
  }

  Future<void> _confirmDelete(BuildContext context, PklUser account) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus akun?'),
        content: Text(
          'Akun ${account.name} (${account.role.label}) akan dihapus dari sistem PKLJOURNEY.',
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

    setState(() {
      _userList.removeWhere(
        (u) => u.accountId == account.accountId && u.role == account.role,
      );
    });

    widget.onDeleteAccount?.call(account);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Akun ${account.name} berhasil dihapus.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _openRegistrationForm(BuildContext context) async {
    final account = await showModalBottomSheet<PklUser>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _RegistrationForm(),
    );
    if (account == null) return;

    final duplicate = _userList.any(
      (existing) =>
          existing.role == account.role &&
          (existing.username.toLowerCase() == account.username.toLowerCase() ||
              existing.accountId.toLowerCase() ==
                  account.accountId.toLowerCase()),
    );
    if (duplicate) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${account.role.accountIdLabel} tersebut sudah terdaftar.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _userList.add(account);
    });

    widget.onRegisterAccount?.call(account);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Akun ${account.role.label.toLowerCase()} berhasil didaftarkan.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final guruCount = _userList.where((u) => u.role == UserRole.guru).length;
    final idukaCount = _userList.where((u) => u.role == UserRole.iduka).length;
    final muridCount = _userList.where((u) => u.role == UserRole.murid).length;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          PageHeading(
            title: 'Kelola Akun',
            subtitle: 'Daftarkan akun guru, murid, dan pembimbing IDUKA.',
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
                    'Admin memegang kendali seluruh data: NIP guru, NISN murid, akun pembimbing IDUKA, dan alamat masing-masing pihak.',
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
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _CountBox(
                  title: 'IDUKA',
                  count: idukaCount,
                  icon: Icons.business_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _CountBox(
                  title: 'Murid',
                  count: muridCount,
                  icon: Icons.school_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          SectionLabel('Daftar pengguna', action: '${_userList.length} akun'),
          ..._userList.map(
            (account) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _AccountTile(
                account: account,
                onDelete:
                    account.role == widget.currentAdmin.role &&
                            account.accountId == widget.currentAdmin.accountId
                        ? null
                        : () => _confirmDelete(context, account),
              ),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _openRegistrationForm(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('+ Daftarkan akun baru'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.maroon,
              side: const BorderSide(color: AppColors.maroon),
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountBox extends StatelessWidget {
  const _CountBox({
    required this.title,
    required this.count,
    required this.icon,
  });

  final String title;
  final int count;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return WhiteCard(
      padding: 13,
      child: Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: AppColors.cream,
            child: Icon(icon, color: AppColors.maroon, size: 17),
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
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({required this.account, this.onDelete});

  final PklUser account;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final color = switch (account.role) {
      UserRole.admin => AppColors.maroon,
      UserRole.guru => AppColors.green,
      UserRole.iduka => const Color(0xFF2E6B8B),
      UserRole.murid => AppColors.amber,
    };
    final icon = switch (account.role) {
      UserRole.admin => Icons.admin_panel_settings_outlined,
      UserRole.guru => Icons.person_pin_outlined,
      UserRole.iduka => Icons.business_rounded,
      UserRole.murid => Icons.school_outlined,
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
                        account.name,
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
                  '${account.role.accountIdLabel}: ${account.accountId}',
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (account.companyName != null &&
                    account.companyName!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Perusahaan: ${account.companyName}',
                    style: const TextStyle(
                      color: AppColors.taupe,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (account.address != null && account.address!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Alamat: ${account.address}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onDelete != null) ...[
            const SizedBox(width: 4),
            IconButton(
              onPressed: onDelete,
              tooltip: 'Hapus akun',
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.delete_outline_rounded, size: 20),
              color: AppColors.maroon,
            ),
          ],
        ],
      ),
    );
  }
}

class _RegistrationForm extends StatefulWidget {
  const _RegistrationForm();

  @override
  State<_RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<_RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _role = UserRole.murid;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final identifier = _identifierController.text.trim();
    Navigator.of(context).pop(
      PklUser(
        username: identifier,
        password: _passwordController.text,
        name: _nameController.text.trim(),
        role: _role,
        accountId: identifier,
        companyName: _role == UserRole.iduka
            ? _companyController.text.trim()
            : null,
        address: _addressController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
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
                const SizedBox(height: 18),
                Text(
                  'Daftarkan akun',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 5),
                const Text('Akun bisa langsung digunakan untuk login.'),
                const SizedBox(height: 18),
                const _RegistrationLabel('JENIS AKUN'),
                const SizedBox(height: 7),
                DropdownButtonFormField<UserRole>(
                  value: _role,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.switch_account_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: UserRole.murid,
                      child: Text('Murid PKL'),
                    ),
                    DropdownMenuItem(
                      value: UserRole.guru,
                      child: Text('Guru Pembimbing Sekolah'),
                    ),
                    DropdownMenuItem(
                      value: UserRole.iduka,
                      child: Text('Pembimbing IDUKA (Industri)'),
                    ),
                  ],
                  onChanged: (role) {
                    if (role != null) setState(() => _role = role);
                  },
                ),
                const SizedBox(height: 13),
                const _RegistrationLabel('NAMA LENGKAP'),
                const SizedBox(height: 7),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Masukkan nama lengkap',
                  ),
                  validator: (value) => value == null || value.trim().length < 3
                      ? 'Nama lengkap wajib diisi'
                      : null,
                ),
                if (_role == UserRole.iduka) ...[
                  const SizedBox(height: 13),
                  const _RegistrationLabel('NAMA PERUSAHAAN / IDUKA'),
                  const SizedBox(height: 7),
                  TextFormField(
                    controller: _companyController,
                    decoration: const InputDecoration(
                      hintText: 'Contoh: PT Aksara Digital Nusantara',
                      prefixIcon: Icon(Icons.business_rounded),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Nama perusahaan/IDUKA wajib diisi'
                        : null,
                  ),
                ],
                const SizedBox(height: 13),
                const _RegistrationLabel('USERNAME / NIP / NISN / ID'),
                const SizedBox(height: 7),
                TextFormField(
                  controller: _identifierController,
                  decoration: InputDecoration(
                    hintText: _role == UserRole.murid
                        ? 'Contoh: 005124012423 (NISN)'
                        : _role == UserRole.guru
                        ? 'Contoh: 19820109940201 (NIP)'
                        : 'Contoh: IDUKA-002',
                    prefixIcon: const Icon(Icons.badge_outlined),
                  ),
                  validator: (value) {
                    final id = value?.trim() ?? '';
                    if (id.isEmpty) return 'Username/ID wajib diisi';
                    return null;
                  },
                ),
                const SizedBox(height: 13),
                const _RegistrationLabel('ALAMAT LENGKAP (DIKELOLA ADMIN)'),
                const SizedBox(height: 7),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    hintText: 'Masukkan alamat lengkap domisili / kantor',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Alamat wajib diisi oleh Admin'
                      : null,
                ),
                const SizedBox(height: 13),
                const _RegistrationLabel('NOMOR TELEPON / WA'),
                const SizedBox(height: 7),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: 'Contoh: 081234567890',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
                const SizedBox(height: 13),
                const _RegistrationLabel('PASSWORD'),
                const SizedBox(height: 7),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Masukkan kata sandi akun',
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
                  validator: (value) => value == null || value.length < 3
                      ? 'Kata sandi minimal 3 karakter'
                      : null,
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: _save,
                  child: const Text('+ Daftarkan akun'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RegistrationLabel extends StatelessWidget {
  const _RegistrationLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: AppColors.taupe,
      fontSize: 10,
      letterSpacing: 0.8,
      fontWeight: FontWeight.w800,
    ),
  );
}
