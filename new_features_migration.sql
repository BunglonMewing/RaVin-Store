-- Migrasi ini menambahkan fitur-fitur baru: profil pengguna, penghitung unduhan, dan kolom screenshot.
-- Jalankan skrip ini di Editor SQL Supabase Anda.

-- 1. Buat tabel "profiles" untuk menyimpan data pengguna tambahan seperti nama panggilan.
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  nickname TEXT,

  CONSTRAINT nickname_length CHECK (char_length(nickname) >= 3)
);

-- Komentar untuk kejelasan
COMMENT ON TABLE public.profiles IS 'Stores public profile information for each user.';
COMMENT ON COLUMN public.profiles.id IS 'Referensi ke auth.users.id';
COMMENT ON COLUMN public.profiles.nickname IS 'Nama panggilan publik untuk pengguna.';

-- Aktifkan RLS untuk tabel profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Kebijakan untuk tabel profiles
CREATE POLICY "Public profiles are viewable by everyone." ON public.profiles
  FOR SELECT USING (true);

CREATE POLICY "Users can insert their own profile." ON public.profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update their own profile." ON public.profiles
  FOR UPDATE USING (auth.uid() = id);

-- 2. Tambahkan kolom "download_count" ke tabel "games".
ALTER TABLE public.games
ADD COLUMN download_count INT DEFAULT 0;

COMMENT ON COLUMN public.games.download_count IS 'Jumlah berapa kali game ini telah diunduh.';

-- 3. (Perbaikan) Tambahkan kolom "screenshots" ke tabel "games" jika belum ada.
-- Frontend sudah menggunakan ini, jadi kita pastikan ada di backend.
ALTER TABLE public.games
ADD COLUMN IF NOT EXISTS screenshots TEXT[];

COMMENT ON COLUMN public.games.screenshots IS 'Array URL ke gambar screenshot.';


-- 4. Buat fungsi RPC untuk menambah jumlah unduhan secara aman.
CREATE OR REPLACE FUNCTION increment_download_count(game_id_to_update BIGINT)
RETURNS VOID AS $$
BEGIN
  UPDATE public.games
  SET download_count = download_count + 1
  WHERE id = game_id_to_update;
END;
$$ LANGUAGE plpgsql;

-- Pesan akhir: Migrasi selesai. Fitur-fitur baru siap untuk diintegrasikan di frontend.
