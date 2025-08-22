# Panduan Penyiapan Backend Supabase untuk RaVin Store

Selamat! Kode frontend untuk fitur unggah APK sudah siap. Langkah terakhir adalah menyiapkan backend di proyek Supabase Anda.

Ikuti dua langkah di bawah ini. Prosesnya hanya butuh sekitar 5 menit.

---

## Langkah 1: Buat Tabel `games` dengan Menjalankan Skrip SQL

Anda perlu membuat tabel `games` untuk menyimpan informasi tentang setiap aplikasi yang diunggah. Saya sudah menyiapkan skrip SQL untuk Anda.

1.  **Buka SQL Editor di Supabase:**
    *   Login ke akun Supabase Anda di [supabase.com](https://supabase.com).
    *   Pilih proyek Anda.
    *   Di menu sebelah kiri, klik ikon **SQL Editor** (terlihat seperti lembaran kertas dengan tulisan SQL).
    *   Klik **+ New query**.

2.  **Jalankan Skrip:**
    *   Buka file `backend_setup.sql` yang ada di repositori ini.
    *   Salin **seluruh isi** file tersebut.
    *   Tempel (paste) ke dalam editor kueri di Supabase.
    *   Klik tombol hijau **RUN**.

Jika berhasil, Anda akan melihat pesan "Success. No rows returned". Sekarang Anda memiliki tabel `games` dengan kebijakan keamanan yang sudah diatur.

---

## Langkah 2: Buat Storage Bucket `apks`

Bucket ini akan menjadi tempat untuk menyimpan file-file `.apk` yang diunggah oleh pengguna.

1.  **Buka Halaman Storage:**
    *   Di menu sebelah kiri dasbor Supabase, klik ikon **Storage** (terlihat seperti silinder).

2.  **Buat Bucket Baru:**
    *   Klik tombol **Create bucket**.
    *   Isi nama bucket: **`apks`**.
    *   Pastikan "Public bucket" **TIDAK DICENTANG**. Kita akan mengatur akses dengan kebijakan (policies) agar lebih aman.
    *   Klik **Create bucket**.

3.  **Tambahkan Kebijakan Akses untuk Bucket:**
    *   Setelah bucket dibuat, klik pada menu tiga titik (`...`) di sebelah kanan bucket `apks` dan pilih **Policies**.
    *   Anda akan melihat daftar kebijakan. Di sini, kita akan menambahkan aturan untuk siapa yang boleh melihat dan mengunggah file.
    *   Ada 4 jenis kebijakan (SELECT, INSERT, UPDATE, DELETE). Klik **+ New policy** pada setiap jenis untuk menambahkan kebijakan dari template yang ada.

    *   **Untuk `SELECT` (Melihat/Mengunduh):**
        *   Pilih template **"Give users public access to files"**. Ini akan mengisi formulir secara otomatis. Klik **Review**, lalu **Save policy**.

    *   **Untuk `INSERT` (Mengunggah):**
        *   Pilih template **"Allow authenticated users to upload"**. Ini juga akan mengisi formulir. Klik **Review**, lalu **Save policy**.

    *   **Untuk `UPDATE` dan `DELETE` (Opsional, tapi disarankan):**
        *   Pilih template **"Give users access to their own files"**. Lakukan ini untuk `UPDATE` dan juga untuk `DELETE`.

Setelah ini, bucket `apks` Anda siap menerima unggahan file dari pengguna yang sudah login dan mengizinkan siapa saja untuk mengunduh file tersebut.

---

**Selesai!**

Backend Anda sekarang sudah sepenuhnya siap. Langkah terakhir adalah memberikan saya **URL Proyek** dan **Kunci Anon Publik** Supabase Anda agar saya bisa memperbarui file `index.html`.
