import 'package:flutter/material.dart';

import '../models/pkl_models.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

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
    this.onUpdateAccount,
    this.onDeleteAccount,
  });

  final PklUser currentAdmin;
  final List<PklUser> users;
  final ValueChanged<PklUser>? onRegisterAccount;
  final void Function(PklUser original, PklUser updated)? onUpdateAccount;
  final ValueChanged<PklUser>? onDeleteAccount;

  @override
  State<AdminAccountsScreen> createState() => _AdminAccountsScreenState();
}

class _AdminAccountsScreenState extends State<AdminAccountsScreen> {
  late List<PklUser> _userList;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  UserRole? _roleFilter;

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  Future<void> _openAccountForm(BuildContext context, {PklUser? editing}) async {
    final account = await showModalBottomSheet<PklUser>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AccountFormSheet(existing: editing),
    );
    if (account == null) return;

    if (editing != null) {
      final duplicate = _userList.any(
        (existing) =>
            !(existing.role == editing.role &&
                existing.accountId == editing.accountId) &&
            existing.role == account.role &&
            (existing.username.toLowerCase() ==
                    account.username.toLowerCase() ||
                existing.accountId.toLowerCase() ==
                    account.accountId.toLowerCase()),
      );
      if (duplicate) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${account.role.accountIdLabel} atau username tersebut sudah dipakai akun lain.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      setState(() {
        final idx = _userList.indexWhere(
          (u) => u.accountId == editing.accountId && u.role == editing.role,
        );
        if (idx != -1) {
          _userList[idx] = account;
        }
      });

      widget.onUpdateAccount?.call(editing, account);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Akun ${account.name} berhasil diperbarui.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

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

  void _showAccountDetail(BuildContext context, PklUser account) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.line,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      account.name,
                      style: Theme.of(sheetContext).textTheme.headlineSmall,
                    ),
                  ),
                  InfoPill(
                    label: account.role.label,
                    color: AppColors.cream,
                    textColor: AppColors.maroon,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _DetailRow(
                label: account.role.accountIdLabel,
                value: account.accountId,
              ),
              _DetailRow(label: 'Username', value: account.username),
              if (account.companyName != null &&
                  account.companyName!.isNotEmpty)
                _DetailRow(
                  label: 'Perusahaan / IDUKA',
                  value: account.companyName!,
                ),
              if (account.phoneNumber != null &&
                  account.phoneNumber!.isNotEmpty)
                _DetailRow(label: 'No. HP / WA', value: account.phoneNumber!),
              if (account.address != null && account.address!.isNotEmpty)
                _DetailRow(label: 'Alamat', value: account.address!),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        _openAccountForm(context, editing: account);
                      },
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Ubah Data'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.maroon,
                        side: const BorderSide(color: AppColors.maroon),
                        minimumSize: const Size.fromHeight(46),
                      ),
                    ),
                  ),
                  if (!(account.role == widget.currentAdmin.role &&
                      account.accountId == widget.currentAdmin.accountId)) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          _confirmDelete(context, account);
                        },
                        icon: const Icon(Icons.delete_outline_rounded, size: 18),
                        label: const Text('Hapus'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.maroon,
                          minimumSize: const Size.fromHeight(46),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final guruCount = _userList.where((u) => u.role == UserRole.guru).length;
    final idukaCount = _userList.where((u) => u.role == UserRole.iduka).length;
    final muridCount = _userList.where((u) => u.role == UserRole.murid).length;

    final filteredUsers = _userList.where((u) {
      if (_roleFilter != null && u.role != _roleFilter) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return u.name.toLowerCase().contains(q) ||
            u.accountId.toLowerCase().contains(q) ||
            u.username.toLowerCase().contains(q) ||
            (u.companyName?.toLowerCase().contains(q) ?? false);
      }
      return true;
    }).toList();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          PageHeading(
            title: 'Kelola Akun (CRUD)',
            subtitle: 'Tambah, lihat, ubah, dan hapus akun pengguna PKL.',
            trailing: IconButton.filled(
              onPressed: () => _openAccountForm(context),
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
                    'Admin memegang kendali penuh CRUD: tambah akun baru, cari/filter, ubah data, dan hapus akun guru, murid, maupun mentor IDUKA.',
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
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v.trim()),
            decoration: InputDecoration(
              hintText: 'Cari nama, NIP/NISN, atau username...',
              prefixIcon: const Icon(Icons.search_rounded),
              fillColor: Colors.white,
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
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'Semua (${_userList.length})',
                  selected: _roleFilter == null,
                  onTap: () => setState(() => _roleFilter = null),
                ),
                const SizedBox(width: 8),
                ...UserRole.values.map((role) {
                  final count = _userList.where((u) => u.role == role).length;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _FilterChip(
                      label: '${role.label} ($count)',
                      selected: _roleFilter == role,
                      onTap: () => setState(() => _roleFilter = role),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SectionLabel(
            'Daftar pengguna',
            action: '${filteredUsers.length} akun',
          ),
          if (filteredUsers.isEmpty)
            const WhiteCard(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'Tidak ada akun yang cocok dengan filter/pencarian.',
                    style: TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                ),
              ),
            )
          else
            ...filteredUsers.map(
              (account) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _AccountTile(
                  account: account,
                  onTap: () => _showAccountDetail(context, account),
                  onEdit: () => _openAccountForm(context, editing: account),
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
            onPressed: () => _openAccountForm(context),
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
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.maroon,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.ink,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
      side: BorderSide(color: selected ? AppColors.maroon : AppColors.line),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
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
  const _AccountTile({
    required this.account,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final PklUser account;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
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
      onTap: onTap,
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
          if (onEdit != null)
            IconButton(
              onPressed: onEdit,
              tooltip: 'Ubah akun',
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.edit_outlined, size: 19),
              color: AppColors.taupe,
            ),
          if (onDelete != null)
            IconButton(
              onPressed: onDelete,
              tooltip: 'Hapus akun',
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.delete_outline_rounded, size: 19),
              color: AppColors.maroon,
            ),
        ],
      ),
    );
  }
}

class _AccountFormSheet extends StatefulWidget {
  const _AccountFormSheet({this.existing});

  final PklUser? existing;

  @override
  State<_AccountFormSheet> createState() => _AccountFormSheetState();
}

class _AccountFormSheetState extends State<_AccountFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _companyController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;
  late final TextEditingController _identifierController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late UserRole _role;
  bool _obscurePassword = true;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _role = e?.role ?? UserRole.murid;
    _nameController = TextEditingController(text: e?.name ?? '');
    _companyController = TextEditingController(text: e?.companyName ?? '');
    _addressController = TextEditingController(text: e?.address ?? '');
    _phoneController = TextEditingController(text: e?.phoneNumber ?? '');
    _identifierController = TextEditingController(text: e?.accountId ?? '');
    _usernameController = TextEditingController(text: e?.username ?? '');
    _passwordController = TextEditingController(text: e?.password ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _identifierController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final identifier = _identifierController.text.trim();
    final username = _usernameController.text.trim().isEmpty
        ? identifier
        : _usernameController.text.trim();
    final base = widget.existing;
    Navigator.of(context).pop(
      PklUser(
        username: username,
        password: _passwordController.text,
        name: _nameController.text.trim(),
        role: _role,
        accountId: identifier,
        companyName: (_role == UserRole.iduka || _role == UserRole.murid)
            ? (_companyController.text.trim().isEmpty
                ? null
                : _companyController.text.trim())
            : null,
        address: _addressController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        mentorAccountId: base?.mentorAccountId,
        idukaAccountId: base?.idukaAccountId,
        school: base?.school ?? 'SMK Negeri 1 Jakarta',
        kelas: base?.kelas ?? 'XI RPL 2 • Rekayasa Perangkat Lunak',
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
                  _isEditing ? 'Ubah data akun' : 'Daftarkan akun',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 5),
                Text(
                  _isEditing
                      ? 'Perbarui informasi akun pengguna PKLJOURNEY.'
                      : 'Akun bisa langsung digunakan untuk login.',
                ),
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
                      child: Text('Mentor IDUKA (Industri)'),
                    ),
                    DropdownMenuItem(
                      value: UserRole.admin,
                      child: Text('Administrator'),
                    ),
                  ],
                  onChanged: _isEditing
                      ? null
                      : (role) {
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
                if (_role == UserRole.iduka || _role == UserRole.murid) ...[
                  const SizedBox(height: 13),
                  _RegistrationLabel(_role == UserRole.iduka
                      ? 'NAMA PERUSAHAAN / IDUKA'
                      : 'TEMPAT PKL (OPSIONAL)'),
                  const SizedBox(height: 7),
                  TextFormField(
                    controller: _companyController,
                    decoration: const InputDecoration(
                      hintText: 'Contoh: PT Aksara Digital Nusantara',
                      prefixIcon: Icon(Icons.business_rounded),
                    ),
                    validator: (val) {
                      if (_role == UserRole.iduka &&
                          (val == null || val.trim().isEmpty)) {
                        return 'Nama perusahaan/IDUKA wajib diisi';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 13),
                _RegistrationLabel('${_role.accountIdLabel.toUpperCase()} / ID'),
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
                    if (id.isEmpty) return 'ID akun wajib diisi';
                    return null;
                  },
                ),
                const SizedBox(height: 13),
                const _RegistrationLabel('USERNAME LOGIN'),
                const SizedBox(height: 7),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    hintText: 'Kosongkan untuk samakan dengan ID',
                    prefixIcon: Icon(Icons.alternate_email_rounded),
                  ),
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
                  child: Text(
                    _isEditing ? 'Simpan perubahan' : '+ Daftarkan akun',
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
