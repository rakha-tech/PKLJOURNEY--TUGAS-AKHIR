// lib/services/admin_service.dart
// Service untuk admin mengambil daftar pengguna, penempatan, dan penetapan bimbingan.

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_user.dart';

class Placement {
  const Placement({
    required this.placementId,
    required this.companyName,
    this.companyAddress,
  });

  final String placementId;
  final String companyName;
  final String? companyAddress;

  factory Placement.fromMap(Map<String, dynamic> map) {
    return Placement(
      placementId: map['placement_id'] as String,
      companyName: map['company_name'] as String,
      companyAddress: map['company_address'] as String?,
    );
  }
}

class StudentAssignment {
  const StudentAssignment({
    required this.assignStudentId,
    required this.studentId,
    required this.teacherId,
    required this.mentorId,
    required this.placementId,
  });

  final String assignStudentId;
  final String studentId;
  final String teacherId;
  final String mentorId;
  final String placementId;

  factory StudentAssignment.fromMap(Map<String, dynamic> map) {
    return StudentAssignment(
      assignStudentId: map['assign_student_id'] as String,
      studentId: map['student_id'] as String,
      teacherId: map['teacher_id'] as String,
      mentorId: map['mentor_id'] as String,
      placementId: map['placement_id'] as String,
    );
  }
}

class AdminService {
  final _client = Supabase.instance.client;

  /// Ambil semua pengguna dari tabel `users` beserta nama role-nya.
  Future<List<AppUser>> fetchAllUsers() async {
    final data = await _client
        .from('users')
        .select('*, roles(role_name)')
        .order('created_at', ascending: false);
    return (data as List)
        .map((e) => AppUser.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Ambil set user_id siswa yang sudah ditetapkan penempatannya.
  Future<Set<String>> fetchAssignedStudentIds() async {
    final data = await _client.from('assign_students').select('student_id');
    return (data as List)
        .map((e) => (e as Map<String, dynamic>)['student_id'] as String)
        .toSet();
  }

  /// Hapus profil pengguna dari tabel `users`.
  Future<void> deleteUser(String userId) async {
    await _client.from('users').delete().eq('user_id', userId);
  }

  /// Buat akun baru melalui Supabase Edge Function `create-user`.
  Future<AppUser> createUser({
    required String email,
    required String password,
    required String fullName,
    required String username,
    required AppRole role,
    String? phone,
  }) async {
    final response = await _client.functions.invoke(
      'create-user',
      body: {
        'email': email,
        'password': password,
        'full_name': fullName,
        'username': username,
        'role_name': role.name,
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
      },
    );

    final data = response.data;
    if (response.status >= 400 || data == null) {
      final msg = data is Map && data['error'] != null
          ? data['error'].toString()
          : 'Gagal membuat akun (status ${response.status}).';
      throw Exception(msg);
    }

    if (data is Map<String, dynamic> && data['user'] is Map<String, dynamic>) {
      return AppUser.fromMap(data['user'] as Map<String, dynamic>);
    }

    throw Exception('Respons server tidak valid saat membuat akun.');
  }

  // ─── Placements & Assign Students ─────────────────────────────────────────

  Future<List<Placement>> fetchPlacements() async {
    final data = await _client
        .from('placements')
        .select()
        .order('company_name', ascending: true);
    return (data as List)
        .map((e) => Placement.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<Placement> createPlacement({
    required String companyName,
    String? companyAddress,
  }) async {
    final data = await _client
        .from('placements')
        .insert({
          'company_name': companyName,
          if (companyAddress != null && companyAddress.trim().isNotEmpty)
            'company_address': companyAddress.trim(),
        })
        .select()
        .single();
    return Placement.fromMap(data);
  }

  Future<List<StudentAssignment>> fetchAssignments() async {
    final data = await _client.from('assign_students').select();
    return (data as List)
        .map((e) => StudentAssignment.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<StudentAssignment> upsertAssignment({
    required String studentId,
    required String teacherId,
    required String mentorId,
    required String placementId,
  }) async {
    final data = await _client
        .from('assign_students')
        .upsert(
          {
            'student_id': studentId,
            'teacher_id': teacherId,
            'mentor_id': mentorId,
            'placement_id': placementId,
          },
          onConflict: 'student_id',
        )
        .select()
        .single();
    return StudentAssignment.fromMap(data);
  }

  Future<void> deleteAssignment(String studentId) async {
    await _client
        .from('assign_students')
        .delete()
        .eq('student_id', studentId);
  }
}
