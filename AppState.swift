import Foundation
import Combine

@MainActor
class AppState: ObservableObject {
    enum Tab: String, CaseIterable {
        case dashboard = "Dashboard"
        case systemClean = "Sistem Verileri"
        case largeFiles = "Büyük Dosyalar"
        case developer = "Geliştirici"
        case settings = "Ayarlar & Yardım"
        
        var iconName: String {
            switch self {
            case .dashboard: return "gauge.medium"
            case .systemClean: return "cpu"
            case .largeFiles: return "doc.on.doc.fill"
            case .developer: return "hammer.fill"
            case .settings: return "gearshape.fill"
            }
        }
    }
    
    @Published var selectedTab: Tab = .dashboard
    
    // Scan States
    @Published var isScanning = false
    @Published var isCleaning = false
    @Published var scanProgress: Double = 0.0
    @Published var currentScanningCategory = ""
    @Published var hasScanned = false
    
    // Space Metrics
    @Published var freeSpace: Int64 = 0
    @Published var totalSpace: Int64 = 0
    @Published var usedSpace: Int64 = 0
    @Published var systemDataSize: Int64 = 0
    
    // Clean Categories Data
    @Published var categories: [CategoryDetail] = []
    @Published var largeFiles: [ScanItem] = []
    
    // Cleaning Stats
    @Published var cleanedAmount: Int64 = 0
    @Published var showCleanSuccessAlert = false
    
    init() {
        loadDiskSpace()
        initializeCategories()
    }
    
    func loadDiskSpace() {
        let space = DiskScanner.shared.getDiskSpace()
        self.freeSpace = space.free
        self.totalSpace = space.total
        self.usedSpace = space.total - space.free
    }
    
    private func initializeCategories() {
        self.categories = CleanCategory.allCases.map { cat in
            CategoryDetail(category: cat, items: [], isSelected: cat.safetyLevel == .recommended)
        }
    }
    
    func startScan() {
        guard !isScanning else { return }
        
        isScanning = true
        scanProgress = 0.0
        hasScanned = false
        cleanedAmount = 0
        
        Task {
            let scanner = DiskScanner.shared
            var updatedCategories: [CategoryDetail] = []
            let totalSteps = Double(CleanCategory.allCases.count + 1) // +1 for large files
            var completedSteps = 0.0
            
            // Scan Standard/System categories
            for cat in CleanCategory.allCases {
                self.currentScanningCategory = cat.displayName
                self.scanProgress = completedSteps / totalSteps
                
                var categoryItems: [ScanItem] = []
                for path in cat.targetPaths {
                    let items = await scanner.scanPath(category: cat, path: path)
                    categoryItems.append(contentsOf: items)
                }
                
                let finalItems = categoryItems
                let isSelected = cat.safetyLevel == .recommended && cat != .appSupportLeftovers
                updatedCategories.append(CategoryDetail(
                    category: cat,
                    items: finalItems,
                    isSelected: isSelected
                ))
                
                completedSteps += 1.0
            }
            
            // Scan Large Files
            self.currentScanningCategory = "Büyük Dosyalar (>100MB)"
            self.scanProgress = completedSteps / totalSteps
            
            let foundLargeFiles = await scanner.scanLargeFiles(minSize: 100 * 1024 * 1024)
            completedSteps += 1.0
            
            // Calculate System Data size (represented by Caches, Logs, App support, Xcode data)
            let systemDataCats: [CleanCategory] = [.systemCache, .systemLogs, .xcodeDerivedData, .xcodeSimulators, .packageCaches, .spotifyCache, .chromeCache, .appSupportLeftovers]
            let computedSystemData = updatedCategories
                .filter { systemDataCats.contains($0.category) }
                .reduce(0) { $0 + $1.totalSize }
            
            self.categories = updatedCategories
            self.largeFiles = foundLargeFiles
            self.systemDataSize = computedSystemData
            self.scanProgress = 1.0
            self.isScanning = false
            self.hasScanned = true
            self.loadDiskSpace()
        }
    }
    
    func cleanSelected(forTab tab: Tab) {
        guard !isCleaning else { return }
        isCleaning = true
        
        Task {
            let scanner = DiskScanner.shared
            var deletedBytes: Int64 = 0
            
            if tab == .systemClean || tab == .developer {
                // Clean from categories
                var updatedCategories: [CategoryDetail] = []
                
                for var catDetail in categories {
                    var remainingItems: [ScanItem] = []
                    
                    for item in catDetail.items {
                        // Delete only if selected and it's recommended or user checked it
                        if item.isSelected {
                            let success = scanner.deleteItem(at: item.path)
                            if success {
                                deletedBytes += item.size
                            } else {
                                // Keep it in the list if deletion failed
                                remainingItems.append(item)
                            }
                        } else {
                            remainingItems.append(item)
                        }
                    }
                    
                    catDetail.items = remainingItems
                    updatedCategories.append(catDetail)
                }
                
                self.categories = updatedCategories
            } else if tab == .largeFiles {
                // Clean from large files
                var remainingLargeFiles: [ScanItem] = []
                
                for item in largeFiles {
                    if item.isSelected {
                        let success = scanner.deleteItem(at: item.path)
                        if success {
                            deletedBytes += item.size
                        } else {
                            remainingLargeFiles.append(item)
                        }
                    } else {
                        remainingLargeFiles.append(item)
                    }
                }
                
                self.largeFiles = remainingLargeFiles
            }
            
            // Re-calculate system data size
            let systemDataCats: [CleanCategory] = [.systemCache, .systemLogs, .xcodeDerivedData, .xcodeSimulators, .packageCaches, .spotifyCache, .chromeCache, .appSupportLeftovers]
            let computedSystemData = categories
                .filter { systemDataCats.contains($0.category) }
                .reduce(0) { $0 + $1.totalSize }
            
            self.cleanedAmount = deletedBytes
            self.systemDataSize = computedSystemData
            self.isCleaning = false
            self.showCleanSuccessAlert = true
            self.loadDiskSpace()
        }
    }
    
    // Toggle single item selection
    func toggleItemSelection(category: CleanCategory, itemId: String) {
        if let catIndex = categories.firstIndex(where: { $0.category == category }) {
            if let itemIndex = categories[catIndex].items.firstIndex(where: { $0.id == itemId }) {
                categories[catIndex].items[itemIndex].isSelected.toggle()
                
                // If safety is danger, make sure to alert or just allow selection
                // Update parent selection category if needed
                let allSelected = categories[catIndex].items.allSatisfy { $0.isSelected }
                categories[catIndex].isSelected = allSelected
            }
        }
    }
    
    // Toggle entire category selection
    func toggleCategorySelection(category: CleanCategory) {
        if let catIndex = categories.firstIndex(where: { $0.category == category }) {
            let newState = !categories[catIndex].isSelected
            categories[catIndex].isSelected = newState
            
            for itemIndex in 0..<categories[catIndex].items.count {
                categories[catIndex].items[itemIndex].isSelected = newState
            }
        }
    }
    
    // Toggle single large file selection
    func toggleLargeFileSelection(itemId: String) {
        if let itemIndex = largeFiles.firstIndex(where: { $0.id == itemId }) {
            largeFiles[itemIndex].isSelected.toggle()
        }
    }
}
