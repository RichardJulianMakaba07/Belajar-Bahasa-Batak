import 'package:flutter/material.dart';
import '../main.dart';

BoxDecoration _card([double radius = 18]) => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: AppColors.border),
  boxShadow: [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.06),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ],
);

/// Satu baris jawaban untuk daftar "Lihat jawaban".
class JawabanItem {
  final String kalimat; // kalimat yang benar
  final bool benar; // apakah pengguna menjawab dengan benar
  const JawabanItem(this.kalimat, this.benar);
}

class LatihanSelesaiPage extends StatelessWidget {
  final int skor; // jumlah jawaban benar
  final int totalSoal;
  final Duration durasi;
  final int xp;
  final int kataDireview;
  final List<JawabanItem> jawaban;
  final String jenisLatihan;
  final VoidCallback onSelesai; // "Selesai & Kembali ke Latihan" + tombol back

  const LatihanSelesaiPage({
    super.key,
    required this.skor,
    required this.totalSoal,
    required this.durasi,
    required this.xp,
    required this.kataDireview,
    required this.jawaban,
    required this.onSelesai,
    this.jenisLatihan = 'susun kalimat',
  });

  String get _judul {
    final persen = totalSoal == 0 ? 0.0 : skor / totalSoal;
    if (persen >= 0.8) return 'Kamu Hebat!';
    if (persen >= 0.5) return 'Bagus, Terus Semangat!';
    return 'Ayo Coba Lagi!';
  }

  String get _waktu {
    if (durasi.inMinutes >= 1) return '${durasi.inMinutes} menit';
    return '${durasi.inSeconds} detik';
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTopBar(),
              const SizedBox(height: 20),
              _buildCheck(),
              const SizedBox(height: 22),
              Text(
                _judul,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.dark,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'Kamu sudah menyelesaikan $totalSoal soal $jenisLatihan.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: AppColors.inactive,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildScoreCard(),
              const SizedBox(height: 14),
              _buildXpBox(),
              const SizedBox(height: 14),
              _buildReviewCard(),
              const SizedBox(height: 26),
              SizedBox(
                height: 54,
                child: FilledButton(
                  onPressed: onSelesai,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Selesai & Kembali ke Latihan',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 50,
                child: OutlinedButton(
                  onPressed: () => _showJawaban(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Lihat jawaban',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---- bar atas ----
  Widget _buildTopBar() {
    return Row(
      children: [
        IconButton(
          onPressed: onSelesai,
          icon: const Icon(Icons.chevron_left_rounded, color: AppColors.dark, size: 30),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          tooltip: 'Kembali',
        ),
        const SizedBox(width: 6),
        const Text(
          'Latihan Selesai',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.dark,
          ),
        ),
      ],
    );
  }

  // ---- lingkaran centang (satu animasi masuk saat halaman muncul) ----
  Widget _buildCheck() {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.6, end: 1),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutBack,
        builder: (context, value, child) =>
            Transform.scale(scale: value, child: child),
        child: Container(
          width: 112,
          height: 112,
          decoration: const BoxDecoration(
            color: AppColors.indicator,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, size: 52, color: AppColors.primary),
        ),
      ),
    );
  }

  // ---- skor & waktu ----
  Widget _buildScoreCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _card(),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _Stat(
                label: 'Skor',
                value: '$skor / $totalSoal',
                caption: '$totalSoal soal',
              ),
            ),
            const VerticalDivider(width: 32, thickness: 1, color: AppColors.border),
            Expanded(
              child: _Stat(label: 'Waktu', value: _waktu, caption: 'selesai'),
            ),
          ],
        ),
      ),
    );
  }

  // ---- XP ----
  Widget _buildXpBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.indicator,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome_rounded, size: 22, color: AppColors.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'XP didapat',
                style: TextStyle(fontSize: 12, color: AppColors.inactive),
              ),
              const SizedBox(height: 2),
              Text(
                '+$xp XP',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.dark,
                ),
              ),
            ],
          ),
          const Spacer(),
          const Text(
            'Latihan ini sudah\ntercatat.',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.inactive,
            ),
          ),
        ],
      ),
    );
  }

  // ---- review ----
  Widget _buildReviewCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _card(16),
      child: Row(
        children: [
          const Icon(Icons.check_rounded, size: 22, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Review hari ini selesai',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$kataDireview kata baru sudah kamu review.',
                  style: const TextStyle(fontSize: 12.5, color: AppColors.inactive),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---- daftar jawaban ----
  void _showJawaban(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Jawaban',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.dark,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Kalimat yang benar untuk tiap soal.',
                style: TextStyle(fontSize: 13, color: AppColors.inactive),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: jawaban.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: AppColors.border),
                  itemBuilder: (_, i) {
                    final item = jawaban[i];
                    final color = item.benar ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 15,
                        backgroundColor: color.withOpacity(0.12),
                        child: Icon(
                          item.benar
                              ? Icons.check_rounded
                              : Icons.close_rounded,
                          size: 18,
                          color: color,
                        ),
                      ),
                      title: Text(
                        item.kalimat,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.dark,
                        ),
                      ),
                      subtitle: Text(
                        'Soal ${i + 1}: ${item.benar ? 'Benar' : 'Belum benar'}',
                        style: TextStyle(fontSize: 12, color: color),
                      ),
                    );
                  },
                ),
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
class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final String caption;

  const _Stat({
    required this.label,
    required this.value,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12.5, color: AppColors.inactive)),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.dark,
          ),
        ),
        const SizedBox(height: 2),
        Text(caption, style: const TextStyle(fontSize: 12, color: AppColors.inactive)),
      ],
    );
  }
}
