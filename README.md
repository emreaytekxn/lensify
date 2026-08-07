# Kawaru ♾️

> **"Her Şeyi Dönüştüren, 0 Maliyetli"**

Kawaru (Japonca 変わる — "değişmek / dönüşmek"), sıradan bir belge tarayıcısının ötesinde, tamamen çevrimdışı (offline) ve yüksek güvenlikli bir Evrensel Medya ve Belge Dönüştürücü uygulamasıdır.

Temel felsefemiz **Sonsuzluk (Infinity)** üzerine kuruludur.

## 🚀 Temel Özellikler

1. **%100 Çevrimdışı (Offline-First):** Bütün özellikler internetsiz çalışır. Belgeleriniz ve dönüştürdüğünüz medyalar asla bir bulut sunucusuna gönderilmez.
2. **0 Maliyet:** Hiçbir ücretli bulut API'si veya sunucu maliyeti yoktur. Uygulama tamamen ücretsiz ve cihaz üstü (on-device) kütüphaneler kullanılarak geliştirilmiştir.
3. **Akıllı Kamera ve PDF Oluşturucu:** Belgeleri tarayın, otomatik kenar algılama ile düzleştirin, çok sayfalı PDF'ler oluşturun.
4. **Resimden Metne (OCR):** Taranan belgelerdeki veya fotoğraflardaki yazıları çıkartıp .txt olarak paylaşın.
5. **PDF Şifreleme:** Güvenli belgelerinizi AES-256 bit ile tamamen kilitleyin.
6. **Evrensel Medya Dönüştürücü:** Ses, video ve resim formatlarını tamamen çevrimdışı olarak birbirine dönüştürün (Örn: MP4 -> MP3, WAV -> AAC).
7. **Akıllı QR/Barkod Okuyucu:** Bağlantıları doğrudan açın veya kopyalayın.

## 🛠️ Teknolojiler

- **Mimari:** Clean Architecture (Domain, Data, Presentation)
- **State Management:** Riverpod
- **Yerel Veritabanı:** Isar Database (Hızlı ve şifreli NoSQL)
- **Tarama & Görüntü:** Camera, Image Cropper, Google ML Kit (OCR)
- **Medya Dönüştürücü:** FFmpeg (ffmpeg_kit_flutter_new)
- **Platform:** iOS & Android (Cross-platform)

## 🎨 Tasarım & UX

- "iOS Sistem Mavisi" (`#007AFF`) tonlarından ayrışan, özgün **Dönüşüm & Döngü** (İki Ok) logolu minimal tasarım.
- Tüm ağır işlemlerde kullanılan büyüleyici **Sonsuzluk (Infinity) Loading Animasyonu**.
- Liste ve ızgara görünümlerinde gerçek sayfa önizlemeleri (Thumbnails).
- Karanlık (Dark) ve Aydınlık (Light) mod tam desteği.

## 📦 Kurulum

1. Depoyu klonlayın: `git clone https://github.com/emreaytekxn/lensify.git` (Proje adı github'da lensify kalsa da, içeriği Kawaru'dur)
2. Klasöre girin: `cd SecureScanProject`
3. Bağımlılıkları yükleyin: `flutter pub get`
4. Uygulamayı çalıştırın: `flutter run`
