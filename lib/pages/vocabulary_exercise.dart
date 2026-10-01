import 'package:flutter/material.dart';
import 'package:pembelajaran_bahasa_batak/main.dart';
import 'package:pembelajaran_bahasa_batak/pages/kalimat_page.dart';
import 'package:pembelajaran_bahasa_batak/pages/quiz1_page.dart';

class VocabularyExercisePage extends StatelessWidget {
  /// Jumlah kata baru yang dipelajari user hari ini.
  final int learnedToday;

  /// Target kata baru per hari.
  final int dailyTarget;

  /// Jumlah soal tiap latihan.
  final int questionCount;


  const VocabularyExercisePage({
    super.key,
    this.learnedToday = 10,
    this.dailyTarget = 10,
    this.questionCount = 10,
  });

  @override
  Widget build(BuildContext context) {
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
            _buildReviewCard(),
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
              meta: '$questionCount soal  •  Pilihan ganda',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Quiz1Page(),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
            _ExerciseCard(
              letter: 'B',
              title: 'Susun Kata Jadi Kalimat',
              description:
                  'Susun kata-kata acak menjadi kalimat yang benar.',
              meta: '$questionCount soal  •  Susun kata',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const KalimatPage(),
                  ),
                );
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
          onTap: () => Navigator.of(context).maybePop(),
          borderRadius: BorderRadius.circular(20),
          child: const Padding(
            padding: EdgeInsets.all(6),
            child: Icon(Icons.arrow_back_rounded, size: 28, color: AppColors.dark),
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
  Widget _buildReviewCard() {
    final hasLearned = learnedToday > 0;

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
                'Review hari ini',
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
                ? 'Kamu belajar $learnedToday kata baru hari ini.'
                : 'Kamu belum belajar kata baru hari ini.',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            hasLearned
                ? 'Latihan berikut akan mereview $learnedToday kata baru itu.'
                : 'Latihan berikut akan mereview kata dari hari sebelumnya.',
            style: const TextStyle(
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📚', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Belum belajar $dailyTarget kata hari ini?',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Kita akan review kata dari hari sebelumnya.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.inactive,
                  ),
                ),
              ],
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
  final VoidCallback onTap;

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
                const Padding(
                  padding: EdgeInsets.only(top: 28, left: 6),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 24,
                    color: AppColors.inactive,
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