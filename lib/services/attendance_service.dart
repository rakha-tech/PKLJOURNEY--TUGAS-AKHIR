// lib/services/attendance_service.dart
// CRUD presensi ke tabel `attendances` + upload foto ke bucket `attendance-photos`.

import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/attendance_record.dart';

class AttendanceService {
  final _client = Supabase.instance.client;
  static const _bucket = 'attendance-photos';

  /// Ambil semua presensi milik siswa yang sedang login (urut terbaru).
  Future<List<AttendanceRecord>> fetchMyAttendances() async {
    final data = await _client
        .from('attendances')
        .select()
        .order('attendance_date', ascending: false);
    return (data as List)
        .map((e) => AttendanceRecord.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Presensi masuk: upload foto ke Storage, simpan check_in ke DB.
  Future<AttendanceRecord> checkIn({required File photoFile}) async {
    final userId = _client.auth.currentUser!.id;
    final photoUrl = await _uploadPhoto(
      userId: userId,
      file: photoFile,
      type: 'masuk',
    );

    // Upsert: satu baris per hari (constraint uq_attendance_per_day)
    final data = await _client
        .from('attendances')
        .upsert({
          'user_id': userId,
          'check_in': DateTime.now().toUtc().toIso8601String(),
          'check_in_photo': photoUrl,
          'attendance_status': 'pending',
        })
        .select()
        .single();
    return AttendanceRecord.fromMap(data);
  }

  /// Presensi pulang: update check_out di baris hari ini.
  Future<AttendanceRecord> checkOut({required File photoFile}) async {
    final userId = _client.auth.currentUser!.id;

    // Upload foto pulang ke storage (opsional, disimpan di DB sebagai catatan)
    // Karena skema hanya punya check_in_photo, kita gunakan field yang sama jika check_in_photo
    // sudah terisi, kita update dengan URL foto pulang.
    final photoUrl = await _uploadPhoto(
      userId: userId,
      file: photoFile,
      type: 'pulang',
    );

    final todayDate =
        DateTime.now().toIso8601String().substring(0, 10); // YYYY-MM-DD

    final data = await _client
        .from('attendances')
        .update({
          'check_out': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('user_id', userId)
        .eq('attendance_date', todayDate)
        .select()
        .single();

    // Simpan URL foto pulang sebagai metadata lokal (tidak ada kolom di DB)
    // Kembalikan record + simpan photoUrl untuk ditampilkan di UI
    return AttendanceRecord.fromMap({
      ...data,
      '_checkout_photo': photoUrl, // key extra untuk UI saja
    });
  }

  /// Ambil record presensi hari ini milik user yang login.
  Future<AttendanceRecord?> fetchTodayAttendance() async {
    final userId = _client.auth.currentUser!.id;
    final todayDate = DateTime.now().toIso8601String().substring(0, 10);
    try {
      final data = await _client
          .from('attendances')
          .select()
          .eq('user_id', userId)
          .eq('attendance_date', todayDate)
          .maybeSingle();
      if (data == null) return null;
      return AttendanceRecord.fromMap(data);
    } catch (_) {
      return null;
    }
  }

  /// Upload foto ke Supabase Storage, return public URL signed.
  Future<String> _uploadPhoto({
    required String userId,
    required File file,
    required String type,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = '$userId/presensi_${type}_$timestamp.jpg';
    await _client.storage.from(_bucket).upload(
          path,
          file,
          fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
        );
    // Signed URL berlaku 7 hari (storage adalah private bucket)
    final signedUrl = await _client.storage
        .from(_bucket)
        .createSignedUrl(path, 60 * 60 * 24 * 7);
    return signedUrl;
  }

  // ─── Untuk Mentor: fetch presensi siswa bimbingan ───────────────────────

  Future<List<AttendanceRecord>> fetchStudentAttendances(String studentId) async {
    final data = await _client
        .from('attendances')
        .select()
        .eq('user_id', studentId)
        .order('attendance_date', ascending: false);
    return (data as List)
        .map((e) => AttendanceRecord.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<AttendanceRecord> approveAttendance(String attendanceId) async {
    final data = await _client
        .from('attendances')
        .update({'attendance_status': 'approved'})
        .eq('attendance_id', attendanceId)
        .select()
        .single();
    return AttendanceRecord.fromMap(data);
  }

  Future<AttendanceRecord> rejectAttendance(
    String attendanceId, {
    required String note,
  }) async {
    final data = await _client
        .from('attendances')
        .update({'attendance_status': 'rejected', 'rejection_note': note})
        .eq('attendance_id', attendanceId)
        .select()
        .single();
    return AttendanceRecord.fromMap(data);
  }
}
