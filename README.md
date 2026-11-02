# BREWLY

Coffee shop management app dengan dashboard, menu, order, inventory, sales report, Google sign-in, dan dark/light mode.

## Stack
- HTML, CSS, JavaScript
- Supabase Auth untuk Google OAuth
- Supabase Postgres untuk data produk, transaksi, item pesanan, profil, dan stok
- GitHub Pages untuk hosting frontend

## Setup Supabase

1. Buat project baru di [Supabase](https://supabase.com/dashboard).
2. Tunggu project selesai dibuat.
3. Buka SQL Editor di dashboard Supabase.
4. Salin seluruh isi file `supabase/schema.sql`, tempel ke SQL Editor, lalu klik Run.
5. Buka Project Settings > API. Salin Project URL dan publishable key (atau anon key lama).
6. Di `index.html`, ganti:
   - `YOUR_SUPABASE_PROJECT_URL` dengan Project URL.
   - `YOUR_SUPABASE_PUBLISHABLE_OR_ANON_KEY` dengan publishable/anon key.
7. Commit perubahan tersebut ke branch `main`.

Publishable/anon key memang boleh dipakai di frontend jika Row Level Security aktif dan policy database benar. Jangan pernah menaruh service_role key di frontend atau repository publik.

## Setup Google Login

1. Di Supabase, buka Authentication > Sign In / Providers > Google. Aktifkan Google provider dan salin callback URL yang disediakan Supabase. Bentuknya seperti `https://<project-ref>.supabase.co/auth/v1/callback`.
2. Buka [Google Cloud Console](https://console.cloud.google.com/). Buat atau pilih project.
3. Masuk ke Google Auth Platform / Clients, buat OAuth Client ID dengan tipe Web application.
4. Pada Authorized JavaScript origins tambahkan:
   - `https://ahmadfas213-cell.github.io`
   - `http://localhost:5500` (untuk pengujian lokal)
5. Pada Authorized redirect URIs masukkan callback URL dari Supabase, bukan URL GitHub Pages.
6. Salin Google Client ID dan Client Secret ke pengaturan Google provider di Supabase, lalu simpan.
7. Di Supabase, buka Authentication > URL Configuration. Atur Site URL ke `https://ahmadfas213-cell.github.io/Coffe-Shop/` dan tambahkan URL itu ke Redirect URLs. Untuk lokal, tambahkan `http://localhost:5500/**`.

Jangan commit Google Client Secret ke GitHub. Secret hanya dimasukkan ke dashboard Supabase.

## Menjalankan lokal

Jalankan local server dari folder project:

```bash
python -m http.server 5500
```

Buka `http://localhost:5500`.

## Deploy GitHub Pages

Workflow tersedia di `.github/workflows/deploy.yml` dan berjalan saat ada push ke `main`. Pastikan Repository Settings > Pages > Build and deployment menggunakan GitHub Actions.

## Fitur

- Google sign-in melalui Supabase Auth setelah kredensial dikonfigurasi.
- Dashboard ringkasan omzet dan pesanan.
- Katalog menu dan quick order.
- Pencatatan transaksi dan item pesanan ke Supabase.
- Inventory dan laporan penjualan.
- Dark mode / light mode dengan preferensi tersimpan.
- Layout responsif untuk desktop dan HP.
- Mode demo memakai localStorage jika Supabase belum dikonfigurasi.

## Status integrasi

Aplikasi sudah disiapkan untuk membaca dan menulis produk, pesanan, item pesanan, serta stok ke Supabase. Login Google tetap memerlukan konfigurasi OAuth di dashboard Google dan Supabase. Jalankan schema SQL sebelum menghubungkan kredensial agar tabel dan policy tersedia.
