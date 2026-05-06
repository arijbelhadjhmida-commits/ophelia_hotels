import 'dart:async';
import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class SmartRoomProvider extends ChangeNotifier {
  bool lightOn = true;
  int temperature = 22;
  bool blindsOpen = false;
  String mode = 'night';
  String? smartRoomId;

  Timer? _debounce;

  void setSmartRoomId(String? id) {
    smartRoomId = id;
  }

  void reset() {
    lightOn = true;
    temperature = 22;
    blindsOpen = false;
    mode = 'night';
    smartRoomId = null;
    notifyListeners();
  }

  void toggleLight() {
    lightOn = !lightOn;
    notifyListeners();
    _sync();
  }

  void setTemp(int t) {
    temperature = t.clamp(16, 30);
    notifyListeners();
    _sync();
  }

  void toggleBlinds() {
    blindsOpen = !blindsOpen;
    notifyListeners();
    _sync();
  }

  void setMode(String m) {
    mode = m;
    switch (m) {
      case 'night':
        lightOn = false;
        temperature = 20;
        blindsOpen = false;
        break;
      case 'sleep':
        lightOn = false;
        temperature = 19;
        blindsOpen = false;
        break;
      case 'work':
        lightOn = true;
        temperature = 22;
        blindsOpen = true;
        break;
    }
    notifyListeners();
    _sync();
  }

  void _sync() {
    if (smartRoomId == null) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        await SupabaseService.updateSmartRoom(smartRoomId!, {
          'light_on': lightOn,
          'temperature': temperature,
          'blinds_open': blindsOpen,
          'mode': mode,
        });
      } catch (_) {
        // silent - controls still work offline
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
