import 'package:flutter/foundation.dart';
import '../../shared/constants/enums.dart';
import '../../shared/constants/tonic_catalog.dart';

/// Provider for Dispensary screen state.
class DispensaryProvider extends ChangeNotifier {
  DispensaryProvider({int initialTabIndex = 0})
      : _selectedTabIndex = initialTabIndex;

  /// Current tab: tonics or botanicals
  int _selectedTabIndex;
  int get selectedTabIndex => _selectedTabIndex;

  /// Currently highlighted tonic (for preview, not selection)
  Tonic? _highlightedTonic;
  Tonic? get highlightedTonic => _highlightedTonic;

  /// Currently highlighted botanical (for preview, not selection)
  Botanical? _highlightedBotanical;
  Botanical? get highlightedBotanical => _highlightedBotanical;

  /// Whether we're viewing tonics (0) or botanicals (1)
  SoundType get currentSoundType =>
      _selectedTabIndex == 0 ? SoundType.tonic : SoundType.botanical;

  void selectTab(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  void highlightTonic(Tonic tonic) {
    _highlightedTonic = tonic;
    _highlightedBotanical = null;
    notifyListeners();
  }

  void highlightBotanical(Botanical botanical) {
    _highlightedBotanical = botanical;
    _highlightedTonic = null;
    notifyListeners();
  }

  void clearHighlight() {
    _highlightedTonic = null;
    _highlightedBotanical = null;
    notifyListeners();
  }
}
