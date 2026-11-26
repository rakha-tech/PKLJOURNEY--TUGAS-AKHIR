import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

abstract final class PklPhotoPresets {
  static const coding =
      'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=800&q=80';
  static const uiDesign =
      'https://images.unsplash.com/photo-1581291518857-4e27b48ff24e?w=800&q=80';
  static const meeting =
      'https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=800&q=80';
  static const networking =
      'https://images.unsplash.com/photo-1558494949-ef010cbdcc31?w=800&q=80';
  static const report =
      'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=800&q=80';

  static const List<Map<String, String>> presets = [
    {
      'label': 'Pemrograman & Coding',
      'url': coding,
      'tag': 'Proyek',
    },
    {
      'label': 'Desain UI & Prototyping',
      'url': uiDesign,
      'tag': 'Pembelajaran',
    },
    {
      'label': 'Diskusi Tim & Mentoring',
      'url': meeting,
      'tag': 'Orientasi',
    },
    {
      'label': 'Konfigurasi Server & Jaringan',
      'url': networking,
      'tag': 'Kegiatan',
    },
    {
      'label': 'Dokumentasi & Laporan',
      'url': report,
      'tag': 'Kegiatan',
    },
  ];
}

class BrandMark extends StatelessWidget {
  const BrandMark({
    super.key,
    this.compact = false,
    this.light = false,
    this.showWordmark = true,
  });

  final bool compact;
  final bool light;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    final color = light ? AppColors.cream : AppColors.maroon;
    final markSize = compact ? 42.0 : 82.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: markSize,
          height: markSize,
          child: CustomPaint(painter: _BrandMarkPainter(color)),
        ),
        if (showWordmark) ...[
          SizedBox(width: compact ? 9 : 13),
          Text(
            'PKLJOURNEY',
            style: TextStyle(
              color: color,
              fontSize: compact ? 15 : 19,
              fontWeight: FontWeight.w800,
              letterSpacing: compact ? 1.35 : 2.2,
            ),
          ),
        ],
      ],
    );
  }
}

class _BrandMarkPainter extends CustomPainter {
  _BrandMarkPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 100;
    canvas.save();
    canvas.scale(scale);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (var i = 0; i < 7; i++) {
      final x = 29.0 + (i * 7.0);
      final top = i == 3 ? 2.0 : (i == 2 || i == 4 ? 6.0 : 11.0);
      canvas.drawLine(Offset(x, top), Offset(x, top + 6), stroke);
    }
    canvas.drawArc(
      const Rect.fromLTWH(31, 13, 38, 29),
      3.14,
      3.14,
      false,
      stroke,
    );
    final shield = Path()
      ..moveTo(17, 28)
      ..lineTo(50, 35)
      ..lineTo(83, 28)
      ..lineTo(80, 66)
      ..quadraticBezierTo(77, 83, 50, 96)
      ..quadraticBezierTo(23, 83, 20, 66)
      ..close();
    canvas.drawPath(shield, stroke);

    final book = Path()
      ..moveTo(29, 43)
      ..quadraticBezierTo(39, 39, 49, 47)
      ..lineTo(49, 63)
      ..quadraticBezierTo(39, 56, 29, 60)
      ..close()
      ..moveTo(51, 47)
      ..quadraticBezierTo(62, 39, 72, 43)
      ..lineTo(72, 60)
      ..quadraticBezierTo(61, 56, 51, 63)
      ..close();
    canvas.drawPath(book, stroke);
    final growth = Path()
      ..moveTo(28, 75)
      ..lineTo(48, 65)
      ..lineTo(60, 52)
      ..lineTo(68, 56)
      ..lineTo(79, 38);
    canvas.drawPath(growth, stroke);
    final arrow = Path()
      ..moveTo(68, 38)
      ..lineTo(80, 35)
      ..lineTo(79, 48)
      ..close();
    canvas.drawPath(arrow, fill);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BrandMarkPainter oldDelegate) =>
      oldDelegate.color != color;
}

class PageHeading extends StatelessWidget {
  const PageHeading({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.action, this.onAction});

  final String text;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.titleLarge),
          ),
          if (action != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.maroon,
                padding: EdgeInsets.zero,
              ),
              child: Text(action!),
            ),
        ],
      ),
    );
  }
}

class InfoPill extends StatelessWidget {
  const InfoPill({
    super.key,
    required this.label,
    this.color = AppColors.paleGreen,
    this.textColor = AppColors.green,
    this.icon,
  });

  final String label;
  final Color color;
  final Color textColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(30)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class WhiteCard extends StatelessWidget {
  const WhiteCard({
    super.key,
    required this.child,
    this.padding = 16,
    this.onTap,
  });

  final Widget child;
  final double padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: child,
    );

    if (onTap == null) return cardContent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: cardContent,
      ),
    );
  }
}

class LiveClockWidget extends StatefulWidget {
  const LiveClockWidget({super.key, this.isLight = false});
  final bool isLight;

  @override
  State<LiveClockWidget> createState() => _LiveClockWidgetState();
}

class _LiveClockWidgetState extends State<LiveClockWidget> {
  late Timer _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = _now.hour.toString().padLeft(2, '0');
    final m = _now.minute.toString().padLeft(2, '0');
    final s = _now.second.toString().padLeft(2, '0');

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: widget.isLight ? AppColors.cream : AppColors.green,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$h:$m:$s WIB',
          style: TextStyle(
            color: widget.isLight ? Colors.white : AppColors.ink,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class PklNotificationButton extends StatelessWidget {
  const PklNotificationButton({super.key, this.unreadCount = 2});

  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: AppColors.ink),
          tooltip: 'Notifikasi',
          onPressed: () {
            showModalBottomSheet<void>(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (context) => const _NotificationBottomSheet(),
            );
          },
        ),
        if (unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.maroon,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                '$unreadCount',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _NotificationBottomSheet extends StatelessWidget {
  const _NotificationBottomSheet();

  @override
  Widget build(BuildContext context) {
    final notifications = [
      (
        title: 'Jurnal Disetujui Pembimbing',
        body:
            'Budi Santoso, S.Kom. telah memeriksa dan menyetujui jurnal "Orientasi lingkungan kerja".',
        time: '15 menit lalu',
        icon: Icons.verified_rounded,
        color: AppColors.green,
      ),
      (
        title: 'Geofencing Lokasi Aktif',
        body:
            'Posisi Anda terverifikasi berada di dalam radius 50m PT Aksara Digital Nusantara.',
        time: '1 jam lalu',
        icon: Icons.location_on_rounded,
        color: AppColors.maroon,
      ),
      (
        title: 'Pengingat Presensi Pulang',
        body:
            'Jam kerja PKL berakhir pukul 16.00 WIB. Pastikan mencatat kehadiran pulang tepat waktu.',
        time: '3 jam lalu',
        icon: Icons.alarm_rounded,
        color: AppColors.amber,
      ),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.notifications_active_rounded,
                    color: AppColors.maroon, size: 22),
                const SizedBox(width: 8),
                Text('Notifikasi PKL',
                    style: Theme.of(context).textTheme.headlineSmall),
                const Spacer(),
                const InfoPill(
                  label: '3 Baru',
                  color: AppColors.paleAmber,
                  textColor: AppColors.amber,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...notifications.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: AppColors.paper,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 17,
                          backgroundColor: item.color.withOpacity(0.12),
                          child:
                              Icon(item.icon, size: 18, color: item.color),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: AppColors.ink,
                                  )),
                              const SizedBox(height: 4),
                              Text(
                                item.body,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.muted,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(item.time,
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.taupe,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class PklPhotoThumbnail extends StatelessWidget {
  const PklPhotoThumbnail({
    super.key,
    required this.imageUrl,
    this.height = 140,
    this.caption,
  });

  final String imageUrl;
  final double height;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog<void>(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 250,
                        color: AppColors.paper,
                        child: const Center(
                          child: CircularProgressIndicator(color: AppColors.maroon),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) =>
                        _fallbackPhotoBox(height: 250),
                  ),
                ),
                if (caption != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      caption!,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                IconButton.filled(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            SizedBox(
              height: height,
              width: double.infinity,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: AppColors.paper,
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.maroon,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) =>
                    _fallbackPhotoBox(height: height),
              ),
            ),
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.zoom_in_rounded, size: 14, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Perbesar',
                      style: TextStyle(
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
    );
  }

  Widget _fallbackPhotoBox({required double height}) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.camera_alt_outlined, color: AppColors.maroon, size: 32),
            SizedBox(height: 6),
            Text(
              'Foto Dokumentasi Kegiatan PKL',
              style: TextStyle(
                color: AppColors.maroon,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String currentDateLabel() {
  const days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu'
  ];
  const months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember'
  ];
  final now = DateTime.now();
  return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
}

String currentTimeLabel() {
  final now = DateTime.now();
  return '${now.hour.toString().padLeft(2, '0')}.${now.minute.toString().padLeft(2, '0')}';
}