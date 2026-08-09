# Kawaru — Antigravity Çalışma Alanı Rehberi

> Bu dosya `.agents/AGENTS.md` yoluna kaydedilmelidir (mevcut dosyanın yerine).
> Antigravity her oturum başında bu dosyayı okur ve oturumlar arası hafızası
> sıfırlandığı için, projenin "hafızası" burasıdır. Kısa/belirsiz bırakma —
> agent burada yazmayan hiçbir şeyi bilmiyor kabul et.

## 0. Mevcut Kural (korunuyor)

Herhangi bir değişiklik, özellik ekleme veya hata giderme yapıldığında, yapılan
tüm değişiklikleri otomatik olarak commit edip `origin main`'e pushla:

```bash
git add .
git commit -m "Mesaj: Yapılan işlemin kısa bir özeti"
git push
```

Bu kural her görev tamamlandığında çalıştırılmalı. Aşağıdaki her madde
tamamlandığında da bu adım uygulanır.

---

## 1. Kimlik: Lensify → Kawaru Rebrand

Uygulama **"Kawaru"** olarak yeniden adlandırılıyor (Japonca 変わる —
"değişmek / dönüşmek" — isim, uygulamanın "her şeyi dönüştürür" vizyonuyla
doğrudan örtüşüyor; bunu tanıtım metinlerinde kullan).

Rebrand şu anda **eksik/karışık** durumda — kod hâlâ üç farklı eski isim
taşıyor: Android paket adı `com.securescan.securescan`, ana widget sınıfı
`SecureScanApp`, pubspec/README ise `Lensify`. Hepsini tek isme indir:

- [ ] `pubspec.yaml`: `name: kawaru`, `description` güncellensin
- [ ] `lib/main.dart`: `SecureScanApp` → `KawaruApp`, `MaterialApp.title: 'Kawaru'`
- [ ] Android `applicationId` (`com.securescan.securescan` → örn.
      `com.naimemreaytekin.kawaru`) — paket klasör yapısını da taşı
      (`android/app/src/main/kotlin/...`), `MainActivity.kt` içindeki paket
      satırını güncelle. Bunu manuel yapmak riskli; Flutter için `rename`
      gibi CLI araçları (bundle id + app name'i tek komutta değiştirir) veya
      Android Studio'nun "Refactor → Rename Package"ı kullanılabilir —
      hangisi mevcutsa.
- [ ] iOS `Runner.xcodeproj` bundle identifier ve display name
- [ ] `README.md`, tüm ekranlardaki başlıklar, hata mesajları, paylaşım
      metinleri ("Lensify ile...", "Sifreli_" öneki vb.)
- [ ] `flutter_launcher_icons` / `flutter_native_splash` asset yolları yeni
      logoya işaret etsin

### Logo Yönü
- **Minimal, maksimum 2 renk.** İkon boyutunda (çok küçük) bile net
  okunmalı — mevcut "sonsuzluk" (infinity) loading animasyon motifiyle
  görsel bir bağ kur (örn. döngü/dönüşüm hareketini çağrıştıran, birbirine
  akan iki ok/eğri — refresh/sync ikonundan daha özgün bir versiyonu).
  Tipografi varsa geometrik, düşük kontrastlı bir sans-serif.
- Mevcut renk paleti (`app_colors.dart`) iOS sistem tonlarını kullanıyor
  (`#007AFF` mavi, sistem gri arkaplanlar). Marka rengini bu paletten türet
  ya da kasıtlı olarak ondan ayrıştır — ikisinden birine karar ver, ortada
  bırakma.
- Işık/karanlık mod ikisi için de çalışan bir versiyon üret (splash logosu
  zaten `assets/splash/splash_logo.png` olarak ayrı tutuluyor, aynı yapı
  korunabilir).

---

## 2. Vizyon: "Her Şeyi Dönüştüren, 0 Maliyetli" Kawaru

Kawaru'nun temel vaadi: kullanıcının elindeki neredeyse her dosya/medya
formatını, **tamamen cihaz üzerinde, internetsiz ve ücretsiz** başka bir
formata çevirebilmesi. Bu iki kısıt asla ihlal edilmez:

1. **0 maliyet:** Hiçbir ücretli bulut API'si, hiçbir sunucu maliyeti
   eklenmeyecek. (OpenAI Whisper API, Google Cloud Speech-to-Text ücretli
   katmanı, herhangi bir "pay-per-conversion" servis — hepsi yasak.)
   Sadece: cihaz üzerinde çalışan açık kaynak/ücretsiz kütüphaneler.
2. **Asla sahte özellik yok.** `MediaConversionService` şu anda **gerçek bir
   dönüştürme yapmıyor** — dosyayı olduğu gibi kopyalayıp 4 saniyelik sahte
   bir bekleme gösteriyor (kod yorumunda bunun nedeni açık: eski
   `ffmpeg_kit_flutter` paketinin CocoaPods deposu kırıldığı için mock
   olarak bırakılmış). Bu artık kabul edilebilir değil — ya gerçek şekilde
   çalıştır ya da kullanıcıya UI'da net şekilde "yakında" olarak göster.
   Çalışıyormuş gibi görünüp çalışmayan hiçbir özellik olmayacak.

### Teknik Çözüm (araştırıldı, güncel)

- **Medya/format dönüştürme:** Eski `ffmpeg_kit_flutter` artık tamamen terk
  edildi (Nisan 2025'te ikili dosyalar kaldırıldı). Yerine **aktif olarak
  bakımı yapılan fork'u** kullan: `ffmpeg_kit_flutter_new` (pub.dev) —
  Android/iOS/macOS/Windows/Linux destekli, güncel FFmpeg sürümünü
  paketliyor, iOS tarafında Swift Package Manager veya checksum'lı önceden
  derlenmiş XCFramework kullanıyor (yani eski CocoaPods 404 sorunu bu
  fork'ta yaşanmaz). `MediaConversionService`'i bu paketle gerçek bir
  implementasyona çevir; format listesini önce en çok kullanılan
  ses/video/resim formatlarıyla sınırla (mp4, mov, mp3, wav, m4a, gif, webp
  gibi), mimariyi yeni format eklemek kolay olacak şekilde kur.
- **Videodaki/sesteki konuşmayı yazıya çevirme:** Bulut API'siz, tamamen
  cihaz üstü ve ücretsiz çözüm olarak `whisper.cpp` tabanlı bir Flutter
  paketi kullan (örn. `whisper_ggml` veya dengi) — model bir kere indirilir
  (ya da asset olarak paketlenir), sonrasında tamamen offline çalışır, 99
  dili destekler (TR ve EN dahil), dosya bazlı transkripsiyon yapabilir.
  Bu, "videodaki sesleri yazıya çevirsin" isteğinin karşılığı.
- **"Her format" iddiasını gerçekçi tut:** Literal olarak sonsuz format
  imkânsız. Prompt/UI dilinde "neredeyse her format" yerine somut, büyüyen
  bir liste sun (Araçlar ekranında kategori bazlı: Resim, Ses, Video,
  Belge) — mimari yeni format eklemeyi ucuzlaştıracak şekilde
  (strateji/servis pattern'i) kurulsun ki liste zamanla büyüsün.
- Yeni bir bağımlılık eklerken önce şunu doğrula: gerçekten ücretsiz mi,
  gerçekten offline çalışıyor mu, aktif bakımı var mı. Üçünden biri
  sağlanmıyorsa kullanma.

---

## 3. UI/UX ve Animasyon

Mevcut tasarım dili (iOS'a yakın renkler, "sonsuzluk" loading animasyonu,
gerçek sayfa önizlemeli thumbnail'lar, karanlık mod) korunacak temel — ama
bir üst seviyeye taşınacak:

- Ekranlar arası geçişlerde tutarlı, tekrar kullanılabilir bir "motion
  sistemi" kur (her ekranda ayrı ayrı elle animasyon yazmak yerine ortak
  transition/curve/duration sabitleri).
- Mikro-etkileşimler ekle: buton basımlarında hafif scale/haptic,
  liste öğelerinde giriş animasyonu, boş durum (empty state) illüstrasyonlu
  ve canlı olsun.
- Sonsuzluk loading motifini Kawaru marka diline uyarlayarak koru — bu zaten
  ayırt edici bir özellik, atma.
- Tutarlılık: yeni eklenen her ekran (dönüştürücü akışları, onboarding,
  yeni logo ile splash) var olan tasarım sistemine (`AppColors`,
  `AppTheme`) uysun, yeni ad-hoc renk/stil eklenmesin.

---

## 4. İlk Açılış Akışı (Onboarding + Dil Seçimi)

Şu an uygulama doğrudan `AnimatedSplashScreen` → ana ekrana geçiyor. Bunun
yerine, **sadece ilk açılışta**:

1. Splash screen (mevcut, korunur)
2. Hızlı kurulum / karşılama ekranı — 2-3 adımlık kısa bir akış:
   - Dil seçimi (Türkçe / English) — **tek seferlik**, sonrasında
     Ayarlar'dan değiştirilebilir (mevcut `settings_provider.dart` +
     `AppLocalizations` altyapısı zaten TR/EN destekliyor, bunu onboarding'e
     bağla)
   - (İsteğe bağlı 1-2 ekran daha: uygulamanın ne yaptığını kısaca
     tanıtan, izin isteklerini bağlamla açıklayan kartlar — kamera, mikrofon
     [transkripsiyon için], biyometri)
3. Sonraki açılışlarda bu akış atlanır — bir flag (`Isar` ayarlarında veya
   `shared_preferences`'ta `onboarding_completed: bool`) ile kontrol edilir.

---

## 5. Kalite ve Yayına Hazırlık (App Store / Google Play)

- Tüm ekranlar, hata mesajları ve boş durumlar hem TR hem EN'de eksiksiz
  olmalı — yeni eklenen her ekran `AppLocalizations` map'ine iki dilde de
  girilecek, tek dilde bırakılmayacak.
- Kamera, mikrofon (yeni transkripsiyon özelliği için), biyometri
  izinlerinin her biri için Info.plist / AndroidManifest'te açık, kullanıcı
  dostu izin açıklamaları (`NSCameraUsageDescription`,
  `NSMicrophoneUsageDescription`, `NSFaceIDUsageDescription` vb.) olsun.
- Gizlilik: uygulama "%100 offline" iddiasını taşıyor — mağaza gönderiminde
  yine de bir gizlilik politikası sayfası/linki gerekiyor (veri toplanmadığını
  açıkça belirten kısa bir sayfa yeterli).
- İkon/splash üretimi zaten `flutter_launcher_icons` ve
  `flutter_native_splash` ile otomatik — yeni logo asset'leri girildikten
  sonra bu iki paketin komutlarını çalıştırmayı unutma.
- Sürüm numarasını (`pubspec.yaml` → `version:`) rebrand ile birlikte
  anlamlı şekilde artır.

---

## 6. Öncelik Sırası

1. Rebrand (Bölüm 1) — isim her yerde tutarlı olmadan diğer işler üstüne
   inşa edilmemeli
2. Sahte dönüştürücüyü gerçek hale getir + transkripsiyon ekle (Bölüm 2)
3. Onboarding + dil seçimi (Bölüm 4)
4. UI/animasyon cilası (Bölüm 3) — mevcut ekranlar rebrand'den sonra tek
   tek gözden geçirilsin
5. Yayına hazırlık kontrol listesi (Bölüm 5)

Her adımda: küçük, test edilebilir parçalar halinde ilerle, her tamamlanan
parçadan sonra Bölüm 0'daki commit+push kuralını uygula.

## 7. Sonuç Mesajı Formatı
Her yaptığın değişiklik ve geliştirmeden sonra, kullanıcıya projeyi çalıştırıp test edebilmesi için terminalde yazması gereken komutları mutlaka hatırlat. Örnek:
```bash
cd /Users/aytek/Desktop/SecureScanProject
flutter run
```
