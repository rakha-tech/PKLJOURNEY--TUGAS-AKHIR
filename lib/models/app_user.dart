// lib/models/app_user.dart
// Model user yang mencerminkan tabel `users` + `roles` di Supabase.
// Menggantikan PklUser & UserRole yang tersebar di berbagai screen.

enum AppRole {
  admin,
  siswa,
  guru,
  mentor;

  static AppRole fromString(String s) => switch (s) {
        'admin' => AppRole.admin,
        'siswa' => AppRole.siswa,
        'guru' => AppRole.guru,
        'mentor' => AppRole.mentor,
        _ => throw ArgumentError('Unknown role: $s'),
      };

  String get label => switch (this) {
        AppRole.admin => 'Admin',
        AppRole.siswa => 'Murid',
        AppRole.guru => 'Guru',
        AppRole.mentor => 'Mentor',
      };

  String get accountIdLabel => switch (this) {
        AppRole.admin => 'ID Admin',
        AppRole.guru => 'NIP',
        AppRole.mentor => 'ID IDUKA',
        AppRole.siswa => 'NISN',
      };
}

class AppUser {
  const AppUser({
    required this.userId,
    required this.role,
    required this.fullName,
    required this.email,
    required this.username,
    this.phone,
  });

  final String userId;
  final AppRole role;
  final String fullName;
  final String email;
  final String username;
  final String? phone;

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      userId: map['user_id'] as String,
      role: AppRole.fromString(
        (map['roles'] as Map<String, dynamic>?)?['role_name'] as String? ?? '',
      ),
      fullName: map['full_name'] as String,
      email: map['email'] as String,
      username: map['username'] as String,
      phone: map['phone'] as String?,
    );
  }

  AppUser copyWith({
    String? fullName,
    String? email,
    String? username,
    String? phone,
  }) {
    return AppUser(
      userId: userId,
      role: role,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      username: username ?? this.username,
      phone: phone ?? this.phone,
    );
  }
}
