import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_colors.dart';
import '../features/learning/presentation/cubit/learning_cubit.dart';

/// Kata yang Dipelajari
class LearnedWordsPage extends StatefulWidget {
  const LearnedWordsPage({super.key});

  @override
  State<LearnedWordsPage> createState() => _LearnedWordsPageState();
}

class _LearnedWordsPageState extends State<LearnedWordsPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<LearningCubit>().state;
    final learnedWords =
        state is LearningLoaded ? state.learnedWords : const [];
    final query = _searchController.text.trim().toLowerCase();
    final visibleWords = learnedWords
        .where((word) =>
            word.word.toLowerCase().contains(query) ||
            word.meaning.toLowerCase().contains(query))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back, size: 22),
                  color: const Color(0xFF0F1B33),
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
            Text(
              '${state is LearningLoaded ? state.learnedWords.length : 0} kata tersimpan di bank kata kamu',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.inactive),
            ),
            const SizedBox(height: 14),
            _SearchBar(
              hint: 'Cari kata yang sudah dipelajari...',
              controller: _searchController,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Semua kata',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F1B33))),
                Text(
                          '${state is LearningLoaded ? visibleWords.length : 0} kata',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (state is LearningLoading)
              const Center(child: CircularProgressIndicator())
            else if (state is LearningError)
              Text('Kata tersimpan gagal dimuat: ${state.message}')
            else if (visibleWords.isEmpty)
              Text(
                query.isEmpty
                    ? 'Belum ada kata yang dipelajari.'
                    : 'Tidak ada kata tersimpan yang cocok dengan pencarian.',
                style: const TextStyle(color: AppColors.inactive),
              )
            else
              for (final w in visibleWords) ...[
                _WordCard(
                  batak: w.word.toUpperCase(),
                  meaning: w.meaning,
                ),
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
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({
    required this.hint,
    required this.controller,
    required this.onChanged,
  });

  OutlineInputBorder _outline(Color c) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: c));

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
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