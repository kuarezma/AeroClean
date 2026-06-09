import SwiftUI

struct ThemeBackgroundView: View {
    let tab: AppState.Tab
    
    var body: some View {
        let colors: [Color]
        switch tab {
        case .dashboard:
            colors = [
                Color(red: 0.18, green: 0.05, blue: 0.35),
                Color(red: 0.08, green: 0.02, blue: 0.18)
            ]
        case .systemClean:
            colors = [
                Color(red: 0.02, green: 0.22, blue: 0.10),
                Color(red: 0.01, green: 0.10, blue: 0.05)
            ]
        case .largeFiles:
            colors = [
                Color(red: 0.25, green: 0.10, blue: 0.02),
                Color(red: 0.12, green: 0.05, blue: 0.01)
            ]
        case .startups:
            colors = [
                Color(red: 0.05, green: 0.10, blue: 0.30),
                Color(red: 0.02, green: 0.05, blue: 0.15)
            ]
        case .uninstaller:
            colors = [
                Color(red: 0.02, green: 0.12, blue: 0.28),
                Color(red: 0.01, green: 0.05, blue: 0.14)
            ]
        case .developer:
            colors = [
                Color(red: 0.22, green: 0.05, blue: 0.30),
                Color(red: 0.10, green: 0.02, blue: 0.15)
            ]
        case .settings:
            colors = [
                Color(red: 0.10, green: 0.10, blue: 0.15),
                Color(red: 0.05, green: 0.05, blue: 0.08)
            ]
        }
        
        return LinearGradient(
            gradient: Gradient(colors: colors),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .edgesIgnoringSafeArea(.all)
    }
}
