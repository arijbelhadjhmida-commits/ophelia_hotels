import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isAdmin = false;
  bool _loading = false;
  String? _error;
  String? _activeReservationId;
  String? _activeHotelName;

  UserModel? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _isAdmin;
  bool get hasActiveStay => _user?.hasActiveStay ?? false;
  bool get loading => _loading;
  String? get error => _error;
  String? get activeReservationId => _activeReservationId;
  String? get activeHotelName => _activeHotelName;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> signIn(String cinOrEmail, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final email = cinOrEmail.contains('@')
          ? cinOrEmail.trim()
          : '${cinOrEmail.trim()}@ophelia-hotels.com';
      await SupabaseService.signIn(email, password);
      final supaUser = SupabaseService.currentUser;
      if (supaUser != null) {
        final profile = await SupabaseService.getProfile(supaUser.id);
        _user = UserModel(
          uid: supaUser.id,
          cin: profile?['cin'] ?? cinOrEmail,
          firstName: profile?['first_name'] ?? 'User',
          lastName: profile?['last_name'] ?? '',
          email: supaUser.email ?? email,
        );
        _isAdmin = profile?['is_admin'] == true;
        _loading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = _fmtError(e.toString());
    }
    _loading = false;
    notifyListeners();
    return false;
  }

  Future<bool> signUp({
    required String cin,
    required String firstName,
    required String lastName,
    required String address,
    required DateTime dob,
    required String password,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final email = '${cin.trim()}@ophelia-hotels.com';
      final dobStr = DateFormat('yyyy-MM-dd').format(dob);
      await SupabaseService.signUp(
        email: email,
        password: password,
        data: {
          'cin': cin,
          'first_name': firstName,
          'last_name': lastName,
          'address': address,
          'date_of_birth': dobStr,
        },
      );
      final supaUser = SupabaseService.currentUser;
      if (supaUser != null) {
        await SupabaseService.upsertProfile({
          'id': supaUser.id,
          'cin': cin,
          'first_name': firstName,
          'last_name': lastName,
          'address': address,
          'date_of_birth': dobStr,
          'is_admin': false,
        });
        _user = UserModel(
          uid: supaUser.id,
          cin: cin,
          firstName: firstName,
          lastName: lastName,
          email: email,
        );
        _isAdmin = false;
        _loading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = _fmtError(e.toString());
    }
    _loading = false;
    notifyListeners();
    return false;
  }

  Future<void> signOut() async {
    try {
      await SupabaseService.signOut();
    } catch (_) {}
    _user = null;
    _isAdmin = false;
    _activeReservationId = null;
    _activeHotelName = null;
    notifyListeners();
  }

  void setActiveStay(bool active, {String? reservationId, String? hotelName}) {
    if (_user != null) {
      _user = _user!.copyWith(hasActiveStay: active);
      _activeReservationId = active ? reservationId : null;
      _activeHotelName = active ? hotelName : null;
      notifyListeners();
    }
  }

  String _fmtError(String e) {
    final l = e.toLowerCase();
    if (l.contains('invalid login') || l.contains('invalid_credentials')) {
      return 'Invalid CIN or password';
    }
    if (l.contains('already registered') || l.contains('already exists') ||
        l.contains('duplicate key')) {
      return 'This CIN is already registered';
    }
    if (l.contains('password')) {
      return 'Password must be at least 5 characters';
    }
    if (l.contains('network') || l.contains('socket') ||
        l.contains('failed host')) {
      return 'Network error. Check your connection';
    }
    if (l.contains('email')) {
      return 'Email format invalid';
    }
    return e.length > 120 ? '${e.substring(0, 120)}…' : e;
  }
}
