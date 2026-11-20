# 🔐 Seymen Auth Proje

Flutter ve Firebase Authentication altyapısı kullanılarak geliştirilmiş, modern ve güvenli kullanıcı kimlik doğrulama uygulaması.

## 🚀 Özellikler

* **Kayıt Ol (Sign Up):** E-posta ve şifre ile hızlı ve doğrulanmış kullanıcı kaydı.
* **Giriş Yap (Sign In):** Firebase Authentication üzerinden güvenli oturum açma.
* **Oturum Yönetimi:** Kullanıcının giriş durumunu anlık takip ederek ilgili ekrana otomatik yönlendirme ve güvenli çıkış yapma.
* **Hata & Form Kontrolleri:** Geçersiz e-posta formatı, eksik alanlar veya hatalı şifre gibi durumlar için anlaşılır kullanıcı geri bildirimleri.

## 🛠️ Kullanılan Teknolojiler

* **Framework:** Flutter
* **Programlama Dili:** Dart
* **Kimlik Doğrulama (Auth):** Firebase Authentication & Firebase Core

## 📂 Proje Yapısı

* `lib/main.dart` — Uygulama başlangıcı, yönlendirme ve arayüz ekranları
* `lib/firebase_options.dart` — Firebase yapılandırma ayarları (yerel)

## ⚙️ Kurulum ve Çalıştırma

Projeyi kendi bilgisayarınızda çalıştırmak için aşağıdaki adımları izleyin:

1. **Depoyu klonlayın:**
   `git clone https://github.com/Seymentpbs/seymen_auth_proje.git`

2. **Proje klasörüne girin ve paketleri yükleyin:**
   `cd seymen_auth_proje`
   `flutter pub get`

3. **Firebase Yapılandırması:**
   * Güvenlik nedeniyle Firebase yapılandırma dosyaları repoya dahil edilmemiştir.
   * Kendi Firebase projenizi oluşturup `flutterfire configure` komutuyla yapılandırma dosyalarınızı ekleyin.

4. **Uygulamayı başlatın:**
   `flutter run`