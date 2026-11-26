import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import 'admin_accounts_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    this.users = const [
      PklUser(
        accountId: 'ADM001',
        username: 'admin',
        name: 'Administrator PKL',
        role: UserRole.admin,
      ),
      PklUser(
        accountId: '0054321980',
        username: 'ahmadfauzi',
        name: 'Ahmad Fauzi',
        role: UserRole.murid,
      ),
      PklUser(
        accountId: '19820109940201',
        username: 'budisantoso',
        name: 'Budi Santoso, M.Pd.',
        role: UserRole.guru,
      ),
      PklUser(
        accountId: 'IDUKA-001',
        username: 'hendro_aksara',
        name: 'Hendro Prasetyo, S.T.',
        role: UserRole.iduka,
        companyName: 'PT Aksara Digital Nusantara',
      ),
    ],
    required this.onLogin,
  });

  final List<PklUser> users;
  final ValueChanged<PklUser> onLogin;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _fillDemo(PklUser user) {
    setState(() {
      _usernameController.text = user.username;
      _passwordController.text = user.password;
    });
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      final entered = _usernameController.text.trim().toLowerCase();
      PklUser? matchedUser;

      for (final user in widget.users) {
        final matchIdentifier =
            user.username.toLowerCase() == entered ||
            user.accountId.toLowerCase() == entered;
        if (matchIdentifier && user.password == _passwordController.text) {
          matchedUser = user;
          break;
        }
      }

      if (matchedUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Username/ID atau kata sandi tidak sesuai.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      widget.onLogin(matchedUser);
    }
  }

  void _showForgotPassword() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.lock_reset_rounded, color: AppColors.maroon),
        title: const Text('Lupa kata sandi?'),
        content: const Text(
          'Hubungi admin sekolah untuk mendaftarkan akun atau meminta bantuan reset kata sandi PKLJOURNEY.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.maroon,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(26, 24, 26, 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      const BrandMark(light: true, showWordmark: false),
                      const SizedBox(height: 12),
                      Text(
                        'LANGKAH PERTAMAMU',
                        style: TextStyle(
                          color: AppColors.cream.withValues(alpha: 0.72),
                          fontSize: 10,
                          letterSpacing: 3,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
                        decoration: BoxDecoration(
                          color: AppColors.cream,
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Selamat datang',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(fontSize: 23),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Masuk dan lanjutkan perjalanan PKL-mu.',
                                style: TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Quick Fill Demo Accounts (Admin, Murid, Guru, Mentor/IDUKA)
                              const _FieldLabel('PILIH AKUN DEMO'),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: widget.users.map((user) {
                                  final roleLabel = user.role == UserRole.iduka
                                      ? 'Mentor'
                                      : user.role.label;
                                  return ActionChip(
                                    avatar: Icon(
                                      switch (user.role) {
                                        UserRole.admin =>
                                          Icons.admin_panel_settings_rounded,
                                        UserRole.murid => Icons.school_rounded,
                                        UserRole.guru =>
                                          Icons.person_pin_rounded,
                                        UserRole.iduka =>
                                          Icons.business_rounded,
                                      },
                                      size: 15,
                                      color: AppColors.maroon,
                                    ),
                                    label: Text(
                                      roleLabel,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.maroon,
                                      ),
                                    ),
                                    backgroundColor: Colors.white,
                                    side: const BorderSide(
                                      color: AppColors.line,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 0,
                                    ),
                                    onPressed: () => _fillDemo(user),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 18),

                              const _FieldLabel('USERNAME / ID / NISN / NIP'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _usernameController,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  hintText: 'Masukkan username atau nomor identitas',
                                  prefixIcon: Icon(Icons.badge_outlined),
                                ),
                                validator: (value) =>
                                    value == null || value.trim().isEmpty
                                        ? 'Masukkan username atau nomor identitas'
                                        : null,
                              ),
                              const SizedBox(height: 18),
                              const _FieldLabel('PASSWORD'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _submit(),
                                decoration: InputDecoration(
                                  hintText: 'Masukkan kata sandi akun',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    tooltip: _obscurePassword
                                        ? 'Tampilkan kata sandi'
                                        : 'Sembunyikan kata sandi',
                                    onPressed: () => setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                    ),
                                  ),
                                ),
                                validator: (value) =>
                                    value == null || value.isEmpty
                                        ? 'Masukkan kata sandi'
                                        : null,
                              ),
                              const SizedBox(height: 9),
                              Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe,
                                    activeColor: AppColors.maroon,
                                    visualDensity: VisualDensity.compact,
                                    onChanged: (value) => setState(
                                      () => _rememberMe = value ?? false,
                                    ),
                                  ),
                                  const Text(
                                    'Ingat saya',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: _showForgotPassword,
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppColors.maroon,
                                      padding: EdgeInsets.zero,
                                    ),
                                    child: const Text('Lupa password?'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ElevatedButton.icon(
                                onPressed: _submit,
                                icon: const Icon(Icons.login_rounded, size: 19),
                                label: const Text('Masuk'),
                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: Text(
                                  'Ketuk salah satu role di atas untuk otomatis mengisi data login.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.muted.withValues(alpha: 0.9),
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'PKLJOURNEY  •  BELAJAR, BERTUMBUH, BERKARYA',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.cream.withValues(alpha: 0.68),
                          fontSize: 9,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.taupe,
        fontSize: 11,
        letterSpacing: 0.8,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
