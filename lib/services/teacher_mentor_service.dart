// lib/services/teacher_mentor_service.dart
// Service untuk Guru & Mentor mengambil daftar siswa bimbingan, presensi, dan jurnal dari Supabase.

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_user.dart';
import '../models/attendance_record.dart';
import '../models/journal_entry.dart';
import 'attendance_service.dart';
import 'journal_service.dart';

class SupervisedStudent {
  const SupervisedStudent({
    required this.student,
    required this.companyName,
    this.companyAddress,
    this.teacher,
    this.mentor,
  });

  final AppUser student;
  final String companyName;
  final String? companyAddress;
  final AppUser? teacher;
  final AppUser? mentor;

  factory SupervisedStudent.fromMap(Map<String, dynamic> map) {
    final placement = map['placements'] as Map<String, dynamic>? ?? {};
    final studentMap = map['student'] as Map<String, dynamic>;
    final teacherMap = map['teacher'] as Map<String, dynamic>?;
    final mentorMap = map['mentor'] as Map<String, dynamic>?;

    return SupervisedStudent(
      student: AppUser.fromMap(studentMap),
      companyName: placement['company_name'] as String? ?? '-',
      companyAddress: placement['company_address'] as String?,
      teacher: teacherMap != null ? AppUser.fromMap(teacherMap) : null,
      mentor: mentorMap != null ? AppUser.fromMap(mentorMap) : null,
    );
  }
}

class StudentAttendanceItem {
  const StudentAttendanceItem({
    required this.record,
    required this.student,
    required this.companyName,
  });

  final AttendanceRecord record;
  final AppUser student;
  final String companyName;
}

class StudentJournalItem {
  const StudentJournalItem({
    required this.entry,
    required this.student,
    required this.companyName,
  });

  final JournalEntry entry;
  final AppUser student;
  final String companyName;
}

class TeacherMentorService {
  final _client = Supabase.instance.client;
  final _attendanceService = AttendanceService();
  final _journalService = JournalService();

  /// Ambil daftar siswa yang dibimbing oleh guru/mentor yang sedang login.
  Future<List<SupervisedStudent>> fetchMyStudents() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final data = await _client
        .from('assign_students')
        .select(
          'placements(company_name, company_address), '
          'student:users!student_id(*, roles(role_name)), '
          'teacher:users!teacher_id(*, roles(role_name)), '
          'mentor:users!mentor_id(*, roles(role_name))',
        )
        .or('teacher_id.eq.$userId,mentor_id.eq.$userId');

    return (data as List)
        .map((e) => SupervisedStudent.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Ambil seluruh presensi siswa bimbingan.
  Future<List<StudentAttendanceItem>> fetchStudentsAttendances() async {
    final students = await fetchMyStudents();
    if (students.isEmpty) return [];

    final studentById = {for (final s in students) s.student.userId: s};
    final ids = studentById.keys.toList();

    final data = await _client
        .from('attendances')
        .select()
        .inFilter('user_id', ids)
        .order('attendance_date', ascending: false);

    return (data as List).map((raw) {
      final record = AttendanceRecord.fromMap(raw as Map<String, dynamic>);
      final info = studentById[record.userId]!;
      return StudentAttendanceItem(
        record: record,
        student: info.student,
        companyName: info.companyName,
      );
    }).toList();
  }

  /// Ambil seluruh jurnal siswa bimbingan.
  Future<List<StudentJournalItem>> fetchStudentsJournals() async {
    final students = await fetchMyStudents();
    if (students.isEmpty) return [];

    final studentById = {for (final s in students) s.student.userId: s};
    final ids = studentById.keys.toList();

    final data = await _client
        .from('journals')
        .select()
        .inFilter('user_id', ids)
        .order('created_at', ascending: false);

    return (data as List).map((raw) {
      final entry = JournalEntry.fromMap(raw as Map<String, dynamic>);
      final info = studentById[entry.userId]!;
      return StudentJournalItem(
        entry: entry,
        student: info.student,
        companyName: info.companyName,
      );
    }).toList();
  }

  Future<AttendanceRecord> approveAttendance(String attendanceId) =>
      _attendanceService.approveAttendance(attendanceId);

  Future<AttendanceRecord> rejectAttendance(
    String attendanceId, {
    required String note,
  }) =>
      _attendanceService.rejectAttendance(attendanceId, note: note);

  Future<JournalEntry> approveJournal(String journalId) =>
      _journalService.approveJournal(journalId);

  Future<JournalEntry> rejectJournal(
    String journalId, {
    required String note,
  }) =>
      _journalService.rejectJournal(journalId, note: note);
}
