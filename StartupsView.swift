import SwiftUI

struct StartupsView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedItemId: String? = nil
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Başlangıç Öğeleri Analizi")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                    Text("Mac'iniz açıldığında arka planda otomatik başlayan servisleri ve uygulamaları yönetin.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                
                Button(action: {
                    appState.scanStartups()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Yenile")
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.15))
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 8)
            
            if appState.startupItems.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "bolt.horizontal.circle.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.indigo.opacity(0.8))
                        .padding()
                        .background(Color.indigo.opacity(0.1))
                        .clipShape(Circle())
                    
                    Text("Başlangıç Ögesi Bulunmadı veya Henüz Taranmadı")
                        .font(.title3)
                        .bold()
                    
                    Text("Mac'inizin başlangıç dosyalarını taramak ve analiz etmek için taramayı başlatın.")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 400)
                    
                    Button(action: {
                        appState.startScan()
                    }) {
                        Text("Başlangıç Dosyalarını Tara")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.indigo)
                            .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .frame(maxHeight: .infinity)
            } else {
                HStack(alignment: .top, spacing: 16) {
                    // Left: List of items grouped by type
                    ScrollView {
                        VStack(alignment: .leading, spacing: 18) {
                            // User agents
                            let userItems = appState.startupItems.filter { $0.type == "Kullanıcı Başlangıcı" }
                            if !userItems.isEmpty {
                                StartupSectionView(
                                    title: "Kullanıcı Başlangıç Öğeleri (Önerilen)",
                                    items: userItems,
                                    selectedId: $selectedItemId,
                                    color: .green
                                )
                            }
                            
                            // System agents
                            let systemAgents = appState.startupItems.filter { $0.type == "Sistem Genel Ajanı" }
                            if !systemAgents.isEmpty {
                                StartupSectionView(
                                    title: "Sistem Genel Ajanları (Dikkat)",
                                    items: systemAgents,
                                    selectedId: $selectedItemId,
                                    color: .orange
                                )
                            }
                            
                            // System daemons
                            let systemDaemons = appState.startupItems.filter { $0.type == "Sistem Genel Servisi" }
                            if !systemDaemons.isEmpty {
                                StartupSectionView(
                                    title: "Sistem Daemonları (Hassas)",
                                    items: systemDaemons,
                                    selectedId: $selectedItemId,
                                    color: .red
                                )
                            }
                        }
                        .padding(.trailing, 4)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    // Right: Details & Advice Panel
                    StartupAdvicePanel(item: getSelectedItem())
                        .frame(width: 300)
                }
                .frame(maxHeight: .infinity)
            }
        }
        .padding(12)
        .onAppear {
            if selectedItemId == nil, let first = appState.startupItems.first {
                selectedItemId = first.id
            }
        }
    }
    
    // Helpers
    private func getSelectedItem() -> StartupItem? {
        if let selectedItemId = selectedItemId {
            return appState.startupItems.first(where: { $0.id == selectedItemId })
        }
        return appState.startupItems.first
    }
}

// Group view for items list
struct StartupSectionView: View {
    let title: String
    let items: [StartupItem]
    @Binding var selectedId: String?
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .bold()
                .foregroundColor(color)
                .padding(.horizontal, 4)
            
            ForEach(items) { item in
                Button(action: {
                    selectedId = item.id
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.name)
                                .font(.system(size: 11.5, weight: .bold))
                                .foregroundColor(selectedId == item.id ? .white : .primary)
                                .lineLimit(1)
                                .truncationMode(.middle)
                            Text(item.label)
                                .font(.system(size: 9))
                                .foregroundColor(selectedId == item.id ? .white.opacity(0.8) : .secondary)
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }
                        Spacer()
                        
                        // Small state indicator
                        Text(item.isEnabled ? "Açık" : "Kapalı")
                            .font(.system(size: 9))
                            .bold()
                            .padding(.vertical, 3)
                            .padding(.horizontal, 6)
                            .foregroundColor(item.isEnabled ? .green : .secondary)
                            .background(item.isEnabled ? Color.green.opacity(0.1) : Color.black.opacity(0.1))
                            .cornerRadius(4)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 10)
                    .background(selectedId == item.id ? Color.indigo.opacity(0.85) : Color.black.opacity(0.15))
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

// Detailed advice panel
struct StartupAdvicePanel: View {
    let item: StartupItem?
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if let item = item {
                HStack(spacing: 8) {
                    Image(systemName: "bolt.horizontal.fill")
                        .font(.title3)
                        .foregroundColor(getSafetyColor())
                        .padding(8)
                        .background(getSafetyColor().opacity(0.1))
                        .cornerRadius(8)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.name)
                            .font(.system(size: 12, weight: .bold))
                            .lineLimit(2)
                        Text(item.type)
                            .font(.caption2)
                            .bold()
                            .foregroundColor(getSafetyColor())
                    }
                }
                
                Divider().opacity(0.3)
                
                // Toggle status
                HStack {
                    Text("Durum")
                        .font(.caption)
                        .bold()
                        .foregroundColor(.secondary)
                    Spacer()
                    
                    Toggle("", isOn: Binding(
                        get: { item.isEnabled },
                        set: { _ in appState.toggleStartup(item: item) }
                    ))
                    .toggleStyle(SwitchToggleStyle(tint: .indigo))
                }
                .padding(.vertical, 4)
                
                Divider().opacity(0.3)
                
                VStack(alignment: .leading, spacing: 10) {
                    DetailFieldView(title: "Başlatıcı Etiketi (Label)", value: item.label)
                    DetailFieldView(title: "Hedef Program", value: item.program)
                    DetailFieldView(title: "Konfigürasyon Yolu", value: item.path)
                }
                
                Divider().opacity(0.3)
                
                // Detailed advice text
                VStack(alignment: .leading, spacing: 6) {
                    Text("Açıklama & Tavsiye")
                        .font(.caption)
                        .bold()
                        .foregroundColor(.secondary)
                    
                    Text(getAdviceText())
                        .font(.system(size: 10.5))
                        .foregroundColor(.primary)
                        .lineSpacing(2.5)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(8)
                        .background(getSafetyColor().opacity(0.06))
                        .cornerRadius(6)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Devre Dışı Bırakılırsa Ne Olur?")
                        .font(.caption)
                        .bold()
                        .foregroundColor(.red.opacity(0.8))
                    Text(getRiskText())
                        .font(.system(size: 10.5))
                        .foregroundColor(.secondary)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
            } else {
                Spacer()
                Text("Detayları ve tavsiyeleri görmek için listeden bir başlangıç ögesi seçin.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                Spacer()
            }
            Spacer()
        }
        .padding(16)
        .background(Color(.windowBackgroundColor).opacity(0.3))
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(getSafetyColor().opacity(0.2), lineWidth: 1)
        )
    }
    
    // Helpers
    private func getSafetyColor() -> Color {
        guard let item = item else { return .secondary }
        switch item.type {
        case "Kullanıcı Başlangıcı": return .green
        case "Sistem Genel Ajanı": return .orange
        case "Sistem Genel Servisi": return .red
        default: return .secondary
        }
    }
    
    private func getAdviceText() -> String {
        guard let item = item else { return "" }
        switch item.type {
        case "Kullanıcı Başlangıcı":
            return "Bu öge yalnızca oturum açtığınızda arka planda çalışan kullanıcı düzeyinde bir programdır. Spotify, Discord, Google Drive gibi uygulamaların açılışta yüklenmesi içindir. Bilgisayarın daha hızlı açılması için kapatılması şiddetle tavsiye edilir."
        case "Sistem Genel Ajanı":
            return "Tüm kullanıcı hesapları için geçerli sistem düzeyinde bir başlatıcıdır. Genellikle tarayıcı güncelleyicileri (Google Chrome Update), grafik sürücüleri ve Adobe servisleri tarafından kullanılır. İhtiyaç duymadığınız üçüncü parti servisleri kapatabilirsiniz."
        case "Sistem Genel Servisi":
            return "İşletim sistemi genelinde çalışan, kök (root) düzeyinde yetkilere sahip arka plan servisidir. Genellikle donanım sürücüleri, yerel sunucular veya güvenlik yazılımları tarafından kurulur. Ne yaptığınızı çok iyi bilmiyorsanız açık kalması sistem kararlılığı için daha iyidir."
        default:
            return ""
        }
    }
    
    private func getRiskText() -> String {
        guard let item = item else { return "" }
        switch item.type {
        case "Kullanıcı Başlangıcı":
            return "Hiçbir risk yoktur. Uygulama başlangıçta otomatik açılmaz. İhtiyacınız olduğunda uygulamayı Dock veya Applications klasöründen manuel açarak normal şekilde kullanabilirsiniz."
        case "Sistem Genel Ajanı":
            return "Uygulamalar arka planda otomatik güncellenmeyebilir. Örneğin Adobe veya Google Update devre dışı bırakılırsa tarayıcı güncellemelerini manuel yapmanız gerekir."
        case "Sistem Genel Servisi":
            return "Bazı kritik sistem veya yazılım servislerinin çalışmasını engelleyebilir. Örneğin veritabanı sunucuları veya harici donanım sürücülerinin macOS tarafından tanınmamasına yol açabilir."
        default:
            return ""
        }
    }
}
