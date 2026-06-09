import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ayarlar & Yardım")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                    Text("AeroClean yapılandırması ve macOS izin rehberi.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 4)
                
                // Permission Guide Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 12) {
                        Image(systemName: "lock.shield.fill")
                            .font(.title)
                            .foregroundColor(.blue)
                        Text("Tam Disk Erişimi Gerekli mi?")
                            .font(.title3)
                            .bold()
                    }
                    
                    Text("macOS'in güvenlik politikaları (TCC) gereği; tarayıcı önbellekleri, mail ekleri, sistem logları ve bazı uygulama verilerini tarayabilmek için AeroClean uygulamasına 'Tam Disk Erişimi' vermeniz gerekebilir. Bu izni vermediğinizde, uygulama sadece erişebildiği genel klasörleri tarar.")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("Nasıl İzin Verilir?")
                        .font(.headline)
                        .padding(.top, 4)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        PermissionStepRow(number: "1", text: "Mac'inizde sol üstteki  simgesine tıklayıp **Sistem Ayarları**'nı açın.")
                        PermissionStepRow(number: "2", text: "**Gizlilik ve Güvenlik** sekmesine gidin.")
                        PermissionStepRow(number: "3", text: "Listeden **Tam Disk Erişimi** seçeneğini bulun.")
                        PermissionStepRow(number: "4", text: "AeroClean uygulamasını listede bularak yanındaki anahtarı **aktif** hale getirin. (Eğer listede yoksa, '+' butonuna basıp uygulamayı Uygulamalar klasöründen seçip ekleyin).")
                    }
                }
                .padding(24)
                .background(Color(.windowBackgroundColor).opacity(0.4))
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                )
                
                // Configuration actions
                VStack(alignment: .leading, spacing: 16) {
                    Text("Genel İşlemler")
                        .font(.title3)
                        .bold()
                    
                    Divider().opacity(0.3)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Tarama Verilerini Temizle")
                                .font(.headline)
                            Text("Tarama sonuçlarını sıfırlar ve hafızadaki önbelleği boşaltır.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button("Sıfırla") {
                            withAnimation {
                                appState.hasScanned = false
                                appState.scanProgress = 0.0
                                appState.categories = []
                                appState.largeFiles = []
                                appState.systemDataSize = 0
                                appState.loadDiskSpace()
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(20)
                .background(Color(.windowBackgroundColor).opacity(0.2))
                .cornerRadius(12)
                
                // About app
                VStack(spacing: 8) {
                    Text("AeroClean v1.0")
                        .font(.headline)
                    Text("Uğur Yaşayan tarafından üretildi")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.blue)
                    Text("Tüm hakları saklıdır. macOS için yerel SwiftUI uygulaması.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 24)
            }
            .padding(12)
        }
    }
}

struct PermissionStepRow: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white)
                .padding(6)
                .background(Color.blue)
                .clipShape(Circle())
                .frame(width: 20, height: 20)
            
            // Format markdown-like bold strings
            Text(LocalizedStringKey(text))
                .font(.subheadline)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
