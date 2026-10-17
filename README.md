# Pembelajaran Bahasa Batak

Repo ini berisi kode sumber dan dokumentasi untuk proyek aplikasi **Pembelajaran Bahasa Batak**, yang dirancang untuk membantu pengguna mengenal, mempelajari, dan melestarikan kekayaan bahasa daerah suku Batak secara interaktif.

## Integrasi data kamus

Aplikasi mengambil entri kamus dari koleksi Cloud Firestore `dict_entries`.
Field utama mengikuti CSV kamus: `headword`, `definitions`, `sourceLang`,
`targetLang`, dan `deletedAt`. Entri dengan `sourceLang: ind` menempatkan kata
Bahasa Batak pada `definitions` dan arti Bahasa Indonesia pada `headword`;
entri dengan `sourceLang: btk` memakai `headword` sebagai kata Batak dan
`definitions` sebagai artinya. Entri yang memiliki `deletedAt` tidak
ditampilkan.

Katalog diambil bertahap dan disimpan dalam memori selama aplikasi berjalan.
Kamus dan kuis menggunakan kata dari katalog itu; pencarian mencocokkan kata
Batak maupun definisinya. Latihan susun kata hanya tersedia jika data kamus
memiliki frasa Bahasa Batak dengan 2–6 kata, sehingga soal tidak dibuat dari
teks contoh statis.

---

## Anggota Kelompok

Proyek ini dikembangkan oleh :

| No | Nama Lengkap | NIM |
| :--- | :--- | :--- |
| 1 | **MUHAMMAD BRITAMA PUTRA JAYA** | `2409106047` |
| 2 | **SANTOSO PARLINDUNGAN TOGATOROP** | `2409106052` |
| 3 | **HENRY MOKY** | `2409106070` |
| 4 | **RICHARD JULIAN MAKABA** | `2409106078` |
| 5 | **MUHAMMAD FATHIR RAHMAN** | `2409106075` |
