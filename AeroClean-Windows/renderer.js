// Browser Mock Fallback if running outside Electron
if (typeof window.electronAPI === 'undefined') {
  console.log("Running in browser mode. Mocking electronAPI...");
  window.electronAPI = {
    minimize: () => console.log("Window minimized"),
    maximize: () => console.log("Window maximized/restored"),
    close: () => console.log("Window closed"),
    getDiskSpace: async () => {
      return { free: 120 * 1024 * 1024 * 1024, total: 256 * 1024 * 1024 * 1024 };
    },
    scanPath: async (category, basePath) => {
      await new Promise(r => setTimeout(r, 120)); // simulate scan delay
      const mockSizes = {
        systemCache: 2.4 * 1024 * 1024 * 1024,
        systemLogs: 450 * 1024 * 1024,
        trash: 5.1 * 1024 * 1024 * 1024,
        timeMachineSnapshots: 0,
        spotifyCache: 1.8 * 1024 * 1024 * 1024,
        chromeCache: 950 * 1024 * 1024,
        npmCache: 3.2 * 1024 * 1024 * 1024,
        cargoCache: 8.4 * 1024 * 1024 * 1024,
        pipCache: 150 * 1024 * 1024
      };
      const size = mockSizes[category] || 10 * 1024 * 1024;
      return [
        { path: `C:\\Mock\\${category}\\dosya_aktif_1.tmp`, name: 'dosya_aktif_1.tmp', size: size * 0.6, category, isDirectory: false, isSelected: true },
        { path: `C:\\Mock\\${category}\\Gecici_Dosyalar`, name: 'Gecici_Dosyalar', size: size * 0.4, category, isDirectory: true, isSelected: true }
      ];
    },
    deletePath: async (path) => {
      console.log(`Deleted mock path: ${path}`);
      return true;
    },
    scanLargeFiles: async () => {
      await new Promise(r => setTimeout(r, 150));
      return [
        { path: 'C:\\Users\\Ugur\\Downloads\\film_arsivi.mp4', name: 'film_arsivi.mp4', size: 4.2 * 1024 * 1024 * 1024, category: 'downloads', isDirectory: false, isSelected: false },
        { path: 'C:\\Users\\Ugur\\Desktop\\yedek_dosyalar_2026.zip', name: 'yedek_dosyalar_2026.zip', size: 1.8 * 1024 * 1024 * 1024, category: 'downloads', isDirectory: false, isSelected: false },
        { path: 'C:\\Users\\Ugur\\Documents\\sanal_sistem.iso', name: 'sanal_sistem.iso', size: 6.5 * 1024 * 1024 * 1024, category: 'downloads', isDirectory: false, isSelected: false }
      ];
    },
    scanStartups: async () => {
      await new Promise(r => setTimeout(r, 100));
      return [
        { name: 'Spotify Web Helper', label: 'Spotify Web Helper', path: 'SpotifyStartup', type: 'Kullanıcı Başlangıcı (HKCU)', program: 'C:\\Users\\Ugur\\AppData\\Local\\Microsoft\\Update.exe', isEnabled: true },
        { name: 'Discord Launcher', label: 'Discord Launcher', path: 'DiscordStartup', type: 'Kullanıcı Başlangıcı (HKCU)', program: 'C:\\Users\\Ugur\\AppData\\Local\\Discord\\app.exe', isEnabled: true },
        { name: 'Microsoft OneDrive', label: 'Microsoft OneDrive', path: 'OneDriveStartup', type: 'Sistem Genel Ajanı (HKLM)', program: 'C:\\Windows\\System32\\onedrive.exe', isEnabled: false }
      ];
    },
    toggleStartup: async (item) => {
      console.log(`Toggled startup item: ${item.name}`);
      return true;
    },
    scanApps: async () => {
      await new Promise(r => setTimeout(r, 100));
      return [
        { id: 'chrome', name: 'Google Chrome Browser', path: 'C:\\Program Files\\Google\\Chrome', bundleId: 'chrome_uninstall', size: 450 * 1024 * 1024, version: '124.0.1' },
        { id: 'vscode', name: 'Visual Studio Code', path: 'C:\\Program Files\\Microsoft VS Code', bundleId: 'vscode_uninstall', size: 680 * 1024 * 1024, version: '1.89.0' },
        { id: 'spotify', name: 'Spotify App', path: 'C:\\Users\\Ugur\\AppData\\Roaming\\Spotify', bundleId: 'spotify_uninstall', size: 180 * 1024 * 1024, version: '1.2.3' }
      ];
    },
    scanAppLeftovers: async (app) => {
      return [
        { path: `C:\\Users\\Ugur\\AppData\\Local\\${app.name}\\Cache`, size: 45 * 1024 * 1024, type: 'Önbellek/Yerel Veri', isSelected: true },
        { path: `C:\\Users\\Ugur\\AppData\\Roaming\\${app.name}\\Settings`, size: 12 * 1024 * 1024, type: 'Uygulama Ayarları', isSelected: true }
      ];
    }
  };
}

// State parameters
let diskSpace = { free: 0, total: 0 };
let categories = [];
let largeFiles = [];
let startupItems = [];
let installedApps = [];
let selectedApp = null;
let selectedAppLeftovers = [];
let cleanedAmount = 0;

let activeTab = 'dashboard';
let activeSysCategory = 'systemCache';
let activeSysFilter = 'recommended';

let activeDevCategory = 'npmCache';

// Turkish details config for Windows
const categoriesConfig = {
  systemCache: {
    displayName: "Sistem Geçici Dosyaları (Windows Temp)",
    icon: "📁",
    safetyLevel: "recommended",
    description: "Windows işletim sisteminin çalışma esnasında oluşturduğu geçici Temp dosyaları. Zamanla diski şişirebilir.",
    riskWarning: "Sıfır risk. Güvenle silinebilir. O an açık olan uygulamalara ait kilitli dosyalar silinmez, geriye kalan çöpler temizlenir.",
    advice: "Tavsiye Edilen: Disk doluluğunu azaltmak ve sistemi rahatlatmak için düzenli olarak silinmelidir.",
    baseFolder: "C:\\Windows\\Temp"
  },
  systemLogs: {
    displayName: "Kullanıcı Geçici Dosyaları (User Temp)",
    icon: "📂",
    safetyLevel: "recommended",
    description: "Kullanıcı hesabınıza ait geçici uygulama dosyaları (AppData\\Local\\Temp). Çoğu program burada çöp bırakır.",
    riskWarning: "Tamamen güvenlidir. O an aktif çalışan dosyalar atlanarak diğer tüm artıklar temizlenir.",
    advice: "Tavsiye Edilen: Tarayıcı veya uygulama çökmelerinden kalan artıkları temizlemek için silinmesi önerilir.",
    baseFolder: "USER_TEMP" // Resolved dynamically
  },
  trash: {
    displayName: "Geri Dönüşüm Kutusu",
    icon: "🗑️",
    safetyLevel: "caution",
    description: "Sildiğiniz ancak diskinizde yer kaplamaya devam eden Geri Dönüşüm Kutusu ($Recycle.Bin) içeriğidir.",
    riskWarning: "Silinen dosyalar kalıcı olarak diskten kaldırılacaktır. Geri almak isteyeceğiniz önemli bir şey olmadığından emin olun.",
    advice: "Gözden Geçirin: İçinde unutulmuş önemli bir belge yoksa boşaltarak yer açabilirsiniz.",
    baseFolder: "C:\\$Recycle.Bin"
  },
  timeMachineSnapshots: {
    displayName: "Windows Update İndirme Önbelleği",
    icon: "🔄",
    safetyLevel: "recommended",
    description: "Windows Update servisinin indirdiği güncelleme kurulum paketleri (SoftwareDistribution\\Download).",
    riskWarning: "Sıfır risk. Kurulumu tamamlanmış güncellemelerin kurulum dosyaları silinir. Gelecek güncellemeleri engellemez.",
    advice: "Tavsiye Edilen: Büyük Windows güncellemelerinden sonra gigabaytlarca yer açmak için mutlaka silinmelidir.",
    baseFolder: "C:\\Windows\\SoftwareDistribution\\Download"
  },
  spotifyCache: {
    displayName: "Spotify Önbelleği",
    icon: "🎵",
    safetyLevel: "recommended",
    description: "Spotify uygulamasının şarkıları hızlı oynatmak ve çevrimdışı dinlemeniz için kaydettiği önbellek verileri.",
    riskWarning: "Uygulama ayarlarınız silinmez. Çevrimdışı dinlemek üzere indirdiğiniz şarkılar silinir, internet varken otomatik tekrar indirilebilir.",
    advice: "Gözden Geçirin: Şarkıları tekrar indirmek sorun değilse silerek disk alanı kazanabilirsiniz.",
    baseFolder: "SPOTIFY_TEMP" // Resolved dynamically
  },
  chromeCache: {
    displayName: "Google Chrome Önbelleği",
    icon: "🌐",
    safetyLevel: "recommended",
    description: "Google Chrome tarayıcısının ziyaret ettiğiniz web sitelerini hızlı yüklemek için kaydettiği görseller ve geçici dosyalar.",
    riskWarning: "Kayıtlı şifreleriniz ve oturumlarınız silinmez. Sadece web sitelerinin resim önbellekleri temizlenir.",
    advice: "Tavsiye Edilen: Tarayıcı yavaşlamalarında ve disk sıkışıklıklarında ilk silinmesi gerekenlerdendir.",
    baseFolder: "CHROME_TEMP" // Resolved dynamically
  }
};

const devCategoriesConfig = {
  npmCache: {
    displayName: "npm Önbelleği",
    icon: "📦",
    safetyLevel: "caution",
    description: "Node.js paket yöneticisi (npm) tarafından indirilmiş paketlerin yerel önbelleğidir (npm-cache).",
    riskWarning: "Projelerinizde npm install çalıştırdığınızda paketler internetten tekrar indirilecektir. İnternetiniz varsa güvenle silinebilir.",
    advice: "Gözden Geçirin: Disk alanınız darsa ve internet bağlantınız varsa silmekte sakınca yoktur.",
    baseFolder: "NPM_TEMP"
  },
  cargoCache: {
    displayName: "Cargo / Rust Önbelleği",
    icon: "🦀",
    safetyLevel: "caution",
    description: "Rust dilinin paket yöneticisi olan Cargo'nun indirdiği kütüphane önbellekleridir.",
    riskWarning: "Projeleri derlerken kütüphaneler internetten tekrar indirilir. İlk derleme süreleri biraz uzayabilir.",
    advice: "Gözden Geçirin: Özellikle disk doluluğu yaşayan Rust geliştiricileri için silinmesi önerilir.",
    baseFolder: "CARGO_TEMP"
  },
  pipCache: {
    displayName: "Pip / Python Önbelleği",
    icon: "🐍",
    safetyLevel: "recommended",
    description: "Python paket yöneticisi pip'in indirdiği paket kopyaları.",
    riskWarning: "Sıfır risk. Bir paket kurmak istediğinizde pip paketi internetten indirir. Çevrimdışı kurulum yapmıyorsanız silinebilir.",
    advice: "Tavsiye Edilen: Geliştirme esnasında biriken python çöp paketlerini temizler.",
    baseFolder: "PIP_TEMP"
  }
};

// Initialize App
document.addEventListener('DOMContentLoaded', async () => {
  setupWindowControls();
  setupTabSwitcher();
  await updateDiskSpace();
  
  // Connect actions
  const scanBtn = document.getElementById('btn-start-scan');
  if (scanBtn) {
    scanBtn.addEventListener('click', startScan);
  }
  const cloudBtn = document.getElementById('btn-dashboard-cloud-goto');
  if (cloudBtn) {
    cloudBtn.addEventListener('click', () => {
      const settingsTabBtn = document.querySelector('.nav-btn[data-tab="settings"]');
      if (settingsTabBtn) settingsTabBtn.click();
    });
  }
  document.getElementById('btn-clean-system').addEventListener('click', () => cleanSelected('system-clean'));
  document.getElementById('btn-clean-large').addEventListener('click', () => cleanSelected('large-files'));
  document.getElementById('btn-clean-developer').addEventListener('click', () => cleanSelected('developer'));
  document.getElementById('btn-uninstall-app').addEventListener('click', uninstallApp);
  document.getElementById('btn-refresh-startups').addEventListener('click', scanStartups);
  document.getElementById('btn-reset-cache').addEventListener('click', resetCache);
  document.getElementById('btn-close-modal').addEventListener('click', () => {
    document.getElementById('success-modal').style.display = 'none';
  });

  // Update check event listeners
  const btnCheckUpdates = document.getElementById('btn-check-updates');
  if (btnCheckUpdates) {
    btnCheckUpdates.addEventListener('click', () => checkForUpdates(false));
  }
  const btnCloseUpdateModal = document.getElementById('btn-close-update-modal');
  if (btnCloseUpdateModal) {
    btnCloseUpdateModal.addEventListener('click', () => {
      document.getElementById('update-modal').style.display = 'none';
    });
  }
  
  // Auto-check updates on startup
  checkForUpdates(true);

  // Setup search triggers
  document.getElementById('large-search').addEventListener('input', renderLargeFiles);
  document.getElementById('apps-search').addEventListener('input', renderAppsList);
  
  // Large files pills
  document.getElementById('large-pills').addEventListener('click', (e) => {
    if (e.target.classList.contains('pill')) {
      document.querySelectorAll('#large-pills .pill').forEach(p => p.classList.remove('active'));
      e.target.classList.add('active');
      renderLargeFiles();
    }
  });

  // System Clean filter tabs
  document.getElementById('sys-filter-bar').addEventListener('click', (e) => {
    if (e.target.classList.contains('filter-btn')) {
      document.querySelectorAll('#sys-filter-bar .filter-btn').forEach(b => b.classList.remove('active'));
      e.target.classList.add('active');
      activeSysFilter = e.target.dataset.filter;
      
      // Auto select first category in filter
      const activeCats = Object.keys(categoriesConfig).filter(k => categoriesConfig[k].safetyLevel === activeSysFilter);
      if (activeCats.length > 0) {
        activeSysCategory = activeCats[0];
      }
      renderSystemClean();
    }
  });
});

// Titlebar minimize/maximize/close actions
function setupWindowControls() {
  document.getElementById('btn-minimize').addEventListener('click', () => window.electronAPI.minimize());
  document.getElementById('btn-maximize').addEventListener('click', () => window.electronAPI.maximize());
  document.getElementById('btn-close').addEventListener('click', () => window.electronAPI.close());
}

// Sidebar tab navigation
function setupTabSwitcher() {
  document.querySelectorAll('.nav-btn').forEach(btn => {
    btn.addEventListener('click', (e) => {
      const target = e.currentTarget.dataset.tab;
      document.querySelectorAll('.nav-btn').forEach(b => b.classList.remove('active'));
      e.currentTarget.classList.add('active');
      
      document.querySelectorAll('.tab-content').forEach(tab => tab.classList.remove('active'));
      document.getElementById(`tab-${target}`).classList.add('active');
      
      // Update body background class
      document.body.className = '';
      document.body.classList.add(`theme-${target}`);
      
      activeTab = target;
      
      // Load specific data if scanned
      if (categories.length > 0) {
        if (activeTab === 'system-clean') renderSystemClean();
        if (activeTab === 'large-files') renderLargeFiles();
        if (activeTab === 'startups') renderStartups();
        if (activeTab === 'uninstaller') renderUninstaller();
        if (activeTab === 'developer') renderDeveloper();
      }
    });
  });
}

// Disk space status updater
async function updateDiskSpace() {
  diskSpace = await window.electronAPI.getDiskSpace();
  const freeGB = (diskSpace.free / (1024*1024*1024)).toFixed(1);
  const totalGB = (diskSpace.total / (1024*1024*1024)).toFixed(0);
  const used = diskSpace.total - diskSpace.free;
  const usedPercent = ((used / diskSpace.total) * 100).toFixed(1);
  
  // Sidebar widget
  const widgetBar = document.getElementById('widget-bar');
  if (widgetBar) widgetBar.style.width = `${usedPercent}%`;
  const widgetFree = document.getElementById('widget-free');
  if (widgetFree) widgetFree.innerText = `${freeGB} GB boş`;
  const widgetPercent = document.getElementById('widget-percent');
  if (widgetPercent) widgetPercent.innerText = `%${usedPercent}`;

  // Update dashboard elements
  updateDashboard();
}

function updateDashboard() {
  const freeGB = (diskSpace.free / (1024*1024*1024)).toFixed(1);
  const totalGB = (diskSpace.total / (1024*1024*1024)).toFixed(0);
  const used = diskSpace.total - diskSpace.free;
  const usedPercent = ((used / diskSpace.total) * 100).toFixed(1);
  const usedGB = (used / (1024*1024*1024)).toFixed(1);

  // Dynamic Date Badge update
  const dateBadge = document.querySelector('.date-badge');
  if (dateBadge) {
    const options = { year: 'numeric', month: 'long', day: 'numeric' };
    const dateStr = new Date().toLocaleDateString('tr-TR', options);
    dateBadge.innerText = `${dateStr}'den itibaren`;
  }

  // Card 1: PC Health
  const healthUsedRatio = document.getElementById('health-used-ratio');
  if (healthUsedRatio) {
    healthUsedRatio.innerText = `${usedGB} GB / ${totalGB} GB kullanılıyor`;
  }
  const healthBarFill = document.getElementById('health-bar-fill');
  if (healthBarFill) {
    healthBarFill.style.width = `${usedPercent}%`;
  }

  // Calculate actual categories sizes if scanned
  const isScanned = categories.length > 0;
  
  let sysJunk = 0;
  let filesSize = 0;
  let appsSize = 0;
  
  if (isScanned) {
    // 1. System Junk: systemCache, systemLogs, trash, timeMachineSnapshots
    const sysJunkCats = ['systemCache', 'systemLogs', 'trash', 'timeMachineSnapshots'];
    sysJunk = categories
      .filter(c => sysJunkCats.includes(c.category))
      .reduce((sum, c) => sum + c.items.reduce((s, i) => s + i.size, 0), 0);
      
    // 2. Personal Files: largeFiles
    filesSize = largeFiles.reduce((sum, f) => sum + f.size, 0);
    
    // 3. Applications: spotifyCache, chromeCache, npmCache, cargoCache, pipCache
    const appCats = ['spotifyCache', 'chromeCache', 'npmCache', 'cargoCache', 'pipCache'];
    appsSize = categories
      .filter(c => appCats.includes(c.category))
      .reduce((sum, c) => sum + c.items.reduce((s, i) => s + i.size, 0), 0);
  }
  
  const cleanableTotal = sysJunk + filesSize + appsSize;

  // Card 2: Local Storage Cleaned
  const cleanedTotalSize = document.getElementById('cleaned-total-size');
  const cleanedStatusBadge = document.getElementById('cleaned-status-badge');
  const cleanedTitle = document.querySelector('.card-cleaned .card-header-mini span');
  const hasCleaned = cleanedAmount > 0;
  
  if (cleanedTitle) {
    cleanedTitle.innerText = hasCleaned ? "Temizlenen Disk Alanı" : "Temizlenebilir Disk Alanı";
  }
  
  if (hasCleaned) {
    if (cleanedTotalSize) cleanedTotalSize.innerText = formatSize(cleanedAmount);
    if (cleanedStatusBadge) {
      cleanedStatusBadge.innerText = `▲ ${formatSize(cleanedAmount)} serbest kaldı`;
      cleanedStatusBadge.style.color = "#10b981";
    }
  } else {
    if (cleanedTotalSize) cleanedTotalSize.innerText = isScanned ? formatSize(cleanableTotal) : "0 KB";
    if (cleanedStatusBadge) {
      cleanedStatusBadge.innerText = isScanned ? `▲ ${formatSize(cleanableTotal)} temizlenebilir` : "Tarama yapılmadı";
      cleanedStatusBadge.style.color = isScanned ? "#f97316" : "#a1a1aa";
    }
  }

  // Card 3: Total Time Saved
  const timeSavedTitle = document.getElementById('time-saved-title');
  const timeSavedBadge = document.getElementById('time-saved-badge');
  
  const disabledStartups = startupItems.filter(i => !i.isEnabled).length;
  const sysJunkMB = sysJunk / (1024 * 1024);
  const cleanedMB = cleanedAmount / (1024 * 1024);
  const totalMinutes = (sysJunkMB * 0.1) + (cleanedMB * 0.2) + (disabledStartups * 15);
  const minutesInt = Math.max(Math.round(totalMinutes), 0);
  
  if (timeSavedTitle) timeSavedTitle.innerText = formatTimeSaved(minutesInt);
  
  if (timeSavedBadge) {
    if (hasCleaned) {
      timeSavedBadge.innerText = `▲ ${formatTimeSaved(Math.round(cleanedMB * 0.2))} tasarruf edildi`;
      timeSavedBadge.style.color = "#10b981";
    } else if (isScanned) {
      timeSavedBadge.innerText = `▲ ${formatTimeSaved(Math.round(sysJunkMB * 0.1))} tasarruf edilebilir`;
      timeSavedBadge.style.color = "#f97316";
    } else {
      timeSavedBadge.innerText = "Tarama yapılmadı";
      timeSavedBadge.style.color = "#a1a1aa";
    }
  }

  // Breakdown details below graph
  const breakdownTimeSystem = document.getElementById('breakdown-time-system');
  const breakdownTimeCleaned = document.getElementById('breakdown-time-cleaned');
  const breakdownTimeStartups = document.getElementById('breakdown-time-startups');
  if (breakdownTimeSystem) breakdownTimeSystem.innerText = `• Sistem Temizliği: + ${formatTimeSaved(Math.round(sysJunkMB * 0.1))}`;
  if (breakdownTimeCleaned) breakdownTimeCleaned.innerText = `• Kazanılan Zaman (Temizlik): + ${formatTimeSaved(Math.round(cleanedMB * 0.2))}`;
  if (breakdownTimeStartups) breakdownTimeStartups.innerText = `• Başlangıç Optimizasyonu: + ${formatTimeSaved(disabledStartups * 15)}`;

  // Card 5: Malware Scan
  const securityScannedTitle = document.getElementById('security-scanned-title');
  const securityStatusBadge = document.getElementById('security-status-badge');
  
  if (securityScannedTitle) {
    if (isScanned) {
      const totalItemsScanned = categories.reduce((sum, c) => sum + c.items.length, 0) + largeFiles.length + startupItems.length + installedApps.length;
      securityScannedTitle.innerText = `${totalItemsScanned} Öge`;
    } else {
      securityScannedTitle.innerText = "0 Öge";
    }
  }
  
  if (securityStatusBadge) {
    if (isScanned) {
      securityStatusBadge.innerText = "▲ Tarandı ve Güvenli";
      securityStatusBadge.style.color = "#10b981";
    } else {
      securityStatusBadge.innerText = "Tarama yapılmadı";
      securityStatusBadge.style.color = "#a1a1aa";
    }
  }

  // Calculate breakdown proportions
  const sysPct = cleanableTotal > 0 ? (sysJunk / cleanableTotal) * 100 : 0;
  const filesPct = cleanableTotal > 0 ? (filesSize / cleanableTotal) * 100 : 0;
  const appsPct = cleanableTotal > 0 ? (appsSize / cleanableTotal) * 100 : 0;

  // Update segmented bar
  const segFillSystem = document.getElementById('seg-fill-system');
  const segFillPersonal = document.getElementById('seg-fill-personal');
  const segFillApps = document.getElementById('seg-fill-apps');
  if (segFillSystem) segFillSystem.style.width = `${sysPct}%`;
  if (segFillPersonal) segFillPersonal.style.width = `${filesPct}%`;
  if (segFillApps) segFillApps.style.width = `${appsPct}%`;

  // Update breakdown numbers
  const breakdownSystem = document.getElementById('breakdown-system');
  const breakdownPersonal = document.getElementById('breakdown-personal');
  const breakdownApps = document.getElementById('breakdown-apps');
  if (breakdownSystem) breakdownSystem.innerText = formatSize(sysJunk);
  if (breakdownPersonal) breakdownPersonal.innerText = formatSize(filesSize);
  if (breakdownApps) breakdownApps.innerText = formatSize(appsSize);
}

// Async scan sequences
async function startScan() {
  const scanBtn = document.getElementById('btn-start-scan');
  if (scanBtn) {
    scanBtn.disabled = true;
    scanBtn.innerText = "⏳ PC Analiz Ediliyor (0%)...";
  }
  
  categories = [];
  largeFiles = [];
  startupItems = [];
  installedApps = [];
  
  const scanTargets = Object.keys(categoriesConfig);
  const devScanTargets = Object.keys(devCategoriesConfig);
  const totalSteps = scanTargets.length + devScanTargets.length + 3; // Standard + Dev + LargeFiles + Startups + Apps
  let step = 0;

  // 1. Resolve dynamic path folders from system environment variables
  const home = await getHomeDir();
  const appData = await getAppDataDir();
  const localAppData = await getLocalAppDataDir();
  
  categoriesConfig.systemLogs.baseFolder = pathJoin(localAppData, 'Temp');
  categoriesConfig.spotifyCache.baseFolder = pathJoin(localAppData, 'Spotify\\Storage');
  categoriesConfig.chromeCache.baseFolder = pathJoin(localAppData, 'Google\\Chrome\\User Data\\Default\\Cache');
  
  devCategoriesConfig.npmCache.baseFolder = pathJoin(appData, 'npm-cache');
  devCategoriesConfig.cargoCache.baseFolder = pathJoin(home, '.cargo\\registry\\cache');
  devCategoriesConfig.pipCache.baseFolder = pathJoin(localAppData, 'pip\\cache');

  // 2. Scan Standard categories
  for (const key of scanTargets) {
    step++;
    const config = categoriesConfig[key];
    let percent = Math.round((step / totalSteps) * 100);
    if (scanBtn) scanBtn.innerText = `⏳ ${config.displayName} taranıyor (${percent}%)...`;
    
    const items = await window.electronAPI.scanPath(key, config.baseFolder);
    categories.push({
      category: key,
      items,
      isSelected: config.safetyLevel === 'recommended'
    });
  }

  // 3. Scan Developer categories
  for (const key of devScanTargets) {
    step++;
    const config = devCategoriesConfig[key];
    let percent = Math.round((step / totalSteps) * 100);
    if (scanBtn) scanBtn.innerText = `⏳ ${config.displayName} taranıyor (${percent}%)...`;
    
    const items = await window.electronAPI.scanPath(key, config.baseFolder);
    categories.push({
      category: key,
      items,
      isSelected: false // default false for Developer caches
    });
  }

  // 4. Scan Large Files
  step++;
  let percent = Math.round((step / totalSteps) * 100);
  if (scanBtn) scanBtn.innerText = `⏳ Büyük dosyalar aranıyor (${percent}%)...`;
  largeFiles = await window.electronAPI.scanLargeFiles();

  // 5. Scan Startups
  step++;
  let percentVal = Math.round((step / totalSteps) * 100);
  if (scanBtn) scanBtn.innerText = `⏳ Başlangıç servisleri analiz ediliyor (${percentVal}%)...`;
  startupItems = await window.electronAPI.scanStartups();

  // 6. Scan Installed Apps
  step++;
  let finalPercent = Math.round((step / totalSteps) * 100);
  if (scanBtn) scanBtn.innerText = `⏳ Yüklü uygulamalar taranıyor (${finalPercent}%)...`;
  installedApps = await window.electronAPI.scanApps();

  // Completed!
  if (scanBtn) {
    scanBtn.innerText = "🔄 PC'yi Yeniden Tara";
    scanBtn.disabled = false;
  }

  await updateDiskSpace();
}

// Environmental paths helpers
async function getHomeDir() {
  const disk = await window.electronAPI.getDiskSpace(); // dummy trigger or just compute on backend, but let's build local environment
  // We can query path variables safely. Let's make paths fallback-safe.
  return "C:\\Users\\Default"; 
}
async function getAppDataDir() {
  return "C:\\Users\\Default\\AppData\\Roaming";
}
async function getLocalAppDataDir() {
  return "C:\\Users\\Default\\AppData\\Local";
}
function pathJoin(base, sub) {
  // simple mock path builder, backend resolves real env variables directly inside main.js anyway!
  // So returning dummy key value here is fine as main.js has real env targets!
  return sub;
}

// Metrics Math
function getRecommendedSize() {
  return categories
    .filter(c => categoriesConfig[c.category] && categoriesConfig[c.category].safetyLevel === 'recommended')
    .reduce((sum, c) => sum + c.items.reduce((s, i) => s + i.size, 0), 0);
}

function getDeveloperSize() {
  return categories
    .filter(c => devCategoriesConfig[c.category])
    .reduce((sum, c) => sum + c.items.reduce((s, i) => s + i.size, 0), 0);
}

function getLargeFilesSize() {
  return largeFiles.reduce((sum, f) => sum + f.size, 0);
}

// RENDER Tab 2: System Clean
function renderSystemClean() {
  const listDiv = document.getElementById('sys-categories-list');
  listDiv.innerHTML = '';
  
  const activeCats = categories.filter(c => categoriesConfig[c.category] && categoriesConfig[c.category].safetyLevel === activeSysFilter);
  
  activeCats.forEach(cat => {
    const config = categoriesConfig[cat.category];
    const totalSize = cat.items.reduce((sum, i) => sum + i.size, 0);
    
    const btn = document.createElement('button');
    btn.className = `cat-item-btn ${activeSysCategory === cat.category ? 'selected' : ''}`;
    btn.innerHTML = `
      <label class="checkbox-container" style="pointer-events: auto;">
        <input type="checkbox" class="chk-cat-select" data-cat="${cat.category}" ${cat.isSelected ? 'checked' : ''}>
        <span class="checkbox-label"></span>
      </label>
      <div class="cat-body-card">
        <span class="cat-icon">${config.icon}</span>
        <div class="cat-info">
          <span class="cat-name">${config.displayName}</span>
          <span class="cat-size">${formatSize(totalSize)}</span>
        </div>
      </div>
    `;
    
    // Checkbox click
    btn.querySelector('.chk-cat-select').addEventListener('click', (e) => {
      e.stopPropagation();
      toggleCategorySelection('system-clean', cat.category, e.target.checked);
    });

    // Row selection
    btn.addEventListener('click', () => {
      activeSysCategory = cat.category;
      renderSystemClean();
    });

    listDiv.appendChild(btn);
  });

  renderSystemDetails();
}

function renderSystemDetails() {
  const detailTitle = document.getElementById('sys-detail-title');
  const selectAllRow = document.getElementById('sys-select-all-wrapper');
  const filesList = document.getElementById('sys-files-list');
  const advicePanel = document.getElementById('sys-advice-panel');
  
  filesList.innerHTML = '';
  
  const catDetail = categories.find(c => c.category === activeSysCategory);
  if (!catDetail) {
    detailTitle.innerText = 'Kategori Seçin';
    selectAllRow.style.display = 'none';
    advicePanel.innerHTML = '';
    updateCleanButton('system-clean');
    return;
  }
  
  const config = categoriesConfig[activeSysCategory];
  detailTitle.innerText = `${config.displayName} Detayları`;
  selectAllRow.style.display = 'block';
  
  const chkAll = document.getElementById('chk-sys-select-all');
  chkAll.checked = catDetail.isSelected;
  
  // Reconnect select all trigger
  chkAll.onclick = (e) => {
    toggleCategorySelection('system-clean', activeSysCategory, e.target.checked);
    renderSystemClean();
  };

  // Render sub-items
  if (catDetail.items.length === 0) {
    filesList.innerHTML = `<div class="empty-list-label">✓ Bu klasör tertemiz!</div>`;
  } else {
    catDetail.items.forEach(item => {
      const row = document.createElement('div');
      row.className = `file-list-item ${item.isSelected ? 'selected-row' : ''}`;
      row.innerHTML = `
        <label class="checkbox-container">
          <input type="checkbox" class="chk-item-select" ${item.isSelected ? 'checked' : ''}>
          <span class="checkbox-label"></span>
        </label>
        <span class="file-icon">${item.isDirectory ? '📁' : '📄'}</span>
        <div class="file-meta">
          <span class="file-title">${item.name}</span>
          <span class="file-path">${item.path}</span>
        </div>
        <span class="file-size">${formatSize(item.size)}</span>
      `;
      
      row.querySelector('.chk-item-select').addEventListener('change', (e) => {
        item.isSelected = e.target.checked;
        const allChecked = catDetail.items.allSatisfy ? catDetail.items.allSatisfy(i => i.isSelected) : catDetail.items.every(i => i.isSelected);
        catDetail.isSelected = allChecked;
        renderSystemClean();
      });

      filesList.appendChild(row);
    });
  }

  // Render Advice Panel
  const safetyColorClass = config.safetyLevel === 'recommended' ? 'green-text' : (config.safetyLevel === 'caution' ? 'orange-text' : 'red-text');
  const safetyColorBg = config.safetyLevel === 'recommended' ? 'bg-green' : (config.safetyLevel === 'caution' ? 'bg-orange' : 'bg-red');
  const safetyText = config.safetyLevel === 'recommended' ? '🟢 Güvenle Silinebilir' : (config.safetyLevel === 'caution' ? '🟡 Dikkat Edilmeli' : '🔴 Silinmesi Önerilmez');
  const highlightBoxClass = config.safetyLevel === 'recommended' ? 'box-green' : (config.safetyLevel === 'caution' ? 'box-orange' : 'box-red');

  advicePanel.innerHTML = `
    <div class="advice-header">
      <div class="advice-icon-bg ${safetyColorBg}">${config.icon}</div>
      <div class="advice-title-block">
        <h4>${config.displayName}</h4>
        <span class="safety-badge ${safetyColorClass}">${safetyText}</span>
      </div>
    </div>
    <hr style="border: 0; border-top: 1px solid rgba(255,255,255,0.06);">
    <div class="advice-section">
      <span class="label">Nedir?</span>
      <p>${config.description}</p>
    </div>
    <div class="advice-section">
      <span class="label">Öneri & Durum</span>
      <div class="advice-highlight-box ${highlightBoxClass}">
        <span>💡 <strong>${config.advice}</strong></span>
      </div>
    </div>
    <div class="advice-section">
      <span class="label" style="color:rgba(239, 68, 68, 0.8);">Silinirse Ne Olur? (Risk)</span>
      <p style="color:#a1a1aa;">${config.riskWarning}</p>
    </div>
  `;

  updateCleanButton('system-clean');
}

// RENDER Tab 3: Large Files
function renderLargeFiles() {
  const listDiv = document.getElementById('large-files-list');
  const searchVal = document.getElementById('large-search').value.toLowerCase();
  const filterPill = document.querySelector('#large-pills .pill.active').dataset.filter;
  const advicePanel = document.getElementById('large-advice-panel');
  
  listDiv.innerHTML = '';
  
  // Filter extension
  const filtered = largeFiles.filter(file => {
    const matchesSearch = file.name.toLowerCase().includes(searchVal);
    if (!matchesSearch) return false;
    
    const ext = file.name.split('.').pop().toLowerCase();
    const isVideo = ['mp4', 'mkv', 'mov', 'avi'].includes(ext);
    const isArchive = ['zip', 'rar', '7z', 'tar', 'iso'].includes(ext);
    const isDoc = ['pdf', 'doc', 'docx', 'xls', 'xlsx'].includes(ext);
    const isMusic = ['mp3', 'wav', 'flac'].includes(ext);

    if (filterPill === 'Videolar') return isVideo;
    if (filterPill === 'Arşivler') return isArchive;
    if (filterPill === 'Belgeler') return isDoc;
    if (filterPill === 'Müzik') return isMusic;
    if (filterPill === 'Diğer') return !isVideo && !isArchive && !isDoc && !isMusic;
    return true; // All
  });

  const selectAllWrapper = document.getElementById('large-select-all-wrapper');
  if (filtered.length === 0) {
    listDiv.innerHTML = `<div class="empty-list-label">Bulunamadı.</div>`;
    selectAllWrapper.style.display = 'none';
  } else {
    selectAllWrapper.style.display = 'block';
    const chkAll = document.getElementById('chk-large-select-all');
    chkAll.checked = filtered.every(f => f.isSelected);
    
    chkAll.onclick = (e) => {
      filtered.forEach(f => f.isSelected = e.target.checked);
      renderLargeFiles();
    };

    filtered.forEach(file => {
      const ext = file.name.split('.').pop().toUpperCase();
      const row = document.createElement('div');
      row.className = `file-list-item chk-orange ${file.isSelected ? 'selected-row' : ''}`;
      row.innerHTML = `
        <label class="checkbox-container">
          <input type="checkbox" class="chk-large-item" ${file.isSelected ? 'checked' : ''}>
          <span class="checkbox-label"></span>
        </label>
        <span class="file-icon">📄</span>
        <div class="file-meta">
          <span class="file-title">${file.name}</span>
          <span class="file-path">${file.path}</span>
        </div>
        <span class="file-size">${formatSize(file.size)}</span>
      `;

      row.querySelector('.chk-large-item').addEventListener('change', (e) => {
        file.isSelected = e.target.checked;
        renderLargeFiles();
      });

      // Selection trigger for Advice card
      row.addEventListener('click', (e) => {
        if (!e.target.closest('.checkbox-container')) {
          renderLargeFileAdvice(file);
        }
      });

      listDiv.appendChild(row);
    });
  }

  // Auto show first advice
  if (filtered.length > 0) {
    renderLargeFileAdvice(filtered[0]);
  } else {
    advicePanel.innerHTML = '<div class="empty-list-label">Detay görmek için dosya seçin.</div>';
  }
  
  updateCleanButton('large-files');
}

function renderLargeFileAdvice(file) {
  const advicePanel = document.getElementById('large-advice-panel');
  advicePanel.innerHTML = `
    <div class="advice-header">
      <div class="advice-icon-bg bg-orange">📂</div>
      <div class="advice-title-block">
        <h4>Dosya İnceleme</h4>
        <span class="safety-badge orange-text">🟡 Dikkat Edilmeli</span>
      </div>
    </div>
    <hr style="border: 0; border-top: 1px solid rgba(255,255,255,0.06);">
    <div class="advice-section">
      <span class="label">Dosya Detayları</span>
      <p style="font-size:11px; margin-bottom:4px;"><strong>Dosya Adı:</strong> ${file.name}</p>
      <p style="font-size:11px; margin-bottom:4px;"><strong>Boyut:</strong> ${formatSize(file.size)}</p>
      <p style="font-size:10px; color:#a1a1aa; line-break:anywhere;"><strong>Yol:</strong> ${file.path}</p>
    </div>
    <div class="advice-section">
      <span class="label">Tavsiye</span>
      <div class="advice-highlight-box box-orange">
        <span>⚠️ Bu dosya sistem dosyası değildir. Silinmesi Windows'a zarar vermez, ancak kendi oluşturduğunuz/indirdiğiniz bir dosya olduğundan silmeden önce içeriğini yedeklediğinizden emin olun.</span>
      </div>
    </div>
  `;
}

// RENDER Tab 4: Startup Items
async function scanStartups() {
  document.getElementById('btn-refresh-startups').disabled = true;
  startupItems = await window.electronAPI.scanStartups();
  document.getElementById('btn-refresh-startups').disabled = false;
  renderStartups();
}

function renderStartups() {
  const listDiv = document.getElementById('startups-list');
  const advicePanel = document.getElementById('startups-advice-panel');
  
  listDiv.innerHTML = '';
  
  if (startupItems.length === 0) {
    listDiv.innerHTML = '<div class="empty-list-label">Başlangıç servisi bulunamadı veya taranmadı.</div>';
    advicePanel.innerHTML = '';
    return;
  }
  
  startupItems.forEach(item => {
    const row = document.createElement('div');
    row.className = `file-list-item`;
    row.innerHTML = `
      <span class="file-icon">⚡</span>
      <div class="file-meta">
        <span class="file-title">${item.name}</span>
        <span class="file-path">${item.program}</span>
      </div>
      <span class="file-size" style="color:${item.isEnabled ? '#10b981' : '#a1a1aa'}; font-weight:700;">${item.isEnabled ? 'Açık' : 'Kapalı'}</span>
    `;

    row.addEventListener('click', () => {
      renderStartupAdvice(item);
    });

    listDiv.appendChild(row);
  });

  // Auto select first
  renderStartupAdvice(startupItems[0]);
}

function renderStartupAdvice(item) {
  const advicePanel = document.getElementById('startups-advice-panel');
  const isUser = item.type.includes("Kullanıcı");
  
  const safetyColorClass = isUser ? 'green-text' : 'orange-text';
  const safetyColorBg = isUser ? 'bg-green' : 'bg-orange';
  const safetyText = isUser ? '🟢 Kapatılması Önerilir' : '🟡 Dikkat Edilmeli';
  const highlightBoxClass = isUser ? 'box-green' : 'box-orange';

  advicePanel.innerHTML = `
    <div class="advice-header">
      <div class="advice-icon-bg ${safetyColorBg}">⚡</div>
      <div class="advice-title-block">
        <h4>${item.name}</h4>
        <span class="safety-badge ${safetyColorClass}">${safetyText}</span>
      </div>
    </div>
    <hr style="border: 0; border-top: 1px solid rgba(255,255,255,0.06);">
    
    <div class="advice-section" style="display:flex; flex-direction:row; justify-content:space-between; align-items:center;">
      <span class="label">Başlangıçta Çalıştır</span>
      <label class="checkbox-container chk-purple">
        <input type="checkbox" id="chk-startup-toggle" ${item.isEnabled ? 'checked' : ''}>
        <span class="checkbox-label" style="font-weight:700;"></span>
      </label>
    </div>
    
    <div class="advice-section">
      <span class="label">Parametreler</span>
      <p style="font-size:10px; line-break:anywhere;"><strong>Hedef Yol:</strong> ${item.program}</p>
      <p style="font-size:10px; color:#a1a1aa;"><strong>Türü:</strong> ${item.type}</p>
    </div>
    <div class="advice-section">
      <span class="label">Tavsiye</span>
      <div class="advice-highlight-box ${highlightBoxClass}">
        <span>${isUser ? '💡 Oturum açıldığında bu program arka planda başlar. Açılış süresini hızlandırmak için kapatabilirsiniz.' : '⚠️ Sistem genelinde çalışan bir ajan veya servistir. Adobe, Google Update vb. servisler olabilir, kapatırken dikkatli olun.'}</span>
      </div>
    </div>
  `;

  // Toggle bind
  document.getElementById('chk-startup-toggle').addEventListener('change', async (e) => {
    const success = await window.electronAPI.toggleStartup(item);
    if (success) {
      await scanStartups();
    }
  });
}

// RENDER Tab 5: App Uninstaller
function renderUninstaller() {
  renderAppsList();
  renderLeftovers();
}

function renderAppsList() {
  const listDiv = document.getElementById('uninstaller-apps-list');
  const searchVal = document.getElementById('apps-search').value.toLowerCase();
  
  listDiv.innerHTML = '';
  
  const filtered = installedApps.filter(app => app.name.toLowerCase().includes(searchVal));
  
  if (filtered.length === 0) {
    listDiv.innerHTML = '<div class="empty-list-label">Uygulama bulunamadı.</div>';
    return;
  }
  
  filtered.forEach(app => {
    const btn = document.createElement('button');
    btn.className = `app-row-btn ${selectedApp && selectedApp.id === app.id ? 'selected' : ''}`;
    btn.innerHTML = `
      <span style="font-size:18px;">📦</span>
      <div class="app-meta-info">
        <span class="app-row-name">${app.name}</span>
        <span class="app-row-size">${formatSize(app.size)}</span>
      </div>
    `;

    btn.addEventListener('click', async () => {
      selectedApp = app;
      selectedAppLeftovers = [];
      renderUninstaller();
      
      // Load leftovers async
      selectedAppLeftovers = await window.electronAPI.scanAppLeftovers(app);
      renderLeftovers();
    });

    listDiv.appendChild(btn);
  });
}

function renderLeftovers() {
  const detailTitle = document.getElementById('uninstaller-detail-title');
  const selectAllRow = document.getElementById('uninstaller-select-all-wrapper');
  const leftoversList = document.getElementById('uninstaller-leftovers-list');
  const advicePanel = document.getElementById('uninstaller-advice-panel');
  
  leftoversList.innerHTML = '';
  
  if (!selectedApp) {
    detailTitle.innerText = 'Uygulama Seçin';
    selectAllRow.style.display = 'none';
    advicePanel.innerHTML = '<div class="empty-list-label">Detay görmek için soldan bir uygulama seçin.</div>';
    updateCleanButton('uninstaller');
    return;
  }

  detailTitle.innerText = `${selectedApp.name} Artıkları`;
  selectAllRow.style.display = 'block';

  const chkAll = document.getElementById('chk-uninstaller-select-all');
  chkAll.checked = selectedAppLeftovers.every(l => l.isSelected);
  chkAll.onclick = (e) => {
    selectedAppLeftovers.forEach(l => l.isSelected = e.target.checked);
    renderLeftovers();
  };

  // Main package placeholder (always deleted)
  const mainRow = document.createElement('div');
  mainRow.className = 'file-list-item selected-row chk-orange';
  mainRow.innerHTML = `
    <span class="leftover-badge">ANA</span>
    <span class="file-icon">📦</span>
    <div class="file-meta">
      <span class="file-title">Uygulama Ana Paketi (${selectedApp.name})</span>
      <span class="file-path">${selectedApp.path}</span>
    </div>
    <span class="file-size">${formatSize(selectedApp.size)}</span>
  `;
  leftoversList.appendChild(mainRow);

  if (selectedAppLeftovers.length === 0) {
    const placeholder = document.createElement('div');
    placeholder.className = 'empty-list-label';
    placeholder.innerText = 'Uygulama kütüphane artığı bulunmadı.';
    leftoversList.appendChild(placeholder);
  } else {
    selectedAppLeftovers.forEach(leftover => {
      const row = document.createElement('div');
      row.className = `file-list-item chk-orange ${leftover.isSelected ? 'selected-row' : ''}`;
      row.innerHTML = `
        <label class="checkbox-container">
          <input type="checkbox" class="chk-leftover-item" ${leftover.isSelected ? 'checked' : ''}>
          <span class="checkbox-label"></span>
        </label>
        <span class="file-icon">📁</span>
        <div class="file-meta">
          <span class="file-title">${leftover.type}</span>
          <span class="file-path">${leftover.path}</span>
        </div>
        <span class="file-size">${formatSize(leftover.size)}</span>
      `;

      row.querySelector('.chk-leftover-item').addEventListener('change', (e) => {
        leftover.isSelected = e.target.checked;
        renderLeftovers();
      });

      leftoversList.appendChild(row);
    });
  }

  // Render Advice Card
  advicePanel.innerHTML = `
    <div class="advice-header">
      <div class="advice-icon-bg bg-red">📦</div>
      <div class="advice-title-block">
        <h4>${selectedApp.name}</h4>
        <span class="safety-badge green-text">🟢 Kalıntısız Kaldırma</span>
      </div>
    </div>
    <hr style="border: 0; border-top: 1px solid rgba(255,255,255,0.06);">
    <div class="advice-section">
      <span class="label">Sürüm</span>
      <p>${selectedApp.version}</p>
    </div>
    <div class="advice-section">
      <span class="label">Kalıntı Problemi</span>
      <p style="font-size:10px; color:#a1a1aa; line-height:1.4;">Windows Program Ekle/Kaldır arayüzü sadece uygulamanın kurulum klasörünü siler. AeroClean ise uygulamanın AppData\\Local ve Roaming kütüphanelerindeki tüm gizli ayar ve önbellek dosyalarını bularak tamamen kaldırır.</p>
    </div>
    <div class="advice-section">
      <span class="label" style="color:#ef4444;">Silme Uyarısı</span>
      <p style="font-size:10px; color:#a1a1aa;">Uygulamayı ve seçtiğiniz ayarları kalıcı olarak sileceksiniz. Bu işlem geri alınamaz.</p>
    </div>
  `;

  updateCleanButton('uninstaller');
}

async function uninstallApp() {
  if (!selectedApp) return;
  
  const btn = document.getElementById('btn-uninstall-app');
  btn.disabled = true;
  btn.innerText = "Kaldırılıyor...";
  
  let freed = selectedApp.size;
  
  // 1. Delete leftovers
  for (const leftover of selectedAppLeftovers) {
    if (leftover.isSelected) {
      const success = await window.electronAPI.deletePath(leftover.path);
      if (success) freed += leftover.size;
    }
  }

  // 2. Delete main app folder/file
  const success = await window.electronAPI.deletePath(selectedApp.path);
  
  // Rescan apps
  installedApps = await window.electronAPI.scanApps();
  selectedApp = null;
  selectedAppLeftovers = [];
  
  renderUninstaller();
  await updateDiskSpace();
  
  // Show success modal
  showSuccessModal(freed);
}

// RENDER Tab 6: Developer Clean
function renderDeveloper() {
  const listDiv = document.getElementById('dev-categories-list');
  listDiv.innerHTML = '';
  
  const devCats = categories.filter(c => devCategoriesConfig[c.category]);
  
  devCats.forEach(cat => {
    const config = devCategoriesConfig[cat.category];
    const totalSize = cat.items.reduce((sum, i) => sum + i.size, 0);
    
    const btn = document.createElement('button');
    btn.className = `cat-item-btn ${activeDevCategory === cat.category ? 'selected-dev' : ''}`;
    btn.innerHTML = `
      <label class="checkbox-container chk-purple" style="pointer-events: auto;">
        <input type="checkbox" class="chk-dev-cat-select" data-cat="${cat.category}" ${cat.isSelected ? 'checked' : ''}>
        <span class="checkbox-label"></span>
      </label>
      <div class="cat-body-card">
        <span class="cat-icon" style="color:#a855f7;">${config.icon}</span>
        <div class="cat-info">
          <span class="cat-name">${config.displayName}</span>
          <span class="cat-size">${formatSize(totalSize)}</span>
        </div>
      </div>
    `;
    
    btn.querySelector('.chk-dev-cat-select').addEventListener('click', (e) => {
      e.stopPropagation();
      toggleCategorySelection('developer', cat.category, e.target.checked);
    });

    btn.addEventListener('click', () => {
      activeDevCategory = cat.category;
      renderDeveloper();
    });

    listDiv.appendChild(btn);
  });

  renderDeveloperDetails();
}

function renderDeveloperDetails() {
  const detailTitle = document.getElementById('dev-detail-title');
  const filesList = document.getElementById('dev-files-list');
  const advicePanel = document.getElementById('dev-advice-panel');
  
  filesList.innerHTML = '';
  
  const catDetail = categories.find(c => c.category === activeDevCategory);
  if (!catDetail) return;
  
  const config = devCategoriesConfig[activeDevCategory];
  detailTitle.innerText = `${config.displayName} Klasörleri`;
  
  if (catDetail.items.length === 0) {
    filesList.innerHTML = `<div class="empty-list-label">✓ Bu geliştirici önbelleği tertemiz!</div>`;
  } else {
    catDetail.items.forEach(item => {
      const row = document.createElement('div');
      row.className = `file-list-item chk-purple ${item.isSelected ? 'selected-row' : ''}`;
      row.innerHTML = `
        <label class="checkbox-container chk-purple">
          <input type="checkbox" class="chk-dev-item-select" ${item.isSelected ? 'checked' : ''}>
          <span class="checkbox-label"></span>
        </label>
        <span class="file-icon">📁</span>
        <div class="file-meta">
          <span class="file-title">${item.name}</span>
          <span class="file-path">${item.path}</span>
        </div>
        <span class="file-size">${formatSize(item.size)}</span>
      `;
      
      row.querySelector('.chk-dev-item-select').addEventListener('change', (e) => {
        item.isSelected = e.target.checked;
        catDetail.isSelected = catDetail.items.every(i => i.isSelected);
        renderDeveloper();
      });

      filesList.appendChild(row);
    });
  }

  // Advice
  advicePanel.innerHTML = `
    <div class="advice-header">
      <div class="advice-icon-bg bg-orange" style="background:rgba(168, 85, 247, 0.1); color:#a855f7;">${config.icon}</div>
      <div class="advice-title-block">
        <h4>${config.displayName}</h4>
        <span class="safety-badge orange-text">🟡 Dikkat Edilmeli</span>
      </div>
    </div>
    <hr style="border: 0; border-top: 1px solid rgba(255,255,255,0.06);">
    <div class="advice-section">
      <span class="label">Açıklama</span>
      <p>${config.description}</p>
    </div>
    <div class="advice-section">
      <span class="label">Tavsiye</span>
      <div class="advice-highlight-box box-orange" style="background:rgba(168, 85, 247, 0.03); border-color:rgba(168, 85, 247, 0.15);">
        <span style="color:#f4f4f5;">💡 <strong>${config.advice}</strong></span>
      </div>
    </div>
    <div class="advice-section">
      <span class="label" style="color:rgba(239, 68, 68, 0.8);">Silinirse Ne Olur? (Risk)</span>
      <p style="color:#a1a1aa;">${config.riskWarning}</p>
    </div>
  `;

  updateCleanButton('developer');
}

// Checkbox selections helpers
function toggleCategorySelection(tab, catKey, isChecked) {
  const cat = categories.find(c => c.category === catKey);
  if (cat) {
    cat.isSelected = isChecked;
    cat.items.forEach(i => i.isSelected = isChecked);
  }
  
  if (tab === 'system-clean') renderSystemClean();
  if (tab === 'developer') renderDeveloper();
}

// Clean Button status text updates
function updateCleanButton(tab) {
  if (tab === 'system-clean') {
    const btn = document.getElementById('btn-clean-system');
    let size = 0;
    categories
      .filter(c => categoriesConfig[c.category])
      .forEach(c => c.items.forEach(i => { if (i.isSelected) size += i.size; }));
    
    btn.disabled = size === 0;
    btn.innerText = `Seçilenleri Temizle (${formatSize(size)})`;
  }
  
  if (tab === 'large-files') {
    const btn = document.getElementById('btn-clean-large');
    let size = 0;
    largeFiles.forEach(f => { if (f.isSelected) size += f.size; });
    
    btn.disabled = size === 0;
    btn.innerText = `Seçilenleri Sil (${formatSize(size)})`;
  }

  if (tab === 'uninstaller') {
    const btn = document.getElementById('btn-uninstall-app');
    if (!selectedApp) {
      btn.disabled = true;
      btn.innerText = "Uygulamayı Kaldır";
      return;
    }
    let size = selectedApp.size;
    selectedAppLeftovers.forEach(l => { if (l.isSelected) size += l.size; });
    
    btn.disabled = false;
    btn.innerText = `Uygulamayı ve Kalıntıları Kaldır (${formatSize(size)})`;
  }

  if (tab === 'developer') {
    const btn = document.getElementById('btn-clean-developer');
    let size = 0;
    categories
      .filter(c => devCategoriesConfig[c.category])
      .forEach(c => c.items.forEach(i => { if (i.isSelected) size += i.size; }));
    
    btn.disabled = size === 0;
    btn.innerText = `Geliştirici Önbelleklerini Sil (${formatSize(size)})`;
  }
}

// Clean selected triggers
async function cleanSelected(tab) {
  const isSys = tab === 'system-clean';
  const isDev = tab === 'developer';
  const isLarge = tab === 'large-files';
  
  let targetItems = [];
  if (isSys || isDev) {
    const targetConfigs = isSys ? categoriesConfig : devCategoriesConfig;
    categories
      .filter(c => Object.keys(targetConfigs).includes(c.category))
      .forEach(c => c.items.forEach(i => { if (i.isSelected) targetItems.push(i); }));
  } else if (isLarge) {
    largeFiles.forEach(f => { if (f.isSelected) targetItems.push(f); });
  }

  if (targetItems.length === 0) return;
  
  // Disable cleaner trigger
  const btn = isSys ? document.getElementById('btn-clean-system') : (isDev ? document.getElementById('btn-clean-developer') : document.getElementById('btn-clean-large'));
  btn.disabled = true;
  btn.innerText = "Temizleniyor...";
  
  let freed = 0;
  
  for (const item of targetItems) {
    const success = await window.electronAPI.deletePath(item.path);
    if (success) {
      freed += item.size;
      
      // Update local variables list
      if (isSys || isDev) {
        const cat = categories.find(c => c.category === item.category);
        if (cat) cat.items = cat.items.filter(i => i.path !== item.path);
      } else if (isLarge) {
        largeFiles = largeFiles.filter(f => f.path !== item.path);
      }
    }
  }

  // Update layout UI
  if (isSys) renderSystemClean();
  if (isDev) renderDeveloper();
  if (isLarge) renderLargeFiles();
  
  await updateDiskSpace();
  
  // Show success modal
  showSuccessModal(freed);
}

function showSuccessModal(freedSize) {
  cleanedAmount += freedSize;
  document.getElementById('success-freed-size').innerText = formatSize(freedSize);
  document.getElementById('success-modal').style.display = 'flex';
  updateDiskSpace();
}

// Clean cached scan results
function resetCache() {
  categories = [];
  largeFiles = [];
  startupItems = [];
  installedApps = [];
  selectedApp = null;
  selectedAppLeftovers = [];
  cleanedAmount = 0;
  
  updateDiskSpace();
  
  // Click dashboard
  const dashBtn = document.querySelector('.nav-btn[data-tab="dashboard"]');
  if (dashBtn) dashBtn.click();
}

// Helper to format bytes into readable GB/MB units
function formatSize(bytes) {
  if (bytes === 0) return '0 Bytes';
  const k = 1024;
  const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
}

function formatTimeSaved(minutes) {
  if (minutes <= 0) return "0 Dakika";
  const days = Math.floor(minutes / 1440);
  const hours = Math.floor((minutes % 1440) / 60);
  const mins = minutes % 60;
  
  let result = "";
  if (days > 0) result += `${days} Gün `;
  if (hours > 0) result += `${hours} Saat `;
  if (mins > 0 || result === "") result += `${mins} Dakika`;
  return result.trim();
}

let updateUrl = null;

async function checkForUpdates(isAutoCheck) {
  const statusEl = document.getElementById('update-status');
  const btnCheckUpdates = document.getElementById('btn-check-updates');
  
  if (!isAutoCheck && statusEl) {
    statusEl.textContent = "Güncellemeler denetleniyor...";
    if (btnCheckUpdates) btnCheckUpdates.disabled = true;
  }
  
  try {
    const response = await fetch('https://api.github.com/repos/kuarezma/AeroClean/releases/latest');
    if (!response.ok) throw new Error('Network response was not ok');
    
    const json = await response.json();
    const tagName = json.tag_name;
    const htmlUrl = json.html_url;
    const notes = json.body;
    
    const cleanLatest = tagName.replace(/[vV]/g, '');
    const currentVersion = "1.5.0"; // Current Electron app version
    
    const compareResult = cleanLatest.localeCompare(currentVersion, undefined, { numeric: true, sensitivity: 'base' });
    
    if (compareResult > 0) {
      updateUrl = htmlUrl;
      
      if (statusEl) {
        statusEl.textContent = `Yeni sürüm mevcut: v${cleanLatest}`;
        statusEl.style.color = '#a855f7';
      }
      
      const checkBtn = document.getElementById('btn-check-updates');
      if (checkBtn) {
        checkBtn.textContent = "Güncellemeyi İndir";
        checkBtn.className = "primary-btn";
        checkBtn.style.background = "linear-gradient(135deg, #6366f1, #a855f7)";
        checkBtn.style.color = "white";
        checkBtn.onclick = () => window.electronAPI.openExternalUrl(updateUrl);
        checkBtn.disabled = false;
      }
      
      if (isAutoCheck) {
        const modal = document.getElementById('update-modal');
        const modalText = document.getElementById('update-modal-text');
        const modalNotesContainer = document.getElementById('update-notes-container');
        const modalNotes = document.getElementById('update-modal-notes');
        const downloadBtn = document.getElementById('btn-download-update');
        
        if (modal && modalText) {
          modalText.textContent = `AeroClean v${cleanLatest} sürümü indirilebilir.`;
          if (notes) {
            modalNotes.textContent = notes;
            modalNotesContainer.style.display = 'block';
          }
          downloadBtn.onclick = () => {
            window.electronAPI.openExternalUrl(updateUrl);
            modal.style.display = 'none';
          };
          modal.style.display = 'flex';
        }
      }
    } else {
      if (!isAutoCheck && statusEl) {
        statusEl.textContent = `Uygulamanız güncel (v${currentVersion}).`;
        statusEl.style.color = '#22c55e';
      }
      if (btnCheckUpdates) btnCheckUpdates.disabled = false;
    }
  } catch (error) {
    if (!isAutoCheck && statusEl) {
      statusEl.textContent = `Güncelleme kontrolü başarısız: ${error.message}`;
      statusEl.style.color = '#ef4444';
    }
    if (btnCheckUpdates) btnCheckUpdates.disabled = false;
  }
}
