import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_colors.dart';
import '../features/learning/presentation/cubit/learning_cubit.dart';
import '../features/learning/presentation/cubit/sentence_cubit.dart';
import 'latihan_selesai_page.dart';

BoxDecoration _card([double radius = 16]) => BoxDecoration(
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

const _xpPerCorrect = 10;
const _gold = Color(0xFFF2B33D);
const _green = Color(0xFF2E7D32);
const _red = Color(0xFFC62828);

class KalimatPage extends StatelessWidget {
  final VoidCallback? onExit;

  const KalimatPage({super.key, this.onExit});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SentenceCubit(),
      child: _KalimatView(onExit: onExit),
    );
  }
}

class _KalimatView extends StatelessWidget {
  final VoidCallback? onExit;

  const _KalimatView({this.onExit});

  Future<bool> _confirmExit(BuildContext context) async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Keluar dari latihan?'),
        content: const Text('Progres latihan ini tidak akan disimpan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Lanjut latihan'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    return leave ?? false;
  }

  Future<void> _exit(BuildContext context) async {
    if (await _confirmExit(context) && context.mounted) {
      if (onExit != null) {
        onExit!();
      } else {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SentenceCubit, SentenceState>(
      listenWhen: (previous, current) =>
          !previous.finished && current.finished,
      listener: (context, state) {
        context.read<LearningCubit>().saveExerciseResult(
          correct: state.solved.length,
          total: state.questions.length,
          reviewedWords: state.questions.expand((q) => q.answer).toSet().length,
          xp: state.solved.length * _xpPerCorrect,
        );
      },
      child: BlocBuilder<SentenceCubit, SentenceState>(
        builder: (context, state) {
          if (state.finished) {
            final skor = state.solved.length;
            return LatihanSelesaiPage(
              skor: skor,
              totalSoal: state.questions.length,
              durasi: state.duration,
              xp: skor * _xpPerCorrect,
              kataDireview: state.questions.expand((q) => q.answer).toSet().length,
              jawaban: [
                for (var i = 0; i < state.questions.length; i++)
                  JawabanItem(
                    state.questions[i].answer.join(' '),
                    state.solved.contains(i),
                  ),
              ],
              onSelesai: () {
                if (onExit != null) {
                  onExit!();
                } else {
                  context.go('/exercise');
                }
              },
            );
          }

          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) _exit(context);
            },
            child: ColoredBox(
              color: AppColors.background,
              child: SafeArea(
                bottom: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopBar(context),
                      const SizedBox(height: 16),
                      _buildProgress(state),
                      const SizedBox(height: 20),
                      const Text(
                        'Susun kata berikut menjadi kalimat yang benar.',
                        style: TextStyle(fontSize: 14, color: AppColors.inactive),
                      ),
                      const SizedBox(height: 14),
                      _buildSentenceCard(state),
                      const SizedBox(height: 22),
                      const _Label('PILIH KATA'),
                      const SizedBox(height: 10),
                      _buildBank(context, state),
                      const SizedBox(height: 22),
                      const _Label('Kata terpilih'),
                      const SizedBox(height: 10),
                      _buildSelected(context, state),
                      const SizedBox(height: 20),
                      _buildHint(state),
                      _buildResult(state),
                      const SizedBox(height: 24),
                      _buildActions(context, state),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  // ---- bar atas ----
  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => _confirmExit(context),
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.dark),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          tooltip: 'Kembali',
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'Susun Kata Jadi Kalimat',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.dark,
            ),
          ),
        ),
      ],
    );
  }

  // ---- progres soal ----
  Widget _buildProgress(SentenceState state) {
    final progress = (state.index + 1) / state.questions.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Soal ${state.index + 1} dari ${state.questions.length}',
          style: const TextStyle(fontSize: 13, color: AppColors.inactive),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(end: progress),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: AppColors.indicator,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  // ---- kartu kalimat ----
  Widget _buildSentenceCard(SentenceState state) {
    final hasWords = state.selected.isNotEmpty;
    final sentence = state.selected.map((w) => w.text).join(' ');

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 96),
      padding: const EdgeInsets.all(18),
      decoration: _card(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              hasWords ? sentence : 'Kalimatmu akan muncul di sini',
              key: ValueKey(sentence),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: hasWords ? AppColors.primary : AppColors.dark,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Icon(Icons.south_rounded, size: 14, color: AppColors.primary),
              SizedBox(width: 6),
              Text(
                'Susun kata dari kiri ke kanan',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.inactive,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---- bank kata ----
  Widget _buildBank(BuildContext context, SentenceState state) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 44),
      child: state.bank.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Semua kata sudah dipakai.',
                style: TextStyle(fontSize: 13, color: AppColors.inactive),
              ),
            )
          : Wrap(
              spacing: 10,
              runSpacing: 10,
              children: state.bank
                  .map((w) => _WordChip(text: w.text, onTap: () => context.read<SentenceCubit>().pick(w)))
                  .toList(),
            ),
    );
  }

  // ---- kata terpilih ----
  Widget _buildSelected(BuildContext context, SentenceState state) {
    final children = <Widget>[];
    for (var i = 0; i < state.selected.length; i++) {
      final word = state.selected[i];
      if (i> 0) {
        children.add(
          const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.inactive),
        );
      }
      children.add(
        InkWell(
          onTap: () => context.read<SentenceCubit>().unpick(word),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Text(
              word.text,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 60),
      decoration: _card(16),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: state.selected.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: Text(
                    'Ketuk kata di atas untuk mulai menyusun.',
                    style: TextStyle(fontSize: 13, color: AppColors.inactive),
                  ),
                )
              : Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: children,
                ),
        ),
      ),
    );
  }

  // ---- petunjuk ----
  Widget _buildHint(SentenceState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.indicator,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_rounded, size: 20, color: _gold),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Petunjuk',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  state.current.hint,
                  style: const TextStyle(fontSize: 12.5, color: AppColors.inactive),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---- hasil pengecekan ----
  Widget _buildResult(SentenceState state) {
    final result = state.result;

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: result == null
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: (result ? _green : _red).withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(
                      result
                          ? Icons.check_circle_rounded
                          : Icons.error_outline_rounded,
                      color: result ? _green : _red,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        result
                            ? 'Benar! Kalimatmu sudah tepat.'
                            : 'Belum tepat. Coba susun ulang.',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: result ? _green : _red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // ---- tombol-tombol ----
  Widget _buildActions(BuildContext context, SentenceState state) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: context.read<SentenceCubit>().reset,
              child: const Text(
                'Reset',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.inactive,
                ),
              ),
            ),
            FilledButton(
              onPressed: state.selected.isEmpty ? null : context.read<SentenceCubit>().check,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Cek jawaban',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => _confirmExit(context),
              child: const Text(
                'Keluar',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.inactive,
                ),
              ),
            ),
            TextButton(
              onPressed: context.read<SentenceCubit>().next,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.isLast ? 'Selesai' : 'Berikutnya',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------------
/// KOMPONEN KECIL
/// ---------------------------------------------------------------------------
class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.inactive,
        letterSpacing: 0.3,
      ),
    );
  }
}

class _WordChip extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _WordChip({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.indicator,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
