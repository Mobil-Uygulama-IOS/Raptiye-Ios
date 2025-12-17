# Raptiye - iOS Proje Yönetim Uygulaması

TaskFlow, iOS platformu için geliştirilmiş modern bir proje yönetim uygulamasıdır. SwiftUI kullanılarak oluşturulmuş olup, kullanıcıların projelerini ve görevlerini etkili bir şekilde yönetmelerine olanak tanır.

## 🚀 Özellikler

- **Modern UI/UX**: SwiftUI ile tasarlanmış kullanıcı dostu arayüz
- **Kullanıcı Kimlik Doğrulama**: Güvenli giriş ve kayıt sistemi
- **Proje Yönetimi**: Proje oluşturma ve yönetim özellikleri
- **Görev Takibi**: Görev oluşturma ve ilerleme takibi
- **Profil Yönetimi**: Kullanıcı profili ve ayarları

## 📱 Ekran Görüntüleri

- Giriş ekranı
- Ana dashboard
- Proje listesi
- Görev yönetimi
- Kullanıcı profili

## 🛠 Teknolojiler

- **SwiftUI**: Modern iOS UI framework'ü
- **iOS 17.0+**: Minimum desteklenen sürüm
- **Firebase**: Backend servisleri (Auth, Firestore)
- **Combine**: Reaktif programlama

## 📋 Gereksinimler

- iOS 17.0 veya üzeri
- Xcode 16.0 veya üzeri
- Swift 5.9 veya üzeri
- Apple Developer hesabı (cihazda test için)

## 🏗 Kurulum

1. Bu repository'yi klonlayın:
   ```bash
   git clone https://github.com/Mobil-Uygulama-IOS/task-flow-3.git
   ```

2. Xcode ile projeyi açın:
   ```bash
   open "Task Flow Versiyon 2.xcodeproj"
   ```

3. **ÖNEMLİ:** Projeyi ilk açtığınızda, Xcode'da şu adımları izleyin:
   - Project Navigator'da (sol panel) proje dosyasına tıklayın
   - "Task Flow Versiyon 2" target'ını seçin
   - "Signing & Capabilities" sekmesine gidin
   - "Team" dropdown'dan kendi Apple Developer Team ID'nizi seçin
   - Eğer Apple Developer hesabınız yoksa, "Add an Account..." seçeneğinden Apple ID'nizi ekleyin

4. Projeyi çalıştırın (Cmd+R)

## 📁 Proje Yapısı

```
Task Flow Versiyon 2/
├── Task_Flow_Versiyon_2App.swift    # Ana uygulama dosyası
├── MainApp.swift                     # Ana görünüm ve navigasyon
├── EnhancedLoginView.swift          # Giriş ekranı
├── AuthViewModel.swift              # Kimlik doğrulama view model
├── FirebaseManager.swift            # Firebase yönetimi (mock)
├── ContentView.swift                # Temel görünüm
└── Assets.xcassets/                 # Uygulama varlıkları
```

## 🔄 Geliştirme Durumu

- ✅ Temel UI/UX tasarımı
- ✅ Firebase entegrasyonu (Auth & Firestore)
- ✅ Kullanıcı kimlik doğrulama
- ✅ Ana navigasyon yapısı
- ✅ Proje yönetimi özellikleri
- ✅ Görev yönetimi özellikleri
- ✅ Çoklu dil desteği (TR/EN)
- 🚧 Proje analitiği
- 🚧 Push notification'lar

## 🤝 Katkıda Bulunma

1. Bu repository'yi fork edin
2. Feature branch oluşturun (`git checkout -b feature/YeniOzellik`)
3. Değişikliklerinizi commit edin (`git commit -am 'Yeni özellik eklendi'`)
4. Branch'inizi push edin (`git push origin feature/YeniOzellik`)
5. Pull Request oluşturun

## 📝 Lisans

Bu proje [MIT Lisansı](LICENSE) altında lisanslanmıştır.

## 📞 İletişim

- Geliştirici: [Doğa], [Bilgehan]
- E-posta: [your-email@example.com]
- Proje Linki: [https://github.com/[ORGANIZATION_NAME]/taskflow-ios](https://github.com/[ORGANIZATION_NAME]/taskflow-ios)

## 🙏 Teşekkürler

- SwiftUI topluluğu
- iOS geliştirici topluluğu
- Açık kaynak katkıcıları

---

⭐ Bu projeyi beğendiyseniz yıldız vermeyi unutmayın!
