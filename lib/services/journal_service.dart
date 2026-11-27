// lib/services/journal_service.dart
// CRUD jurnal ke tabel `journals` + upload foto ke bucket `journal-photos`.

import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/journal_entry.dart';

class JournalService {
  final _client = Supabase.instance.client;
  static const _bucket = 'journal-photos';

  /// Ambil semua jurnal milik user yang login.
  Future<List<JournalEntry>> fetchMyJournals() async {
    final data = await _client
        .from('journals')
        .select()
        .order('created_at', ascending: false);
    return (data as List)
        .map((e) => JournalEntry.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Tambah jurnal baru + upload foto wajib.
  Future<JournalEntry> addJournal({
    required String title,
    required String description,
    required File photoFile,
  }) async {
    final userId = _client.auth.currentUser!.id;
    final photoUrl = await _uploadPhoto(userId: userId, file: photoFile);

    final data = await _client
        .from('journals')
        .insert({
          'user_id': userId,
          'journal_title': title,
          'journal_description': description,
          'journal_document_photo': photoUrl,
          'journal_status': 'pending',
        })
        .select()
        .single();
    return JournalEntry.fromMap(data);
  }

  Future<String> _uploadPhoto({
    required String userId,
    required File file,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = '$userId/journal_$timestamp.jpg';
    await _client.storage.from(_bucket).upload(
          path,
          file,
          fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
        );
    return _client.storage
        .from(_bucket)
        .createSignedUrl(path, 60 * 60 * 24 * 7);
  }

  // ─── Untuk Mentor / Guru: fetch jurnal siswa ────────────────────────────

  Future<List<JournalEntry>> fetchStudentJournals(String studentId) async {
    final data = await _client
        .from('journals')
        .select()
        .eq('user_id', studentId)
        .order('created_at', ascending: false);
    return (data as List)
        .map((e) => JournalEntry.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<JournalEntry> approveJournal(String journalId) async {
    final data = await _client
        .from('journals')
        .update({'journal_status': 'approved'})
        .eq('journal_id', journalId)
        .select()
        .single();
    return JournalEntry.fromMap(data);
  }

  Future<JournalEntry> rejectJournal(
    String journalId, {
    required String note,
  }) async {
    final data = await _client
        .from('journals')
        .update({'journal_status': 'rejected', 'rejection_note': note})
        .eq('journal_id', journalId)
        .select()
        .single();
    return JournalEntry.fromMap(data);
  }
}
