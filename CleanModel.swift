import Foundation

enum SafetyLevel: String, Codable, CaseIterable {
    case recommended = "recommended"
    case caution = "caution"
    case danger = "danger"
    
    var colorName: String {
        switch self {
        case .recommended: return "Green"
        case .caution: return "Orange"
        case .danger: return "Red"
        }
    }
    
    var title: String {
        switch self {
        case .recommended: return "Güvenle Silinebilir (Önerilen)"
        case .caution: return "Dikkat Edilmeli (Tavsiye Edilmez)"
        case .danger: return "Sistem / Hassas Veri (Silinmez)"
        }
    }
}

enum CleanCategory: String, Codable, CaseIterable {
    case systemCache = "systemCache"
    case systemLogs = "systemLogs"
    case trash = "trash"
    case xcodeDerivedData = "xcodeDerivedData"
    case xcodeSimulators = "xcodeSimulators"
    case packageCaches = "packageCaches"
    case downloads = "downloads"
    case mailDownloads = "mailDownloads"
    case spotifyCache = "spotifyCache"
    case chromeCache = "chromeCache"
    case appSupportLeftovers = "appSupportLeftovers"
    
    var displayName: String {
        switch self {
        case .systemCache: return "Sistem ve Uygulama Önbellekleri"
        case .systemLogs: return "Sistem ve Günlük Kayıtları (Loglar)"
        case .trash: return "Çöp Kutusu"
        case .xcodeDerivedData: return "Xcode Derleme Dosyaları (Derived Data)"
        case .xcodeSimulators: return "Xcode Simülatör Dosyaları"
        case .packageCaches: return "Paket Yöneticileri Önbellekleri"
        case .downloads: return "İndirilenler Klasörü"
        case .mailDownloads: return "E-Posta Ekleri ve İndirilenleri"
        case .spotifyCache: return "Spotify Önbelleği"
        case .chromeCache: return "Google Chrome Önbelleği"
        case .appSupportLeftovers: return "Uygulama Kalıntıları (App Support)"
        }
    }
    
    var iconName: String {
        switch self {
        case .systemCache: return "square.stack.3d.up.fill"
        case .systemLogs: return "doc.text.fill"
        case .trash: return "trash.fill"
        case .xcodeDerivedData: return "hammer.fill"
        case .xcodeSimulators: return "iphone.badge.play"
        case .packageCaches: return "shippingbox.fill"
        case .downloads: return "arrow.down.circle.fill"
        case .mailDownloads: return "envelope.open.fill"
        case .spotifyCache: return "music.note.list"
        case .chromeCache: return "globe"
        case .appSupportLeftovers: return "folder.badge.minus"
        }
    }
    
    var safetyLevel: SafetyLevel {
        switch self {
        case .systemCache, .systemLogs, .xcodeDerivedData, .spotifyCache, .chromeCache:
            return .recommended
        case .trash, .xcodeSimulators, .packageCaches, .downloads, .mailDownloads:
            return .caution
        case .appSupportLeftovers:
            return .danger
        }
    }
    
    var description: String {
        switch self {
        case .systemCache:
            return "macOS ve uygulamalar tarafından geçici olarak oluşturulan dosyalar. Uygulamaların hızlı yüklenmesine yardımcı olurlar, ancak zamanla gereksiz birikirler."
        case .systemLogs:
            return "Uygulamalar ve işletim sistemi hatalarını veya çalışma günlüklerini kaydeden rapor dosyaları. Hata analizi yapmıyorsanız tamamen gereksizdir."
        case .trash:
            return "Kullanıcı tarafından silinen ancak henüz diskten tamamen kaldırılmayan Çöp Kutusu (Trash) içeriğidir."
        case .xcodeDerivedData:
            return "Xcode'un projelerinizi derlerken oluşturduğu önbellek, indeksler ve geçici derleme çıktıları. Geliştiriciler için devasa boyutlara ulaşabilir."
        case .xcodeSimulators:
            return "iOS Simülatörlerinin günlük kayıtları, geçici dosyaları ve simüle edilmiş cihazlarda yüklü uygulama verileri."
        case .packageCaches:
            return "Geliştirici araçlarının (Homebrew, npm, Cargo, CocoaPods) daha önce indirdiği kütüphanelerin yerel kopyaları."
        case .downloads:
            return "Kullanıcı olarak internetten indirdiğiniz dosyaların (dmg, zip, pdf) varsayılan depolanma yeri."
        case .mailDownloads:
            return "Mail uygulamasında e-posta eklerini açtığınızda macOS tarafından geçici olarak diske kaydedilen kopyalar."
        case .spotifyCache:
            return "Spotify uygulamasının şarkıları hızlı oynatmak ve çevrimdışı dinlemeniz için kaydettiği önbellek verileri."
        case .chromeCache:
            return "Google Chrome tarayıcısının ziyaret ettiğiniz web sitelerini hızlı yüklemek için kaydettiği görseller ve geçici dosyalar."
        case .appSupportLeftovers:
            return "Artık bilgisayarınızda yüklü olmayan eski uygulamalardan geriye kalan veri ve ayar klasörleri."
        }
    }
    
    var riskWarning: String {
        switch self {
        case .systemCache:
            return "Güvenle silinebilir. Silindikten sonra uygulamaların ilk açılışı birkaç saniye daha uzun sürebilir, ardından önbellek sağlıklı olarak otomatik yeniden oluşturulur."
        case .systemLogs:
            return "Sıfır risk. Tamamen güvenle silinebilir. Hiçbir yan etkisi yoktur."
        case .trash:
            return "Dosyalar kalıcı olarak silinecektir. Çöpte geri almak isteyeceğiniz önemli bir dosya olmadığından emin olun."
        case .xcodeDerivedData:
            return "Güvenle silinebilir. Projelerinizi Xcode'da ilk açtığınızda indeksleme ve ilk derleme işlemi normalden biraz daha uzun sürecektir."
        case .xcodeSimulators:
            return "Simülatörlerdeki test ettiğiniz uygulamalar ve onların içindeki test verileri (varsa kaydettiğiniz kullanıcı oturumları) silinir. Simülatörler temiz açılır."
        case .packageCaches:
            return "Silindikten sonra projelerinizde terminal üzerinden ilk paket yüklemesini yaptığınızda paketler internetten tekrar çekilecektir, bu sebeple ilk yükleme uzun sürebilir."
        case .downloads:
            return "İçinde kişisel arşiviniz, resimleriniz veya belgeleriniz olabilir. Bu klasörün içeriğini detaylı incelemeden silmemeniz önerilir."
        case .mailDownloads:
            return "Dosyalar e-posta sunucunuzda (örn. Gmail, iCloud) kalmaya devam eder. Sadece bilgisayarınızdaki geçici kopyaları silinir. Mail'den tekrar tıklayarak indirebilirsiniz."
        case .spotifyCache:
            return "Uygulama ayarlarınız silinmez. Ancak çevrimdışı dinlemek üzere indirdiğiniz şarkılar silinir ve internet bağlantısı olduğunda tekrar indirilmeleri gerekir."
        case .chromeCache:
            return "Çerezleriniz ve kayıtlı şifreleriniz silinmez, oturumlarınız açık kalır. Sadece web sitelerinin resim önbellekleri silinir, siteler ilk girişte yeniden indirilir."
        case .appSupportLeftovers:
            return "Çok dikkatli olunmalıdır! Eğer aktif olarak kullandığınız bir uygulamanın klasörünü silerseniz, o uygulamanın ayarları, lisansları veya yerel verileri sıfırlanabilir."
        }
    }
    
    var advice: String {
        switch self {
        case .systemCache: return "Tavsiye Edilen: Haftada veya ayda bir kez temizlenmesi disk sağlığı için iyidir."
        case .systemLogs: return "Tavsiye Edilen: Disk alanından bağımsız olarak düzenli silinmesinde hiçbir sakınca yoktur."
        case .trash: return "Gözden Geçirin: İçinde unutulmuş önemli bir dosya yoksa boşaltabilirsiniz."
        case .xcodeDerivedData: return "Tavsiye Edilen: Özellikle Xcode yavaşladığında veya derleme hataları verdiğinde mutlaka silinmelidir."
        case .xcodeSimulators: return "Gözden Geçirin: Simülatörlerde sakladığınız kritik test verileri yoksa silinmesi büyük yer kazandırır."
        case .packageCaches: return "Gözden Geçirin: Disk alanınız darsa ve internet bağlantınız varsa silmekte sakınca yoktur."
        case .downloads: return "Dikkat Edin: Bu klasördeki dosyaları tek tek inceleyerek gereksiz olanları manuel seçip temizleyin."
        case .mailDownloads: return "Tavsiye Edilen: Ekler mail kutunuzda güvendedir, yerel önbelleğin silinmesinde sakınca yoktur."
        case .spotifyCache: return "Gözden Geçirin: Şarkıları tekrar indirmek sorun değilse silerek disk alanı kazanabilirsiniz."
        case .chromeCache: return "Tavsiye Edilen: Tarayıcı yavaşlamalarında ve disk sıkışıklıklarında ilk silinmesi gerekenlerdendir."
        case .appSupportLeftovers: return "Silmeyin/Seçici Olun: Yalnızca kaldırdığınızdan emin olduğunuz eski uygulamaların isimlerini taşıyan klasörleri silin."
        }
    }
    
    var targetPaths: [String] {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        switch self {
        case .systemCache:
            return [
                "\(home)/Library/Caches",
                "/Library/Caches"
            ]
        case .systemLogs:
            return [
                "\(home)/Library/Logs",
                "/Library/Logs"
            ]
        case .trash:
            return ["\(home)/.Trash"]
        case .xcodeDerivedData:
            return ["\(home)/Library/Developer/Xcode/DerivedData"]
        case .xcodeSimulators:
            return [
                "\(home)/Library/Developer/CoreSimulator/Devices",
                "\(home)/Library/Logs/CoreSimulator"
            ]
        case .packageCaches:
            return [
                "\(home)/.npm/_cacache",
                "\(home)/.cargo/registry/cache",
                "\(home)/.cargo/git/db",
                "\(home)/Library/Caches/CocoaPods",
                "\(home)/Library/Caches/Homebrew"
            ]
        case .downloads:
            return ["\(home)/Downloads"]
        case .mailDownloads:
            return ["\(home)/Library/Containers/com.apple.mail/Data/Library/Mail Downloads"]
        case .spotifyCache:
            return ["\(home)/Library/Caches/com.spotify.client"]
        case .chromeCache:
            return [
                "\(home)/Library/Caches/Google/Chrome/Default/Cache",
                "\(home)/Library/Caches/Google/Chrome/Default/Code Cache"
            ]
        case .appSupportLeftovers:
            return ["\(home)/Library/Application Support"]
        }
    }
}

struct ScanItem: Identifiable, Codable {
    var id: String { path }
    let path: String
    let name: String
    let size: Int64
    let category: CleanCategory
    let isDirectory: Bool
    var isSelected: Bool
    
    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
}

struct CategoryDetail: Identifiable {
    var id: CleanCategory { category }
    let category: CleanCategory
    var items: [ScanItem]
    var totalSize: Int64 {
        items.reduce(0) { $0 + $1.size }
    }
    var isSelected: Bool
    
    var formattedTotalSize: String {
        ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file)
    }
}

// Utility class for scanning file system
class DiskScanner {
    static let shared = DiskScanner()
    
    func getDiskSpace() -> (free: Int64, total: Int64) {
        let fileURL = URL(fileURLWithPath: "/")
        do {
            let values = try fileURL.resourceValues(forKeys: [.volumeAvailableCapacityKey, .volumeTotalCapacityKey])
            let free = Int64(values.volumeAvailableCapacity ?? 0)
            let total = Int64(values.volumeTotalCapacity ?? 0)
            return (free, total)
        } catch {
            print("Error reading disk capacity: \(error)")
            return (0, 0)
        }
    }
    
    // Scans a folder recursively and returns the size + items in it (shallow or deep based on configuration)
    func scanPath(category: CleanCategory, path: String) async -> [ScanItem] {
        let fm = FileManager.default
        let url = URL(fileURLWithPath: path)
        var items: [ScanItem] = []
        
        var isDir: ObjCBool = false
        guard fm.fileExists(atPath: path, isDirectory: &isDir) else {
            return []
        }
        
        // If the path itself is not a directory, just return it
        if !isDir.boolValue {
            do {
                let attrs = try fm.attributesOfItem(atPath: path)
                let size = attrs[.size] as? Int64 ?? 0
                return [ScanItem(path: path, name: url.lastPathComponent, size: size, category: category, isDirectory: false, isSelected: category.safetyLevel == .recommended)]
            } catch {
                return []
            }
        }
        
        // For special large containers, we might want to list top level contents
        // For Caches, App Support, Downloads, etc., listing the children gives the user precise delete choices.
        do {
            let contents = try fm.contentsOfDirectory(at: url, includingPropertiesForKeys: [.isDirectoryKey, .fileSizeKey], options: [.skipsHiddenFiles])
            
            for itemUrl in contents {
                // If it is App Support, we only list items that might be leftovers, but since it's "Danger" safety level,
                // we list sub-folders representing apps.
                let pathStr = itemUrl.path
                var itemIsDir: ObjCBool = false
                if fm.fileExists(atPath: pathStr, isDirectory: &itemIsDir) {
                    let size = await getDirectorySize(at: itemUrl)
                    if size > 0 {
                        let name = itemUrl.lastPathComponent
                        // App Support subfolders: by default NOT selected (Danger)
                        // Downloads: by default NOT selected (Caution)
                        let defaultSelected = (category.safetyLevel == .recommended) && (category != .appSupportLeftovers)
                        
                        items.append(ScanItem(
                            path: pathStr,
                            name: name,
                            size: size,
                            category: category,
                            isDirectory: itemIsDir.boolValue,
                            isSelected: defaultSelected
                        ))
                    }
                }
            }
        } catch {
            // If contentsOfDirectory fails (e.g. permission error), try calculating size of the root folder directly
            let size = await getDirectorySize(at: url)
            if size > 0 {
                items.append(ScanItem(
                    path: path,
                    name: url.lastPathComponent,
                    size: size,
                    category: category,
                    isDirectory: true,
                    isSelected: category.safetyLevel == .recommended
                ))
            }
        }
        
        // Sort items by size descending
        return items.sorted(by: { $0.size > $1.size })
    }
    
    // Deep directory size calculation asynchronously
    private func getDirectorySize(at url: URL) async -> Int64 {
        let fm = FileManager.default
        var totalSize: Int64 = 0
        
        guard let enumerator = fm.enumerator(
            at: url,
            includingPropertiesForKeys: [.fileSizeKey, .isDirectoryKey],
            options: [.skipsHiddenFiles],
            errorHandler: { _, _ in true }
        ) else {
            return 0
        }
        
        while let fileURL = enumerator.nextObject() as? URL {
            do {
                let resourceValues = try fileURL.resourceValues(forKeys: [.fileSizeKey, .isDirectoryKey])
                if let isDirectory = resourceValues.isDirectory, !isDirectory {
                    if let fileSize = resourceValues.fileSize {
                        totalSize += Int64(fileSize)
                    }
                }
            } catch {
                // Ignore single file read errors
            }
        }
        
        return totalSize
    }
    
    // Scanner for finding files larger than a threshold in home directory
    func scanLargeFiles(minSize: Int64 = 100 * 1024 * 1024, limit: Int = 100) async -> [ScanItem] {
        let fm = FileManager.default
        let homeUrl = fm.homeDirectoryForCurrentUser
        var largeFiles: [ScanItem] = []
        
        // We will scan Downloads, Documents, Desktop, and Movie/Music/Pictures folders for large files
        let scanSubdirectories = ["Downloads", "Documents", "Desktop", "Movies", "Music", "Pictures"]
        
        for dirName in scanSubdirectories {
            let dirUrl = homeUrl.appendingPathComponent(dirName)
            guard fm.fileExists(atPath: dirUrl.path) else { continue }
            
            guard let enumerator = fm.enumerator(
                at: dirUrl,
                includingPropertiesForKeys: [.fileSizeKey, .isDirectoryKey, .contentModificationDateKey],
                options: [.skipsHiddenFiles, .skipsPackageDescendants],
                errorHandler: { _, _ in true }
            ) else {
                continue
            }
            
            while let fileURL = enumerator.nextObject() as? URL {
                do {
                    let resourceValues = try fileURL.resourceValues(forKeys: [.fileSizeKey, .isDirectoryKey])
                    if let isDirectory = resourceValues.isDirectory, !isDirectory {
                        if let fileSize = resourceValues.fileSize, Int64(fileSize) >= minSize {
                            largeFiles.append(ScanItem(
                                path: fileURL.path,
                                name: fileURL.lastPathComponent,
                                size: Int64(fileSize),
                                category: .downloads, // We list them as user files
                                isDirectory: false,
                                isSelected: false // Large files should NEVER be auto-selected for safety
                            ))
                        }
                    }
                } catch {
                    // Ignore errors
                }
                
                // Cap the search to prevent infinite scanning
                if largeFiles.count >= limit {
                    break
                }
            }
            
            if largeFiles.count >= limit {
                break
            }
        }
        
        return largeFiles.sorted(by: { $0.size > $1.size })
    }
    
    // Safe deletion of a file or folder
    func deleteItem(at path: String) -> Bool {
        let fm = FileManager.default
        guard fm.fileExists(atPath: path) else {
            return true // Already deleted/doesn't exist
        }
        
        // Safety guard: NEVER allow deleting home directory or root system folders
        let home = fm.homeDirectoryForCurrentUser.path
        let protectedPaths = [
            home,
            "\(home)/Desktop",
            "\(home)/Documents",
            "\(home)/Library",
            "/",
            "/System",
            "/Library",
            "/Applications",
            "/Users"
        ]
        
        if protectedPaths.contains(path) {
            print("CRITICAL: Prevented deletion of protected path: \(path)")
            return false
        }
        
        do {
            try fm.removeItem(atPath: path)
            return true
        } catch {
            print("Failed to delete item at \(path): \(error.localizedDescription)")
            return false
        }
    }
}
