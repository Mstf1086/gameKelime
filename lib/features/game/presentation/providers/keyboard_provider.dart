import 'package:flutter/foundation.dart';
import '../../../../core/utils/game_utils.dart';

/// Klavye UI state'ini yöneten hafif provider.
class KeyboardProvider extends ChangeNotifier {
  final Set<String> _pressedKeys = {};
  final Set<String> _disabledKeys = {};

  Set<String> get pressedKeys => Set.unmodifiable(_pressedKeys);
  Set<String> get disabledKeys => Set.unmodifiable(_disabledKeys);

  /// Tuşa basıldı olarak işaretle.
  void pressKey(String key) {
    _pressedKeys.add(key.toUpperCase());
    notifyListeners();
  }

  /// Tuşu devre dışı bırak.
  void disableKey(String key) {
    _disabledKeys.add(key.toUpperCase());
    notifyListeners();
  }

  /// Birden fazla tuşu devre dışı bırak.
  void disableKeys(Iterable<String> keys) {
    for (final key in keys) {
      _disabledKeys.add(key.toUpperCase());
    }
    notifyListeners();
  }

  /// Tuş durumlarını sıfırla.
  void reset() {
    _pressedKeys.clear();
    _disabledKeys.clear();
    notifyListeners();
  }

  /// Tuş basılı mı?
  bool isPressed(String key) => _pressedKeys.contains(key.toUpperCase());

  /// Tuş devre dışı mı?
  bool isDisabled(String key) => _disabledKeys.contains(key.toUpperCase());

  /// Tuş kullanılabilir mi?
  bool isEnabled(String key) =>
      GameUtils.isKeyInKeyboard(key) && !_disabledKeys.contains(key.toUpperCase());
}
