// lib/services/student_service.dart
// Fetch info penempatan PKL (tempat PKL, guru pembimbing, mentor IDUKA) untuk siswa yang login.

import 'package:supabase_flutter/supabase_flutter.dart';

class StudentPlacementInfo {
  const StudentPlacementInfo({
    required this.companyName,
    this.companyAddress,
    required this.teacherName,
    required this.teacherEmail,
    this.teacherPhone,
    required this.mentorName,
    required this.mentorEmail,
    this.mentorPhone,
  });

  final String companyName;
  final String? companyAddress;
  final String teacherName;
  final String teacherEmail;
  final String? teacherPhone;
  final String mentorName;
  final String mentorEmail;
  final String? mentorPhone;

  factory StudentPlacementInfo.fromMap(Map<String, dynamic> map) {
    final placement = map['placements'] as Map<String, dynamic>? ?? {};
    final teacher = map['teacher'] as Map<String, dynamic>? ?? {};
    final mentor = map['mentor'] as Map<String, dynamic>? ?? {};

    return StudentPlacementInfo(
      companyName: placement['company_name'] as String? ?? '-',
      companyAddress: placement['company_address'] as String?,
      teacherName: teacher['full_name'] as String? ?? '-',
      teacherEmail: teacher['email'] as String? ?? '-',
      teacherPhone: teacher['phone'] as String?,
      mentorName: mentor['full_name'] as String? ?? '-',
      mentorEmail: mentor['email'] as String? ?? '-',
      mentorPhone: mentor['phone'] as String?,
    );
  }
}

class StudentService {
  final _client = Supabase.instance.client;

  Future<StudentPlacementInfo?> fetchMyAssignment() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    final data = await _client
        .from('assign_students')
        .select(
          'placements(company_name, company_address), '
          'teacher:users!teacher_id(full_name, email, phone), '
          'mentor:users!mentor_id(full_name, email, phone)',
        )
        .eq('student_id', userId)
        .maybeSingle();

    if (data == null) return null;
    return StudentPlacementInfo.fromMap(data);
  }
}
