# BREWLY

Coffee shop management app dengan dashboard, menu, order, inventory, sales report, Google sign-in, dan dark/light mode.

## Stack
- HTML, CSS, JavaScript
- Supabase Auth untuk Google OAuth
- Supabase Postgres untuk database (schema tersedia di `supabase/schema.sql`)
- Bisa di-host sebagai static site, termasuk GitHub Pages

## Menjalankan
Buka `index.html` melalui local server, bukan file://. Contoh:

```bash
python -m http.server 5500
```

Lalu buka http://localhost:5500.

## Mengaktifkan Google Login
1. Buat project di Supabase.
2. Buka Authentication > Providers > Google, lalu aktifkan Google provider.
3. Buat OAuth Client ID di Google Cloud Console. Tambahkan callback URL Supabase yang ditampilkan di halaman provider Google.
4. Masukkan Client ID dan Client Secret ke konfigurasi Google provider di Supabase.
5. Buka Authentication > URL Configuration. Tambahkan URL localhost dan URL deployment ke Site URL / Redirect URLs.
6. Di `index.html`, ganti `YOUR_SUPABASE_PROJECT_URL` dengan Project URL dan `YOUR_SUPABASE_ANON_KEY` dengan publishable/anon key dari Supabase.

Jangan pernah memasukkan Supabase service-role key ke frontend atau repository publik.

## Database
Jalankan isi `supabase/schema.sql` melalui SQL Editor Supabase. Schema menyiapkan tabel profil, kategori, produk, pesanan, item pesanan, dan stok, beserta Row Level Security dasar.

## Catatan status
- Google OAuth baru aktif setelah konfigurasi Supabase dan Google Cloud selesai.
- Mode demo menyimpan pesanan dan stok di localStorage browser.
- Tampilan dan interaksi dashboard sudah tersedia. Sinkronisasi transaksi/menu/stok ke tabel Supabase adalah tahap integrasi berikutnya.
- GitHub Pages hanya melayani frontend statis. Supabase menjadi layanan autentikasi dan database.
