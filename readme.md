# CoBuy v4 — WAMP Kurulumu

## Kurulum

1. ZIP içindeki `CoBuy` klasörünü `C:\wamp64\www\CoBuy` konumuna çıkarın.
2. WAMP Server'da Apache ve MySQL servislerini başlatın.
3. Yeni kurulumda phpMyAdmin üzerinden `database.sql` dosyasını içe aktarın.
4. Önceki v3 veritabanını koruyacaksanız yalnızca `migration.sql` dosyasını içe aktarın.
5. Chrome'da `http://localhost/CoBuy/frontend/` adresini açın.
6. Eski arayüz görünürse `Ctrl + F5` yapın.

## Demo hesapları

- Kullanıcı: `user@cobuy.local` / `123456`
- Satıcı: `seller@cobuy.local` / `123456`
- Yönetici: `admin@cobuy.local` / `123456`

## v4 düzeltmeleri

- “Talebimi Sepete Ekle” işlemi sayısal veriler açıkça dönüştürülerek ve hata mesajı gösterilerek düzeltildi.
- Mesaj gönderme işlemi ayrı konuşma sayfasında çalışır; geçmiş kişiler sol tarafta listelenir.
- Firma logosu isteğe bağlıdır. Ürün fotoğrafı, ürün ilanı oluşturulurken zorunlu olarak eklenir.
- Ürün kartları ürün detayına açılır; detay sayfasından ortak sepete veya mağaza ilanına geçilir.
- Şikâyet için ayrı sayfa eklendi.
- Aynı kullanıcı aynı kişiyi en fazla 3 kez şikâyet edebilir.
- 10 aktif şikâyette hesap otomatik askıya alınır.
- Açık şikâyet geri çekilebilir veya “telafi edildi” açıklamasıyla olumlu kapatılabilir.
- Ana sayfa güven sayfasından ayrıldı ve platformu anlatan rehber yapısına dönüştürüldü.
- Profil fotoğrafı, kullanıcı adı, şehir, ilçe ve hakkımda alanı düzenlenebilir.
- Ortak sepet hedefi kişi değil toplam ürün adedi olarak gösterilir; tek kişi hedefin tamamını talep edebilir.

## Fotoğraf klasörleri

- Ürünler: `uploads/products`
- Profil: `uploads/profiles`
- Firma logosu: `uploads/seller-logos`
- Dükkan: `uploads/seller-shops`
- Ev arkadaşı ilanları: `uploads/roommates`

Fotoğraf üst sınırı 5 MB'dır. PHP kurulumunda `file_put_contents` ve klasör yazma izinlerinin açık olması gerekir.
