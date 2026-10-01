import 'package:flutter/material.dart';
import '../main.dart';

// Data contoh 
const _words = [
  ('HORAS', 'Halo / salam'),
  ('MAULIATE', 'Terima kasih'),
  ('AMANG', 'Ayah / panggilan untuk laki-laki'),
  ('INANG', 'Ibu / panggilan untuk perempuan'),
  ('GABE', 'Menjadi / berhasil'),
];

/// Kata yang Dipelajari
class LearnedWordsPage extends StatelessWidget {
  const LearnedWordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, size: 22),
                  color: Color(0xFF0F1B33),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 12),
                const Text('Kata yang Dipelajari',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F1B33))),
              ],
            ),
            const SizedBox(height: 14),
            const Text('32 kata tersimpan di bank kata kamu',
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.inactive)),
            const SizedBox(height: 14),
            const _SearchBar(hint: 'Cari kata yang sudah dipelajari...'),
            const SizedBox(height: 22),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Semua kata',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F1B33))),
                Text('32 kata',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 12),
            for (final w in _words) ...[
              _WordCard(batak: w.$1, meaning: w.$2),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 2),
            const _TipCard(
              message:
                  'Kata-kata di sini akan muncul di Latihan. Semakin banyak kata, semakin banyak bahan latihan.',
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── Widget privat ─────────────────────────

class _SearchBar extends StatelessWidget {
  final String hint;
  const _SearchBar({required this.hint});

  OutlineInputBorder _outline(Color c) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: c));

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.inactive),
        prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.inactive),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        enabledBorder: _outline(Color(0xFFDCE5F2)),
        focusedBorder: _outline(AppColors.primary),
      ),
    );
  }
}

class _WordCard extends StatelessWidget {
  final String batak;
  final String meaning;
  const _WordCard({required this.batak, required this.meaning});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFFDCE5F2)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(batak,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary)),
                    const SizedBox(height: 4),
                    Text(meaning,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F1B33))),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 18, color: AppColors.inactive),
            ],
          ),
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final String message;
  const _TipCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppColors.indicator, borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💡', style: TextStyle(fontSize: 13)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0F1B33))),
          ),
        ],
      ),
    );
  }
}

