import 'package:flutter/material.dart';
import '../main.dart';
import 'learned_words_page.dart';
import 'new_word_search_page.dart';

// Data contoh 
const _words = [
  ('HORAS', 'Halo / salam'),
  ('MAULIATE', 'Terima kasih'),
  ('AMANG', 'Ayah / panggilan untuk laki-laki'),
];

/// Kamus
class DictionaryPage extends StatelessWidget {
  const DictionaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          children: [
            const Text('Kamus',
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0F1B33))),
            const SizedBox(height: 4),
            const Text('Cari arti kata atau lihat kata yang sudah kamu pelajari.',
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5F6F8A))),
            const SizedBox(height: 16),
            const _SearchBar(hint: 'Cari kata Bahasa Batak...'),
            const SizedBox(height: 24),
            InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const LearnedWordsPage(),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Kata yang sudah dipelajari',
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
            ),
            const SizedBox(height: 12),
            for (final w in _words) ...[
              _WordCard(batak: w.$1, meaning: w.$2),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 2),
            _InfoCard(
              icon: '🔎',
              title: 'Cari kata baru',
              message: 'Belum pernah dipelajari? Cari di sini.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NewWordSearchPage(),
                  ),
                );
              },
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
            fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF5F6F8A)),
        prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF5F6F8A)),
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
              const Icon(Icons.chevron_right, size: 18, color: Color(0xFF5F6F8A)),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String icon;
  final String title;
  final String message;
  final VoidCallback? onTap;
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.message,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppColors.indicator, borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$icon $title',
                style: const TextStyle(fontSize: 12, color: Color(0xFF5F6F8A))),
            const SizedBox(height: 4),
            Text(message,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0F1B33))),
          ],
        ),
      ),
    );
  }
}

