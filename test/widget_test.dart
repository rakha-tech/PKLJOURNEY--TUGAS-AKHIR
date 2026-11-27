import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';

import 'package:pkljourney/models/pkl_models.dart';
import 'package:pkljourney/services/pkl_store.dart';

void main() {
  test('InternshipSchedule menghitung hari kerja 6 bulan tanpa Sabtu & Minggu',
      () {
    // 1 minggu penuh (Senin 23 Nov - Minggu 29 Nov 2026) = 5 hari kerja
    final oneWeek = InternshipSchedule.countWorkingDays(
      DateTime(2026, 11, 23),
      DateTime(2026, 11, 29),
    );
    expect(oneWeek, 5);

    // 6 bulan (1 Jul 2026 - 31 Des 2026)
    final sixMonths = InternshipSchedule(
      startDate: DateTime(2026, 7, 1),
      endDate: DateTime(2026, 12, 31),
      durationMonths: 6,
    );
    expect(sixMonths.durationMonths, 6);
    expect(sixMonths.totalWorkingDays, 132);
  });

  test('PklStore mendukung CRUD Admin, Edit Profil, Presensi, Jurnal & Riwayat',
      () {
    final store = PklStore();
    final initialCount = store.users.length;

    // 1. Admin Create
    const newStudent = PklUser(
      accountId: '0099887766',
      username: 'bintang',
      name: 'Bintang Pratama',
      role: UserRole.murid,
    );
    expect(store.addUser(newStudent), isTrue);
    expect(store.users.length, initialCount + 1);

    // 2. Admin Update / Edit Profil
    final updated = newStudent.copyWith(name: 'Bintang Pratama Putra');
    expect(
      store.updateUser(
        originalAccountId: '0099887766',
        originalRole: UserRole.murid,
        updated: updated,
        isSelfProfileEdit: true,
      ),
      isTrue,
    );
    expect(
      store.users.firstWhere((u) => u.accountId == '0099887766').name,
      'Bintang Pratama Putra',
    );

    // 3. Murid Presensi Masuk & Pulang dengan foto
    final dummyPhoto = Uint8List.fromList([1, 2, 3, 4]);
    store.recordCheckIn(student: updated, photoBytes: dummyPhoto);
    store.recordCheckOut(student: updated, photoBytes: dummyPhoto);
    final studentAtt = store.attendanceForStudent('0099887766');
    expect(studentAtt, isNotEmpty);
    expect(studentAtt.first.checkInPhotoBytes, isNotNull);
    expect(studentAtt.first.checkOutPhotoBytes, isNotNull);

    // 4. Murid Jurnal + Validasi & Masukan Mentor IDUKA
    store.addJournal(
      student: updated,
      title: 'Belajar Flutter Widget',
      description: 'Membuat form upload foto presensi dan jurnal.',
      tag: 'Proyek',
      imageBytes: dummyPhoto,
    );
    final studentJournals = store.journalsForStudent('0099887766');
    expect(studentJournals, isNotEmpty);

    final mentor = store.users.firstWhere((u) => u.role == UserRole.iduka);
    store.validateJournalByMentor(
      journalId: studentJournals.first.id,
      mentor: mentor,
      approve: true,
      note: 'Mantap, dokumentasi jelas.',
    );
    final validated = store.journalsForStudent('0099887766').first;
    expect(validated.isValidatedByMentor, isTrue);
    expect(validated.mentorNote, 'Mantap, dokumentasi jelas.');

    // 5. Riwayat tercatat untuk semua aktivitas
    expect(store.history.length, greaterThanOrEqualTo(5));

    // 6. Admin Delete
    store.deleteUser(updated);
    expect(store.users.length, initialCount);
  });
}
