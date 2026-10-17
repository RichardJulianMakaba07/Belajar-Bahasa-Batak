import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../core/theme/app_colors.dart';
import '../features/profile/presentation/cubit/profile_cubit.dart';

BoxDecoration _card([double radius = 20]) => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(radius),
  boxShadow: [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.07),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ],
);

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

const _ulosRed = Color(0xFFC62828);
const _gold = Color(0xFFF2B33D);

class _ProfilPageState extends State<ProfilPage> {
  // ---- data contoh ----

  // ---- foto profil ----
  Uint8List? _photo; // null = belum ada foto, tampilkan inisial
  final ImagePicker _picker = ImagePicker();

  final List<_BadgeData> _badges = const [
    _BadgeData(Icons.waving_hand_rounded, 'Horas!', true),
    _BadgeData(Icons.local_fire_department_rounded, '7 Hari', true),
    _BadgeData(Icons.menu_book_rounded, '100 Kata', true),
    _BadgeData(Icons.emoji_events_rounded, 'Sempurna', false),
  ];

  // ---- data dari Cubit ----
  String get _name => context.read<ProfileCubit>().state.name;
  bool get _reminder => context.read<ProfileCubit>().state.reminder;
  int get _level => context.read<ProfileCubit>().state.level;
  int get _xp => context.read<ProfileCubit>().state.xp;
  int get _xpTarget => context.read<ProfileCubit>().state.xpTarget;

  // ---- helper ----
  String get _username =>
      '@${_name.toLowerCase().replaceAll(RegExp(r'\s+'), '')}';

  String get _initials {
    final parts = _name
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  // Kamera hanya tersedia di Android & iOS.
  bool get _canUseCamera =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (file == null) return; // dibatalkan
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() => _photo = bytes);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto tidak bisa dibuka. Coba lagi.')),
      );
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 20, 8, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Foto profil',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.dark,
                    ),
                  ),
                ),
              ),
              if (_canUseCamera)
                ListTile(
                  leading: const Icon(
                    Icons.photo_camera_outlined,
                    color: AppColors.primary,
                  ),
                  title: const Text('Ambil foto'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickPhoto(ImageSource.camera);
                  },
                ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: AppColors.primary,
                ),
                title: const Text('Pilih dari galeri'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickPhoto(ImageSource.gallery);
                },
              ),
              if (_photo != null)
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline_rounded,
                    color: _ulosRed,
                  ),
                  title: const Text(
                    'Hapus foto',
                    style: TextStyle(color: _ulosRed),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    setState(() => _photo = null);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editProfile() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _EditNameSheet(initialName: _name),
    );
    if (result != null && mounted) {
      context.read<ProfileCubit>().updateName(result);
    }
  }

  Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Keluar dari akun?'),
        content: const Text('Kamu bisa masuk lagi kapan saja.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _ulosRed),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      // TODO: tambahkan logika logout yang sebenarnya di sini.
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Kamu telah keluar.')));
    }
  }

  // -------------------------------------------------------------------------
  // BUILD
  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileCubit>().state;
    return ColoredBox(
      color: AppColors.background,
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 14),
            Text(
              profile.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.dark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _username,
              style: const TextStyle(fontSize: 14, color: AppColors.inactive),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.indicator,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.translate_rounded, size: 16, color: AppColors.primary),
                  SizedBox(width: 6),
                  Text(
                    'Pelajar bahasa Batak',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLevelCard(),
                  const SizedBox(height: 14),
                  _buildStats(),
                  const SizedBox(height: 24),
                  const _SectionTitle('Pencapaian'),
                  const SizedBox(height: 12),
                  _buildBadges(),
                  const SizedBox(height: 24),
                  const _SectionTitle('Pengaturan'),
                  const SizedBox(height: 12),
                  _buildSettings(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- header + avatar ----
  Widget _buildHeader() {
    const headerHeight = 100.0; // tinggi bagian biru (sebelumnya 200)
    const avatarSize = 112.0;

    return SizedBox(
      height: headerHeight + avatarSize / 2,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: headerHeight,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(32),
              ),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, const Color(0xFF082F63)],
                  ),
                ),
                child: CustomPaint(painter: _UlosPainter()),
              ),
            ),
          ),
          Positioned(
            top: headerHeight - avatarSize / 2,
            left: 0,
            right: 0,
            child: Center(child: _buildAvatar(avatarSize)),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(double size) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: GestureDetector(
              onTap: _showPhotoOptions,
              child: ClipOval(
                child: _photo != null
                    ? Image.memory(_photo!, fit: BoxFit.cover)
                    : Container(
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [_ulosRed, Color(0xFF8E1B1B)],
                          ),
                        ),
                        child: Text(
                          _initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 2,
            child: GestureDetector(
              onTap: _showPhotoOptions,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(
                  Icons.photo_camera_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---- level ----
  Widget _buildLevelCard() {
    final progress = (_xp / _xpTarget).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Level $_level',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.dark,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: _gold.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Menengah',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF9A6A00),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '$_xp XP',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.indicator,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_xpTarget - _xp} XP lagi menuju Level ${_level + 1}',
            style: const TextStyle(fontSize: 12.5, color: AppColors.inactive),
          ),
        ],
      ),
    );
  }

  // ---- statistik ----
  Widget _buildStats() {
    return const Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.local_fire_department_rounded,
            color: Color(0xFFEF6C00),
            value: '7',
            label: 'Hari beruntun',
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.menu_book_rounded,
            color: AppColors.primary,
            value: '128',
            label: 'Kata dikuasai',
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.gps_fixed_rounded,
            color: Color(0xFF2E7D32),
            value: '86%',
            label: 'Akurasi',
          ),
        ),
      ],
    );
  }

  // ---- pencapaian ----
  Widget _buildBadges() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
      decoration: _card(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _badges.map((b) => _BadgeItem(data: b)).toList(),
      ),
    );
  }

  // ---- pengaturan ----
  Widget _buildSettings() {
    const divider = Divider(height: 1, indent: 68, color: Color(0xFFEEF1F6));

    return Container(
      decoration: _card(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: Column(
            children: [
              _SettingTile(
                icon: Icons.edit_outlined,
                title: 'Edit profil',
                onTap: _editProfile,
              ),
              divider,
              _SettingTile(
                icon: Icons.notifications_none_rounded,
                title: 'Pengingat belajar harian',
                onTap: () => context.read<ProfileCubit>().setReminder(!_reminder),
                trailing: Switch(
                  value: _reminder,
                  activeColor: AppColors.primary,
                  onChanged: context.read<ProfileCubit>().setReminder,
                ),
              ),
              divider,
              _SettingTile(
                icon: Icons.info_outline_rounded,
                title: 'Tentang aplikasi',
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: 'Belajar Bahasa Batak',
                  applicationVersion: '1.0.0',
                ),
              ),
              divider,
              _SettingTile(
                icon: Icons.logout_rounded,
                title: 'Keluar',
                color: _ulosRed,
                onTap: _confirmLogout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// KOMPONEN KECIL
/// ---------------------------------------------------------------------------
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AppColors.dark,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: _card(18),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11.5, color: AppColors.inactive),
          ),
        ],
      ),
    );
  }
}

class _BadgeData {
  final IconData icon;
  final String label;
  final bool unlocked;
  const _BadgeData(this.icon, this.label, this.unlocked);
}

class _BadgeItem extends StatelessWidget {
  final _BadgeData data;
  const _BadgeItem({required this.data});

  @override
  Widget build(BuildContext context) {
    final unlocked = data.unlocked;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: unlocked
                ? _gold.withOpacity(0.25)
                : const Color(0xFFEDF0F5),
            border: unlocked ? Border.all(color: _gold, width: 2) : null,
          ),
          child: Icon(
            unlocked ? data.icon : Icons.lock_outline_rounded,
            size: 26,
            color: unlocked ? const Color(0xFFB77900) : AppColors.inactive,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          data.label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: unlocked ? AppColors.dark : AppColors.inactive,
          ),
        ),
      ],
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? color;

  const _SettingTile({
    required this.icon,
    required this.title,
    this.onTap,
    this.trailing,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: c.withOpacity(0.10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: c, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
          color: color ?? AppColors.dark,
        ),
      ),
      trailing:
          trailing ?? const Icon(Icons.chevron_right_rounded, color: AppColors.inactive),
    );
  }
}

/// ---------------------------------------------------------------------------
/// BOTTOM SHEET EDIT NAMA
/// ---------------------------------------------------------------------------
class _EditNameSheet extends StatefulWidget {
  final String initialName;
  const _EditNameSheet({required this.initialName});

  @override
  State<_EditNameSheet> createState() => _EditNameSheetState();
}

class _EditNameSheetState extends State<_EditNameSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialName,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final value = _controller.text.trim();
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit profil',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.dark,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controller,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              onFieldSubmitted: (_) => _save(),
              validator: (value) {
                final name = value?.trim() ?? '';
                if (name.isEmpty) return 'Nama wajib diisi.';
                if (name.length < 3) return 'Nama minimal 3 karakter.';
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Nama',
                prefixIcon: const Icon(Icons.person_outline_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _save,
              child: const Text(
                'Simpan',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// MOTIF ULOS di header: pola belah ketupat tipis + pita merah-emas di bawah
/// ---------------------------------------------------------------------------
class _UlosPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Pola belah ketupat tipis
    final line = Paint()
      ..color = Colors.white.withOpacity(0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    const s = 36.0;
    for (double y = 0; y < size.height; y += s) {
      final shift = ((y / s).round() % 2 == 0) ? 0.0 : s / 2;
      for (double x = -s + shift; x < size.width + s; x += s) {
        final path = Path()
          ..moveTo(x + s / 2, y)
          ..lineTo(x + s, y + s / 2)
          ..lineTo(x + s / 2, y + s)
          ..lineTo(x, y + s / 2)
          ..close();
        canvas.drawPath(path, line);
      }
    }

    // Pita ulos: segitiga emas di atas pita merah
    const bandHeight = 8.0;
    const tooth = 16.0;
    final baseY = size.height - bandHeight;

    final triangles = Path();
    for (double x = 0; x < size.width; x += tooth) {
      triangles
        ..moveTo(x, baseY)
        ..lineTo(x + tooth / 2, baseY - 8)
        ..lineTo(x + tooth, baseY)
        ..close();
    }
    canvas.drawPath(triangles, Paint()..color = _gold);

    canvas.drawRect(
      Rect.fromLTWH(0, baseY, size.width, bandHeight),
      Paint()..color = _ulosRed,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}