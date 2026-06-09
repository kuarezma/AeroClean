import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack {
            // Main Content Area
            VStack {
                if appState.isScanning {
                    ScanningView()
                } else if appState.hasScanned {
                    ScannedDashboardView()
                } else {
                    ReadyScanView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.bottom, 72) // Safe space for the floating bottom action button
            
            // Bottom Center Action Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    if appState.isScanning {
                        BottomCircularActionButton(title: "Durdur", color: .purple) {
                            appState.isScanning = false
                        }
                    } else {
                        BottomCircularActionButton(
                            title: appState.hasScanned ? "Yeniden" : "Tara",
                            color: .indigo
                        ) {
                            withAnimation(.spring()) {
                                appState.startScan()
                            }
                        }
                    }
                    Spacer()
                }
            }
            .edgesIgnoringSafeArea(.bottom)
        }
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

// 1. Ready Scan View (Smart Care Landing Page)
struct ReadyScanView: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Glowing System Display Icon
            ZStack {
                Circle()
                    .fill(RadialGradient(gradient: Gradient(colors: [Color.indigo.opacity(0.35), Color.clear]), center: .center, startRadius: 10, endRadius: 110))
                    .frame(width: 240, height: 240)
                
                Image(systemName: "desktopcomputer")
                    .font(.system(size: 110, weight: .thin))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [.white, .purple.opacity(0.8), .indigo]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .purple.opacity(0.4), radius: 24)
            }
            
            // Title & Description
            VStack(spacing: 8) {
                Text("Akıllı Bakım (Smart Care)")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Tek dokunuşla diskinizde yer açın ve sisteminizi optimize edin.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 420)
            }
            
            // Checklist of essentials
            VStack(alignment: .leading, spacing: 14) {
                BulletPointView(icon: "sparkles", color: .green, title: "Hızlı Temizlik", desc: "Önbellek, log ve sistem artıklarını tespit eder.")
                BulletPointView(icon: "bolt.horizontal.fill", color: .orange, title: "Performans Arttırıcı", desc: "Arka plan servislerini ve başlangıç ögelerini denetler.")
                BulletPointView(icon: "doc.on.doc.fill", color: .blue, title: "Büyük Dosya Taraması", desc: "Diskte en çok yer kaplayan dosyaları listeler.")
            }
            .padding(20)
            .background(Color.white.opacity(0.03))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
            .frame(maxWidth: 440)
            
            Spacer()
        }
    }
}

// 2. Active Scanning View
struct ScanningView: View {
    @EnvironmentObject var appState: AppState
    @State private var rotationAngle = 0.0
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Spinning Glass Orb
            ZStack {
                Circle()
                    .fill(RadialGradient(gradient: Gradient(colors: [.indigo.opacity(0.4), .purple.opacity(0.1), .clear]), center: .center, startRadius: 5, endRadius: 100))
                    .frame(width: 200, height: 200)
                
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [.purple, .indigo, .pink, .clear]),
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 6
                    )
                    .frame(width: 140, height: 140)
                    .rotationEffect(Angle(degrees: rotationAngle))
                    .onAppear {
                        withAnimation(Animation.linear(duration: 2.5).repeatForever(autoreverses: false)) {
                            rotationAngle = 360.0
                        }
                    }
                
                Image(systemName: "sparkles")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                    .shadow(color: .purple.opacity(0.8), radius: 12)
            }
            
            // Scanning Status Labels
            VStack(spacing: 8) {
                Text("Gereksiz Dosyalar Aranıyor...")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.white)
                
                Text(appState.currentScanningCategory)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .padding(.horizontal, 24)
            }
            
            // Detailed Progress Bar
            VStack(spacing: 8) {
                ProgressView(value: appState.scanProgress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .purple))
                    .frame(height: 6)
                    .cornerRadius(3)
                
                Text("%\(Int(appState.scanProgress * 100))")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.purple)
            }
            .frame(maxWidth: 320)
            
            Spacer()
        }
    }
}

// 3. Scanned Result Dashboard View
struct ScannedDashboardView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("AeroClean Dashboard")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Text("Tarama tamamlandı. Aşağıdan veya yan menüden temizliğe başlayın.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal, 8)
            
            // Grid Split
            HStack(spacing: 20) {
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
                    .frame(height: 200)
                    
                    HStack(spacing: 20) {
                        StatLabelView(color: .blue, title: "Kullanılan", value: formatSize(appState.usedSpace))
                        StatLabelView(color: .green, title: "Boş Alan", value: formatSize(appState.freeSpace))
                        StatLabelView(color: .purple, title: "Sistem Verileri", value: formatSize(appState.systemDataSize))
                    }
                }
                .padding(20)
                .background(Color.white.opacity(0.03))
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
                
                // System Info Card
                VStack(alignment: .leading, spacing: 14) {
                    Text("Sistem Bilgileri")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Divider().opacity(0.2)
                    
                    SystemInfoRow(icon: "macbook", title: "Mac Cihazı", value: getMacModelName())
                    SystemInfoRow(icon: "cpu", title: "İşlemci", value: "\(ProcessInfo.processInfo.activeProcessorCount) Çekirdekli Çip")
                    SystemInfoRow(icon: "info.circle", title: "macOS Sürümü", value: getOSVersion())
                    
                    Spacer()
                }
                .padding(20)
                .frame(maxWidth: 340)
                .background(Color.white.opacity(0.02))
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
            }
            .frame(maxHeight: .infinity)
            
            // Shortcuts Bottom Cards
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
        }
    }
    
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

// Helper Bullet Point for Landing checklist
struct BulletPointView: View {
    let icon: String
    let color: Color
    let title: String
    let desc: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(color)
                .frame(width: 20, height: 20)
                .background(color.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                Text(desc)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
        }
    }
}

// 4. Circular action button component
struct BottomCircularActionButton: View {
    let title: String
    let color: Color
    let action: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.black.opacity(0.75))
                
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [color, color.opacity(0.5), .pink]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3.5
                    )
            }
            .frame(width: 84, height: 84)
            .shadow(color: color.opacity(0.5), radius: isHovered ? 16 : 8)
            .overlay(
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
            )
            .scaleEffect(isHovered ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isHovered)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hover in
            isHovered = hover
        }
        .padding(.bottom, 20)
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
