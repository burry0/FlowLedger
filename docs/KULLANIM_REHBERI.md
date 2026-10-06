# FlowLedger kullanım rehberi

Bu rehber FlowLedger ile tipik bir ayı adım adım anlatır. Ekran adları Türkçe arayüzdeki gibidir.

## 1. Müşteriler ve varsayılan kategoriler

1. **Müşteriler → Müşteri Ekle** ile müşteriyi oluşturun.
2. Müşteriyi açın. **Varsayılan Kategoriler** altında bu müşteriye düzenli sattığınız hizmetleri fiyatlarıyla ekleyin. İsterseniz **iş aşamaları** da tanımlayın (örn. *Kaba kurgu → Renk → Ses*). Bu aşamalar, o kategoriden oluşturulan her işe kontrol listesi olarak kopyalanır.

Varsayılan kategoriler şablondur. Dönem açıldığında ad ve fiyatları döneme kopyalanır; sonradan fiyat değiştirmek geçmiş işleri değiştirmez.

## 2. Aktif dönem

Her müşterinin her zaman tek bir **aktif dönemi** vardır. Müşteri sayfasında şunlar görünür:

- dönemin başlangıç tarihi, toplam ve alınan tutar,
- özet şeridi: **Alınacak Tutar**, **Devam Ediyor**, **Açık revizyon** ve **Onay bekleyen**,
- dönemi TXT/XLSX olarak kaydetme ve ödeme kaydetme düğmeleri.

## 3. İş ekleme

- Bir **kategori düğmesine** tıklayarak dönemin sabit fiyatıyla iş ekleyin.
- Kategorisi olmayan işler için **+ Tek Seferlik İş** kullanın (başlık, fiyat ve adedi siz girersiniz).
- Yeni iş **Devam Ediyor** olarak başlar. Aşamaları işaretleyin, bitince **Tamamlandı Olarak İşaretle** deyin. Alınacak tutara yalnızca tamamlanan işler eklenir.

Bir işi değiştirmek için kartı açıp **Düzenle**'ye basın: başlığı, adedi, **çarpanı** (×1, ×1,25, ×1,5, ×2, ×3 — acil veya ek emek gerektiren işler için) ve notu değiştirebilirsiniz. Diyalog yazarken `fiyat × adet × çarpan = toplam` sonucunu gösterir.

### Parça parça faturalanan taslaklar

Bazen taslağı şimdi, tam halini sonra teslim edersiniz. Örneğin taslak için fiyatın yarısını, final için kalanını alırsınız.

- Tek seferlik iş eklerken ya da herhangi bir işte **Düzenle** içinde **Taslak — devamı sonra gelecek** seçeneğini açın ve final fiyatın ne kadarının şimdi faturalanacağını kaydırıcıyla ayarlayın (varsayılan %50). Diyalog iki parçayı da gösterir, örneğin *Şimdi ₺1.000 (%50) · Tamamlanınca ₺1.000*.
- Taslak içinde bulunduğunuz dönemde faturalanır ve müşteri sayfasında **Tamamlanacak Taslaklar** altında görünür. O dönem kapansa bile orada kalır.
- Müşteri sayfasında tek satırlık bir özet görünür (*13 taslak · faturalanacak ₺…*). **Taslakları görüntüle** listeyi açar.
- Tam halini teslim edince bu listede **Tamamla**'ya basın. Kalan tutar aktif döneme tamamlanmış iş olarak eklenir. Taslağın kendi fiyatı kullanılır, sonradan yapılan fiyat değişiklikleri uygulanmaz.
- Tamamlanan bir taslağın payı artık değiştirilemez. Tamamlama kaydını silerseniz taslak yeniden tamamlanmayı bekler.

## 4. Revizyonlar ve geri bildirim

Her iş bir teslimattır. Kartı açıp **Revizyonlar**'a tıklayın.

- **Yeni Versiyon** V1, V2… ekler (örn. *Final* olarak yeniden adlandırabilirsiniz). Neyin değiştiğini ve dosya yolu/bağlantısını yazın.
- Versiyonun durumunu seçin: **Taslak**, **Gönderildi** veya **Onaylandı**.
- **Geri Bildirim Ekle** ile müşterinin isteğini kaydedin. **Revizyon** (mevcut işte değişiklik) veya **Yeni Kapsam** (yeni bir istek, örn. "9:16 versiyonunu da yapalım") seçin. Videolar için `00:43` gibi zaman kodu ekleyebilirsiniz.
- Geri bildirimin solundaki daireye tıklayınca **Çözüldü** olur; menüsünden **Yapılmayacak**, **Yeniden aç**, **Düzenle** veya **Sil** seçilebilir.
- Müşteri sayfasındaki iş kartında `V3 · Değişiklik istendi · 2 açık revizyon` gibi tek satırlık bir özet görünür.

Revizyonlar kapalı dönemlerde de çalışır ve tutarları, ödemeleri veya iş durumunu asla değiştirmez.

**Geçmiş** paneli (geniş pencerede sağda, dar pencerede ayrı sekmede) versiyonları, geri bildirimleri, tamamlanan aşamaları ve işin tamamlanmasını zaman sırasıyla gösterir. Kayıtlardan türetildiği için bir durum birkaç kez değiştiyse yalnızca son zaman görünür.

## 5. Ödeme alma

- **Ödemenin Bir Kısmını Aldım**: dönem açık kalırken alınan parayı kaydeder. İki yol var:
  - **Tutar gir**: aldığın tutarı yazarsın.
  - **İş seç**: müşterinin ödediği tamamlanmış işleri işaretlersin, tutar bunların toplamı olur. Bu işlerde ödeme tarihiyle birlikte **Ödendi** yazar, ödeme kaydında da hangi işlerin karşılığı olduğu görünür. Bir iş yalnızca bir kez ödendi olarak işaretlenebilir.
- Kalan bakiye her zaman iş toplamı eksi tüm ödemelerdir; ödemeyi hangi yolla girdiğin fark etmez. Ödendi olarak işaretli bir işi düzenlemek veya silmek ödeme kaydını değiştirmez; FlowLedger bunu hatırlatır.
- **Ödeme Aldım**: son ödemeyi kaydeder ve **dönemi kapatır**. Güncel varsayılan kategorilerle otomatik olarak yeni bir aktif dönem başlar. Devam eden işlerin önce tamamlanması veya silinmesi gerekir.

Kapalı dönemler müşteri sayfasında **Geçmiş Dönemler** altında ve **Dönemler** ekranında listelenir. Revizyonlar hariç salt okunurdur.

## 6. Raporlar

Müşteri sayfasındaki **TXT Al** ve **XLSX Al**, aktif dönemin raporunu mevcut dilinizde ve para biriminizde kaydeder: özet, işler (adet ve çarpanla) ve ödemeler.

## 7. Yedekleme ve geri yükleme

**Ayarlar → Yedekleme**

- **Yedek al** tüm verileri tek bir `.db` dosyasına kaydeder. Bunu düzenli yapın ve bir kopyayı bilgisayarınızın dışında saklayın.
- **Yedekten geri yükle** mevcut tüm verilerin yerine bir yedeği koyar. FlowLedger önce dosyayı kontrol eder, içinde kaç müşteri ve iş olduğunu gösterir ve hiçbir şeyi değiştirmeden önce mevcut verilerinizi bir güvenlik kopyasına kaydeder.

## 8. Dil ve para birimi

**Ayarlar → Dil**: Türkçe, English, Deutsch ve Русский arasında geçiş yapar.
**Ayarlar → Para birimi**: para birimi sembolünü ve biçimini değiştirir. Tutarlar dönüştürülmez.

## Verileriniz nerede?

Tüm veriler bilgisayarınızda tek bir dosyadadır:
`%APPDATA%\com.burry.flowledger\FlowLedger\flowledger.db`

Hiçbir veri internete gönderilmez. Yeni kurulum boş veritabanıyla başlar.
