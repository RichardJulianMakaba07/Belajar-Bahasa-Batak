import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_colors.dart';
import '../features/learning/presentation/cubit/learning_cubit.dart';
import '../features/learning/presentation/cubit/quiz_cubit.dart';
import 'latihan_selesai_page.dart';

const List<QuizWord> _defaultWords = [
  QuizWord(word: 'Horas', meaning: 'Halo / salam'),
  QuizWord(word: 'Mauliate', meaning: 'Terima kasih'),
  QuizWord(word: 'Amang', meaning: 'Bapak / ayah'),
  QuizWord(word: 'Inang', meaning: 'Ibu'),
  QuizWord(word: 'Boru', meaning: 'Anak perempuan'),
  QuizWord(word: 'Bere', meaning: 'Keponakan'),
  QuizWord(word: 'Lae', meaning: 'Ipar laki-laki'),
  QuizWord(word: 'Eda', meaning: 'Ipar perempuan'),
  QuizWord(word: 'Dame', meaning: 'Damai'),
  QuizWord(word: 'Tulang', meaning: 'Paman'),
  QuizWord(word: 'Mangan', meaning: 'Makan'),
  QuizWord(word: 'Pasu-pasu', meaning: 'Berkat'),
];

/// ---------------------------------------------------------------------------
/// HALAMAN KUIS: PILIH ARTI KATA
/// ---------------------------------------------------------------------------
class Quiz1Page extends StatelessWidget {
  final List<QuizWord>? words;
  final int questionCount;
  final void Function(int score, int total)? onFinished;

  const Quiz1Page({
    super.key,
    this.words,
    this.questionCount = 10,
    this.onFinished,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuizCubit(
        words ?? _defaultWords,
        questionCount: questionCount,
      ),
      child: _QuizView(
        onFinished: onFinished,
      ),
    );
  }
}

class _QuizView extends StatelessWidget {
  static const _correctColor = Color(0xFF2E9E5B);
  static const _correctBg = Color(0xFFE8F6EE);
  static const _wrongColor = Color(0xFFD64545);
  static const _wrongBg = Color(0xFFFDECEC);

  final void Function(int score, int total)? onFinished;

  const _QuizView({this.onFinished});

  Future<bool> _confirmExit(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari kuis?'),
        content: const Text('Progres kuis ini tidak akan disimpan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Lanjut latihan'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _exit(BuildContext context) async {
    if (await _confirmExit(context) && context.mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<QuizCubit, QuizState>(
      listenWhen: (previous, current) =>
          !previous.finished && current.finished,
      listener: (context, state) {
        context.read<LearningCubit>().saveExerciseResult(
          correct: state.score,
          total: state.questions.length,
          reviewedWords: state.questions.length,
          xp: state.score * 10,
        );
        onFinished?.call(state.score, state.questions.length);
      },
      child: BlocBuilder<QuizCubit, QuizState>(
        builder: (context, state) {
          if (state.questions.isEmpty) {
            return const Scaffold(
              backgroundColor: AppColors.background,
              body: Center(
                child: Text('Belum ada kata untuk latihan.'),
              ),
            );
          }

          if (state.finished) {
            return LatihanSelesaiPage(
              skor: state.score,
              totalSoal: state.questions.length,
              durasi: state.duration,
              xp: state.score * 10,
              kataDireview: state.questions.length,
              jawaban: [
                for (var i = 0; i < state.questions.length; i++)
                  JawabanItem(
                    state.questions[i].word,
                    i < state.answers.length ? state.answers[i] : false,
                  ),
              ],
              onSelesai: () => context.go('/exercise'),
            );
          }

          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) _exit(context);
            },
            child: Scaffold(
              backgroundColor: AppColors.background,
              body: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(context),
                            const SizedBox(height: 14),
                            _buildProgress(context, state),
                            const SizedBox(height: 26),
                            const Text(
                              'Apa arti kata ini?',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: AppColors.dark,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildWordCard(state),
                            const SizedBox(height: 14),
                            ...List.generate(
                              state.current.options.length,
                              (i) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildOption(context, state, i),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildHint(context, state),
                          ],
                        ),
                      ),
                    ),
                    _buildFooterActions(context, state),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () => _exit(context),
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
          'Pilih Arti Kata',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.dark,
          ),
        ),
      ],
    );
  }

  Widget _buildProgress(BuildContext context, QuizState state) {
    final total = state.questions.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Soal ${state.index + 1} dari $total',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.inactive,
          ),
        ),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween(end: (state.index + 1) / total),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          builder: (context, value, _) => ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: const Color(0xFFDDE4EF),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWordCard(QuizState state) {
    return Container(
      width: double.infinity,
      height: 172,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              state.current.word.toUpperCase(),
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Kata yang sedang kamu review',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, QuizState state, int i) {
    const letters = ['A', 'B', 'C', 'D'];
    final isCorrect = i == state.current.correctIndex;
    final isSelected = i == state.selected;

    Color bg = Colors.white;
    Color borderColor = AppColors.border;
    Widget? trailing;

    if (state.answered) {
      if (isCorrect) {
        bg = _correctBg;
        borderColor = _correctColor;
        trailing = const Icon(
          Icons.check_circle_rounded,
          color: _correctColor,
          size: 22,
        );
      } else if (isSelected) {
        bg = _wrongBg;
        borderColor = _wrongColor;
        trailing = const Icon(
          Icons.cancel_rounded,
          color: _wrongColor,
          size: 22,
        );
      }
    }

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () => context.read<QuizCubit>().selectOption(i),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 42,
                child: Text(
                  letters[i],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  state.current.options[i],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.dark,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHint(BuildContext context, QuizState state) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.indicator,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.read<QuizCubit>().toggleHint(),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('💡', style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          'Petunjuk',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.dark,
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        turns: state.hintOpen ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.inactive,
                        ),
                      ),
                    ],
                  ),
                  if (state.hintOpen) ...[
                    const SizedBox(height: 6),
                    const Text(
                      'Pilih jawaban yang paling tepat.',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.inactive,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterActions(BuildContext context, QuizState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () => _exit(context),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.inactive,
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            ),
            child: const Text(
              'Keluar',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: state.answered
                ? () => context.read<QuizCubit>().next()
                : null,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              disabledForegroundColor: const Color(0xFFA9B6CB),
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.isLast ? 'Selesai' : 'Berikutnya',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_rounded, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
