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
    case timeMachineSnapshots = "timeMachineSnapshots"
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
        case .timeMachineSnapshots: return "Time Machine Yerel Yedekleri (Snapshots)"
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
        case .timeMachineSnapshots: return "clock.arrow.circlepath"
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
        case .trash, .xcodeSimulators, .packageCaches, .downloads, .mailDownloads, .timeMachineSnapshots:
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
        case .timeMachineSnapshots:
            return "macOS'in harici yedekleme diski bağlı değilken sistem düzeyinde otomatik aldığı yerel anlık yedekleme kopyalarıdır."
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
        case .timeMachineSnapshots:
            return "Mevcut yerel yedeklemeler silinir. Harici diskinizdeki Time Machine yedekleriniz kesinlikle etkilenmez. NOT: macOS güvenlik kısıtlamaları nedeniyle bu işlemin tamamlanabilmesi için uygulamanın yönetici (root/sudo) yetkileriyle çalıştırılması gerekir."
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
        case .timeMachineSnapshots: return "Yönetici İzni Gerekebilir: Özellikle diskiniz dolduğunda sistem verilerini rahatlatmak için silinmelidir."
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
        case .timeMachineSnapshots:
            return [] // Scanned via command line wrapper
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

// Structs for Startup Optimizer
struct StartupItem: Identifiable, Codable {
    var id: String { path }
    let name: String
    let label: String
    let path: String
    let type: String       // "Kullanıcı", "Sistem Ajanı", "Sistem Servisi"
    let program: String    // Target executable path
    var isEnabled: Bool
}

// Structs for App Uninstaller
struct InstalledApp: Identifiable, Codable {
    var id: String { path }
    let name: String
    let path: String
    let bundleId: String
    let size: Int64
    let version: String
    
    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
}

struct AppLeftover: Identifiable, Codable {
    var id: String { path }
    let path: String
    let size: Int64
    let type: String       // "Önbellek", "Uygulama Desteği", "Ayarlar (Plist)", "Günlükler", "Sandbox Kabı"
    var isSelected: Bool
    
    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
}

// Utility class for scanning file system
class DiskScanner {
    static let shared = DiskScanner()
    
    // Shell execution helper
    func runShellCommand(_ executable: String, arguments: [String]) -> String? {
        let (output, _) = runShellCommandWithStatus(executable, arguments: arguments)
        return output
    }
    
    // Shell execution helper that returns exit code
    func runShellCommandWithStatus(_ executable: String, arguments: [String]) -> (output: String?, exitCode: Int32) {
        let process = Process()
        let pipe = Pipe()
        let errorPipe = Pipe()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        process.standardOutput = pipe
        process.standardError = errorPipe
        
        do {
            try process.run()
            process.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8)
            return (output, process.terminationStatus)
        } catch {
            print("Failed to run command \(executable): \(error)")
            return (nil, -1)
        }
    }
    
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
    
    // Scans a folder recursively and returns the size + items in it
    func scanPath(category: CleanCategory, path: String) async -> [ScanItem] {
        // Special case: Time Machine Snapshots
        if category == .timeMachineSnapshots {
            return await scanTimeMachineSnapshots()
        }
        
        let fm = FileManager.default
        let url = URL(fileURLWithPath: path)
        var items: [ScanItem] = []
        
        var isDir: ObjCBool = false
        guard fm.fileExists(atPath: path, isDirectory: &isDir) else {
            return []
        }
        
        if !isDir.boolValue {
            do {
                let attrs = try fm.attributesOfItem(atPath: path)
                let size = attrs[.size] as? Int64 ?? 0
                return [ScanItem(path: path, name: url.lastPathComponent, size: size, category: category, isDirectory: false, isSelected: category.safetyLevel == .recommended)]
            } catch {
                return []
            }
        }
        
        do {
            let contents = try fm.contentsOfDirectory(at: url, includingPropertiesForKeys: [.isDirectoryKey, .fileSizeKey], options: [.skipsHiddenFiles])
            
            for itemUrl in contents {
                let pathStr = itemUrl.path
                var itemIsDir: ObjCBool = false
                if fm.fileExists(atPath: pathStr, isDirectory: &itemIsDir) {
                    let size = await getDirectorySize(at: itemUrl)
                    if size > 0 {
                        let name = itemUrl.lastPathComponent
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
        
        return items.sorted(by: { $0.size > $1.size })
    }
    
    // Time Machine snapshots scanning helper
    private func scanTimeMachineSnapshots() async -> [ScanItem] {
        guard let output = runShellCommand("/usr/bin/tmutil", arguments: ["listlocalsnapshots", "/"]) else {
            return []
        }
        
        var items: [ScanItem] = []
        let lines = output.components(separatedBy: .newlines)
        
        // Match com.apple.TimeMachine.2026-06-09-150244.local style patterns robustly
        let pattern = "com\\.apple\\.TimeMachine\\.[0-9a-zA-Z\\-]+\\.local"
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return []
        }
        
        for line in lines {
            let cleanLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            let range = NSRange(cleanLine.startIndex..<cleanLine.endIndex, in: cleanLine)
            
            if let match = regex.firstMatch(in: cleanLine, options: [], range: range) {
                if let swiftRange = Range(match.range, in: cleanLine) {
                    let snapshotId = String(cleanLine[swiftRange])
                    
                    var name = snapshotId
                    let parts = snapshotId.components(separatedBy: ".")
                    if parts.count >= 4 {
                        let datePart = parts[3]
                        name = "Time Machine Yedek Kopyası (\(datePart))"
                    }
                    
                    items.append(ScanItem(
                        path: snapshotId,
                        name: name,
                        size: 250 * 1024 * 1024, // 250 MB placeholder
                        category: .timeMachineSnapshots,
                        isDirectory: false,
                        isSelected: false
                    ))
                }
            }
        }
        return items
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
                                category: .downloads,
                                isDirectory: false,
                                isSelected: false
                            ))
                        }
                    }
                } catch {
                    // Ignore errors
                }
                
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
    
    // Scanner for startup items plist files
    func scanStartupItems() -> [StartupItem] {
        let fm = FileManager.default
        let home = fm.homeDirectoryForCurrentUser.path
        
        let launchDirs = [
            (path: "\(home)/Library/LaunchAgents", type: "Kullanıcı Başlangıcı"),
            (path: "/Library/LaunchAgents", type: "Sistem Genel Ajanı"),
            (path: "/Library/LaunchDaemons", type: "Sistem Genel Servisi")
        ]
        
        var items: [StartupItem] = []
        
        for dir in launchDirs {
            guard fm.fileExists(atPath: dir.path) else { continue }
            do {
                let contents = try fm.contentsOfDirectory(atPath: dir.path)
                for file in contents {
                    // Match either .plist or .plist.disabled files
                    guard file.hasSuffix(".plist") || file.hasSuffix(".disabled") else { continue }
                    
                    let filePath = "\(dir.path)/\(file)"
                    let isEnabled = file.hasSuffix(".plist")
                    
                    // Parse plist dictionary
                    if let dict = NSDictionary(contentsOfFile: filePath) {
                        let label = dict["Label"] as? String ?? file
                        let name = URL(fileURLWithPath: file).deletingPathExtension().deletingPathExtension().lastPathComponent
                        
                        var programPath = ""
                        if let prog = dict["Program"] as? String {
                            programPath = prog
                        } else if let args = dict["ProgramArguments"] as? [String], !args.isEmpty {
                            programPath = args[0]
                        }
                        
                        items.append(StartupItem(
                            name: name,
                            label: label,
                            path: filePath,
                            type: dir.type,
                            program: programPath.isEmpty ? "Belirtilmemiş" : programPath,
                            isEnabled: isEnabled
                        ))
                    }
                }
            } catch {
                print("Failed to read launch directory \(dir.path): \(error)")
            }
        }
        
        return items
    }
    
    // Disables / Enables startup items by renaming plist suffix
    func toggleStartupItem(_ item: StartupItem) -> Bool {
        let fm = FileManager.default
        guard fm.fileExists(atPath: item.path) else { return false }
        
        let oldPath = item.path
        let newPath: String
        
        if item.isEnabled {
            // Disable: rename .plist -> .plist.disabled
            newPath = oldPath.replacingOccurrences(of: ".plist", with: ".plist.disabled")
        } else {
            // Enable: rename .plist.disabled -> .plist
            newPath = oldPath.replacingOccurrences(of: ".plist.disabled", with: ".plist")
        }
        
        do {
            try fm.moveItem(atPath: oldPath, toPath: newPath)
            return true
        } catch {
            print("Failed to toggle startup item plist \(oldPath) to \(newPath): \(error)")
            return false
        }
    }
    
    // Scanner for App Uninstaller
    func scanInstalledApps() async -> [InstalledApp] {
        let fm = FileManager.default
        let appsDir = "/Applications"
        var apps: [InstalledApp] = []
        
        guard fm.fileExists(atPath: appsDir) else { return [] }
        
        do {
            let contents = try fm.contentsOfDirectory(atPath: appsDir)
            for file in contents {
                guard file.hasSuffix(".app") else { continue }
                
                let appPath = "\(appsDir)/\(file)"
                
                // Exclude system utilities or protected OS apps
                let systemApps = ["Safari.app", "Utilities", "App Store.app", "Siri.app", "Mail.app", "Maps.app", "Photos.app", "FaceTime.app", "Calendar.app", "Contacts.app", "Notes.app", "Reminders.app", "FindMy.app", "Freeform.app", "Home.app", "Messages.app", "Music.app", "News.app", "Podcasts.app", "Stocks.app", "TV.app", "VoiceMemos.app", "Weather.app", "Books.app", "Calculator.app", "Chess.app", "Dictionary.app", "DVD Player.app", "Font Book.app", "Image Capture.app", "Launchpad.app", "Mission Control.app", "Photo Booth.app", "Preview.app", "QuickTime Player.app", "Stickies.app", "System Settings.app", "TextEdit.app", "Time Machine.app"]
                
                if systemApps.contains(file) { continue }
                
                let infoPlistPath = "\(appPath)/Contents/Info.plist"
                var bundleId = "com.ugurmac.\(file)"
                var version = "1.0"
                var displayName = file.replacingOccurrences(of: ".app", with: "")
                
                if fm.fileExists(atPath: infoPlistPath) {
                    if let dict = NSDictionary(contentsOfFile: infoPlistPath) {
                        bundleId = dict["CFBundleIdentifier"] as? String ?? bundleId
                        version = dict["CFBundleShortVersionString"] as? String ?? version
                        displayName = dict["CFBundleDisplayName"] as? String ?? (dict["CFBundleName"] as? String ?? displayName)
                    }
                }
                
                // Get app bundle size
                let appUrl = URL(fileURLWithPath: appPath)
                let size = await getDirectorySize(at: appUrl)
                
                if size > 0 {
                    apps.append(InstalledApp(
                        name: displayName,
                        path: appPath,
                        bundleId: bundleId,
                        size: size,
                        version: version
                    ))
                }
            }
        } catch {
            print("Failed to read Applications folder: \(error)")
        }
        
        return apps.sorted(by: { $0.name.localizedCompare($1.name) == .orderedAscending })
    }
    
    // Leftover scanner for a specific app
    func scanLeftovers(for app: InstalledApp) async -> [AppLeftover] {
        let fm = FileManager.default
        let home = fm.homeDirectoryForCurrentUser.path
        var leftovers: [AppLeftover] = []
        
        // Target locations to check
        let scanPaths = [
            (path: "\(home)/Library/Application Support", type: "Uygulama Desteği"),
            (path: "\(home)/Library/Caches", type: "Önbellek"),
            (path: "\(home)/Library/Logs", type: "Günlükler"),
            (path: "\(home)/Library/Preferences", type: "Ayarlar (Plist)"),
            (path: "\(home)/Library/Containers", type: "Sandbox Kabı")
        ]
        
        // Match parameters: Name of the application (e.g. "Spotify") or bundle ID (e.g. "com.spotify.client")
        let appName = app.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let appBundleId = app.bundleId.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Extract basic name without extensions or spaces
        let basicName = appName.replacingOccurrences(of: " ", with: "")
        
        for target in scanPaths {
            guard fm.fileExists(atPath: target.path) else { continue }
            do {
                let contents = try fm.contentsOfDirectory(atPath: target.path)
                for file in contents {
                    let fileLower = file.lowercased()
                    
                    // Matching algorithm: matches if the name or bundle ID is part of the filename/foldername
                    let matches = fileLower.contains(appName) ||
                                  fileLower.contains(appBundleId) ||
                                  (!basicName.isEmpty && fileLower.contains(basicName))
                    
                    if matches {
                        let leftoverPath = "\(target.path)/\(file)"
                        let leftoverUrl = URL(fileURLWithPath: leftoverPath)
                        
                        var isDir: ObjCBool = false
                        let size: Int64
                        if fm.fileExists(atPath: leftoverPath, isDirectory: &isDir) {
                            if isDir.boolValue {
                                size = await getDirectorySize(at: leftoverUrl)
                            } else {
                                do {
                                    let attrs = try fm.attributesOfItem(atPath: leftoverPath)
                                    size = attrs[.size] as? Int64 ?? 0
                                } catch {
                                    size = 0
                                }
                            }
                            
                            if size > 0 {
                                leftovers.append(AppLeftover(
                                    path: leftoverPath,
                                    size: size,
                                    type: target.type,
                                    isSelected: true // Recommended to check by default
                                ))
                            }
                        }
                    }
                }
            } catch {
                // Ignore single directory scan failures
            }
        }
        
        return leftovers.sorted(by: { $0.size > $1.size })
    }
    
    // Safe deletion of a file or folder
    func deleteItem(at path: String) -> Bool {
        // Special case: Time Machine Local Snapshots
        if path.contains("com.apple.TimeMachine") {
            let components = path.components(separatedBy: ".")
            if components.count >= 4 {
                let datePart = components[3] // "2026-06-09-150244"
                print("DELETING TIME MACHINE SNAPSHOT: \(datePart)")
                let (_, exitCode) = runShellCommandWithStatus("/usr/bin/tmutil", arguments: ["deletelocalsnapshots", datePart])
                return exitCode == 0
            }
        }
        
        let fm = FileManager.default
        guard fm.fileExists(atPath: path) else {
            return true
        }
        
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
