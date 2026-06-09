import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        let formattedDate: String = {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "tr_TR")
            formatter.dateFormat = "d MMMM yyyy'den itibaren'"
            return formatter.string(from: Date())
        }()
        
        return VStack(spacing: 16) {
            // Header: "Aktivite Özetim" (My Activity) & Date
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Aktivite Özetim (My Activity)")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("Mac'inizin güncel durum ve temizlik aktiviteleri.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                
                Text(formattedDate)
                    .font(.caption)
                    .bold()
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(6)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.top, 4)
            
            // Grid Split (3 Columns side-by-side)
            HStack(alignment: .top, spacing: 16) {
                
                // Column 1: Mac Health & Recommendations
                VStack(spacing: 16) {
                    // Card 1: Mac Health
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Mac Durumu")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.secondary)
                            Spacer()
                            Image(systemName: "info.circle")
                                .foregroundColor(.secondary)
                                .font(.caption2)
                        }
                        
                        Text("Harika (Excellent)")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("MacBook Air")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        // Centered laptop illustration
                        HStack {
                            Spacer()
                            ZStack {
                                Circle()
                                    .fill(RadialGradient(gradient: Gradient(colors: [Color.cyan.opacity(0.3), Color.clear]), center: .center, startRadius: 5, endRadius: 60))
                                    .frame(width: 120, height: 120)
                                
                                Image(systemName: "laptopcomputer")
                                    .font(.system(size: 54, weight: .ultraLight))
                                    .foregroundStyle(
                                        LinearGradient(gradient: Gradient(colors: [.white, .cyan.opacity(0.8), .blue]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                    )
                                    .shadow(color: .cyan.opacity(0.5), radius: 10)
                            }
                            Spacer()
                        }
                        
                        Spacer()
                        
                        // Macintosh HD Progress Bar
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Macintosh HD")
                                    .font(.caption2)
                                    .bold()
                                Spacer()
                                Text("\(formatSize(appState.usedSpace)) / \(formatSize(appState.totalSpace)) kullanılıyor")
                                    .font(.system(size: 9))
                                    .foregroundColor(.secondary)
                            }
                            
                            let usedPercentage = Double(appState.usedSpace) / max(Double(appState.totalSpace), 1.0)
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color.white.opacity(0.08))
                                        .frame(height: 4)
                                    
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color.white)
                                        .frame(width: geo.size.width * CGFloat(usedPercentage), height: 4)
                                }
                            }
                            .frame(height: 4)
                        }
                    }
                    .padding(18)
                    .frame(height: 230)
                    .background(Color.white.opacity(0.03))
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.05), lineWidth: 0.8))
                    
                    // Card 4: Recommendations
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Önerilen Eylemler")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("Hepsini Gör")
                                .font(.system(size: 9))
                                .foregroundColor(.blue)
                        }
                        
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "app.badge.minus")
                                .font(.title3)
                                .foregroundColor(.blue)
                                .frame(width: 32, height: 32)
                                .background(Color.blue.opacity(0.1))
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Kullanılmayanları Kaldır")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                                Text("Mac'inizde uzun süredir açmadığınız uygulamaları tespit edip kaldırın.")
                                    .font(.system(size: 9.5))
                                    .foregroundColor(.secondary)
                                    .lineLimit(3)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        Spacer()
                    }
                    .padding(18)
                    .frame(height: 150)
                    .background(Color.white.opacity(0.02))
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.04), lineWidth: 0.8))
                }
                
                VStack(spacing: 16) {
                    // Card 2: Local Storage Cleaned
                    let hasCleaned = appState.cleanedAmount > 0
                    
                    let scannedSystemJunk = appState.hasScanned ? Double(
                        appState.categories.filter {
                            [.systemCache, .systemLogs, .trash, .timeMachineSnapshots, .mailDownloads].contains($0.category)
                        }.reduce(0) { $0 + $1.totalSize }
                    ) : 0.0
                    
                    let scannedFiles = appState.hasScanned ? Double(
                        appState.largeFiles.reduce(0) { $0 + $1.size } +
                        (appState.categories.first(where: { $0.category == .downloads })?.totalSize ?? 0)
                    ) : 0.0
                    
                    let scannedApps = appState.hasScanned ? Double(
                        appState.categories.filter {
                            [.appSupportLeftovers, .spotifyCache, .chromeCache, .xcodeSimulators, .xcodeDerivedData, .packageCaches].contains($0.category)
                        }.reduce(0) { $0 + $1.totalSize }
                    ) : 0.0
                    
                    let cleanableSize = Int64(scannedSystemJunk + scannedFiles + scannedApps)
                    
                    let titleLabel = hasCleaned ? "Temizlenen Disk Alanı" : "Temizlenebilir Disk Alanı"
                    let displaySize = hasCleaned ? formatSize(appState.cleanedAmount) : (appState.hasScanned ? formatSize(cleanableSize) : "0 KB")
                    let badgeLabel = hasCleaned ? "▲ \(formatSize(appState.cleanedAmount)) serbest kaldı" : (appState.hasScanned ? "▲ \(formatSize(cleanableSize)) temizlenebilir" : "Tarama yapılmadı")
                    let badgeColor: Color = hasCleaned ? .green : (appState.hasScanned ? .orange : .secondary)

                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(titleLabel)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.secondary)
                            Spacer()
                            Image(systemName: "info.circle")
                                .foregroundColor(.secondary)
                                .font(.caption2)
                        }
                        
                        Text(displaySize)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text(badgeLabel)
                            .font(.caption2)
                            .bold()
                            .foregroundColor(badgeColor)
                        
                        Spacer()
                        
                        // Live disk spaces math
                        let sysJunk = scannedSystemJunk
                        let filesSize = scannedFiles
                        let appsSize = scannedApps
                        
                        let totalCleanable = sysJunk + filesSize + appsSize
                        let sysPct = totalCleanable > 0 ? sysJunk / totalCleanable : 0.0
                        let filesPct = totalCleanable > 0 ? filesSize / totalCleanable : 0.0
                        let appsPct = totalCleanable > 0 ? appsSize / totalCleanable : 0.0
                        
                        // Proportional segment bar
                        SegmentedProgressBar(systemJunkPercent: sysPct, personalFilesPercent: filesPct, appsPercent: appsPct)
                        
                        Spacer()
                        
                        // Details Breakdown
                        VStack(spacing: 6) {
                            StatRowView(color: .green, title: "Sistem Çöpü", sizeStr: formatSize(Int64(sysJunk)))
                            StatRowView(color: .blue, title: "Kişisel Dosyalar", sizeStr: formatSize(Int64(filesSize)))
                            StatRowView(color: .purple, title: "Uygulamalar", sizeStr: formatSize(Int64(appsSize)))
                        }
                    }
                    .padding(18)
                    .frame(height: 230)
                    .background(Color.white.opacity(0.03))
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.05), lineWidth: 0.8))
                    
                    // Card 5: Scanned for Malware
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Güvenlik & Tehditler")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.secondary)
                            Spacer()
                            Image(systemName: "info.circle")
                                .foregroundColor(.secondary)
                                .font(.caption2)
                        }
                        
                        let totalItemsScanned = appState.hasScanned ? (appState.categories.reduce(0) { $0 + $1.items.count } + appState.largeFiles.count + appState.startupItems.count) : 0
                        Text(appState.hasScanned ? "\(totalItemsScanned) Öge" : "0 Öge")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(appState.hasScanned ? "▲ Tarandı ve Güvenli" : "Tarama yapılmadı")
                            .font(.caption2)
                            .bold()
                            .foregroundColor(appState.hasScanned ? .green : .secondary)
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            Image(systemName: "hand.raised.fill")
                                .font(.caption)
                                .foregroundColor(.white)
                                .frame(width: 20, height: 20)
                                .background(appState.hasScanned ? Color.pink : Color.gray)
                                .clipShape(Circle())
                            
                            Text("Tehdit Geçmişi: 0 zararlı öge")
                                .font(.system(size: 9.5))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(18)
                    .frame(height: 150)
                    .background(Color.white.opacity(0.02))
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.04), lineWidth: 0.8))
                }
                
                // Column 3: Time Saved & Cloud Cleanup
                VStack(spacing: 16) {
                    // Card 3: Total Time Saved
                    let sysJunkMB = Double(appState.systemDataSize) / (1024 * 1024)
                    let cleanedMB = Double(appState.cleanedAmount) / (1024 * 1024)
                    let disabledStartups = appState.startupItems.filter { !$0.isEnabled }.count
                    let hasCleaned = appState.cleanedAmount > 0
                    
                    let totalMinutes = (sysJunkMB * 0.1) + (cleanedMB * 0.2) + Double(disabledStartups * 15)
                    let minutesInt = max(Int(totalMinutes), 0)
                    let timeSavedStr = formatTimeSavedText(minutesInt)
                    
                    let timeBadgeStr = hasCleaned ? "▲ \(formatTimeSavedText(Int(cleanedMB * 0.2))) tasarruf edildi" : (appState.hasScanned ? "▲ \(formatTimeSavedText(Int(sysJunkMB * 0.1))) tasarruf edilebilir" : "Tarama yapılmadı")
                    let timeBadgeColor: Color = hasCleaned ? .green : (appState.hasScanned ? .orange : .secondary)

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Kazanılan Toplam Zaman")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.secondary)
                            Spacer()
                            Image(systemName: "info.circle")
                                .foregroundColor(.secondary)
                                .font(.caption2)
                        }
                        
                        Text(timeSavedStr)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text(timeBadgeStr)
                            .font(.caption2)
                            .bold()
                            .foregroundColor(timeBadgeColor)
                        
                        // Curved SVG Graph Line representation
                        CurveGraphView()
                            .frame(height: 48)
                            .padding(.top, 2)
                        
                        Spacer()
                        
                        // Time saved breakdown list
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Etkinlik Zamanı")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.secondary)
                            
                            Text("• Sistem Temizliği: + \(formatTimeSavedText(Int(sysJunkMB * 0.1)))")
                                .font(.system(size: 9))
                                .foregroundColor(.primary)
                            Text("• Kazanılan Zaman (Temizlik): + \(formatTimeSavedText(Int(cleanedMB * 0.2)))")
                                .font(.system(size: 9))
                                .foregroundColor(.primary)
                            Text("• Başlangıç Optimizasyonu: + \(formatTimeSavedText(disabledStartups * 15))")
                                .font(.system(size: 9))
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(18)
                    .frame(height: 230)
                    .background(Color.white.opacity(0.03))
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.05), lineWidth: 0.8))
                    
                    // Card 6: Cloud Cleanup
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Bulut Alan Ölçümü")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.secondary)
                            Spacer()
                            Image(systemName: "cloud.fill")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        
                        Text("Bulut Depolama")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Serbest kalan GB'ları saymak için bulut hesabını bağlayın.")
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Spacer()
                        
                        Button(action: {
                            appState.selectedTab = .settings
                        }) {
                            Text("Bulut Temizliğine Git")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color.white.opacity(0.08))
                                .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(18)
                    .frame(height: 150)
                    .background(Color.white.opacity(0.02))
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.04), lineWidth: 0.8))
                }
            }
            
            // Bottom Action buttons triggers Scan/Re-scan
            HStack {
                Spacer()
                Button(action: {
                    withAnimation(.spring()) {
                        appState.startScan()
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.clockwise")
                        Text(appState.hasScanned ? "Mac'i Yeniden Tara" : "Mac'i Tara ve Analiz Et")
                            .bold()
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .foregroundColor(.white)
                    .background(LinearGradient(gradient: Gradient(colors: [.indigo, .purple]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .cornerRadius(20)
                    .shadow(color: .purple.opacity(0.25), radius: 10)
                }
                .buttonStyle(PlainButtonStyle())
                Spacer()
            }
            .padding(.top, 8)
        }
        .padding(12)
    }
}

// 1. Proportional Segmented Progress Bar
struct SegmentedProgressBar: View {
    let systemJunkPercent: Double
    let personalFilesPercent: Double
    let appsPercent: Double
    
    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 1.5) {
                if systemJunkPercent > 0 {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.green)
                        .frame(width: max(geo.size.width * CGFloat(systemJunkPercent), 6))
                }
                
                if personalFilesPercent > 0 {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.blue)
                        .frame(width: max(geo.size.width * CGFloat(personalFilesPercent), 6))
                }
                
                if appsPercent > 0 {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.purple)
                        .frame(width: max(geo.size.width * CGFloat(appsPercent), 6))
                }
            }
        }
        .frame(height: 6)
        .cornerRadius(3)
        .background(Color.white.opacity(0.06))
    }
}

// 2. Stat row view helper for Card 2 breakdown
struct StatRowView: View {
    let color: Color
    let title: String
    let sizeStr: String
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text(title)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
            Spacer()
            Text(sizeStr)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.primary)
        }
    }
}

// 3. Curved Line Graph View representing saved times
struct CurveGraphView: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Path { path in
                    path.move(to: CGPoint(x: 0, y: geo.size.height * 0.85))
                    path.addCurve(
                        to: CGPoint(x: geo.size.width, y: geo.size.height * 0.2),
                        control1: CGPoint(x: geo.size.width * 0.35, y: geo.size.height * 0.9),
                        control2: CGPoint(x: geo.size.width * 0.65, y: geo.size.height * 0.1)
                    )
                }
                .stroke(
                    LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.cyan]), startPoint: .leading, endPoint: .trailing),
                    style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                )
                
                // Glowing coordinate dot
                Circle()
                    .fill(Color.white)
                    .frame(width: 7, height: 7)
                    .shadow(color: .cyan, radius: 4)
                    .position(x: geo.size.width * 0.85, y: geo.size.height * 0.3)
            }
        }
    }
}

func formatSize(_ bytes: Int64) -> String {
    ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
}

func formatTimeSavedText(_ minutes: Int) -> String {
    if minutes <= 0 { return "0 Dakika" }
    let days = minutes / 1440
    let hours = (minutes % 1440) / 60
    let mins = minutes % 60
    
    var result = ""
    if days > 0 { result += "\(days) Gün " }
    if hours > 0 { result += "\(hours) Saat " }
    if mins > 0 || result.isEmpty { result += "\(mins) Dakika" }
    return result.trimmingCharacters(in: .whitespaces)
}
