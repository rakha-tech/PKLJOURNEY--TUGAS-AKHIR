// lib/models/journal_entry.dart
// Mencerminkan tabel `journals` di Supabase.

import 'attendance_record.dart' show ApprovalStatus;

class JournalEntry {
  const JournalEntry({
    required this.journalId,
    required this.userId,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    this.documentPhoto,
    this.approvedBy,
    this.approvedAt,
    this.rejectionNote,
  });

  final String journalId;
  final String userId;
  final String title;
  final String description;
  final String? documentPhoto;
  final ApprovalStatus status;
  final DateTime createdAt;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? rejectionNote;

  static ApprovalStatus _parseStatus(String s) => switch (s) {
        'approved' => ApprovalStatus.approved,
        'rejected' => ApprovalStatus.rejected,
        _ => ApprovalStatus.pending,
      };

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      journalId: map['journal_id'] as String,
      userId: map['user_id'] as String,
      title: map['journal_title'] as String,
      description: map['journal_description'] as String,
      documentPhoto: map['journal_document_photo'] as String?,
      status: _parseStatus(map['journal_status'] as String),
      createdAt: DateTime.parse(map['created_at'] as String).toLocal(),
      approvedBy: map['approved_by'] as String?,
      approvedAt: map['approved_at'] != null
          ? DateTime.parse(map['approved_at'] as String).toLocal()
          : null,
      rejectionNote: map['rejection_note'] as String?,
    );
  }

  String get statusLabel => switch (status) {
        ApprovalStatus.approved => 'Disetujui',
        ApprovalStatus.rejected => 'Ditolak',
        ApprovalStatus.pending => 'Menunggu Review',
      };

  String get dateLabel {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return '${createdAt.day} ${months[createdAt.month - 1]} ${createdAt.year}';
  }

  String get timeLabel =>
      '${createdAt.hour.toString().padLeft(2, '0')}.${createdAt.minute.toString().padLeft(2, '0')}';
}
