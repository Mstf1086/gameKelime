import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/game_utils.dart';
import '../providers/game_provider.dart';

/// Cihazın sistem klavyesi ile harf tahmini yapılan giriş alanı.
///
/// Ekranda özel bir klavye göstermez; kullanıcı cihazın kendi
/// klavyesiyle yazar. Her girilen karakter anında tahmin olarak
/// işlenir ve alan temizlenir. Türkçe olmayan klavyelerde
/// g→ğ, c→ç gibi köprüler `GameUtils.normalizeLetterForAnswer`
/// ile kabul edilir; kutularda doğrusu (Türkçe harf) gösterilir.
class SystemKeyboardInput extends StatefulWidget {
  const SystemKeyboardInput({super.key});

  @override
  State<SystemKeyboardInput> createState() => _SystemKeyboardInputState();
}

class _SystemKeyboardInputState extends State<SystemKeyboardInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _controller,
        enabled: game.level != null && !game.isGameOver,
        autocorrect: false,
        enableSuggestions: false,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          hintText: 'Harf gir (ağac için yaz: agac)',
          prefixIcon: const Icon(Icons.keyboard),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onChanged: _handleInput,
      ),
    );
  }

  void _handleInput(String value) {
    if (value.isEmpty) return;
    final game = context.read<GameProvider>();
    final answer = game.level?.answer ?? '';
    for (final raw in value.split('')) {
      if (game.isGameOver) break;
      final normalized = GameUtils.normalizeLetterForAnswer(raw, answer);
      if (normalized != null) {
        game.guessLetter(normalized);
      }
    }
    // Alanı temizle ki sonraki harf de tahmin olarak işlensin.
    _controller.clear();
  }
}