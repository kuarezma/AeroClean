import SwiftUI

struct SystemCleanView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedCategory: CleanCategory = .systemCache
    @State private var selectedSafetyFilter: SafetyLevel = .recommended
    @State private var hoveredItemId: String? = nil
    
    var body: some View {
        VStack(spacing: 16) {
            // Header with overall action
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sistem Verileri Temizliği")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                    Text("Detaylı önbellek, log ve uygulama artıklarını analiz edin.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                
                if appState.hasScanned {
                    Button(action: {
                        appState.cleanSelected(forTab: .systemClean)
                    }) {
                        HStack {
                            Image(systemName: "sparkles")
                            Text("Seçilenleri Temizle (\(formatSize(getSelectedSize())))")
                                .bold()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .foregroundColor(.white)
                        .background(getSelectedSize() > 0 ? Color.blue : Color.gray)
                        .cornerRadius(8)
                    }
                    .disabled(getSelectedSize() == 0 || appState.isCleaning)
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 8)
            
            if !appState.hasScanned {
                // Not scanned state
                VStack(spacing: 20) {
                    Image(systemName: "cpu")
                        .font(.system(size: 64))
                        .foregroundColor(.indigo.opacity(0.8))
                        .padding()
                        .background(Color.indigo.opacity(0.1))
                        .clipShape(Circle())
                    
                    Text("Sistem Verileri Henüz Taranmadı")
                        .font(.title3)
                        .bold()
                    
                    Text("Bilgisayarınızdaki önbellekleri, günlükleri ve diğer sistem verilerini analiz etmek için tarama başlatın.")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 400)
                    
                    Button(action: {
                        appState.startScan()
                    }) {
                        Text("Sistem Verilerini Tara")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .frame(maxHeight: .infinity)
            } else {
                // Active Scan Data View
                VStack(spacing: 16) {
                    // Safety Category Filters Tab
                    HStack(spacing: 0) {
                        ForEach(SafetyLevel.allCases, id: \.self) { level in
                            Button(action: {
                                withAnimation {
                                    selectedSafetyFilter = level
                                    // Auto-select first category in this filter
                                    if let firstCat = CleanCategory.allCases.first(where: { $0.safetyLevel == level }) {
                                        selectedCategory = firstCat
                                    }
                                }
                            }) {
                                HStack(spacing: 6) {
                                    Circle()
                                        .fill(getSafetyColor(level))
                                        .frame(width: 8, height: 8)
                                    Text(level.title)
                                        .font(.subheadline)
                                        .bold(selectedSafetyFilter == level)
                                }
                                .padding(.vertical, 10)
                                .padding(.horizontal, 16)
                                .foregroundColor(selectedSafetyFilter == level ? .primary : .secondary)
                                .background(selectedSafetyFilter == level ? Color.white.opacity(0.1) : Color.clear)
                                .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(4)
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Main Tri-Pane View: Categories (Left), File List (Middle), Advice Panel (Right)
                    HStack(alignment: .top, spacing: 16) {
                        // Pane 1: Categories list for this safety level
                        VStack(spacing: 10) {
                            ScrollView {
                                VStack(spacing: 8) {
                                    ForEach(getCategoriesForFilter(), id: \.id) { catDetail in
                                        CategoryRowView(
                                            detail: catDetail,
                                            isSelected: selectedCategory == catDetail.category,
                                            onSelect: {
                                                selectedCategory = catDetail.category
                                            },
                                            onToggle: {
                                                appState.toggleCategorySelection(category: catDetail.category)
                                            }
                                        )
                                    }
                                }
                                .padding(.trailing, 4)
                            }
                        }
                        .frame(width: 250)
                        
                        // Pane 2: Detailed contents of active category
                        VStack(alignment: .leading, spacing: 12) {
                            Text("\(selectedCategory.displayName) İçeriği")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            if let catDetail = appState.categories.first(where: { $0.category == selectedCategory }) {
                                if catDetail.items.isEmpty {
                                    VStack(spacing: 12) {
                                        Spacer()
                                        Image(systemName: "checkmark.circle")
                                            .font(.system(size: 40))
                                            .foregroundColor(.green)
                                        Text("Bu klasör tamamen temiz!")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(Color.black.opacity(0.1))
                                    .cornerRadius(12)
                                } else {
                                    // Header controls (Select all)
                                    HStack {
                                        Button(action: {
                                            appState.toggleCategorySelection(category: selectedCategory)
                                        }) {
                                            HStack(spacing: 6) {
                                                Image(systemName: catDetail.isSelected ? "checkmark.square.fill" : "square")
                                                    .foregroundColor(catDetail.isSelected ? .blue : .secondary)
                                                Text("Tümünü Seç / Kaldır")
                                                    .font(.caption)
                                                    .bold()
                                            }
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        Spacer()
                                        Text("\(catDetail.items.count) öge listede")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal, 8)
                                    
                                    // Items List
                                    ScrollView {
                                        LazyVStack(spacing: 6) {
                                            ForEach(catDetail.items) { item in
                                                ItemRowView(
                                                    item: item,
                                                    onToggle: {
                                                        appState.toggleItemSelection(category: selectedCategory, itemId: item.id)
                                                    }
                                                )
                                            }
                                        }
                                        .padding(.trailing, 4)
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(16)
                        .background(Color(.windowBackgroundColor).opacity(0.2))
                        .cornerRadius(12)
                        
                        // Pane 3: Advice and Warning Card
                        AdvicePanel(category: selectedCategory)
                            .frame(width: 280)
                    }
                }
                .frame(maxHeight: .infinity)
            }
        }
        .padding(12)
        .alert(isPresented: $appState.showCleanSuccessAlert) {
            Alert(
                title: Text("Temizlik Tamamlandı"),
                message: Text("Seçtiğiniz gereksiz veriler güvenle silindi.\n\nSerbest Bırakılan Alan: \(formatSize(appState.cleanedAmount))"),
                dismissButton: .default(Text("Tamam"))
            )
        }
    }
    
    // Helpers
    private func getSafetyColor(_ level: SafetyLevel) -> Color {
        switch level {
        case .recommended: return .green
        case .caution: return .orange
        case .danger: return .red
        }
    }
    
    private func getCategoriesForFilter() -> [CategoryDetail] {
        appState.categories.filter { $0.category.safetyLevel == selectedSafetyFilter }
    }
    
    private func getSelectedSize() -> Int64 {
        var size: Int64 = 0
        for cat in appState.categories {
            for item in cat.items {
                if item.isSelected {
                    size += item.size
                }
            }
        }
        return size
    }
    
    private func formatSize(_ bytes: Int64) -> String {
        ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
    }
}

// Row component for listing main Clean Categories
struct CategoryRowView: View {
    let detail: CategoryDetail
    let isSelected: Bool
    let onSelect: () -> Void
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            // Checkbox
            Button(action: onToggle) {
                Image(systemName: detail.isSelected ? "checkmark.square.fill" : "square")
                    .foregroundColor(detail.isSelected ? .blue : .secondary)
                    .font(.title3)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Row body click targets selection
            Button(action: onSelect) {
                HStack {
                    Image(systemName: detail.category.iconName)
                        .frame(width: 24, height: 24)
                        .foregroundColor(isSelected ? .white : .blue)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(detail.category.displayName)
                            .font(.system(size: 11, weight: .bold))
                            .lineLimit(1)
                            .foregroundColor(isSelected ? .white : .primary)
                        Text(detail.formattedTotalSize)
                            .font(.caption2)
                            .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 10)
                .background(isSelected ? Color.blue.opacity(0.85) : Color.black.opacity(0.15))
                .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

// Row component for listing single Files/Folders inside a category
struct ItemRowView: View {
    let item: ScanItem
    let onToggle: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 10) {
            Button(action: onToggle) {
                Image(systemName: item.isSelected ? "checkmark.square.fill" : "square")
                    .foregroundColor(item.isSelected ? .blue : .secondary)
            }
            .buttonStyle(PlainButtonStyle())
            
            Image(systemName: item.isDirectory ? "folder.fill" : "doc.fill")
                .foregroundColor(item.isDirectory ? .yellow : .secondary)
                .font(.system(size: 13))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.system(size: 11, weight: .medium))
                    .lineLimit(1)
                Text(item.path)
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            
            Spacer()
            
            Text(item.formattedSize)
                .font(.caption2)
                .bold()
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(Color.black.opacity(isHovered ? 0.2 : 0.1))
        .cornerRadius(6)
        .onHover { hover in
            isHovered = hover
        }
    }
}

// Advice Panel showing detailed warning cards
struct AdvicePanel: View {
    let category: CleanCategory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Category info
            HStack(spacing: 10) {
                Image(systemName: category.iconName)
                    .font(.title2)
                    .foregroundColor(getSafetyColor())
                    .padding(8)
                    .background(getSafetyColor().opacity(0.1))
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(category.displayName)
                        .font(.system(size: 12, weight: .bold))
                        .lineLimit(2)
                    Text(category.safetyLevel == .recommended ? "🟢 Güvenle Silinebilir" :
                            (category.safetyLevel == .caution ? "🟡 Dikkat Edilmeli" : "🔴 Silinmesi Önerilmez"))
                        .font(.caption2)
                        .bold()
                        .foregroundColor(getSafetyColor())
                }
            }
            .padding(.bottom, 6)
            
            Divider().opacity(0.3)
            
            // Description block
            VStack(alignment: .leading, spacing: 6) {
                Text("Nedir?")
                    .font(.caption)
                    .bold()
                    .foregroundColor(.secondary)
                Text(category.description)
                    .font(.system(size: 11))
                    .foregroundColor(.primary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            // Advice block
            VStack(alignment: .leading, spacing: 6) {
                Text("Öneri & Durum")
                    .font(.caption)
                    .bold()
                    .foregroundColor(.secondary)
                
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(getSafetyColor())
                        .font(.caption)
                        .padding(.top, 1)
                    Text(category.advice)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.primary)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(8)
                .background(getSafetyColor().opacity(0.06))
                .cornerRadius(6)
            }
            
            // Risk details
            VStack(alignment: .leading, spacing: 6) {
                Text("Silinirse Ne Olur? (Risk)")
                    .font(.caption)
                    .bold()
                    .foregroundColor(.red.opacity(0.8))
                Text(category.riskWarning)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
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
    
    private func getSafetyColor() -> Color {
        switch category.safetyLevel {
        case .recommended: return .green
        case .caution: return .orange
        case .danger: return .red
        }
    }
}
