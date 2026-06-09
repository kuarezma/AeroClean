import SwiftUI

struct DeveloperCleanView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedCategory: CleanCategory = .xcodeDerivedData
    
    let developerCategories: [CleanCategory] = [.xcodeDerivedData, .xcodeSimulators, .packageCaches]
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Geliştirici Önbellek Temizliği")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                    Text("Xcode ve paket yöneticilerinin (Brew, npm, Cargo) biriktirdiği gigabaytlarca önbelleği temizleyin.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                
                if appState.hasScanned {
                    Button(action: {
                        appState.cleanSelected(forTab: .developer)
                    }) {
                        HStack {
                            Image(systemName: "hammer.fill")
                            Text("Geliştirici Önbelleklerini Sil (\(formatSize(getSelectedSize())))")
                                .bold()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .foregroundColor(.white)
                        .background(getSelectedSize() > 0 ? Color.purple : Color.gray)
                        .cornerRadius(8)
                    }
                    .disabled(getSelectedSize() == 0 || appState.isCleaning)
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 8)
            
            if !appState.hasScanned {
                // Scan required
                VStack(spacing: 20) {
                    Image(systemName: "hammer.circle.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.purple.opacity(0.8))
                        .padding()
                        .background(Color.purple.opacity(0.1))
                        .clipShape(Circle())
                    
                    Text("Geliştirici Verileri Henüz Taranmadı")
                        .font(.title3)
                        .bold()
                    
                    Text("Xcode derleme çıktılarını ve paket önbelleklerini analiz etmek için tarama başlatın.")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 400)
                    
                    Button(action: {
                        appState.startScan()
                    }) {
                        Text("Yazılımcı Dosyalarını Tara")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.purple)
                            .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .frame(maxHeight: .infinity)
            } else {
                // Scanned View
                HStack(alignment: .top, spacing: 16) {
                    // Left Column: The 3 major developer categories
                    VStack(spacing: 12) {
                        ForEach(developerCategories, id: \.self) { cat in
                            if let detail = appState.categories.first(where: { $0.category == cat }) {
                                Button(action: {
                                    selectedCategory = cat
                                }) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Image(systemName: cat.iconName)
                                                .font(.headline)
                                                .foregroundColor(selectedCategory == cat ? .white : .purple)
                                            Spacer()
                                            
                                            Button(action: {
                                                appState.toggleCategorySelection(category: cat)
                                            }) {
                                                Image(systemName: detail.isSelected ? "checkmark.circle.fill" : "circle")
                                                    .foregroundColor(selectedCategory == cat ? .white : (detail.isSelected ? .green : .secondary))
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                        
                                        Text(cat.displayName)
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(selectedCategory == cat ? .white : .primary)
                                        
                                        HStack {
                                            Text(detail.formattedTotalSize)
                                                .font(.title3)
                                                .bold()
                                                .foregroundColor(selectedCategory == cat ? .white : .primary)
                                            Spacer()
                                            Text(cat.safetyLevel == .recommended ? "🟢 Önerilen" : "🟡 Dikkat Et")
                                                .font(.system(size: 9))
                                                .bold()
                                                .foregroundColor(selectedCategory == cat ? .white.opacity(0.8) : .secondary)
                                        }
                                    }
                                    .padding(16)
                                    .background(selectedCategory == cat ? Color.purple.opacity(0.8) : Color.black.opacity(0.15))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.purple.opacity(selectedCategory == cat ? 0.8 : 0.1), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        Spacer()
                    }
                    .frame(width: 250)
                    
                    // Middle Column: Sub-items breakdown of selected developer cache
                    VStack(alignment: .leading, spacing: 12) {
                        Text("\(selectedCategory.displayName) Klasörleri")
                            .font(.headline)
                        
                        if let catDetail = appState.categories.first(where: { $0.category == selectedCategory }) {
                            if catDetail.items.isEmpty {
                                VStack(spacing: 12) {
                                    Spacer()
                                    Image(systemName: "checkmark.seal.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.green)
                                    Text("Bu önbellek klasörü tertemiz!")
                                        .foregroundColor(.secondary)
                                        .font(.subheadline)
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color.black.opacity(0.1))
                                .cornerRadius(12)
                            } else {
                                ScrollView {
                                    LazyVStack(spacing: 6) {
                                        ForEach(catDetail.items) { item in
                                            HStack {
                                                Button(action: {
                                                    appState.toggleItemSelection(category: selectedCategory, itemId: item.id)
                                                }) {
                                                    Image(systemName: item.isSelected ? "checkmark.square.fill" : "square")
                                                        .foregroundColor(item.isSelected ? .purple : .secondary)
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                                
                                                Image(systemName: "folder.fill")
                                                    .foregroundColor(.yellow)
                                                
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(item.name)
                                                        .font(.system(size: 11, weight: .bold))
                                                    Text(item.path)
                                                        .font(.system(size: 9))
                                                        .foregroundColor(.secondary)
                                                        .lineLimit(1)
                                                        .truncationMode(.middle)
                                                }
                                                Spacer()
                                                Text(item.formattedSize)
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
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(16)
                    .background(Color(.windowBackgroundColor).opacity(0.2))
                    .cornerRadius(12)
                    
                    // Right Column: Advice panel
                    AdvicePanel(category: selectedCategory)
                        .frame(width: 280)
                }
                .frame(maxHeight: .infinity)
            }
        }
        .padding(12)
        .alert(isPresented: $appState.showCleanSuccessAlert) {
            Alert(
                title: Text("Yazılımcı Önbellekleri Temizlendi"),
                message: Text("Seçilen geliştirici önbellekleri başarıyla kaldırıldı.\n\nSerbest Bırakılan Alan: \(formatSize(appState.cleanedAmount))"),
                dismissButton: .default(Text("Tamam"))
            )
        }
    }
    
    // Helpers
    private func getSelectedSize() -> Int64 {
        var size: Int64 = 0
        for cat in developerCategories {
            if let detail = appState.categories.first(where: { $0.category == cat }) {
                for item in detail.items {
                    if item.isSelected {
                        size += item.size
                    }
                }
            }
        }
        return size
    }
    
    private func formatSize(_ bytes: Int64) -> String {
        ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
    }
}
