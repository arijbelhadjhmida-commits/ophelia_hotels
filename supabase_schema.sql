-- ═══════════════════════════════════════════════════════════════════════════
-- OPHELIA HOTELS — SUPABASE SCHEMA
-- Run this entire file in: Supabase Dashboard → SQL Editor → Run
-- ═══════════════════════════════════════════════════════════════════════════

-- ─── 1. PROFILES (extends auth.users) ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS profiles (
  id            UUID    REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  cin           TEXT    UNIQUE NOT NULL,
  first_name    TEXT    NOT NULL DEFAULT 'User',
  last_name     TEXT    NOT NULL DEFAULT '',
  address       TEXT,
  date_of_birth DATE,
  is_admin      BOOLEAN NOT NULL DEFAULT FALSE,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── 2. RESERVATIONS ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS reservations (
  id                 UUID    DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id            UUID    REFERENCES auth.users(id) ON DELETE SET NULL,
  hotel_id           TEXT    NOT NULL,
  hotel_name         TEXT    NOT NULL,
  service_id         TEXT    NOT NULL,
  service_name       TEXT    NOT NULL,
  service_category   TEXT,
  reservation_type   TEXT    NOT NULL CHECK (reservation_type IN ('room','service')),
  check_in           DATE,
  check_out          DATE,
  booking_date       DATE,
  nights             INTEGER,
  adults             INTEGER,
  children           INTEGER,
  formula            TEXT,
  sport_package      BOOLEAN DEFAULT FALSE,
  spa_package        BOOLEAN DEFAULT FALSE,
  persons            INTEGER,
  total_price        INTEGER NOT NULL,
  status             TEXT    NOT NULL DEFAULT 'confirmed'
                     CHECK (status IN ('confirmed','active','completed','cancelled')),
  created_at         TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── 3. SMART ROOM STATES ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS smart_room_states (
  id              UUID    DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id         UUID    REFERENCES auth.users(id) ON DELETE SET NULL,
  reservation_id  UUID    REFERENCES reservations(id) ON DELETE SET NULL,
  room_number     TEXT    NOT NULL DEFAULT '312',
  hotel_name      TEXT,
  light_on        BOOLEAN NOT NULL DEFAULT TRUE,
  temperature     INTEGER NOT NULL DEFAULT 22 CHECK (temperature BETWEEN 16 AND 30),
  blinds_open     BOOLEAN NOT NULL DEFAULT FALSE,
  mode            TEXT    NOT NULL DEFAULT 'night' CHECK (mode IN ('night','sleep','work')),
  is_active       BOOLEAN NOT NULL DEFAULT TRUE,
  checked_in_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  checked_out_at  TIMESTAMPTZ,
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── 4. ROOM SERVICE REQUESTS ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS room_service_requests (
  id             UUID    DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id        UUID    REFERENCES auth.users(id) ON DELETE SET NULL,
  smart_room_id  UUID    REFERENCES smart_room_states(id) ON DELETE SET NULL,
  request_type   TEXT    NOT NULL CHECK (request_type IN ('cleaning','complaint','food_order')),
  subject        TEXT,
  details        TEXT,
  items          JSONB,
  status         TEXT    NOT NULL DEFAULT 'pending'
                 CHECK (status IN ('pending','in_progress','completed','cancelled')),
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── 5. AUTO-CREATE PROFILE TRIGGER ──────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO public.profiles (id, cin, first_name, last_name, address, date_of_birth, is_admin)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'cin', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'first_name', 'User'),
    COALESCE(NEW.raw_user_meta_data->>'last_name', ''),
    NEW.raw_user_meta_data->>'address',
    CASE WHEN (NEW.raw_user_meta_data->>'date_of_birth') IS NOT NULL
         THEN (NEW.raw_user_meta_data->>'date_of_birth')::DATE
         ELSE NULL END,
    FALSE
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ─── 6. DISABLE RLS (demo mode — enable with policies for production) ─────────
ALTER TABLE profiles              DISABLE ROW LEVEL SECURITY;
ALTER TABLE reservations          DISABLE ROW LEVEL SECURITY;
ALTER TABLE smart_room_states     DISABLE ROW LEVEL SECURITY;
ALTER TABLE room_service_requests DISABLE ROW LEVEL SECURITY;

-- ═══════════════════════════════════════════════════════════════════════════
-- ADMIN USER SETUP
-- Step 1: Go to Supabase Dashboard → Authentication → Users → Add User
--         Email:    admin@ophelia-hotels.com
--         Password: admin
--         ✅ Check "Auto Confirm User"
-- Step 2: Run the UPDATE below to grant admin privileges:
-- ═══════════════════════════════════════════════════════════════════════════

-- UPDATE profiles SET is_admin = TRUE, first_name = 'Admin', last_name = 'System'
-- WHERE cin = 'admin';
