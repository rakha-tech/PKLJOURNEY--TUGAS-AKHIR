import 'package:flutter/material.dart';

import '../services/teacher_mentor_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class TeacherStudentsScreen extends StatefulWidget {
  const TeacherStudentsScreen({super.key});

  @override
  State<TeacherStudentsScreen> createState() => _TeacherStudentsScreenState();
}

class _TeacherStudentsScreenState extends State<TeacherStudentsScreen> {
  final _service = TeacherMentorService();

  bool _isLoading = true;
  List<SupervisedStudent> _students = [];

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);
    try {
      final list = await _service.fetchMyStudents();
      if (mounted) {
        setState(() {
          _students = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat daftar murid: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showContactSheet(
    BuildContext context, {
    required String name,
    required String subtitle,
    required String phone,
    required String email,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.cream,
                    child: Text(
                      name.isEmpty ? '?' : name[0].toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.maroon,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (phone.isNotEmpty) ...[
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  tileColor: AppColors.paper,
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.green,
                    radius: 18,
                    child: Icon(
                      Icons.chat_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  title: const Text(
                    'WhatsApp / Chat',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    phone,
                    style: const TextStyle(fontSize: 11, color: AppColors.muted),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: AppColors.muted,
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Menghubungkan ke WhatsApp: $phone'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
              ],
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                tileColor: AppColors.paper,
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF2E6B8B),
                  radius: 18,
                  child: Icon(
                    Icons.mail_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                title: const Text(
                  'Kirim Email',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  email,
                  style: const TextStyle(fontSize: 11, color: AppColors.muted),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.muted,
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Membuka email ke: $email'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadStudents,
        color: AppColors.maroon,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const PageHeading(
              title: 'Murid Bimbingan',
              subtitle:
                  'Daftar siswa PKL beserta tempat praktik dan pembimbing IDUKA.',
            ),
            SectionLabel(
              'Siswa terdaftar',
              action: '${_students.length} murid',
            ),
            if (_isLoading && _students.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.maroon),
                ),
              )
            else if (_students.isEmpty)
              const WhiteCard(
                child: Column(
                  children: [
                    Icon(
                      Icons.groups_outlined,
                      color: AppColors.muted,
                      size: 38,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Belum ada murid bimbingan',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Admin belum menetapkan siswa ke bimbingan Anda.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                  ],
                ),
              )
            else
              ..._students.map((item) {
                final student = item.student;
                final mentor = item.mentor;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: WhiteCard(
                    padding: 15,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 21,
                              backgroundColor: AppColors.cream,
                              child: Text(
                                student.fullName.isEmpty
                                    ? '?'
                                    : student.fullName[0].toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.maroon,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    student.fullName,
                                    style: const TextStyle(
                                      color: AppColors.ink,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '@${student.username} • ${student.email}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.muted,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(11),
                          decoration: BoxDecoration(
                            color: AppColors.paper,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.business_rounded,
                                    size: 15,
                                    color: AppColors.green,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      item.companyName,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (item.companyAddress != null &&
                                  item.companyAddress!.isNotEmpty) ...[
                                const SizedBox(height: 3),
                                Text(
                                  item.companyAddress!,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ],
                              if (mentor != null) ...[
                                const SizedBox(height: 6),
                                Text(
                                  'Mentor IDUKA: ${mentor.fullName}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.maroon,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _showContactSheet(
                                  context,
                                  name: student.fullName,
                                  subtitle: 'Murid PKL • ${item.companyName}',
                                  phone: student.phone ?? '',
                                  email: student.email,
                                ),
                                icon: const Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 16,
                                ),
                                label: const Text('Hubungi Murid'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.maroon,
                                  side: const BorderSide(
                                    color: AppColors.maroon,
                                  ),
                                  minimumSize: const Size.fromHeight(40),
                                ),
                              ),
                            ),
                            if (mentor != null) ...[
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _showContactSheet(
                                    context,
                                    name: mentor.fullName,
                                    subtitle:
                                        'Mentor IDUKA • ${item.companyName}',
                                    phone: mentor.phone ?? '',
                                    email: mentor.email,
                                  ),
                                  icon: const Icon(
                                    Icons.support_agent_rounded,
                                    size: 16,
                                  ),
                                  label: const Text('Hubungi Mentor'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.green,
                                    side: const BorderSide(
                                      color: AppColors.green,
                                    ),
                                    minimumSize: const Size.fromHeight(40),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
