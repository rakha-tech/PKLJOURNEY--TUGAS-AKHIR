import 'package:flutter/material.dart';

import '../models/pkl_models.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({
    super.key,
    required this.user,
    required this.entries,
    this.showBackButton = true,
  });

  final PklUser user;
  final List<PklHistoryEntry> entries;
  final bool showBackButton;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedCategory = 'Semua';

  @override
  Widget build(BuildContext context) {
    final categories = ['Semua', 'Presensi', 'Jurnal', 'Akun', 'Profil', 'Bimbingan'];
    final filtered = widget.entries.where((e) {
      if (_selectedCategory == 'Semua') return true;
      return e.category == _selectedCategory;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: widget.showBackButton
          ? AppBar(
              title: const Text('Riwayat Aktivitas'),
              backgroundColor: AppColors.paper,
            )
          : null,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            if (!widget.showBackButton)
              const PageHeading(
                title: 'Riwayat Aktivitas',
                subtitle: 'Catatan seluruh aktivitas dan perubahan terbaru.',
              ),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.cream.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                children: [
                  const Icon(Icons.history_rounded,
                      color: AppColors.maroon, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Menampilkan riwayat aktivitas untuk ${widget.user.name} (${widget.user.role.label}).',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.ink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((cat) {
                  final selected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: selected,
                      onSelected: (_) =>
                          setState(() => _selectedCategory = cat),
                      selectedColor: AppColors.maroon,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : AppColors.ink,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                      side: BorderSide(
                        color: selected ? AppColors.maroon : AppColors.line,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            SectionLabel(
              'Daftar Riwayat',
              action: '${filtered.length} aktivitas',
            ),
            if (filtered.isEmpty)
              const WhiteCard(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      Icon(Icons.history_toggle_off_rounded,
                          color: AppColors.muted, size: 38),
                      SizedBox(height: 10),
                      Text(
                        'Belum ada riwayat pada kategori ini.',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...filtered.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: WhiteCard(
                    padding: 14,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor:
                              _categoryColor(entry.category).withValues(alpha: 0.14),
                          child: Icon(
                            _categoryIcon(entry.category),
                            color: _categoryColor(entry.category),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      entry.title,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                  ),
                                  InfoPill(
                                    label: entry.category,
                                    color: AppColors.paper,
                                    textColor: AppColors.taupe,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                entry.description,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.muted,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${entry.actorName} (${entry.actorRole.label}) • ${entry.timeLabel}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.taupe,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _categoryColor(String category) => switch (category) {
        'Presensi' => AppColors.green,
        'Jurnal' => AppColors.amber,
        'Akun' => AppColors.maroon,
        'Profil' => const Color(0xFF2E6B8B),
        _ => AppColors.taupe,
      };

  IconData _categoryIcon(String category) => switch (category) {
        'Presensi' => Icons.fact_check_rounded,
        'Jurnal' => Icons.menu_book_rounded,
        'Akun' => Icons.manage_accounts_rounded,
        'Profil' => Icons.person_rounded,
        _ => Icons.assignment_ind_rounded,
      };
}
