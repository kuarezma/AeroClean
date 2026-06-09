import SwiftUI

struct LargeFilesView: View {
    @EnvironmentObject var appState: AppState
    @State private var searchText = ""
    @State private var selectedExtensionFilter = "All"
    @State private var selectedFileId: String? = nil
    
    let filters = ["All", "Videolar", "Arşivler", "Belgeler", "Müzik", "Diğer"]
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Büyük Dosya Analizi")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                    Text("Home dizininizdeki 100MB'tan büyük dosyaları bulun ve temizleyin.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                
                if appState.hasScanned {
                    Button(action: {
                        appState.cleanSelected(forTab: .largeFiles)
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Seçilenleri Sil (\(formatSize(getSelectedSize())))")
                                .bold()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .foregroundColor(.white)
                        .background(getSelectedSize() > 0 ? Color.orange : Color.gray)
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
                    Image(systemName: "doc.on.doc.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.orange.opacity(0.8))
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .clipShape(Circle())
                    
                    Text("Büyük Dosyalar Henüz Taranmadı")
                        .font(.title3)
                        .bold()
                    
                    Text("Diskinizde en çok yer kaplayan dosyaları tespit etmek için tam tarama başlatın.")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 400)
                    
                    Button(action: {
                        appState.startScan()
                    }) {
                        Text("Mac'i Tara ve Büyük Dosyaları Bul")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.orange)
                            .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .frame(maxHeight: .infinity)
            } else {
                VStack(spacing: 12) {
                    // Filters and Search Bar
                    HStack(spacing: 12) {
                        // Search textfield
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondary)
                            TextField("Dosya adı ara...", text: $searchText)
                                .textFieldStyle(PlainTextFieldStyle())
                        }
                        .padding(8)
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(8)
                        
                        // Dropdown-like tab filters
                        HStack(spacing: 4) {
                            ForEach(filters, id: \.self) { filter in
                                Button(action: {
                                    selectedExtensionFilter = filter
                                }) {
                                    Text(filter)
                                        .font(.caption)
                                        .bold(selectedExtensionFilter == filter)
                                        .padding(.vertical, 6)
                                        .padding(.horizontal, 10)
                                        .foregroundColor(selectedExtensionFilter == filter ? .white : .secondary)
                                        .background(selectedExtensionFilter == filter ? Color.orange : Color.clear)
                                        .cornerRadius(6)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(4)
                        .background(Color.black.opacity(0.15))
                        .cornerRadius(8)
                    }
                    
                    // Master Select Toggle
                    HStack {
                        let filtered = getFilteredFiles()
                        let allChecked = filtered.allSatisfy { $0.isSelected } && !filtered.isEmpty
                        
                        Button(action: {
                            toggleAllFiltered(checked: !allChecked)
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: allChecked ? "checkmark.square.fill" : "square")
                                    .foregroundColor(allChecked ? .orange : .secondary)
                                Text("Tümünü Seç / Seçimi Kaldır")
                                    .font(.caption)
                                    .bold()
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        Spacer()
                        Text("Bulunan: \(filtered.count) Dosya")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 6)
                    
                    // Grid/List and Advice Panel split
                    HStack(spacing: 16) {
                        // Left List of files
                        let filtered = getFilteredFiles()
                        if filtered.isEmpty {
                            VStack {
                                Spacer()
                                Image(systemName: "folder.badge.questionmark")
                                    .font(.system(size: 48))
                                    .foregroundColor(.secondary)
                                    .padding(.bottom, 8)
                                Text("Arama kriterlerine uygun büyük dosya bulunamadı.")
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black.opacity(0.1))
                            .cornerRadius(12)
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 6) {
                                    ForEach(filtered) { file in
                                        Button(action: {
                                            selectedFileId = file.id
                                        }) {
                                            HStack(spacing: 8) {
                                                Button(action: {
                                                    appState.toggleLargeFileSelection(itemId: file.id)
                                                }) {
                                                    Image(systemName: file.isSelected ? "checkmark.square.fill" : "square")
                                                        .foregroundColor(file.isSelected ? .orange : .secondary)
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                                
                                                Image(systemName: getFileIcon(file.name))
                                                    .foregroundColor(getFileIconColor(file.name))
                                                    .font(.system(size: 14))
                                                
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(file.name)
                                                        .font(.system(size: 11, weight: .bold))
                                                        .lineLimit(1)
                                                        .foregroundColor(selectedFileId == file.id ? .white : .primary)
                                                    Text(file.path)
                                                        .font(.system(size: 9))
                                                        .foregroundColor(selectedFileId == file.id ? .white.opacity(0.8) : .secondary)
                                                        .lineLimit(1)
                                                        .truncationMode(.middle)
                                                }
                                                Spacer()
                                                Text(file.formattedSize)
                                                    .font(.caption2)
                                                    .bold()
                                                    .foregroundColor(selectedFileId == file.id ? .white : .secondary)
                                            }
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 10)
                                            .background(selectedFileId == file.id ? Color.orange.opacity(0.8) : Color.black.opacity(0.15))
                                            .cornerRadius(8)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.trailing, 4)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        
                        // Right Side Panel detailing advice for selected file
                        LargeFileAdvicePanel(file: getSelectedFile())
                            .frame(width: 280)
                    }
                }
                .frame(maxHeight: .infinity)
            }
        }
        .padding(12)
        .onAppear {
            // Auto-select first file if available
            if selectedFileId == nil, let firstFile = getFilteredFiles().first {
                selectedFileId = firstFile.id
            }
        }
        .alert(isPresented: $appState.showCleanSuccessAlert) {
            Alert(
                title: Text("Büyük Dosya Temizliği Tamamlandı"),
                message: Text("Seçtiğiniz büyük dosyalar diskten kalıcı olarak kaldırıldı.\n\nSerbest Bırakılan Alan: \(formatSize(appState.cleanedAmount))"),
                dismissButton: .default(Text("Tamam"))
            )
        }
    }
    
    // Helpers
    private func getSelectedFile() -> ScanItem? {
        if let selectedFileId = selectedFileId {
            return appState.largeFiles.first(where: { $0.id == selectedFileId })
        }
        return getFilteredFiles().first
    }
    
    private func getFilteredFiles() -> [ScanItem] {
        return appState.largeFiles.filter { item in
            let matchesSearch = searchText.isEmpty || item.name.localizedCaseInsensitiveContains(searchText)
            
            if !matchesSearch { return false }
            
            switch selectedExtensionFilter {
            case "Videolar":
                return isVideo(item.name)
            case "Arşivler":
                return isArchive(item.name)
            case "Belgeler":
                return isDocument(item.name)
            case "Müzik":
                return isMusic(item.name)
            case "Diğer":
                return !isVideo(item.name) && !isArchive(item.name) && !isDocument(item.name) && !isMusic(item.name)
            default:
                return true
            }
        }
    }
    
    private func toggleAllFiltered(checked: Bool) {
        let filtered = getFilteredFiles()
        for item in filtered {
            if let index = appState.largeFiles.firstIndex(where: { $0.id == item.id }) {
                appState.largeFiles[index].isSelected = checked
            }
        }
    }
    
    private func getSelectedSize() -> Int64 {
        appState.largeFiles
            .filter { $0.isSelected }
            .reduce(0) { $0 + $1.size }
    }
    
    private func formatSize(_ bytes: Int64) -> String {
        ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
    }
    
    // File classification utility
    private func isVideo(_ filename: String) -> Bool {
        let ext = URL(fileURLWithPath: filename).pathExtension.lowercased()
        return ["mp4", "mkv", "mov", "avi", "flv", "webm"].contains(ext)
    }
    private func isArchive(_ filename: String) -> Bool {
        let ext = URL(fileURLWithPath: filename).pathExtension.lowercased()
        return ["zip", "rar", "tar", "gz", "7z", "dmg", "pkg"].contains(ext)
    }
    private func isDocument(_ filename: String) -> Bool {
        let ext = URL(fileURLWithPath: filename).pathExtension.lowercased()
        return ["pdf", "docx", "xlsx", "pptx", "epub", "pages", "numbers", "key"].contains(ext)
    }
    private func isMusic(_ filename: String) -> Bool {
        let ext = URL(fileURLWithPath: filename).pathExtension.lowercased()
        return ["mp3", "wav", "m4a", "flac", "ogg"].contains(ext)
    }
    
    private func getFileIcon(_ filename: String) -> String {
        if isVideo(filename) { return "video.fill" }
        if isArchive(filename) { return "doc.zipper" }
        if isDocument(filename) { return "doc.text.fill" }
        if isMusic(filename) { return "music.note" }
        return "doc.fill"
    }
    
    private func getFileIconColor(_ filename: String) -> Color {
        if isVideo(filename) { return .purple }
        if isArchive(filename) { return .red }
        if isDocument(filename) { return .blue }
        if isMusic(filename) { return .green }
        return .secondary
    }
}

// Large file advice sidebar detail card
struct LargeFileAdvicePanel: View {
    let file: ScanItem?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if let file = file {
                HStack(spacing: 8) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.title2)
                        .foregroundColor(.orange)
                        .padding(8)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Dosya Detayları")
                            .font(.system(size: 12, weight: .bold))
                        Text("🟡 Dikkat Edilmeli")
                            .font(.caption2)
                            .bold()
                            .foregroundColor(.orange)
                    }
                }
                
                Divider().opacity(0.3)
                
                VStack(alignment: .leading, spacing: 12) {
                    DetailFieldView(title: "Dosya Adı", value: file.name)
                    DetailFieldView(title: "Boyut", value: file.formattedSize)
                    DetailFieldView(title: "Uzantı", value: URL(fileURLWithPath: file.name).pathExtension.uppercased())
                    DetailFieldView(title: "Dosya Konumu", value: file.path)
                }
                
                Divider().opacity(0.3)
                
                // General advice for large files
                VStack(alignment: .leading, spacing: 6) {
                    Text("Tavsiye")
                        .font(.caption)
                        .bold()
                        .foregroundColor(.secondary)
                    
                    HStack(alignment: .top, spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                            .padding(.top, 1)
                        
                        Text("Bu bir kullanıcı dosyasıdır. İşletim sisteminin kararlı çalışmasıyla ilgisi yoktur. Silinmesi macOS'e zarar vermez; fakat dosya içeriğini kaybetmek istemiyorsanız silmeden önce dosyayı incelediğinizden veya harici bir diske yedeklediğinizden emin olun.")
                            .font(.system(size: 10.5))
                            .foregroundColor(.primary)
                            .lineSpacing(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(8)
                    .background(Color.orange.opacity(0.06))
                    .cornerRadius(6)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Silinirse Ne Olur? (Risk)")
                        .font(.caption)
                        .bold()
                        .foregroundColor(.red.opacity(0.8))
                    Text("Dosya çöp kutusuna atılmadan doğrudan kalıcı olarak silinir. Geri getirilmesi mümkün olmayacaktır.")
                        .font(.system(size: 10.5))
                        .foregroundColor(.secondary)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
            } else {
                Spacer()
                Text("İncelemek için listeden bir dosya seçin.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                Spacer()
            }
            Spacer()
        }
        .padding(16)
        .background(Color(.windowBackgroundColor).opacity(0.3))
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.2), lineWidth: 1)
        )
    }
}

struct DetailFieldView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 9))
                .foregroundColor(.secondary)
                .bold()
            Text(value)
                .font(.system(size: 10.5))
                .foregroundColor(.primary)
                .lineLimit(2)
                .truncationMode(.middle)
        }
    }
}
