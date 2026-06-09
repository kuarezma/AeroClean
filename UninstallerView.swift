import SwiftUI

struct UninstallerView: View {
    @EnvironmentObject var appState: AppState
    @State private var searchText = ""
    @State private var selectedAppId: String? = nil
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Uygulama Kaldırıcı (Uninstaller)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                    Text("Uygulamaları çöp kutusuna attığınızda arkada bıraktıkları gigabaytlarca kalıntıyla birlikte tamamen silin.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                
                Button(action: {
                    appState.scanApps()
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
            
            if appState.installedApps.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "app.badge.minus")
                        .font(.system(size: 64))
                        .foregroundColor(.red.opacity(0.8))
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .clipShape(Circle())
                    
                    Text("Uygulamalar Taranmadı veya Bulunmadı")
                        .font(.title3)
                        .bold()
                    
                    Text("Kurulu üçüncü parti uygulamaları ve disk kalıntılarını analiz etmek için taramayı başlatın.")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 400)
                    
                    Button(action: {
                        appState.startScan()
                    }) {
                        Text("Uygulamaları Tara")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .frame(maxHeight: .infinity)
            } else {
                HStack(alignment: .top, spacing: 16) {
                    // Left Column: Searchable Applications list
                    VStack(spacing: 10) {
                        // Search bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondary)
                            TextField("Uygulama ara...", text: $searchText)
                                .textFieldStyle(PlainTextFieldStyle())
                        }
                        .padding(8)
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(8)
                        
                        // Scrollable List
                        ScrollView {
                            let filtered = getFilteredApps()
                            if filtered.isEmpty {
                                Text("Arama sonucunda uygulama bulunamadı.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.top, 40)
                            } else {
                                LazyVStack(spacing: 6) {
                                    ForEach(filtered) { app in
                                        Button(action: {
                                            selectedAppId = app.id
                                            appState.selectApp(app)
                                        }) {
                                            HStack(spacing: 8) {
                                                // Retrieve and render native Mac app icon
                                                Image(nsImage: NSWorkspace.shared.icon(forFile: app.path))
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 28, height: 28)
                                                
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(app.name)
                                                        .font(.system(size: 11.5, weight: .bold))
                                                        .foregroundColor(selectedAppId == app.id ? .white : .primary)
                                                        .lineLimit(1)
                                                    Text(app.formattedSize)
                                                        .font(.caption2)
                                                        .foregroundColor(selectedAppId == app.id ? .white.opacity(0.8) : .secondary)
                                                }
                                                Spacer()
                                            }
                                            .padding(.vertical, 6)
                                            .padding(.horizontal, 10)
                                            .background(selectedAppId == app.id ? Color.red.opacity(0.8) : Color.black.opacity(0.15))
                                            .cornerRadius(8)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                        }
                    }
                    .frame(width: 260)
                    
                    // Middle Column: Selected App Leftovers review
                    VStack(alignment: .leading, spacing: 12) {
                        if let selectedApp = appState.selectedApp {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("\(selectedApp.name) Disk Kalıntıları")
                                            .font(.headline)
                                            .lineLimit(1)
                                        Text("Ana Paket Boyutu: \(selectedApp.formattedSize)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                }
                                
                                Button(action: {
                                    appState.uninstallSelectedApp()
                                }) {
                                    HStack {
                                        Image(systemName: "trash.fill")
                                        Text("Uygulamayı ve Kalıntıları Kaldır (\(formatSize(getTotalUninstallSize())))")
                                            .bold()
                                    }
                                    .padding(.vertical, 10)
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(.white)
                                    .background(Color.red)
                                    .cornerRadius(8)
                                }
                                .disabled(appState.isUninstallingApp)
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                            Divider().opacity(0.3)
                            
                            // App main package entry (always deleted, static indicator)
                            HStack {
                                Image(systemName: "checkmark.square.fill")
                                    .foregroundColor(.red)
                                Image(nsImage: NSWorkspace.shared.icon(forFile: selectedApp.path))
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 18, height: 18)
                                Text("Uygulama Ana Paketi (\(selectedApp.name).app)")
                                    .font(.system(size: 11, weight: .bold))
                                Spacer()
                                Text(selectedApp.formattedSize)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 6)
                            .padding(.horizontal, 8)
                            .background(Color.black.opacity(0.1))
                            .cornerRadius(6)
                            
                            // Discovered leftovers list
                            if appState.isScanningLeftovers {
                                Spacer()
                                HStack {
                                    Spacer()
                                    ProgressView()
                                        .padding(.trailing, 6)
                                    Text("Kütüphane kalıntıları taranıyor...")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                                Spacer()
                            } else if appState.selectedAppLeftovers.isEmpty {
                                Spacer()
                                VStack(spacing: 8) {
                                    Image(systemName: "sparkles")
                                        .font(.largeTitle)
                                        .foregroundColor(.green)
                                    Text("Bu uygulamaya ait kütüphane kalıntısı bulunamadı!")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                Spacer()
                            } else {
                                ScrollView {
                                    LazyVStack(spacing: 6) {
                                        ForEach(appState.selectedAppLeftovers) { leftover in
                                            HStack {
                                                Button(action: {
                                                    appState.toggleLeftoverSelection(itemId: leftover.id)
                                                }) {
                                                    Image(systemName: leftover.isSelected ? "checkmark.square.fill" : "square")
                                                        .foregroundColor(leftover.isSelected ? .red : .secondary)
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                                
                                                Image(systemName: "folder.fill")
                                                    .foregroundColor(.yellow)
                                                
                                                VStack(alignment: .leading, spacing: 2) {
                                                    HStack(spacing: 6) {
                                                        Text(leftover.type)
                                                            .font(.system(size: 8))
                                                            .bold()
                                                            .lineLimit(1)
                                                            .layoutPriority(1)
                                                            .padding(.horizontal, 4)
                                                            .padding(.vertical, 1)
                                                            .foregroundColor(.red)
                                                            .background(Color.red.opacity(0.1))
                                                            .cornerRadius(3)
                                                        
                                                        Text(URL(fileURLWithPath: leftover.path).lastPathComponent)
                                                            .font(.system(size: 11, weight: .bold))
                                                            .lineLimit(1)
                                                            .truncationMode(.middle)
                                                    }
                                                    Text(leftover.path)
                                                        .font(.system(size: 9))
                                                        .foregroundColor(.secondary)
                                                        .lineLimit(1)
                                                        .truncationMode(.middle)
                                                }
                                                
                                                Spacer()
                                                
                                                Text(leftover.formattedSize)
                                                    .font(.caption2)
                                                    .foregroundColor(.secondary)
                                            }
                                            .padding(.vertical, 6)
                                            .padding(.horizontal, 8)
                                            .background(Color.black.opacity(0.1))
                                            .cornerRadius(6)
                                        }
                                    }
                                }
                            }
                        } else {
                            Spacer()
                            Text("Detayları ve disk kalıntılarını listelemek için soldan bir uygulama seçin.")
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                            Spacer()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(16)
                    .background(Color(.windowBackgroundColor).opacity(0.2))
                    .cornerRadius(12)
                    
                    // Right Column: Advice panel
                    UninstallerAdvicePanel(app: appState.selectedApp)
                        .frame(width: 280)
                }
                .frame(maxHeight: .infinity)
            }
        }
        .padding(12)
        .onAppear {
            if selectedAppId == nil, let first = appState.installedApps.first {
                selectedAppId = first.id
                appState.selectApp(first)
            }
        }
        .alert(isPresented: $appState.showCleanSuccessAlert) {
            Alert(
                title: Text("Uygulama Tamamen Kaldırıldı"),
                message: Text("Uygulama paketi ve seçilen tüm kütüphane artıkları diskten temizlendi.\n\nSerbest Bırakılan Alan: \(formatSize(appState.cleanedAmount))"),
                dismissButton: .default(Text("Tamam"))
            )
        }
    }
    
    // Helpers
    private func getFilteredApps() -> [InstalledApp] {
        if searchText.isEmpty {
            return appState.installedApps
        }
        return appState.installedApps.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    private func getTotalUninstallSize() -> Int64 {
        guard let app = appState.selectedApp else { return 0 }
        var size = app.size
        for leftover in appState.selectedAppLeftovers {
            if leftover.isSelected {
                size += leftover.size
            }
        }
        return size
    }
    
    private func formatSize(_ bytes: Int64) -> String {
        ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
    }
}

// Advice panel layout
struct UninstallerAdvicePanel: View {
    let app: InstalledApp?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "app.badge.minus")
                    .font(.title3)
                    .foregroundColor(.red)
                    .padding(8)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Neden Uninstaller?")
                        .font(.system(size: 12, weight: .bold))
                    Text("🟢 Önerilen Temizlik")
                        .font(.caption2)
                        .bold()
                        .foregroundColor(.green)
                }
            }
            
            Divider().opacity(0.3)
            
            // Core advice explanation
            VStack(alignment: .leading, spacing: 6) {
                Text("Kalıntı Sorunu Nedir?")
                    .font(.caption)
                    .bold()
                    .foregroundColor(.secondary)
                
                Text("macOS'te uygulamaları sadece çöp kutusuna sürüklemek, uygulamanın çalışırken sistem kütüphanelerine kurduğu veritabanlarını, önbellekleri, logları ve lisans ayar dosyalarını temizlemez. Bu kalıntılar sistem verileri (System Data) altında birikerek gigabaytlarca çöp alan oluşturur.")
                    .font(.system(size: 10.5))
                    .foregroundColor(.primary)
                    .lineSpacing(2.5)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(8)
                    .background(Color.green.opacity(0.06))
                    .cornerRadius(6)
            }
            
            if let app = app {
                Divider().opacity(0.3)
                
                VStack(alignment: .leading, spacing: 10) {
                    DetailFieldView(title: "Uygulama Adı", value: app.name)
                    DetailFieldView(title: "Uygulama Kimliği (Bundle ID)", value: app.bundleId)
                    DetailFieldView(title: "Versiyon", value: app.version)
                }
                
                Divider().opacity(0.3)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Silinirse Ne Olur?")
                        .font(.caption)
                        .bold()
                        .foregroundColor(.red.opacity(0.8))
                    Text("Uygulama ana paketi (/Applications'dan) ve seçtiğiniz kütüphane artıkları kalıcı olarak silinecektir. Uygulamayı daha sonra tekrar kurarsanız, tüm ayarları ve oturumları sıfırlanmış olarak temiz açılacaktır.")
                        .font(.system(size: 10.5))
                        .foregroundColor(.secondary)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color(.windowBackgroundColor).opacity(0.3))
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.red.opacity(0.2), lineWidth: 1)
        )
    }
}
