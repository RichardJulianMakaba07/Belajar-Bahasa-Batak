import 'dart:math';

import 'package:flutter/material.dart';
import '../main.dart';
import 'latihan_selesai_page.dart';

class QuizWord {
  final String word;
  final String meaning;

  const QuizWord({required this.word, required this.meaning});
}

/// Satu soal: kata, 4 pilihan arti, dan indeks jawaban yang benar.
class _QuizQuestion {
  final String word;
  final List<String> options;
  final int correctIndex;

  const _QuizQuestion({
    required this.word,
    required this.options,
    required this.correctIndex,
  });
}

const List<QuizWord> _dummyWords = [
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
class Quiz1Page extends StatefulWidget {
  /// Kata sumber soal. Jika null, memakai data dummy.
  final List<QuizWord>? words;

  /// Jumlah soal (default 10). Dibatasi oleh jumlah kata yang tersedia.
  final int questionCount;

  /// Dipanggil saat kuis selesai, membawa skor. Jika null, hanya dialog hasil.
  final void Function(int score, int total)? onFinished;

  const Quiz1Page({
    super.key,
    this.words,
    this.questionCount = 10,
    this.onFinished,
  });

  @override
  State<Quiz1Page> createState() => _Quiz1PageState();
}

class _Quiz1PageState extends State<Quiz1Page> {
  static const _correctColor = Color(0xFF2E9E5B);
  static const _correctBg = Color(0xFFE8F6EE);
  static const _wrongColor = Color(0xFFD64545);
  static const _wrongBg = Color(0xFFFDECEC);

  late final List<_QuizQuestion> _questions;
  int _index = 0;
  int? _selected; // indeks jawaban yang dipilih pada soal saat ini
  int _score = 0;
  final List<bool> _answers = [];
  bool _hintOpen = true;

  final Stopwatch _stopwatch = Stopwatch()..start();
  Duration _duration = Duration.zero;
  bool _finished = false;

  bool get _answered => _selected != null;
  bool get _isLast => _index == _questions.length - 1;
  _QuizQuestion get _current => _questions[_index];

  @override
  void initState() {
    super.initState();
    _questions = _buildQuestions(widget.words ?? _dummyWords);
  }

  // Membuat soal acak: 1 jawaban benar + 3 pengecoh dari arti kata lain.
  List<_QuizQuestion> _buildQuestions(List<QuizWord> words) {
    final rnd = Random();
    final pool = [...words]..shuffle(rnd);
    final picked = pool.take(min(widget.questionCount, pool.length));

    return picked.map((w) {
      final distractors = words
          .where((x) => x.meaning != w.meaning)
          .map((x) => x.meaning)
          .toSet()
          .toList()
        ..shuffle(rnd);
      final options = [w.meaning, ...distractors.take(3)]..shuffle(rnd);
      return _QuizQuestion(
        word: w.word,
        options: options,
        correctIndex: options.indexOf(w.meaning),
      );
    }).toList();
  }

  void _selectOption(int i) {
    if (_answered) return;

    setState(() {
      _selected = i;

      final correct = i == _current.correctIndex;
      _answers.add(correct);

      if (correct) _score++;
    });
  }

  void _next() {
    if (!_answered) return;
    if (_isLast) {
      _finish();
    } else {
      setState(() {
        _index++;
        _selected = null;
      });
    }
  }

  void _finish() {
    _stopwatch.stop();

    setState(() {
      _duration = _stopwatch.elapsed;
      _finished = true;
    });

    widget.onFinished?.call(_score, _questions.length);
  }

  Future<bool> _confirmExit() async {
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

  Future<void> _exit() async {
    if (await _confirmExit() && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return LatihanSelesaiPage(
        skor: _score,
        totalSoal: _questions.length,
        durasi: _duration,
        xp: _score * 10,
        kataDireview: _questions.length,
        jawaban: [
          for (var i = 0; i < _questions.length; i++)
            JawabanItem(
              _questions[i].word,
              i < _answers.length ? _answers[i] : false,
            ),
        ],
        onSelesai: () {
          Navigator.of(context).pop();
        },
      );
    }
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _exit();
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
                      _buildHeader(),
                      const SizedBox(height: 14),
                      _buildProgress(),
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
                      _buildWordCard(),
                      const SizedBox(height: 14),
                      ...List.generate(
                        _current.options.length,
                        (i) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildOption(i),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildHint(),
                    ],
                  ),
                ),
              ),
              _buildFooterActions(),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------ HEADER
  Widget _buildHeader() {
    return Row(
      children: [
        InkWell(
          onTap: _exit,
          borderRadius: BorderRadius.circular(20),
          child: const Padding(
            padding: EdgeInsets.all(6),
            child: Icon(Icons.arrow_back_rounded, size: 28, color: AppColors.dark),
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

  // ---------------------------------------------------------------- PROGRESS
  Widget _buildProgress() {
    final total = _questions.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Soal ${_index + 1} dari $total',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.inactive,
          ),
        ),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween(end: (_index + 1) / total),
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

  // --------------------------------------------------------------- WORD CARD
  Widget _buildWordCard() {
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
              _current.word.toUpperCase(),
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

  // ------------------------------------------------------------------ OPTION
  Widget _buildOption(int i) {
    const letters = ['A', 'B', 'C', 'D'];
    final isCorrect = i == _current.correctIndex;
    final isSelected = i == _selected;

    Color bg = Colors.white;
    Color borderColor = AppColors.border;
    Widget? trailing;

    if (_answered) {
      if (isCorrect) {
        bg = _correctBg;
        borderColor = _correctColor;
        trailing = const Icon(Icons.check_circle_rounded,
            color: _correctColor, size: 22);
      } else if (isSelected) {
        bg = _wrongBg;
        borderColor = _wrongColor;
        trailing =
            const Icon(Icons.cancel_rounded, color: _wrongColor, size: 22);
      }
    }

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () => _selectOption(i),
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
                  _current.options[i],
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

  // -------------------------------------------------------------------- HINT
  Widget _buildHint() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.indicator,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _hintOpen = !_hintOpen),
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
                        turns: _hintOpen ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.inactive,
                        ),
                      ),
                    ],
                  ),
                  if (_hintOpen) ...[
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

  // ---------------------------------------------------------- FOOTER ACTIONS
  Widget _buildFooterActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: _exit,
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
            onPressed: _answered ? _next : null,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              disabledForegroundColor: const Color(0xFFA9B6CB),
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isLast ? 'Selesai' : 'Berikutnya',
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