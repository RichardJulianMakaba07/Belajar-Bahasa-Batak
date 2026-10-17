import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_colors.dart';
import '../features/learning/domain/entities/batak_word.dart';
import '../features/learning/presentation/cubit/learning_cubit.dart';
import '../features/learning/presentation/cubit/sentence_cubit.dart';

class VocabularyExercisePage extends StatelessWidget {
  /// Jumlah soal tiap latihan.
  final int questionCount;

  const VocabularyExercisePage({super.key, this.questionCount = 10});

  @override
  Widget build(BuildContext context) {
    final learningState = context.watch<LearningCubit>().state;
    final words = learningState is LearningLoaded
        ? learningState.words
        : const <BatakWord>[];
    final learnedCount = learningState is LearningLoaded
        ? learningState.learnedWords.length
        : 0;
    final quizCount = min(questionCount, words.length);
    final sentenceCount = SentenceCubit.questionsFromWords(
      words,
      count: questionCount,
    ).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            _buildHeader(context),
            const SizedBox(height: 12),
            const Text(
              'Pilih cara latihan yang kamu mau.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.inactive,
              ),
            ),
            const SizedBox(height: 16),
            if (learningState is LearningLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (learningState is LearningError)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Data latihan gagal dimuat: ${learningState.message}',
                  style: const TextStyle(color: AppColors.inactive),
                ),
              ),
            _buildReviewCard(learnedCount),
            const SizedBox(height: 28),
            const Text(
              'PILIH JENIS LATIHAN',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
                color: AppColors.inactive,
              ),
            ),
            const SizedBox(height: 12),
            _ExerciseCard(
              letter: 'A',
              title: 'Pilih Arti Kata',
              description: 'Pilih arti yang benar dari kata yang ditampilkan.',
              meta: '$quizCount soal  •  Pilihan ganda',
              onTap: quizCount == 0
                  ? null
                  : () {
                      context.push('/exercise/quiz');
                    },
            ),
            const SizedBox(height: 14),
            _ExerciseCard(
              letter: 'B',
              title: 'Susun Kata Jadi Kalimat',
              description: sentenceCount == 0
                  ? 'Belum ada frasa yang cukup panjang di database untuk latihan ini.'
                  : 'Susun kata-kata dari frasa kamus menjadi urutan yang benar.',
              meta: '$sentenceCount soal  •  Susun kata',
              onTap: sentenceCount == 0
                  ? null
                  : () {
                      context.push('/exercise/sentence');
                    },
            ),
            const SizedBox(height: 28),
            _buildInfoBox(),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------ HEADER
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () => context.go('/home'),
          borderRadius: BorderRadius.circular(20),
          child: const Padding(
            padding: EdgeInsets.all(6),
            child: Icon(
              Icons.arrow_back_rounded,
              size: 28,
              color: AppColors.dark,
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'Latihan Kata',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.dark,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------ REVIEW CARD
  Widget _buildReviewCard(int learnedCount) {
    final hasLearned = learnedCount > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: AppColors.indicator,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('✨', style: TextStyle(fontSize: 16)),
              SizedBox(width: 6),
              Text(
                'Kosakata dipelajari',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.dark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            hasLearned
                ? 'Kamu sudah mempelajari $learnedCount kata dari kamus.'
                : 'Kamu belum menandai kata yang sudah dipelajari.',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Soal latihan dibuat dari kosakata yang tersedia di database.',
            style: TextStyle(
              fontSize: 13,
              height: 1.3,
              fontWeight: FontWeight.w700,
              color: AppColors.inactive,
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------- INFO BOX
  Widget _buildInfoBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
      decoration: BoxDecoration(
        color: AppColors.indicator,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('📚', style: TextStyle(fontSize: 18)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Materi kamus dan soal latihan mengikuti data Bahasa Batak '
              'yang tersedia di database.',
              style: TextStyle(
                fontSize: 13,
                height: 1.3,
                fontWeight: FontWeight.w700,
                color: AppColors.inactive,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// KARTU JENIS LATIHAN
/// ---------------------------------------------------------------------------
class _ExerciseCard extends StatelessWidget {
  final String letter;
  final String title;
  final String description;
  final String meta;
  final VoidCallback? onTap;

  const _ExerciseCard({
    required this.letter,
    required this.title,
    required this.description,
    required this.meta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 14, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 42,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      letter,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.dark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.3,
                          fontWeight: FontWeight.w700,
                          color: AppColors.inactive,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        meta,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 28, left: 6),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 24,
                    color: onTap == null
                        ? AppColors.border
                        : AppColors.inactive,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
