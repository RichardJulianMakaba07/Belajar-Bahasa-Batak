import 'package:flutter/material.dart';
import '../main.dart';

class BatakWord {
  final String word;
  final String meaning;
  final bool isLearned;

  const BatakWord({
    required this.word,
    required this.meaning,
    this.isLearned = false,
  });
}

const List<BatakWord> _dummyWords = [
  BatakWord(word: 'Horas', meaning: 'Halo / salam'),
  BatakWord(word: 'Mauliate', meaning: 'Terima kasih'),
  BatakWord(word: 'Amang', meaning: 'Bapak / ayah'),
  BatakWord(word: 'Inang', meaning: 'Ibu'),
  BatakWord(word: 'Boru', meaning: 'Anak perempuan'),
  BatakWord(word: 'Bere', meaning: 'Keponakan'),
  BatakWord(word: 'Lae', meaning: 'Sapaan untuk ipar laki-laki'),
  // Contoh kata yang sudah dipelajari -> tidak muncul di halaman ini.
  BatakWord(word: 'Dame', meaning: 'Damai', isLearned: true),
];

const List<String> _exampleWords = ['Horas', 'Mauliate', 'Amang', 'Inang'];

/// ---------------------------------------------------------------------------
/// HALAMAN CARI KATA BARU
/// ---------------------------------------------------------------------------
class NewWordSearchPage extends StatefulWidget {

  /// Dipanggil saat user menekan hasil pencarian (mis. buka detail kata).
  final ValueChanged<BatakWord>? onWordTap;

  const NewWordSearchPage({super.key, this.onWordTap});

  @override
  State<NewWordSearchPage> createState() => _NewWordSearchPageState();
}

class _NewWordSearchPageState extends State<NewWordSearchPage> {

  final TextEditingController _controller = TextEditingController();
  List<BatakWord> _results = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Hanya kata yang BELUM dipelajari yang ditampilkan.
  void _search(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _results = [];
      } else {
        _results = _dummyWords
            .where((w) => !w.isLearned && w.word.toLowerCase().contains(q))
            .toList();
      }
    });
  }

  void _selectExample(String word) {
    _controller.text = word;
    _controller.selection = TextSelection.collapsed(offset: word.length);
    _search(word);
  }

  @override
  Widget build(BuildContext context) {
    final hasQuery = _controller.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              _buildHeader(),
              const SizedBox(height: 14),
              const Text(
                'Temukan arti kata Bahasa Batak yang ingin kamu tahu.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                  color: AppColors.inactive,
                ),
              ),
              const SizedBox(height: 12),
              _buildSearchField(),
              const SizedBox(height: 28),
              _buildSectionLabel('CONTOH KATA'),
              const SizedBox(height: 12),
              _buildExampleChips(),
              if (hasQuery) ...[
                const SizedBox(height: 28),
                _buildSectionLabel('HASIL PENCARIAN'),
                const SizedBox(height: 12),
                if (_results.isEmpty)
                  _buildEmptyResult()
                else
                  ..._results.map(_buildResultCard),
              ],
              const SizedBox(height: 20),
              _buildTipBox(),
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
          onTap: () => Navigator.of(context).maybePop(),
          borderRadius: BorderRadius.circular(20),
          child: const Padding(
            padding: EdgeInsets.all(6),
            child: Icon(Icons.arrow_back_rounded, size: 28, color: AppColors.dark),
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'Cari Kata Baru',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.dark,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------ SEARCH FIELD
  Widget _buildSearchField() {
    return TextField(
      controller: _controller,
      onChanged: _search,
      textInputAction: TextInputAction.search,
      onSubmitted: _search,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.dark,
      ),
      decoration: InputDecoration(
        hintText: 'Ketik kata, misalnya: horas',
        hintStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.inactive,
        ),
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.dark, size: 20),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.inactive),
                onPressed: () {
                  _controller.clear();
                  _search('');
                },
              ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  // ----------------------------------------------------------- SECTION LABEL
  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.4,
        color: AppColors.inactive,
      ),
    );
  }

  // ----------------------------------------------------------- EXAMPLE CHIPS
  Widget _buildExampleChips() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 16,
      childAspectRatio: 3.6,
      children: _exampleWords.map((word) {
        return Material(
          color: AppColors.indicator,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: () => _selectExample(word),
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  word.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ------------------------------------------------------------ RESULT CARD
  Widget _buildResultCard(BatakWord word) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onWordTap?.call(word),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        word.word.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        word.meaning,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.dark,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Belum dipelajari',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.inactive,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    size: 26, color: AppColors.inactive),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------- EMPTY RESULT
  Widget _buildEmptyResult() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: const Text(
        'Kata tidak ditemukan di daftar kata yang belum dipelajari.',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.inactive,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- TIP BOX
  Widget _buildTipBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.indicator,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Belum menemukan kata?',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.dark,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Coba gunakan ejaan yang lebih singkat atau berbeda.',
            style: TextStyle(
              fontSize: 14,
              height: 1.3,
              fontWeight: FontWeight.w800,
              color: AppColors.dark,
            ),
          ),
        ],
      ),
    );
  }
}