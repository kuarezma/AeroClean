import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("AeroClean Dashboard")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Text("Mac'inizi tarayın, performansı artırın ve gigabaytlarca yer açın.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal, 8)
            
            HStack(spacing: 24) {
                // Storage Gauge Card
                VStack(spacing: 16) {
                    Text("Disk Durumu")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    StorageGaugeView(
                        used: appState.usedSpace,
                        free: appState.freeSpace,
                        total: appState.totalSpace,
                        systemData: appState.systemDataSize,
                        hasScanned: appState.hasScanned
                    )
                    .frame(height: 220)
                    
                    // Stats Breakdown
                    HStack(spacing: 20) {
                        StatLabelView(color: .blue, title: "Kullanılan", value: formatSize(appState.usedSpace))
                        StatLabelView(color: .green, title: "Boş Alan", value: formatSize(appState.freeSpace))
                        if appState.hasScanned {
                            StatLabelView(color: .purple, title: "Sistem Verileri", value: formatSize(appState.systemDataSize))
                        }
                    }
                }
                .padding(24)
                .background(Color(.windowBackgroundColor).opacity(0.4))
                .background(.ultraThinMaterial)
                .cornerRadius(18)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                
                // Scan Trigger & System Info Card
                VStack(spacing: 20) {
                    // System Details
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Sistem Bilgileri")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Divider().opacity(0.3)
                        
                        SystemInfoRow(icon: "macbook", title: "Mac Cihazı", value: getMacModelName())
                        SystemInfoRow(icon: "cpu", title: "İşlemci", value: "\(ProcessInfo.processInfo.activeProcessorCount) Çekirdekli Çip")
                        SystemInfoRow(icon: "info.circle", title: "macOS Sürümü", value: getOSVersion())
                    }
                    .padding(20)
                    .background(Color(.windowBackgroundColor).opacity(0.2))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.05), lineWidth: 1)
                    )
                    
                    Spacer()
                    
                    // Scan button and progress
                    VStack(spacing: 12) {
                        if appState.isScanning {
                            VStack(spacing: 8) {
                                ProgressView(value: appState.scanProgress)
                                    .progressViewStyle(LinearProgressViewStyle(tint: .purple))
                                    .frame(height: 8)
                                    .cornerRadius(4)
                                
                                Text(appState.currentScanningCategory)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                
                                Text("%\(Int(appState.scanProgress * 100))")
                                    .font(.headline)
                                    .bold()
                                    .foregroundColor(.purple)
                            }
                        } else {
                            Button(action: {
                                withAnimation(.spring()) {
                                    appState.startScan()
                                }
                            }) {
                                HStack(spacing: 10) {
                                    Image(systemName: "magnifyingglass.circle.fill")
                                        .font(.title2)
                                    Text(appState.hasScanned ? "Yeniden Tara" : "Mac'i Tara")
                                        .font(.headline)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .foregroundColor(.white)
                                .background(
                                    LinearGradient(gradient: Gradient(colors: [Color.indigo, Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .cornerRadius(12)
                                .shadow(color: Color.purple.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            if appState.hasScanned {
                                Text("Tarama tamamlandı. Yan menüden detayları inceleyip temizleyebilirsiniz.")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                    .multilineTextAlignment(.center)
                            }
                        }
                    }
                }
                .frame(maxWidth: 340)
                .padding(24)
                .background(Color(.windowBackgroundColor).opacity(0.4))
                .background(.ultraThinMaterial)
                .cornerRadius(18)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            }
            
            // Bottom quick summary dashboard cards (if scanned)
            if appState.hasScanned {
                HStack(spacing: 16) {
                    DashboardSummaryCard(
                        title: "Önerilen Temizlik",
                        sizeStr: formatSize(getRecommendedSize()),
                        icon: "checkmark.shield.fill",
                        color: .green,
                        description: "Sistem önbellekleri ve logları güvenle silinebilir.",
                        action: { appState.selectedTab = .systemClean }
                    )
                    
                    DashboardSummaryCard(
                        title: "Geliştirici Dosyaları",
                        sizeStr: formatSize(getDeveloperSize()),
                        icon: "hammer.fill",
                        color: .purple,
                        description: "Xcode Derived Data ve simülatör artıkları.",
                        action: { appState.selectedTab = .developer }
                    )
                    
                    DashboardSummaryCard(
                        title: "Büyük Dosyalar",
                        sizeStr: formatSize(getLargeFilesSize()),
                        icon: "doc.on.doc.fill",
                        color: .orange,
                        description: "Home klasöründeki 100MB+ büyüklüğündeki dosyalar.",
                        action: { appState.selectedTab = .largeFiles }
                    )
                }
            } else {
                // Info block
                HStack(spacing: 16) {
                    InfoBlockView(icon: "shield.fill", color: .green, title: "Güvenli Silme", desc: "AeroClean, sisteminizin stabil çalışması için gerekli hiçbir dosyayı silmez.")
                    InfoBlockView(icon: "sparkles", color: .blue, title: "Detaylı Tavsiyeler", desc: "Her klasör ve dosya için ne olduğu, riskleri ve temizleme tavsiyeleri gösterilir.")
                    InfoBlockView(icon: "terminal.fill", color: .purple, title: "Geliştirici Dostu", desc: "Derived Data, paket önbellekleri gibi devasa yer kaplayan yazılımcı çöplerini bulur.")
                }
                .padding(.top, 8)
            }
        }
        .padding(12)
    }
    
    // Helpers
    private func formatSize(_ bytes: Int64) -> String {
        ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
    }
    
    private func getRecommendedSize() -> Int64 {
        appState.categories
            .filter { $0.category.safetyLevel == .recommended }
            .reduce(0) { $0 + $1.totalSize }
    }
    
    private func getDeveloperSize() -> Int64 {
        appState.categories
            .filter { $0.category == .xcodeDerivedData || $0.category == .xcodeSimulators || $0.category == .packageCaches }
            .reduce(0) { $0 + $1.totalSize }
    }
    
    private func getLargeFilesSize() -> Int64 {
        appState.largeFiles.reduce(0) { $0 + $1.size }
    }
    
    private func getMacModelName() -> String {
        // Approximate model info or run a quick command. We will return a static standard or read from ProcessInfo
        #if arch(arm64)
        return "Apple Silicon Mac"
        #else
        return "Intel Core Mac"
        #endif
    }
    
    private func getOSVersion() -> String {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        return "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
    }
}

// Custom Circular Gauge
struct StorageGaugeView: View {
    let used: Int64
    let free: Int64
    let total: Int64
    let systemData: Int64
    let hasScanned: Bool
    
    var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(Color.primary.opacity(0.05), lineWidth: 24)
            
            // Used Space arc
            Circle()
                .trim(from: 0.0, to: CGFloat(Double(used) / max(Double(total), 1.0)))
                .stroke(
                    LinearGradient(gradient: Gradient(colors: [.blue, .indigo]), startPoint: .top, endPoint: .bottom),
                    style: StrokeStyle(lineWidth: 24, lineCap: .round)
                )
                .rotationEffect(Angle(degrees: -90))
                .animation(.easeOut(duration: 1.0), value: used)
            
            // System Data Highlight arc (nested or layered)
            if hasScanned && systemData > 0 {
                Circle()
                    .trim(from: 0.0, to: CGFloat(Double(systemData) / max(Double(total), 1.0)))
                    .stroke(
                        LinearGradient(gradient: Gradient(colors: [.purple, .pink]), startPoint: .top, endPoint: .bottom),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(Angle(degrees: -90))
                    .padding(18)
                    .animation(.easeOut(duration: 1.0), value: systemData)
            }
            
            // Text center labels
            VStack(spacing: 4) {
                Text(ByteCountFormatter.string(fromByteCount: free, countStyle: .file))
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                Text("Boş Alan")
                    .font(.caption)
                    .bold()
                    .foregroundColor(.secondary)
                Text("Toplam: \(ByteCountFormatter.string(fromByteCount: total, countStyle: .file))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding(10)
    }
}

struct StatLabelView: View {
    let color: Color
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.caption)
                    .bold()
                    .foregroundColor(.primary)
            }
        }
    }
}

struct SystemInfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 24, height: 24)
                .foregroundColor(.indigo)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            Spacer()
        }
    }
}

struct InfoBlockView: View {
    let icon: String
    let color: Color
    let title: String
    let desc: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .padding(8)
                .background(color.opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .bold()
                Text(desc)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.windowBackgroundColor).opacity(0.3))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
}

struct DashboardSummaryCard: View {
    let title: String
    let sizeStr: String
    let icon: String
    let color: Color
    let description: String
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(color)
                    Spacer()
                    Image(systemName: "arrow.right.circle.fill")
                        .foregroundColor(.secondary.opacity(isHovered ? 0.8 : 0.4))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(sizeStr)
                        .font(.title3)
                        .bold()
                        .foregroundColor(.primary)
                }
                
                Text(description)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(height: 28, alignment: .topLeading)
            }
            .padding(16)
            .background(Color(.windowBackgroundColor).opacity(isHovered ? 0.5 : 0.3))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(isHovered ? 0.4 : 0.1), lineWidth: 1)
            )
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isHovered)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hover in
            isHovered = hover
        }
    }
}
