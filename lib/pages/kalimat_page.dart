import 'package:flutter/material.dart';
import '../main.dart';

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

const _defaultHint = 'Pikirkan urutan kalimat yang paling natural.';

/// XP yang didapat untuk setiap jawaban benar.
const _xpPerCorrect = 10;

class _Question {
  final List<String> words; // semua kata yang tampil (boleh ada pengecoh)
  final List<String> answer; // urutan kata yang benar
  final String hint;

  const _Question({
    required this.words,
    required this.answer,
    this.hint = _defaultHint,
  });
}

const List<_Question> _questions = [
  _Question(
    words: ['aku', 'mauliate', 'hamu', 'HORAS', 'ma'],
    answer: ['HORAS', 'mauliate', 'ma', 'hamu'],
  ),
  _Question(
    words: ['hita', 'ahu', 'ma', 'mangan'],
    answer: ['mangan', 'ma', 'hita'],
  ),
  _Question(
    words: ['tu', 'dang', 'jabu', 'ahu', 'mulak'],
    answer: ['mulak', 'ahu', 'tu', 'jabu'],
  ),
  _Question(
    words: ['Batak', 'hamu', 'halak', 'ahu'],
    answer: ['ahu', 'halak', 'Batak'],
  ),
  _Question(words: ['huboto', 'mauliate', 'dang'], answer: ['dang', 'huboto']),
];

class _Word {
  final int id; // urutan asli di bank kata
  final String text;
  const _Word(this.id, this.text);
}

class KalimatPage extends StatefulWidget {
  final VoidCallback? onExit;

  const KalimatPage({super.key, this.onExit});

  @override
  State<KalimatPage> createState() => _KalimatPageState();
}

class _KalimatPageState extends State<KalimatPage> {
  int _index = 0;
  late List<_Word> _bank; // kata yang belum dipilih
  late List<_Word> _selected; // kata yang sudah dipilih (berurutan)
  bool? _result; // null = belum dicek, true = benar, false = salah
  final Set<int> _solved = {}; // soal yang sudah dijawab benar
  final Stopwatch _stopwatch = Stopwatch()..start(); // hitung waktu latihan
  Duration _duration = Duration.zero;
  bool _finished = false; // true = tampilkan halaman Latihan Selesai

  _Question get _q => _questions[_index];
  bool get _isLast => _index == _questions.length - 1;

  static const _gold = Color(0xFFF2B33D);
  static const _green = Color(0xFF2E7D32);
  static const _red = Color(0xFFC62828);

  @override
  void initState() {
    super.initState();
    _loadQuestion();
  }

  // -------------------------------------------------------------------------
  // LOGIKA
  // -------------------------------------------------------------------------
  void _loadQuestion() {
    _bank = [for (var i = 0; i < _q.words.length; i++) _Word(i, _q.words[i])];
    _selected = [];
    _result = null;
  }

  void _pick(_Word word) {
    setState(() {
      _bank.remove(word);
      _selected.add(word);
      _result = null;
    });
  }

  void _unpick(_Word word) {
    setState(() {
      _selected.remove(word);
      _bank.add(word);
      _bank.sort((a, b) => a.id.compareTo(b.id));
      _result = null;
    });
  }

  void _reset() => setState(_loadQuestion);

  void _check() {
    final user = _selected.map((w) => w.text).join(' ');
    final correct = _q.answer.join(' ');
    final ok = user == correct;
    setState(() {
      _result = ok;
      if (ok) _solved.add(_index);
    });
  }

  void _next() {
    if (_isLast) {
      _finish();
      return;
    }
    setState(() {
      _index++;
      _loadQuestion();
    });
  }

  void _exit() {
    if (widget.onExit != null) {
      widget.onExit!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  Future<void> _confirmExit() async {
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
    if (leave == true && mounted) _exit();
  }

  void _finish() {
    _stopwatch.stop();
    setState(() {
      _duration = _stopwatch.elapsed;
      _finished = true; // langsung pindah ke halaman Latihan Selesai
    });
  }

  void _restart() {
    setState(() {
      _solved.clear();
      _index = 0;
      _loadQuestion();
      _finished = false;
      _stopwatch
        ..reset()
        ..start();
    });
  }

  // Tombol "Selesai & Kembali ke Latihan" di halaman hasil.
  void _backToLatihan() {
    _restart();
    widget.onExit?.call();
  }

  // -------------------------------------------------------------------------
  // BUILD
  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    if (_finished) {
      final skor = _solved.length;
      return LatihanSelesaiPage(
        skor: skor,
        totalSoal: _questions.length,
        durasi: _duration,
        xp: skor * _xpPerCorrect,
        kataDireview: _questions.expand((q) => q.answer).toSet().length,
        jawaban: [
          for (var i = 0; i < _questions.length; i++)
            JawabanItem(_questions[i].answer.join(' '), _solved.contains(i)),
        ],
        onSelesai: _backToLatihan,
      );
    }

    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(),
              const SizedBox(height: 16),
              _buildProgress(),
              const SizedBox(height: 20),
              const Text(
                'Susun kata berikut menjadi kalimat yang benar.',
                style: TextStyle(fontSize: 14, color: AppColors.inactive),
              ),
              const SizedBox(height: 14),
              _buildSentenceCard(),
              const SizedBox(height: 22),
              const _Label('PILIH KATA'),
              const SizedBox(height: 10),
              _buildBank(),
              const SizedBox(height: 22),
              const _Label('Kata terpilih'),
              const SizedBox(height: 10),
              _buildSelected(),
              const SizedBox(height: 20),
              _buildHint(),
              _buildResult(),
              const SizedBox(height: 24),
              _buildActions(),
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
          onPressed: _confirmExit,
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
  Widget _buildProgress() {
    final progress = (_index + 1) / _questions.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Soal ${_index + 1} dari ${_questions.length}',
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
  Widget _buildSentenceCard() {
    final hasWords = _selected.isNotEmpty;
    final sentence = _selected.map((w) => w.text).join(' ');

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
  Widget _buildBank() {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 44),
      child: _bank.isEmpty
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
              children: _bank
                  .map((w) => _WordChip(text: w.text, onTap: () => _pick(w)))
                  .toList(),
            ),
    );
  }

  // ---- kata terpilih ----
  Widget _buildSelected() {
    final children = <Widget>[];
    for (var i = 0; i < _selected.length; i++) {
      final word = _selected[i];
      if (i > 0) {
        children.add(
          const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.inactive),
        );
      }
      children.add(
        InkWell(
          onTap: () => _unpick(word),
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
          child: _selected.isEmpty
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
  Widget _buildHint() {
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
                  _q.hint,
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
  Widget _buildResult() {
    final result = _result;

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
  Widget _buildActions() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: _reset,
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
              onPressed: _selected.isEmpty ? null : _check,
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
              onPressed: _confirmExit,
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
              onPressed: _next,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isLast ? 'Selesai' : 'Berikutnya',
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
