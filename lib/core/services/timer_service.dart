import 'dart:async';
import 'package:flutter/foundation.dart';

/// Level süresi sayaç servisi.
/// game_provider tarafından başlatılır/sonlandırılır.
class TimerService extends ChangeNotifier {
  Duration _remaining = Duration.zero;
  Duration get remaining => _remaining;
  bool _isActive = false;
  bool get isActive => _isActive;

  Timer? _timer;

  void setLimit(Duration limit) {
    _remaining = limit;
    notifyListeners();
  }

  void start() {
    if (_isActive) return;
    _isActive = true;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining > Duration.zero) {
        _remaining -= const Duration(seconds: 1);
        notifyListeners();
      } else {
        stop();
      }
    });
    notifyListeners();
  }

  void pause() {
    _timer?.cancel();
    _isActive = false;
    notifyListeners();
  }

  void resume() {
    if (!_isActive) {
      _isActive = true;
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_remaining > Duration.zero) {
          _remaining -= const Duration(seconds: 1);
          notifyListeners();
        } else {
          stop();
        }
      });
      notifyListeners();
    }
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _isActive = false;
    _remaining = Duration.zero;
    notifyListeners();
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
