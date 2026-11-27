import 'package:flutter/foundation.dart';

import '../models/pkl_models.dart';
import '../widgets/app_widgets.dart';

/// Penyedia state dummy terpusat aplikasi PKLJOURNEY agar perubahan dari Admin,
/// Murid, Guru, dan Mentor IDUKA saling terhubung di memori dan tercatat di Riwayat.
class PklStore extends ChangeNotifier {
  PklStore() {
    _seedInitialData();
  }

  final InternshipSchedule schedule = InternshipSchedule(
    startDate: DateTime(2026, 7, 1),
    endDate: DateTime(2026, 12, 31),
    durationMonths: 6,
  );

  PklUser? _currentUser;
  PklUser? get currentUser => _currentUser;

  final List<PklUser> _users = [];
  List<PklUser> get users => List.unmodifiable(_users);

  final List<PklAttendanceRecord> _attendanceRecords = [];
  List<PklAttendanceRecord> get attendanceRecords =>
      List.unmodifiable(_attendanceRecords);

  final List<PklJournalEntry> _journals = [];
  List<PklJournalEntry> get journals => List.unmodifiable(_journals);

  final List<PklHistoryEntry> _history = [];
  List<PklHistoryEntry> get history => List.unmodifiable(_history);

  final List<PklNotificationItem> _notifications = [];
  List<PklNotificationItem> get notifications =>
      List.unmodifiable(_notifications);

  void _seedInitialData() {
    _users.addAll(const [
      PklUser(
        accountId: 'ADM001',
        username: 'admin',
        name: 'Administrator PKL',
        role: UserRole.admin,
        address: 'SMK Negeri 1 Jakarta',
        phoneNumber: '08111000222',
      ),
      PklUser(
        accountId: '19820109940201',
        username: 'budisantoso',
        name: 'Budi Santoso, M.Pd.',
        role: UserRole.guru,
        address: 'Jl. Merdeka No. 45, Jakarta Pusat',
        phoneNumber: '081234567891',
      ),
      PklUser(
        accountId: '19790512200312',
        username: 'sitinurbaya',
        name: 'Siti Nurbaya, S.Pd.',
        role: UserRole.guru,
        address: 'Jl. Cempaka Putih No. 12, Jakarta Pusat',
        phoneNumber: '081234567892',
      ),
      PklUser(
        accountId: 'IDUKA-001',
        username: 'hendro_aksara',
        name: 'Hendro Prasetyo, S.T.',
        role: UserRole.iduka,
        companyName: 'PT Aksara Digital Nusantara',
        address:
            'Gedung Menara Sudirman Lt. 12, Jl. Jend. Sudirman Kav. 28, Jakarta Pusat',
        phoneNumber: '081398765432',
      ),
      PklUser(
        accountId: '0054321980',
        username: 'ahmadfauzi',
        name: 'Ahmad Fauzi',
        role: UserRole.murid,
        companyName: 'PT Aksara Digital Nusantara',
        address: 'Jl. Kebon Jeruk No. 8, Jakarta Barat',
        phoneNumber: '085712345678',
        mentorAccountId: '19820109940201',
        idukaAccountId: 'IDUKA-001',
      ),
      PklUser(
        accountId: '0054321981',
        username: 'sitinurhaliza',
        name: 'Siti Nurhaliza',
        role: UserRole.murid,
        companyName: 'PT Aksara Digital Nusantara',
        address: 'Jl. Rawamangun Muka No. 19, Jakarta Timur',
        phoneNumber: '085712345679',
        mentorAccountId: '19820109940201',
        idukaAccountId: 'IDUKA-001',
      ),
      PklUser(
        accountId: '0054321982',
        username: 'dimasanggara',
        name: 'Dimas Anggara',
        role: UserRole.murid,
        companyName: 'PT Aksara Digital Nusantara',
        address: 'Jl. Kemanggisan Raya No. 4, Jakarta Barat',
        phoneNumber: '085712345680',
        mentorAccountId: '19790512200312',
        idukaAccountId: 'IDUKA-001',
      ),
    ]);

    _attendanceRecords.addAll([
      PklAttendanceRecord(
        id: 'att-001',
        studentAccountId: '0054321980',
        studentName: 'Ahmad Fauzi',
        date: DateTime(2026, 11, 26),
        checkInTime: '07.45',
        checkOutTime: '16.05',
        checkInPhoto: PklPhotoPresets.coding,
        checkOutPhoto: PklPhotoPresets.report,
        isApprovedByIduka: true,
        idukaApproverName: 'Hendro Prasetyo, S.T.',
        idukaApprovalTime: '16.10 WIB',
      ),
      PklAttendanceRecord(
        id: 'att-002',
        studentAccountId: '0054321980',
        studentName: 'Ahmad Fauzi',
        date: DateTime(2026, 11, 25),
        checkInTime: '07.50',
        checkOutTime: '16.00',
        checkInPhoto: PklPhotoPresets.uiDesign,
        checkOutPhoto: PklPhotoPresets.meeting,
        isApprovedByIduka: true,
        idukaApproverName: 'Hendro Prasetyo, S.T.',
        idukaApprovalTime: '16.15 WIB',
      ),
      PklAttendanceRecord(
        id: 'att-003',
        studentAccountId: '0054321980',
        studentName: 'Ahmad Fauzi',
        date: DateTime(2026, 11, 24),
        checkInTime: '07.55',
        checkOutTime: '16.10',
        checkInPhoto: PklPhotoPresets.networking,
        checkOutPhoto: PklPhotoPresets.report,
        isApprovedByIduka: false,
      ),
      PklAttendanceRecord(
        id: 'att-004',
        studentAccountId: '0054321981',
        studentName: 'Siti Nurhaliza',
        date: DateTime(2026, 11, 26),
        checkInTime: '07.40',
        checkOutTime: '16.00',
        checkInPhoto: PklPhotoPresets.uiDesign,
        checkOutPhoto: PklPhotoPresets.meeting,
        isApprovedByIduka: true,
        idukaApproverName: 'Hendro Prasetyo, S.T.',
        idukaApprovalTime: '16.05 WIB',
      ),
      PklAttendanceRecord(
        id: 'att-005',
        studentAccountId: '0054321982',
        studentName: 'Dimas Anggara',
        date: DateTime(2026, 11, 26),
        checkInTime: '07.58',
        checkInPhoto: PklPhotoPresets.report,
        isApprovedByIduka: false,
      ),
    ]);

    _journals.addAll([
      const PklJournalEntry(
        id: 'j-001',
        studentAccountId: '0054321980',
        studentName: 'Ahmad Fauzi',
        title: 'Implementasi Slicing UI Dashboard & Integrasi Tema',
        description:
            'Menyelesaikan slicing antarmuka dashboard siswa PKL serta merapikan komponen tema maroon dan cream.',
        date: '26 November 2026',
        time: '09.30',
        tag: 'Proyek',
        imageUrl: PklPhotoPresets.coding,
        isReviewedByTeacher: true,
        teacherNote: 'Bagus, pertahankan kerapian struktur widget.',
        teacherName: 'Budi Santoso, M.Pd.',
        teacherReviewTime: '15.20 WIB',
        isValidatedByMentor: true,
        mentorNote: 'Sudah sesuai standar desain tim frontend.',
        mentorName: 'Hendro Prasetyo, S.T.',
        mentorValidationTime: '16.05 WIB',
      ),
      const PklJournalEntry(
        id: 'j-002',
        studentAccountId: '0054321980',
        studentName: 'Ahmad Fauzi',
        title: 'Orientasi lingkungan kerja',
        description:
            'Mengenal tim, aturan kerja, dan alur kegiatan di tempat PKL.',
        date: '25 November 2026',
        time: '08.15',
        tag: 'Orientasi',
        imageUrl: PklPhotoPresets.meeting,
        isReviewedByTeacher: false,
        isValidatedByMentor: false,
      ),
      const PklJournalEntry(
        id: 'j-003',
        studentAccountId: '0054321981',
        studentName: 'Siti Nurhaliza',
        title: 'Desain Prototype Halaman Profil',
        description:
            'Membuat wireframe dan komponen reusable untuk halaman profil pengguna.',
        date: '26 November 2026',
        time: '13.40',
        tag: 'Pembelajaran',
        imageUrl: PklPhotoPresets.uiDesign,
        isReviewedByTeacher: false,
        isValidatedByMentor: false,
      ),
    ]);

    _history.addAll([
      PklHistoryEntry(
        id: 'hist-001',
        timestamp: DateTime(2026, 11, 26, 16, 10),
        timeLabel: '26 Nov 2026 • 16.10 WIB',
        actorAccountId: 'IDUKA-001',
        actorName: 'Hendro Prasetyo, S.T.',
        actorRole: UserRole.iduka,
        category: 'Presensi',
        title: 'Validasi Presensi Murid',
        description: 'Menyetujui presensi Ahmad Fauzi tanggal 26 Nov 2026.',
      ),
      PklHistoryEntry(
        id: 'hist-002',
        timestamp: DateTime(2026, 11, 26, 16, 5),
        timeLabel: '26 Nov 2026 • 16.05 WIB',
        actorAccountId: 'IDUKA-001',
        actorName: 'Hendro Prasetyo, S.T.',
        actorRole: UserRole.iduka,
        category: 'Jurnal',
        title: 'Validasi & Masukan Jurnal',
        description:
            'Menyetujui jurnal "Implementasi Slicing UI Dashboard & Integrasi Tema" milik Ahmad Fauzi.',
      ),
      PklHistoryEntry(
        id: 'hist-003',
        timestamp: DateTime(2026, 11, 26, 15, 20),
        timeLabel: '26 Nov 2026 • 15.20 WIB',
        actorAccountId: '19820109940201',
        actorName: 'Budi Santoso, M.Pd.',
        actorRole: UserRole.guru,
        category: 'Jurnal',
        title: 'Review Jurnal Murid',
        description:
            'Memberikan catatan pembimbing pada jurnal Ahmad Fauzi.',
      ),
      PklHistoryEntry(
        id: 'hist-004',
        timestamp: DateTime(2026, 11, 26, 7, 45),
        timeLabel: '26 Nov 2026 • 07.45 WIB',
        actorAccountId: '0054321980',
        actorName: 'Ahmad Fauzi',
        actorRole: UserRole.murid,
        category: 'Presensi',
        title: 'Presensi Masuk Tercatat',
        description: 'Mengunggah foto bukti kehadiran masuk pukul 07.45 WIB.',
      ),
      PklHistoryEntry(
        id: 'hist-005',
        timestamp: DateTime(2026, 11, 25, 9, 0),
        timeLabel: '25 Nov 2026 • 09.00 WIB',
        actorAccountId: 'ADM001',
        actorName: 'Administrator PKL',
        actorRole: UserRole.admin,
        category: 'Bimbingan',
        title: 'Penetapan Bimbingan PKL',
        description:
            'Menetapkan Budi Santoso, M.Pd. sebagai guru pembimbing Ahmad Fauzi & Siti Nurhaliza.',
      ),
    ]);

    _notifications.addAll([
      const PklNotificationItem(
        id: 'notif-1',
        title: 'Jurnal Disetujui Pembimbing',
        body:
            'Budi Santoso, M.Pd. & Hendro Prasetyo, S.T. telah memeriksa jurnal "Implementasi Slicing UI Dashboard & Integrasi Tema".',
        time: '15 menit lalu',
        targetRole: UserRole.murid,
      ),
      const PklNotificationItem(
        id: 'notif-2',
        title: 'Pengingat Presensi Pulang',
        body:
            'Jam kerja PKL Senin–Jumat berakhir pukul 16.00 WIB. Pastikan unggah foto saat presensi pulang.',
        time: '1 jam lalu',
        targetRole: UserRole.murid,
      ),
      const PklNotificationItem(
        id: 'notif-3',
        title: 'Permintaan Validasi Presensi & Jurnal',
        body:
            'Ada presensi dan jurnal murid baru yang menunggu validasi Mentor IDUKA.',
        time: '20 menit lalu',
        targetRole: UserRole.iduka,
      ),
      const PklNotificationItem(
        id: 'notif-4',
        title: 'Jurnal Baru Siap Ditinjau',
        body:
            'Ahmad Fauzi dan Siti Nurhaliza mengunggah jurnal kegiatan terbaru.',
        time: '30 menit lalu',
        targetRole: UserRole.guru,
      ),
      const PklNotificationItem(
        id: 'notif-5',
        title: 'Pembaruan Data Akun & Bimbingan',
        body:
            '1 murid belum memiliki guru pembimbing tetap. Periksa menu Bimbingan.',
        time: '10 menit lalu',
        targetRole: UserRole.admin,
      ),
    ]);
  }

  void login(PklUser user) {
    _currentUser = user;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  // ============================================================
  // CRUD AKUN (ADMIN) & EDIT PROFIL (SEMUA ROLE)
  // ============================================================

  bool addUser(PklUser newUser) {
    final duplicate = _users.any(
      (u) =>
          u.role == newUser.role &&
          (u.username.toLowerCase() == newUser.username.toLowerCase() ||
              u.accountId.toLowerCase() == newUser.accountId.toLowerCase()),
    );
    if (duplicate) return false;

    _users.add(newUser);
    _addHistory(
      actor: _currentUser ?? newUser,
      category: 'Akun',
      title: 'Tambah Akun ${newUser.role.label}',
      description:
          'Mendaftarkan akun ${newUser.name} (${newUser.role.accountIdLabel}: ${newUser.accountId}).',
    );
    _addNotification(
      title: 'Akun Baru Terdaftar',
      body: 'Akun ${newUser.name} (${newUser.role.label}) telah ditambahkan.',
      targetRole: UserRole.admin,
    );
    notifyListeners();
    return true;
  }

  bool updateUser({
    required String originalAccountId,
    required UserRole originalRole,
    required PklUser updated,
    bool isSelfProfileEdit = false,
  }) {
    final idx = _users.indexWhere(
      (u) => u.accountId == originalAccountId && u.role == originalRole,
    );
    if (idx == -1) return false;

    _users[idx] = updated;
    if (_currentUser != null &&
        _currentUser!.accountId == originalAccountId &&
        _currentUser!.role == originalRole) {
      _currentUser = updated;
    }

    _addHistory(
      actor: _currentUser ?? updated,
      category: isSelfProfileEdit ? 'Profil' : 'Akun',
      title: isSelfProfileEdit
          ? 'Perbarui Profil ${updated.role.label}'
          : 'Ubah Data Akun ${updated.role.label}',
      description: isSelfProfileEdit
          ? '${updated.name} memperbarui informasi profil akun.'
          : 'Data akun ${updated.name} (${updated.accountId}) diperbarui.',
    );
    notifyListeners();
    return true;
  }

  void deleteUser(PklUser account) {
    _users.removeWhere(
      (u) => u.accountId == account.accountId && u.role == account.role,
    );
    _addHistory(
      actor: _currentUser ?? account,
      category: 'Akun',
      title: 'Hapus Akun ${account.role.label}',
      description: 'Menghapus akun ${account.name} (${account.accountId}).',
    );
    notifyListeners();
  }

  void assignMentor(String studentAccountId, String? teacherAccountId) {
    final idx = _users.indexWhere(
      (u) => u.accountId == studentAccountId && u.role == UserRole.murid,
    );
    if (idx == -1) return;

    final student = _users[idx];
    _users[idx] = teacherAccountId == null
        ? student.copyWith(clearMentorAccountId: true)
        : student.copyWith(mentorAccountId: teacherAccountId);

    final teacherName = teacherAccountId == null
        ? 'Belum ditetapkan'
        : _users
                .where((u) => u.accountId == teacherAccountId)
                .map((u) => u.name)
                .firstOrNull ??
            teacherAccountId;

    _addHistory(
      actor: _currentUser ?? student,
      category: 'Bimbingan',
      title: 'Perbarui Pembimbing Murid',
      description: '${student.name} dibimbing oleh $teacherName.',
    );
    notifyListeners();
  }

  // ============================================================
  // PRESENSI MURID & VALIDASI MENTOR IDUKA
  // ============================================================

  List<PklAttendanceRecord> attendanceForStudent(String studentAccountId) {
    return _attendanceRecords
        .where((r) => r.studentAccountId == studentAccountId)
        .toList();
  }

  PklAttendanceRecord? todayAttendanceForStudent(String studentAccountId) {
    final now = DateTime.now();
    for (final r in _attendanceRecords) {
      if (r.studentAccountId == studentAccountId &&
          r.date.year == now.year &&
          r.date.month == now.month &&
          r.date.day == now.day) {
        return r;
      }
    }
    return null;
  }

  void recordCheckIn({
    required PklUser student,
    required Uint8List photoBytes,
  }) {
    final now = DateTime.now();
    final timeStr = _formatTime(now);
    final existingIdx = _attendanceRecords.indexWhere(
      (r) =>
          r.studentAccountId == student.accountId &&
          r.date.year == now.year &&
          r.date.month == now.month &&
          r.date.day == now.day,
    );

    if (existingIdx != -1) {
      _attendanceRecords[existingIdx] =
          _attendanceRecords[existingIdx].copyWith(
        checkInTime: timeStr,
        checkInPhotoBytes: photoBytes,
        isApprovedByIduka: false,
        isRejectedByIduka: false,
      );
    } else {
      _attendanceRecords.insert(
        0,
        PklAttendanceRecord(
          id: 'att-${now.microsecondsSinceEpoch}',
          studentAccountId: student.accountId,
          studentName: student.name,
          date: DateTime(now.year, now.month, now.day),
          checkInTime: timeStr,
          checkInPhotoBytes: photoBytes,
          isApprovedByIduka: false,
        ),
      );
    }

    _addHistory(
      actor: student,
      category: 'Presensi',
      title: 'Presensi Masuk',
      description:
          '${student.name} mengunggah foto presensi masuk pukul $timeStr WIB.',
    );
    _addNotification(
      title: 'Presensi Masuk Baru',
      body: '${student.name} melakukan presensi masuk pukul $timeStr WIB.',
      targetRole: UserRole.iduka,
    );
    notifyListeners();
  }

  void recordCheckOut({
    required PklUser student,
    required Uint8List photoBytes,
  }) {
    final now = DateTime.now();
    final timeStr = _formatTime(now);
    final existingIdx = _attendanceRecords.indexWhere(
      (r) =>
          r.studentAccountId == student.accountId &&
          r.date.year == now.year &&
          r.date.month == now.month &&
          r.date.day == now.day,
    );

    if (existingIdx != -1) {
      _attendanceRecords[existingIdx] =
          _attendanceRecords[existingIdx].copyWith(
        checkOutTime: timeStr,
        checkOutPhotoBytes: photoBytes,
      );
    } else {
      _attendanceRecords.insert(
        0,
        PklAttendanceRecord(
          id: 'att-${now.microsecondsSinceEpoch}',
          studentAccountId: student.accountId,
          studentName: student.name,
          date: DateTime(now.year, now.month, now.day),
          checkInTime: timeStr,
          checkOutTime: timeStr,
          checkOutPhotoBytes: photoBytes,
          isApprovedByIduka: false,
        ),
      );
    }

    _addHistory(
      actor: student,
      category: 'Presensi',
      title: 'Presensi Pulang',
      description:
          '${student.name} mengunggah foto presensi pulang pukul $timeStr WIB.',
    );
    _addNotification(
      title: 'Presensi Pulang Baru',
      body:
          '${student.name} melakukan presensi pulang pukul $timeStr WIB dan menunggu konfirmasi.',
      targetRole: UserRole.iduka,
    );
    notifyListeners();
  }

  void validateAttendance({
    required String recordId,
    required bool approve,
    required PklUser mentor,
  }) {
    final idx = _attendanceRecords.indexWhere((r) => r.id == recordId);
    if (idx == -1) return;

    final now = DateTime.now();
    final timeStr = '${_formatTime(now)} WIB';
    final rec = _attendanceRecords[idx];

    _attendanceRecords[idx] = rec.copyWith(
      isApprovedByIduka: approve,
      isRejectedByIduka: !approve,
      idukaApproverName: mentor.name,
      idukaApprovalTime: timeStr,
    );

    _addHistory(
      actor: mentor,
      category: 'Presensi',
      title: approve ? 'Setujui Presensi Murid' : 'Tolak Presensi Murid',
      description:
          '${mentor.name} ${approve ? "menyetujui" : "menolak"} presensi ${rec.studentName} (${rec.shortDate}).',
    );
    _addNotification(
      title: approve ? 'Presensi Disetujui' : 'Presensi Ditolak',
      body:
          '${mentor.name} ${approve ? "menyetujui" : "menolak"} presensi tanggal ${rec.shortDate}.',
      targetRole: UserRole.murid,
    );
    notifyListeners();
  }

  // ============================================================
  // JURNAL MURID & VALIDASI/MASUKAN GURU + MENTOR IDUKA
  // ============================================================

  List<PklJournalEntry> journalsForStudent(String studentAccountId) {
    return _journals
        .where((j) => j.studentAccountId == studentAccountId)
        .toList();
  }

  void addJournal({
    required PklUser student,
    required String title,
    required String description,
    required String tag,
    Uint8List? imageBytes,
  }) {
    final now = DateTime.now();
    final timeStr = _formatTime(now);
    final entry = PklJournalEntry(
      id: 'j-${now.microsecondsSinceEpoch}',
      studentAccountId: student.accountId,
      studentName: student.name,
      title: title,
      description: description,
      date: currentDateLabel(),
      time: timeStr,
      tag: tag,
      imageBytes: imageBytes,
    );
    _journals.insert(0, entry);

    _addHistory(
      actor: student,
      category: 'Jurnal',
      title: 'Tambah Jurnal Kegiatan',
      description: '${student.name} menulis jurnal "$title".',
    );
    _addNotification(
      title: 'Jurnal Baru dari ${student.name}',
      body: 'Judul: "$title" menunggu validasi dan masukan.',
      targetRole: UserRole.iduka,
    );
    _addNotification(
      title: 'Jurnal Baru dari ${student.name}',
      body: 'Judul: "$title" siap ditinjau guru pembimbing.',
      targetRole: UserRole.guru,
    );
    notifyListeners();
  }

  void reviewJournalByTeacher({
    required String journalId,
    required PklUser teacher,
    String? note,
  }) {
    final idx = _journals.indexWhere((j) => j.id == journalId);
    if (idx == -1) return;

    final now = DateTime.now();
    final timeStr = '${_formatTime(now)} WIB';
    final item = _journals[idx];

    _journals[idx] = item.copyWith(
      isReviewedByTeacher: true,
      teacherNote: note?.trim().isEmpty == true ? null : note?.trim(),
      teacherName: teacher.name,
      teacherReviewTime: timeStr,
    );

    _addHistory(
      actor: teacher,
      category: 'Jurnal',
      title: 'Tinjau Jurnal Murid',
      description:
          '${teacher.name} memberikan masukan pada jurnal "${item.title}" milik ${item.studentName}.',
    );
    _addNotification(
      title: 'Masukan Guru pada Jurnal',
      body:
          '${teacher.name} meninjau jurnal "${item.title}".',
      targetRole: UserRole.murid,
    );
    notifyListeners();
  }

  void validateJournalByMentor({
    required String journalId,
    required PklUser mentor,
    required bool approve,
    String? note,
  }) {
    final idx = _journals.indexWhere((j) => j.id == journalId);
    if (idx == -1) return;

    final now = DateTime.now();
    final timeStr = '${_formatTime(now)} WIB';
    final item = _journals[idx];

    _journals[idx] = item.copyWith(
      isValidatedByMentor: approve,
      isRejectedByMentor: !approve,
      mentorNote: note?.trim().isEmpty == true ? null : note?.trim(),
      mentorName: mentor.name,
      mentorValidationTime: timeStr,
    );

    _addHistory(
      actor: mentor,
      category: 'Jurnal',
      title: approve ? 'Validasi Jurnal Murid' : 'Tolak Jurnal Murid',
      description:
          '${mentor.name} ${approve ? "menyetujui" : "menolak"} & memberi masukan pada jurnal "${item.title}" (${item.studentName}).',
    );
    _addNotification(
      title: approve ? 'Jurnal Divalidasi Mentor' : 'Jurnal Ditolak Mentor',
      body:
          '${mentor.name} ${approve ? "menyetujui" : "menolak"} jurnal "${item.title}".',
      targetRole: UserRole.murid,
    );
    notifyListeners();
  }

  // ============================================================
  // HELPERS: HISTORY & NOTIFICATIONS
  // ============================================================

  List<PklHistoryEntry> historyForUser(PklUser user) {
    if (user.role == UserRole.admin) return _history;
    if (user.role == UserRole.murid) {
      return _history
          .where((h) =>
              h.actorAccountId == user.accountId ||
              h.description.contains(user.name))
          .toList();
    }
    return _history
        .where((h) =>
            h.actorAccountId == user.accountId ||
            h.actorRole == UserRole.murid ||
            h.category == 'Presensi' ||
            h.category == 'Jurnal')
        .toList();
  }

  List<PklNotificationItem> notificationsForRole(UserRole role) {
    return _notifications
        .where((n) => n.targetRole == null || n.targetRole == role)
        .toList();
  }

  int unreadNotificationCount(UserRole role) {
    return notificationsForRole(role).where((n) => !n.isRead).length;
  }

  void markAllNotificationsRead(UserRole role) {
    for (var i = 0; i < _notifications.length; i++) {
      final n = _notifications[i];
      if ((n.targetRole == null || n.targetRole == role) && !n.isRead) {
        _notifications[i] = n.copyWith(isRead: true);
      }
    }
    notifyListeners();
  }

  void _addHistory({
    required PklUser actor,
    required String category,
    required String title,
    required String description,
  }) {
    final now = DateTime.now();
    _history.insert(
      0,
      PklHistoryEntry(
        id: 'hist-${now.microsecondsSinceEpoch}',
        timestamp: now,
        timeLabel: '${_formatDateShort(now)} • ${_formatTime(now)} WIB',
        actorAccountId: actor.accountId,
        actorName: actor.name,
        actorRole: actor.role,
        category: category,
        title: title,
        description: description,
      ),
    );
  }

  void _addNotification({
    required String title,
    required String body,
    UserRole? targetRole,
  }) {
    final now = DateTime.now();
    _notifications.insert(
      0,
      PklNotificationItem(
        id: 'notif-${now.microsecondsSinceEpoch}',
        title: title,
        body: body,
        time: 'Baru saja (${_formatTime(now)} WIB)',
        targetRole: targetRole,
      ),
    );
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}.${dt.minute.toString().padLeft(2, '0')}';

  String _formatDateShort(DateTime dt) {
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
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}
