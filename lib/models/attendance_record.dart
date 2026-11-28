// lib/models/attendance_record.dart
// Mencerminkan tabel `attendances` di Supabase.

enum ApprovalStatus { pending, approved, rejected }

class AttendanceRecord {
  const AttendanceRecord({
    required this.attendanceId,
    required this.userId,
    required this.attendanceDate,
    required this.status,
    this.checkIn,
    this.checkOut,
    this.checkInPhoto,
    this.approvedBy,
    this.approvedAt,
    this.rejectionNote,
  });

  final String attendanceId;
  final String userId;
  final DateTime attendanceDate;
  final ApprovalStatus status;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final String? checkInPhoto;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? rejectionNote;

  static ApprovalStatus _parseStatus(String s) => switch (s) {
        'approved' => ApprovalStatus.approved,
        'rejected' => ApprovalStatus.rejected,
        _ => ApprovalStatus.pending,
      };

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      attendanceId: map['attendance_id'] as String,
      userId: map['user_id'] as String,
      attendanceDate: DateTime.parse(map['attendance_date'] as String),
      status: _parseStatus(map['attendance_status'] as String),
      checkIn: map['check_in'] != null
          ? DateTime.parse(map['check_in'] as String).toLocal()
          : null,
      checkOut: map['check_out'] != null
          ? DateTime.parse(map['check_out'] as String).toLocal()
          : null,
      checkInPhoto: map['check_in_photo'] as String?,
      approvedBy: map['approved_by'] as String?,
      approvedAt: map['approved_at'] != null
          ? DateTime.parse(map['approved_at'] as String).toLocal()
          : null,
      rejectionNote: map['rejection_note'] as String?,
    );
  }

  String get statusLabel => switch (status) {
        ApprovalStatus.approved => 'Disetujui Pembimbing IDUKA',
        ApprovalStatus.rejected => 'Ditolak',
        ApprovalStatus.pending => 'Menunggu Konfirmasi IDUKA',
      };

  bool get isComplete => checkIn != null && checkOut != null;

  String get shortWeekday {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return days[attendanceDate.weekday - 1];
  }

  String get shortDate {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${attendanceDate.day} ${months[attendanceDate.month - 1]}';
  }
}
