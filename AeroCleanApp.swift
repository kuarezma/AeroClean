import SwiftUI

@main
struct AeroCleanApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            MainContainerView()
                .environmentObject(appState)
                .frame(minWidth: 1050, minHeight: 650)
        }
        .windowStyle(.hiddenTitleBar)
    }
}

// Main Window Container View
struct MainContainerView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack(spacing: 0) {
            // Sidebar Panel
            SidebarView()
                .frame(width: 210)
                .background(VisualEffectView(material: .sidebar, blendingMode: .behindWindow))
            
            // Divider line
            Rectangle()
                .fill(Color.black.opacity(0.15))
                .frame(width: 1)
                .edgesIgnoringSafeArea(.all)
            
            // Content Area based on active navigation selection
            ZStack {
                VisualEffectView(material: .underWindowBackground, blendingMode: .behindWindow)
                    .edgesIgnoringSafeArea(.all)
                
                ThemeBackgroundView(tab: appState.selectedTab)
                    .opacity(0.82)
                    .animation(.easeInOut(duration: 0.4), value: appState.selectedTab)
                    .edgesIgnoringSafeArea(.all)
                
                Group {
                    switch appState.selectedTab {
                    case .dashboard:
                        DashboardView()
                    case .systemClean:
                        SystemCleanView()
                    case .largeFiles:
                        LargeFilesView()
                    case .startups:
                        StartupsView()
                    case .uninstaller:
                        UninstallerView()
                    case .developer:
                        DeveloperCleanView()
                    case .settings:
                        SettingsView()
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .trailing)))
                .padding(20)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

// Sidebar Navigation
struct SidebarView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Window control spacing or logo header
            HStack(spacing: 10) {
                Circle()
                    .fill(LinearGradient(gradient: Gradient(colors: [.indigo, .purple]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 28, height: 28)
                    .overlay(
                        Image(systemName: "sparkles")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 1) {
                    Text("AeroClean")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Text("macOS Optimizer")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.top, 54) // Safe offset for system close/minimize traffic light buttons
            .padding(.bottom, 32)
            .padding(.horizontal, 20)
            
            // Navigation tabs
            VStack(spacing: 4) {
                ForEach(AppState.Tab.allCases, id: \.self) { tab in
                    SidebarButton(
                        tab: tab,
                        isSelected: appState.selectedTab == tab,
                        action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                appState.selectedTab = tab
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 10)
            
            Spacer()
            
            // Disk health indicator in sidebar bottom
            SidebarDiskWidget()
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            
            // Developer signature
            Text("Uğur Yaşayan tarafından üretildi")
                .font(.system(size: 9))
                .foregroundColor(.secondary.opacity(0.7))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 16)
        }
    }
}

struct SidebarButton: View {
    let tab: AppState.Tab
    let isSelected: Bool
    let action: () -> Void
    @State private var isHovered = false
    
    var tabColor: Color {
        switch tab {
        case .dashboard: return .purple
        case .systemClean: return .green
        case .largeFiles: return .orange
        case .startups: return .blue
        case .uninstaller: return .red
        case .developer: return .pink
        case .settings: return .gray
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Active indicator capsule on the far left
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(isSelected ? tabColor : Color.clear)
                    .frame(width: 3, height: 16)
                
                // Icon tile
                Image(systemName: tab.iconName)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(isSelected ? .white : tabColor)
                    .frame(width: 24, height: 24)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(isSelected ? tabColor : tabColor.opacity(0.1))
                    )
                    .shadow(color: isSelected ? tabColor.opacity(0.3) : Color.clear, radius: 4, x: 0, y: 2)
                
                Text(tab.rawValue)
                    .font(.system(size: 12.5, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? .white : .primary.opacity(0.85))
                
                Spacer()
            }
            .padding(.vertical, 5)
            .padding(.leading, 4)
            .padding(.trailing, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.white.opacity(0.06) : (isHovered ? Color.white.opacity(0.03) : Color.clear))
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hover in
            isHovered = hover
        }
    }
}

struct SidebarDiskWidget: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "harddrive.fill")
                    .foregroundColor(.secondary)
                    .font(.caption)
                Text("Disk Doluluğu")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.secondary)
            }
            
            let usedPercentage = Double(appState.usedSpace) / max(Double(appState.totalSpace), 1.0)
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.primary.opacity(0.1))
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 3)
                        .fill(LinearGradient(gradient: Gradient(colors: [.blue, .indigo]), startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * CGFloat(usedPercentage), height: 6)
                }
            }
            .frame(height: 6)
            
            HStack {
                Text(ByteCountFormatter.string(fromByteCount: appState.freeSpace, countStyle: .file) + " boş")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                Spacer()
                Text(String(format: "%%%.1f", usedPercentage * 100))
                    .font(.system(size: 9))
                    .bold()
                    .foregroundColor(.primary)
            }
        }
        .padding(12)
        .background(Color.primary.opacity(0.03))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.primary.opacity(0.05), lineWidth: 1)
        )
    }
}

// Vibrant background blur view utility
struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
