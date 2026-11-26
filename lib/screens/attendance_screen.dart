import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class AttendanceRecordItem {
  const AttendanceRecordItem({
    required this.shortWeekday,
    required this.shortDate,
    this.checkInTime,
    this.checkOutTime,
    this.checkInPhoto,
    this.checkOutPhoto,
    this.isApprovedByIduka = false,
    this.idukaApproverName,
    this.idukaApprovalTime,
  });

  final String shortWeekday;
  final String shortDate;
  final String? checkInTime;
  final String? checkOutTime;
  final String? checkInPhoto;
  final String? checkOutPhoto;
  final bool isApprovedByIduka;
  final String? idukaApproverName;
  final String? idukaApprovalTime;

  String get approvalStatusLabel =>
      isApprovedByIduka ? 'Disetujui Pembimbing IDUKA' : 'Menunggu Konfirmasi IDUKA';
}

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({
    super.key,
    this.idukaMentorName = 'Hendro Prasetyo, S.T.',
    this.hasCheckedIn,
    this.hasCheckedOut,
    this.checkInTime,
    this.checkOutTime,
    this.onAttendanceAction,
  });

  final bool? hasCheckedIn;
  final bool? hasCheckedOut;
  final String? checkInTime;
  final String? checkOutTime;
  final VoidCallback? onAttendanceAction;
  final String idukaMentorName;

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final String _currentPhotoUrl = PklPhotoPresets.coding;

  late bool _hasCheckedIn;
  late bool _hasCheckedOut;
  late String? _checkInTime;
  late String? _checkOutTime;

  late final List<AttendanceRecordItem> _records = [
    AttendanceRecordItem(
      shortWeekday: 'Senin',
      shortDate: '24 Nov 2026',
      checkInTime: '07.50',
      checkOutTime: '16.05',
      checkInPhoto: PklPhotoPresets.coding,
      checkOutPhoto: PklPhotoPresets.report,
      isApprovedByIduka: true,
      idukaApproverName: widget.idukaMentorName,
      idukaApprovalTime: '16.15 WIB',
    ),
    AttendanceRecordItem(
      shortWeekday: 'Selasa',
      shortDate: '25 Nov 2026',
      checkInTime: '07.45',
      checkOutTime: '16.10',
      checkInPhoto: PklPhotoPresets.meeting,
      checkOutPhoto: PklPhotoPresets.report,
      isApprovedByIduka: true,
      idukaApproverName: widget.idukaMentorName,
      idukaApprovalTime: '16.20 WIB',
    ),
    AttendanceRecordItem(
      shortWeekday: 'Rabu',
      shortDate: '26 Nov 2026',
      checkInTime: '07.55',
      checkOutTime: '16.00',
      checkInPhoto: PklPhotoPresets.networking,
      checkOutPhoto: PklPhotoPresets.report,
      isApprovedByIduka: true,
      idukaApproverName: widget.idukaMentorName,
      idukaApprovalTime: '16.10 WIB',
    ),
    AttendanceRecordItem(
      shortWeekday: 'Kamis',
      shortDate: '27 Nov 2026',
      checkInTime: '07.40',
      checkOutTime: '16.15',
      checkInPhoto: PklPhotoPresets.uiDesign,
      checkOutPhoto: PklPhotoPresets.report,
      isApprovedByIduka: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _hasCheckedIn = widget.hasCheckedIn ?? true;
    _hasCheckedOut = widget.hasCheckedOut ?? false;
    _checkInTime = widget.checkInTime ?? '07.45';
    _checkOutTime = widget.checkOutTime;
  }

  void _recordAttendance() {
    if (_hasCheckedIn && _hasCheckedOut) return;

    final isCheckIn = !_hasCheckedIn;
    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}.${now.minute.toString().padLeft(2, '0')}';

    setState(() {
      if (!_hasCheckedIn) {
        _hasCheckedIn = true;
        _checkInTime = timeStr;
      } else if (!_hasCheckedOut) {
        _hasCheckedOut = true;
        _checkOutTime = timeStr;
        _records.insert(
          0,
          AttendanceRecordItem(
            shortWeekday: 'Hari Ini',
            shortDate: '${now.day} Nov ${now.year}',
            checkInTime: _checkInTime,
            checkOutTime: _checkOutTime,
            checkInPhoto: _currentPhotoUrl,
            checkOutPhoto: PklPhotoPresets.report,
            isApprovedByIduka: false,
          ),
        );
      }
    });

    if (widget.onAttendanceAction != null) {
      widget.onAttendanceAction!();
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.paleGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.green,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isCheckIn
                    ? 'Foto Presensi Masuk Berhasil Diunggah!'
                    : 'Foto Presensi Pulang Berhasil Diunggah!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Kehadiranmu tercatat dan menunggu konfirmasi dari Pembimbing IDUKA (${widget.idukaMentorName}).',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted, fontSize: 12, height: 1.5),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.paper,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.line),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded,
                            size: 16, color: AppColors.maroon),
                        const SizedBox(width: 8),
                        const Text('Waktu Tercatat:',
                            style: TextStyle(fontSize: 12, color: AppColors.muted)),
                        const Spacer(),
                        Text('${currentTimeLabel()} WIB',
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.business_rounded,
                            size: 16, color: AppColors.green),
                        const SizedBox(width: 8),
                        const Text('Konfirmasi Oleh:',
                            style: TextStyle(fontSize: 12, color: AppColors.muted)),
                        const Spacer(),
                        Text('Pembimbing IDUKA',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.green)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(sheetContext),
                child: const Text('Mengerti & Tutup'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAttendanceDetail(AttendanceRecordItem record) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.line,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Icon(Icons.event_note_rounded,
                        color: AppColors.maroon, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Detail Presensi Harian',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${record.shortWeekday}, ${record.shortDate}',
                  style: const TextStyle(
                      color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 18),

                // Approval Status Card (Only IDUKA confirms)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: record.isApprovedByIduka
                        ? AppColors.paleGreen
                        : AppColors.paleAmber,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: record.isApprovedByIduka
                          ? AppColors.green.withOpacity(0.3)
                          : AppColors.amber.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: record.isApprovedByIduka
                            ? AppColors.green
                            : AppColors.amber,
                        child: Icon(
                          record.isApprovedByIduka
                              ? Icons.check_circle_rounded
                              : Icons.hourglass_top_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              record.isApprovedByIduka
                                  ? 'Disetujui Pembimbing IDUKA'
                                  : 'Menunggu Konfirmasi IDUKA',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: record.isApprovedByIduka
                                    ? AppColors.green
                                    : AppColors.amber,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              record.isApprovedByIduka
                                  ? 'Dikonfirmasi oleh ${record.idukaApproverName ?? widget.idukaMentorName} • ${record.idukaApprovalTime ?? '16.15 WIB'}'
                                  : 'Pembimbing industri: ${widget.idukaMentorName}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.taupe,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Waktu & Foto Masuk
                const Text(
                  'PRESENSI MASUK',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.taupe,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.paper,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.login_rounded,
                              size: 16, color: AppColors.green),
                          const SizedBox(width: 6),
                          const Text('Waktu Masuk: ',
                              style: TextStyle(fontSize: 12, color: AppColors.muted)),
                          Text(
                            record.checkInTime != null
                                ? '${record.checkInTime} WIB'
                                : 'Belum presensi',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      if (record.checkInPhoto != null || record.checkInTime != null) ...[
                        const SizedBox(height: 10),
                        PklPhotoThumbnail(
                          imageUrl: record.checkInPhoto ?? _currentPhotoUrl,
                          height: 130,
                          caption: 'Foto Bukti Presensi Masuk',
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Waktu & Foto Pulang
                const Text(
                  'PRESENSI PULANG',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.taupe,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.paper,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.logout_rounded,
                              size: 16, color: AppColors.maroon),
                          const SizedBox(width: 6),
                          const Text('Waktu Pulang: ',
                              style: TextStyle(fontSize: 12, color: AppColors.muted)),
                          Text(
                            record.checkOutTime != null
                                ? '${record.checkOutTime} WIB'
                                : 'Belum presensi pulang',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      if (record.checkOutTime != null) ...[
                        const SizedBox(height: 10),
                        PklPhotoThumbnail(
                          imageUrl: record.checkOutPhoto ?? PklPhotoPresets.report,
                          height: 130,
                          caption: 'Foto Bukti Presensi Pulang',
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Tutup Detail'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isComplete = _hasCheckedIn && _hasCheckedOut;
    final statusLabel = isComplete
        ? 'Presensi Lengkap'
        : _hasCheckedIn
            ? 'Sedang Praktik'
            : 'Belum Presensi';
    final statusColor = isComplete
        ? AppColors.green
        : _hasCheckedIn
            ? AppColors.amber
            : AppColors.maroon;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          PageHeading(
            title: 'Presensi PKL',
            subtitle: 'Upload foto kehadiran untuk konfirmasi Pembimbing IDUKA.',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InfoPill(
                  label: statusLabel,
                  color: isComplete
                      ? AppColors.paleGreen
                      : _hasCheckedIn
                          ? AppColors.paleAmber
                          : AppColors.cream,
                  textColor: statusColor,
                  icon: isComplete
                      ? Icons.check_circle_outline_rounded
                      : Icons.schedule_rounded,
                ),
                const SizedBox(width: 6),
                const PklNotificationButton(unreadCount: 2),
              ],
            ),
          ),

          // Live Clock & Operational Time Banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.maroon, AppColors.maroonDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      currentDateLabel().toUpperCase(),
                      style: TextStyle(
                        color: AppColors.cream.withOpacity(0.85),
                        fontSize: 10,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const InfoPill(
                      label: 'PKL AKTIF',
                      color: Color(0x33FFFFFF),
                      textColor: Colors.white,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const LiveClockWidget(isLight: true),
                const SizedBox(height: 6),
                Text(
                  'Jam Kerja Industri: 08.00 – 16.00 WIB',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Konfirmasi IDUKA Notice
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.paleGreen,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.green.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_user_rounded,
                    color: AppColors.green, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Presensi dikonfirmasi dan disetujui langsung oleh Pembimbing IDUKA (${widget.idukaMentorName}). Guru sekolah tidak perlu mengonfirmasi presensi.',
                    style: const TextStyle(
                      color: AppColors.green,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Upload Foto & Catat Kehadiran (Tanpa Ganti Foto)
          const SectionLabel('Foto Kehadiran Hari Ini'),
          WhiteCard(
            padding: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    children: [
                      Image.network(
                        _currentPhotoUrl,
                        height: 170,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 170,
                          color: AppColors.cream,
                          child: const Center(
                            child: Icon(Icons.camera_alt,
                                size: 48, color: AppColors.maroon),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 10,
                        bottom: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.68),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.access_time_rounded,
                                  size: 12, color: Colors.white),
                              const SizedBox(width: 5),
                              Text(
                                'Foto kehadiran ${currentTimeLabel()} WIB',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Time Blocks
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.paper,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _TimeBlock(
                          label: 'JAM MASUK',
                          time: _checkInTime ?? '--.--',
                          complete: _hasCheckedIn,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppColors.line,
                        margin: const EdgeInsets.symmetric(horizontal: 14),
                      ),
                      Expanded(
                        child: _TimeBlock(
                          label: 'JAM PULANG',
                          time: _checkOutTime ?? '--.--',
                          complete: _hasCheckedOut,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                ElevatedButton.icon(
                  onPressed: isComplete ? null : _recordAttendance,
                  icon: Icon(
                    isComplete
                        ? Icons.check_circle_rounded
                        : _hasCheckedIn
                            ? Icons.logout_rounded
                            : Icons.camera_alt_rounded,
                  ),
                  label: Text(
                    isComplete
                        ? 'Presensi Hari Ini Selesai'
                        : _hasCheckedIn
                            ? 'Upload Foto & Catat Pulang'
                            : 'Upload Foto & Catat Masuk',
                  ),
                  style: isComplete
                      ? ElevatedButton.styleFrom(
                          disabledBackgroundColor: AppColors.paleGreen,
                          disabledForegroundColor: AppColors.green,
                        )
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // Riwayat Presensi (Clickable tiles)
          SectionLabel(
            'Riwayat Kehadiran (Klik untuk Detail)',
            action: '${_records.length} hari',
          ),
          WhiteCard(
            padding: _records.isEmpty ? 16 : 0,
            child: _records.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        'Belum ada riwayat presensi.',
                        style: TextStyle(color: AppColors.muted),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      for (var index = 0;
                          index < _records.length && index < 7;
                          index++) ...[
                        if (index > 0)
                          const Divider(height: 1, indent: 16, endIndent: 16),
                        InkWell(
                          onTap: () => _showAttendanceDetail(_records[index]),
                          borderRadius: BorderRadius.circular(16),
                          child: _AttendanceHistoryRow(record: _records[index]),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _TimeBlock extends StatelessWidget {
  const _TimeBlock({
    required this.label,
    required this.time,
    required this.complete,
  });

  final String label;
  final String time;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 9,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              time,
              style: TextStyle(
                color: complete ? AppColors.ink : AppColors.muted,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (complete) ...[
              const SizedBox(width: 5),
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.green,
                size: 15,
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _AttendanceHistoryRow extends StatelessWidget {
  const _AttendanceHistoryRow({required this.record});

  final AttendanceRecordItem record;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.shortWeekday.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  record.shortDate,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Masuk: ${record.checkInTime ?? '--.--'}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Pulang: ${record.checkOutTime ?? '--.--'}',
                      style: const TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  record.approvalStatusLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: record.isApprovedByIduka
                        ? AppColors.green
                        : AppColors.amber,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.muted,
            size: 19,
          ),
        ],
      ),
    );
  }
}
