-- =================================================================
-- MIGRATION SCRIPT: COIN SYSTEM & GAME PRICING
-- =================================================================
-- Tujuan: Menambahkan fungsionalitas sistem koin dan harga game.
-- Jalankan skrip ini di Editor SQL Supabase Anda.

-- 1. Tambahkan kolom "coins" ke tabel "profiles"
-- Kolom ini akan menyimpan saldo koin untuk setiap pengguna.
-- =================================================================
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS coins INT DEFAULT 0;

COMMENT ON COLUMN public.profiles.coins IS 'Saldo koin virtual yang dimiliki pengguna.';

-- 2. Tambahkan kolom "price" ke tabel "games"
-- Kolom ini akan menyimpan harga game dalam bentuk koin.
-- Harga 0 atau NULL berarti game tersebut gratis.
-- =================================================================
ALTER TABLE public.games
ADD COLUMN IF NOT EXISTS price INT DEFAULT 0;

COMMENT ON COLUMN public.games.price IS 'Harga game dalam koin. 0 berarti gratis.';

-- Pesan akhir: Migrasi untuk skema dasar sistem koin selesai.
-- Langkah selanjutnya adalah membuat fungsi untuk menangani transaksi.
-- Lihat langkah berikutnya dalam rencana.

-- 3. Buat fungsi RPC untuk menangani pembelian game
-- Fungsi ini akan mengurangi koin pengguna dan mencatat unduhan dalam satu transaksi.
-- Ini membuatnya aman dan mencegah manipulasi dari sisi klien.
-- =================================================================
CREATE OR REPLACE FUNCTION purchase_game(game_id_to_purchase BIGINT)
RETURNS TEXT AS $$
DECLARE
  game_price INT;
  user_coins INT;
  current_user_id UUID := auth.uid();
BEGIN
  -- 1. Dapatkan harga game dari tabel 'games'
  SELECT price INTO game_price FROM public.games WHERE id = game_id_to_purchase;

  -- Jika game tidak ditemukan, kembalikan error
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Game dengan ID % tidak ditemukan.', game_id_to_purchase;
  END IF;

  -- 2. Dapatkan saldo koin pengguna dari tabel 'profiles'
  SELECT coins INTO user_coins FROM public.profiles WHERE id = current_user_id;

  -- 3. Periksa apakah pengguna memiliki cukup koin
  IF user_coins < game_price THEN
    RAISE EXCEPTION 'Koin tidak cukup. Anda memiliki %, tetapi harga game adalah %.', user_coins, game_price;
  END IF;

  -- 4. Jika koin cukup, kurangi saldo koin pengguna
  UPDATE public.profiles
  SET coins = coins - game_price
  WHERE id = current_user_id;

  -- 5. Tambahkan jumlah unduhan game
  UPDATE public.games
  SET download_count = download_count + 1
  WHERE id = game_id_to_purchase;

  -- 6. Kembalikan pesan sukses
  RETURN 'Pembelian berhasil!';
END;
$$ LANGUAGE plpgsql;

-- Pesan akhir: Fungsi 'purchase_game' telah dibuat.
-- Anda sekarang dapat memanggil fungsi ini dari aplikasi frontend Anda.


-- =================================================================
-- ADMIN FUNCTION: ADD COINS TO USER
-- =================================================================
-- FUNGSI INI HANYA UNTUK ADMIN. JANGAN DI-EXPOSE KE PUBLIC API.
-- Cara penggunaan: Jalankan dari SQL Editor di dasbor Supabase Anda.
-- CONTOH: SELECT add_coins_to_user('user@example.com', 100);
-- =================================================================
CREATE OR REPLACE FUNCTION add_coins_to_user(user_email TEXT, amount_to_add INT)
RETURNS TEXT AS $$
DECLARE
  target_user_id UUID;
BEGIN
  -- 1. Dapatkan ID pengguna dari email mereka di tabel auth.users
  SELECT id INTO target_user_id FROM auth.users WHERE email = user_email;

  -- Jika pengguna tidak ditemukan, kembalikan error
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Pengguna dengan email % tidak ditemukan.', user_email;
  END IF;

  -- 2. Tambahkan koin ke profil pengguna
  -- Menggunakan `ON CONFLICT` untuk membuat profil jika belum ada, lalu menambahkan koin.
  INSERT INTO public.profiles (id, coins)
  VALUES (target_user_id, amount_to_add)
  ON CONFLICT (id)
  DO UPDATE SET coins = profiles.coins + amount_to_add;

  -- 3. Kembalikan pesan sukses
  RETURN 'Sukses! ' || amount_to_add || ' koin telah ditambahkan ke akun ' || user_email;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Pesan akhir: Fungsi admin 'add_coins_to_user' telah dibuat.
-- Jalankan fungsi ini dari SQL Editor untuk menambahkan koin ke pengguna.
