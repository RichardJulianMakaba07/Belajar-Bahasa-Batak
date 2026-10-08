import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_colors.dart';
import '../features/learning/domain/entities/learning_progress.dart';
import '../features/learning/presentation/cubit/learning_cubit.dart';

/// Page 1 — Beranda
class HomePage extends StatelessWidget {
  final VoidCallback? onLearnWord;
  final VoidCallback? onStartPractice;

  const HomePage({
    super.key,
    this.onLearnWord,
    this.onStartPractice,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<LearningCubit>().state;
    final progress = state is LearningLoaded
        ? state.progress
        : const LearningProgress.initial();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          children: [
            const Text('HORAS, MARULI 👋',
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0F1B33))),
            const SizedBox(height: 4),
            const Text('Belajar arti kata Bahasa Batak.',
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.inactive)),
            const SizedBox(height: 16),
            _SearchBar(
              hint: 'Cari kata Bahasa Batak...',
              onSubmitted: (query) {
                final q = query.trim();

                if (q.isNotEmpty) {
                  context.push(
                    '/dictionary/new?q=${Uri.encodeQueryComponent(q)}',
                  );
                }
              },
            ),
            const SizedBox(height: 24),
            const _SectionTitle('Kata hari ini'),
            const SizedBox(height: 12),
            // Kartu kata hari ini
            Material(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: onLearnWord,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('HORAS',
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                      SizedBox(height: 6),
                      Text('Halo / salam',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                      SizedBox(height: 10),
                      Text('Pelajari kata →',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const _SectionTitle('Perkembanganmu'),
            const SizedBox(height: 12),
            // Kartu progres
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Color(0xFFDCE5F2)),
              ),
              child: Row(
                children: [
                  Expanded(child: _Stat(value: '${progress.learnedCount}', label: 'kata dipelajari')),
                  Expanded(child: _Stat(value: '${progress.streakDays} 🔥', label: 'hari streak')),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onStartPractice,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Mulai pelajari arti kata →',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 16),
            const _InfoCard(
              icon: '💡',
              title: 'Tips',
              message: 'Coba hafalkan 5 kata baru hari ini.',
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── Widget privat ─────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F1B33)));
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.primary)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onSubmitted;

  const _SearchBar({
    required this.hint,
    this.onSubmitted,
  });

  OutlineInputBorder _outline(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c),
      );

  @override
  Widget build(BuildContext context) {
    return TextField(
      onSubmitted: onSubmitted,
      textInputAction: TextInputAction.search,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.inactive,
        ),
        prefixIcon: const Icon(
          Icons.search,
          size: 18,
          color: AppColors.inactive,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        enabledBorder: _outline(const Color(0xFFDCE5F2)),
        focusedBorder: _outline(AppColors.primary),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String icon;
  final String title;
  final String message;
  const _InfoCard(
      {required this.icon, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppColors.indicator, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$icon $title',
              style: const TextStyle(fontSize: 12, color: AppColors.inactive)),
          const SizedBox(height: 4),
          Text(message,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0F1B33))),
        ],
      ),
    );
  }
}