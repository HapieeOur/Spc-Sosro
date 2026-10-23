-- ==============================================================================
-- ALUR REGISTRASI DAN PERSETUJUAN (ACC) OPERATOR OLEH ADMIN
-- Jalankan skrip ini di Supabase Dashboard -> SQL Editor
-- ==============================================================================

-- 1. Pastikan default nilai is_active adalah FALSE pada tabel profiles
ALTER TABLE public.profiles ALTER COLUMN is_active SET DEFAULT false;

-- 2. Trigger Function: Saat ada user baru mendaftar di auth.users,
--    otomatis buat profile dengan role 'operator' dan is_active = false (menunggu ACC)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (
    id,
    email,
    full_name,
    role,
    is_active
  )
  VALUES (
    new.id,
    new.email,
    COALESCE(new.raw_user_meta_data->>'full_name', split_part(new.email, '@', 1)),
    'operator',
    false -- Menunggu ACC Admin
  )
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    full_name = COALESCE(EXCLUDED.full_name, public.profiles.full_name);

  RETURN new;
END;
$$;

-- 3. Pasang trigger ke tabel auth.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 4. Fungsi RPC agar Admin bisa menyetujui (ACC) atau menonaktifkan akun
CREATE OR REPLACE FUNCTION public.admin_set_user_status(
  p_user_id uuid,
  p_is_active boolean
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Validasi role admin
  IF NOT EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role = 'admin' AND is_active = true
  ) THEN
    RAISE EXCEPTION 'Akses ditolak: Hanya administrator yang dapat mengubah status pengguna.'
      USING ERRCODE = 'SPC02';
  END IF;

  UPDATE public.profiles
  SET is_active = p_is_active,
      updated_at = now()
  WHERE id = p_user_id;

  -- Catat log aktivitas jika tabel audit tersedia
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'activity_logs') THEN
    INSERT INTO public.activity_logs (
      actor_id,
      actor_name_snapshot,
      action,
      entity_type,
      entity_id,
      description
    )
    SELECT
      auth.uid(),
      COALESCE(p.full_name, 'Admin'),
      CASE WHEN p_is_active THEN 'user_approved' ELSE 'user_disabled' END,
      'profile',
      p_user_id::text,
      CASE WHEN p_is_active THEN 'Menyetujui (ACC) akun pengguna' ELSE 'Menonaktifkan akun pengguna' END
    FROM public.profiles p
    WHERE p.id = auth.uid();
  END IF;
END;
$$;

-- ==============================================================================
-- CONTOH QUERY MANUAL (BISA DIJALANKAN DI SQL EDITOR ADMIN):
-- ==============================================================================
-- 1. Lihat daftar user yang sedang menunggu ACC:
--    SELECT id, email, full_name, role, created_at
--    FROM public.profiles
--    WHERE is_active = false
--    ORDER BY created_at DESC;

-- 2. ACC / Aktifkan akun pengguna:
--    UPDATE public.profiles SET is_active = true WHERE id = 'MASUKKAN_ID_USER_DISINI';
-- ==============================================================================
