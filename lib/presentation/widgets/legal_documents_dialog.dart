import 'package:flutter/material.dart';
import 'kawaru_text.dart';

class LegalDocumentsDialog {
  static void showPrivacyPolicy(BuildContext context) {
    _showModal(
      context,
      'Gizlilik Politikası',
      '''
Kawaru Gizlilik Politikası

1. Veri Toplama ve Kullanım
Kawaru, tamamen çevrimdışı (offline) çalışan bir uygulamadır. Cihazınızda gerçekleştirdiğiniz tüm medya dönüştürme, yapay zeka transkripsiyonu ve belge tarama işlemleri cihazınızda lokal olarak gerçekleşir. Hiçbir veriniz uzak sunuculara gönderilmez veya üçüncü şahıslarla paylaşılmaz.

2. İzinler
Uygulama, temel işlevlerini yerine getirebilmek için Kamera (belge tarama için) ve Dosya/Medya erişimi izinlerine ihtiyaç duyar. Bu izinler yalnızca uygulamanın içindeki işlemler sırasında kullanılır.

3. Üçüncü Taraf Yazılımlar
Kawaru, cihaz içi işlemler için FFmpeg ve Whisper AI gibi açık kaynaklı araçları kullanır. Bu araçlar da aynı çevrimdışı prensiple çalışır.

4. Değişiklikler
Gizlilik Politikamız üzerinde zaman zaman güncellemeler yapabiliriz. Tüm güncellemeler bu sayfa üzerinden kullanıcılara duyurulacaktır.

İletişim: support@kawaruapp.com
      ''',
    );
  }

  static void showKVKK(BuildContext context) {
    _showModal(
      context,
      'KVKK Aydınlatma Metni',
      '''
Kişisel Verilerin Korunması Kanunu (KVKK) Aydınlatma Metni

Değerli Kullanıcımız,

Kişisel verilerinizin güvenliği hususuna azami hassasiyet göstermekteyiz. Kawaru uygulaması olarak, 6698 sayılı Kişisel Verilerin Korunması Kanunu ("KVKK") uyarınca kişisel veri işlemediğimizi, uygulamamızın %100 çevrimdışı (offline) çalıştığını taahhüt ederiz.

1. İşlenen Kişisel Veriler
Uygulamayı kullanırken oluşturduğunuz veya aktardığınız veriler (fotoğraflar, belgeler, ses dosyaları vb.) cihazınızın belleğinde kalır. Kawaru tarafından herhangi bir kişisel veri (isim, e-posta, kullanım alışkanlıkları vb.) toplanmamaktadır.

2. Verilerin İşlenme Amacı
Söz konusu veriler, yalnızca sizin talebiniz doğrultusunda medya dönüşümü ve belge tarama amacıyla, anlık olarak cihazınızın işlemcisi kullanılarak işlenmektedir.

3. Verilerin Aktarılması
Hiçbir kişisel veri, yurt içindeki veya yurt dışındaki üçüncü kişilere aktarılmaz. Bulut depolama entegrasyonu tamamen sizin kontrolünüzdedir (Share menüsü üzerinden).

Hukuki süreçler ve detaylı bilgi için resmi KVKK mevzuatını inceleyebilirsiniz.
      ''',
    );
  }

  static void showTerms(BuildContext context) {
    _showModal(
      context,
      'Kullanım Koşulları',
      '''
Kawaru Kullanım Koşulları

1. Kabul Beyanı
Uygulamamızı indirerek ve kullanarak bu koşulları kabul etmiş sayılırsınız. 

2. Hizmetin Kullanımı
Kawaru, medya dönüştürme, belge yönetimi ve çevrimdışı AI transkripsiyonu hizmetleri sunar. Uygulamayı yasadışı amaçlar için kullanmak yasaktır. 

3. Garanti Reddi
Uygulama "olduğu gibi" sunulmaktadır. Çevrimdışı yapay zeka analizlerinin (Whisper) doğruluk oranı cihaz performansına ve ses kalitesine göre değişiklik gösterebilir; %100 doğruluk garantisi verilmez.

4. Sorumluluğun Sınırlandırılması
Uygulama kullanımından doğabilecek dolaylı veri kayıplarından Kawaru geliştiricileri sorumlu tutulamaz. Lütfen önemli belgelerinizi düzenli olarak yedekleyin.

5. Fikri Mülkiyet
Uygulama içindeki tasarımlar, logolar ve yazılımlar Kawaru'ya aittir ve izinsiz kopyalanamaz.

Teşekkür ederiz.
      ''',
    );
  }

  static void _showModal(BuildContext context, String title, String content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: KawaruText(
                        content.trim(),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              height: 1.6,
                              fontSize: 15,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
