import 'dart:typed_data';

enum UserRole {
  admin,
  guru,
  iduka,
  murid;

  String get label => switch (this) {
        UserRole.admin => 'Admin',
        UserRole.guru => 'Guru',
        UserRole.iduka => 'Mentor IDUKA',
        UserRole.murid => 'Murid',
      };

  String get accountIdLabel => switch (this) {
        UserRole.admin => 'ID Admin',
        UserRole.guru => 'NIP',
        UserRole.iduka => 'ID IDUKA',
        UserRole.murid => 'NISN',
      };
}

class PklUser {
  const PklUser({
    required this.accountId,
    required this.username,
    required this.name,
    required this.role,
    this.password = '123456',
    this.companyName,
    this.address,
    this.phoneNumber,
    this.mentorAccountId,
    this.idukaAccountId,
    this.school = 'SMK Negeri 1 Jakarta',
    this.kelas = 'XI RPL 2 • Rekayasa Perangkat Lunak',
  });

  final String accountId;
  final String username;
  final String name;
  final UserRole role;
  final String password;
  final String? companyName;
  final String? address;
  final String? phoneNumber;
  final String? mentorAccountId;
  final String? idukaAccountId;
  final String? school;
  final String? kelas;

  PklUser copyWith({
    String? accountId,
    String? username,
    String? name,
    UserRole? role,
    String? password,
    String? companyName,
    String? address,
    String? phoneNumber,
    String? mentorAccountId,
    bool clearMentorAccountId = false,
    String? idukaAccountId,
    bool clearIdukaAccountId = false,
    String? school,
    String? kelas,
  }) {
    return PklUser(
      accountId: accountId ?? this.accountId,
      username: username ?? this.username,
      name: name ?? this.name,
      role: role ?? this.role,
      password: password ?? this.password,
      companyName: companyName ?? this.companyName,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      mentorAccountId: clearMentorAccountId
          ? null
          : (mentorAccountId ?? this.mentorAccountId),
      idukaAccountId:
          clearIdukaAccountId ? null : (idukaAccountId ?? this.idukaAccountId),
      school: school ?? this.school,
      kelas: kelas ?? this.kelas,
    );
  }
}

class InternshipSchedule {
  const InternshipSchedule({
    required this.startDate,
    required this.endDate,
    this.durationMonths = 6,
  });

  final DateTime startDate;
  final DateTime endDate;
  final int durationMonths;

  /// Menghitung jumlah hari kerja (Senin–Jumat), Sabtu & Minggu libur.
  static int countWorkingDays(DateTime start, DateTime end) {
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);
    if (e.isBefore(s)) return 0;

    var count = 0;
    var current = s;
    while (!current.isAfter(e)) {
      if (current.weekday != DateTime.saturday &&
          current.weekday != DateTime.sunday) {
        count++;
      }
      current = current.add(const Duration(days: 1));
    }
    return count;
  }

  int get totalWorkingDays => countWorkingDays(startDate, endDate);

  int elapsedWorkingDays([DateTime? asOf]) {
    final now = asOf ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (today.isBefore(startDate)) return 0;
    final clampedEnd = today.isAfter(endDate) ? endDate : today;
    return countWorkingDays(startDate, clampedEnd);
  }

  int remainingWorkingDays([DateTime? asOf]) {
    final remaining = totalWorkingDays - elapsedWorkingDays(asOf);
    return remaining < 0 ? 0 : remaining;
  }

  double progressRatio([DateTime? asOf]) {
    final total = totalWorkingDays;
    if (total == 0) return 0;
    return (elapsedWorkingDays(asOf) / total).clamp(0.0, 1.0);
  }

  String get periodLabel {
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
    return '${startDate.day} ${months[startDate.month - 1]} ${startDate.year} – '
        '${endDate.day} ${months[endDate.month - 1]} ${endDate.year}';
  }
}

class PklAttendanceRecord {
  const PklAttendanceRecord({
    required this.id,
    required this.studentAccountId,
    required this.studentName,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    this.checkInPhoto,
    this.checkOutPhoto,
    this.checkInPhotoBytes,
    this.checkOutPhotoBytes,
    this.isApprovedByIduka = false,
    this.isRejectedByIduka = false,
    this.idukaApproverName,
    this.idukaApprovalTime,
  });

  final String id;
  final String studentAccountId;
  final String studentName;
  final DateTime date;
  final String? checkInTime;
  final String? checkOutTime;
  final String? checkInPhoto;
  final String? checkOutPhoto;
  final Uint8List? checkInPhotoBytes;
  final Uint8List? checkOutPhotoBytes;
  final bool isApprovedByIduka;
  final bool isRejectedByIduka;
  final String? idukaApproverName;
  final String? idukaApprovalTime;

  PklAttendanceRecord copyWith({
    String? checkInTime,
    String? checkOutTime,
    String? checkInPhoto,
    String? checkOutPhoto,
    Uint8List? checkInPhotoBytes,
    Uint8List? checkOutPhotoBytes,
    bool? isApprovedByIduka,
    bool? isRejectedByIduka,
    String? idukaApproverName,
    String? idukaApprovalTime,
  }) {
    return PklAttendanceRecord(
      id: id,
      studentAccountId: studentAccountId,
      studentName: studentName,
      date: date,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      checkInPhoto: checkInPhoto ?? this.checkInPhoto,
      checkOutPhoto: checkOutPhoto ?? this.checkOutPhoto,
      checkInPhotoBytes: checkInPhotoBytes ?? this.checkInPhotoBytes,
      checkOutPhotoBytes: checkOutPhotoBytes ?? this.checkOutPhotoBytes,
      isApprovedByIduka: isApprovedByIduka ?? this.isApprovedByIduka,
      isRejectedByIduka: isRejectedByIduka ?? this.isRejectedByIduka,
      idukaApproverName: idukaApproverName ?? this.idukaApproverName,
      idukaApprovalTime: idukaApprovalTime ?? this.idukaApprovalTime,
    );
  }

  String get shortWeekday {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    return days[date.weekday - 1];
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String get approvalStatusLabel {
    if (isApprovedByIduka) return 'Disetujui Mentor IDUKA';
    if (isRejectedByIduka) return 'Ditolak Mentor IDUKA';
    return 'Menunggu Konfirmasi IDUKA';
  }
}

class PklJournalEntry {
  const PklJournalEntry({
    required this.id,
    required this.studentAccountId,
    required this.studentName,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.tag,
    this.imageUrl,
    this.imageBytes,
    this.isReviewedByTeacher = false,
    this.teacherNote,
    this.teacherName,
    this.teacherReviewTime,
    this.isValidatedByMentor = false,
    this.isRejectedByMentor = false,
    this.mentorNote,
    this.mentorName,
    this.mentorValidationTime,
  });

  final String id;
  final String studentAccountId;
  final String studentName;
  final String title;
  final String description;
  final String date;
  final String time;
  final String tag;
  final String? imageUrl;
  final Uint8List? imageBytes;

  final bool isReviewedByTeacher;
  final String? teacherNote;
  final String? teacherName;
  final String? teacherReviewTime;

  final bool isValidatedByMentor;
  final bool isRejectedByMentor;
  final String? mentorNote;
  final String? mentorName;
  final String? mentorValidationTime;

  bool get isFullyReviewed => isReviewedByTeacher || isValidatedByMentor;

  PklJournalEntry copyWith({
    String? title,
    String? description,
    String? tag,
    String? imageUrl,
    Uint8List? imageBytes,
    bool? isReviewedByTeacher,
    String? teacherNote,
    String? teacherName,
    String? teacherReviewTime,
    bool? isValidatedByMentor,
    bool? isRejectedByMentor,
    String? mentorNote,
    String? mentorName,
    String? mentorValidationTime,
  }) {
    return PklJournalEntry(
      id: id,
      studentAccountId: studentAccountId,
      studentName: studentName,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date,
      time: time,
      tag: tag ?? this.tag,
      imageUrl: imageUrl ?? this.imageUrl,
      imageBytes: imageBytes ?? this.imageBytes,
      isReviewedByTeacher: isReviewedByTeacher ?? this.isReviewedByTeacher,
      teacherNote: teacherNote ?? this.teacherNote,
      teacherName: teacherName ?? this.teacherName,
      teacherReviewTime: teacherReviewTime ?? this.teacherReviewTime,
      isValidatedByMentor: isValidatedByMentor ?? this.isValidatedByMentor,
      isRejectedByMentor: isRejectedByMentor ?? this.isRejectedByMentor,
      mentorNote: mentorNote ?? this.mentorNote,
      mentorName: mentorName ?? this.mentorName,
      mentorValidationTime: mentorValidationTime ?? this.mentorValidationTime,
    );
  }
}

class PklHistoryEntry {
  const PklHistoryEntry({
    required this.id,
    required this.timestamp,
    required this.timeLabel,
    required this.actorAccountId,
    required this.actorName,
    required this.actorRole,
    required this.category,
    required this.title,
    required this.description,
  });

  final String id;
  final DateTime timestamp;
  final String timeLabel;
  final String actorAccountId;
  final String actorName;
  final UserRole actorRole;
  final String category;
  final String title;
  final String description;
}

class PklNotificationItem {
  const PklNotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    this.targetRole,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String body;
  final String time;
  final UserRole? targetRole;
  final bool isRead;

  PklNotificationItem copyWith({bool? isRead}) {
    return PklNotificationItem(
      id: id,
      title: title,
      body: body,
      time: time,
      targetRole: targetRole,
      isRead: isRead ?? this.isRead,
    );
  }
}
