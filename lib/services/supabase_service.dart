import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient get _db => Supabase.instance.client;
  static User? get currentUser => _db.auth.currentUser;

  // ─── Auth ────────────────────────────────────────────────────────────────
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required Map<String, dynamic> data,
  }) async {
    return await _db.auth.signUp(email: email, password: password, data: data);
  }

  static Future<AuthResponse> signIn(String email, String password) async {
    return await _db.auth.signInWithPassword(email: email, password: password);
  }

  static Future<void> signOut() async => await _db.auth.signOut();

  // ─── Profiles ────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> getProfile(String userId) async {
    try {
      return await _db.from('profiles').select().eq('id', userId).maybeSingle();
    } catch (_) {
      return null;
    }
  }

  static Future<void> upsertProfile(Map<String, dynamic> data) async {
    await _db.from('profiles').upsert(data);
  }

  static Future<List<Map<String, dynamic>>> getAllProfiles() async {
    final res = await _db
        .from('profiles')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  // ─── Reservations ────────────────────────────────────────────────────────
  static Future<String?> createReservation(Map<String, dynamic> data) async {
    final r = await _db.from('reservations').insert(data).select('id').single();
    return r['id'] as String?;
  }

  static Future<void> updateReservationStatus(String id, String status) async {
    await _db.from('reservations').update({'status': status}).eq('id', id);
  }

  static Future<List<Map<String, dynamic>>> getAllReservations() async {
    final res = await _db
        .from('reservations')
        .select('*, profiles(first_name, last_name, cin)')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  // ─── Smart Room States ───────────────────────────────────────────────────
  static Future<String?> activateSmartRoom(Map<String, dynamic> data) async {
    final r = await _db
        .from('smart_room_states')
        .insert(data)
        .select('id')
        .single();
    return r['id'] as String?;
  }

  static Future<void> updateSmartRoom(String id, Map<String, dynamic> data) async {
    await _db.from('smart_room_states').update({
      ...data,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  static Future<void> deactivateSmartRoom(String smartRoomId) async {
    await _db
        .from('smart_room_states')
        .update({
          'is_active': false,
          'checked_out_at': DateTime.now().toIso8601String(),
        })
        .eq('id', smartRoomId);
  }

  static Future<List<Map<String, dynamic>>> getAllActiveSmartRooms() async {
    final res = await _db
        .from('smart_room_states')
        .select('*, profiles(first_name, last_name, cin)')
        .eq('is_active', true)
        .order('updated_at', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  // ─── Room Service Requests ───────────────────────────────────────────────
  static Future<void> createRoomServiceRequest(Map<String, dynamic> data) async {
    await _db.from('room_service_requests').insert(data);
  }

  static Future<List<Map<String, dynamic>>> getAllRoomServiceRequests() async {
    final res = await _db
        .from('room_service_requests')
        .select('*, profiles(first_name, last_name, cin)')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  static Future<void> updateRequestStatus(String id, String status) async {
    await _db.from('room_service_requests').update({'status': status}).eq('id', id);
  }

  // ─── Admin Stats ─────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getAdminStats() async {
    final reservations = await _db.from('reservations').select('total_price, status');
    final activeRooms = await _db.from('smart_room_states').select('id').eq('is_active', true);
    final requests = await _db.from('room_service_requests').select('id').eq('status', 'pending');
    final users = await _db.from('profiles').select('id').eq('is_admin', false);

    final reservationList = List<Map<String, dynamic>>.from(reservations);
    final totalRevenue = reservationList.fold<int>(
        0, (sum, r) => sum + ((r['total_price'] as num?)?.toInt() ?? 0));

    return {
      'total_reservations': reservationList.length,
      'active_stays': (activeRooms as List).length,
      'pending_requests': (requests as List).length,
      'total_users': (users as List).length,
      'total_revenue': totalRevenue,
    };
  }
}
