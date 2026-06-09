const { app, BrowserWindow, ipcMain } = require('electron');
const path = require('path');
const fs = require('fs');
const { exec } = require('child_process');

let mainWindow;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1050,
    height: 650,
    minWidth: 1050,
    minHeight: 650,
    frame: false,             // Frameless for custom modern titlebar/window styling
    transparent: true,        // Allow acrylic/blur background styling
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false
    }
  });

  mainWindow.loadFile('index.html');
  
  // Suppress default menu bar
  mainWindow.setMenuBarVisibility(false);
}

app.whenReady().then(() => {
  createWindow();

  app.on('activate', function () {
    if (BrowserWindow.getAllWindows().length === 0) createWindow();
  });
});

app.on('window-all-closed', function () {
  if (process.platform !== 'darwin') app.quit();
});

// Window controls IPC
ipcMain.on('window-minimize', () => mainWindow.minimize());
ipcMain.on('window-maximize', () => {
  if (mainWindow.isMaximized()) {
    mainWindow.unmaximize();
  } else {
    mainWindow.maximize();
  }
});
ipcMain.on('window-close', () => mainWindow.close());

// Helper to run commands
function runCommand(cmd) {
  return new Promise((resolve) => {
    exec(cmd, { maxBuffer: 1024 * 1024 * 10 }, (error, stdout, stderr) => {
      if (error) {
        resolve({ error, stdout: '', stderr });
      } else {
        resolve({ error: null, stdout, stderr });
      }
    });
  });
}

// 1. Get Windows Disk space
ipcMain.handle('get-disk-space', async () => {
  const cmd = `powershell -Command "Get-CimInstance -ClassName Win32_LogicalDisk -Filter \\"DeviceID='C:'\\" | Select-Object Size, FreeSpace | ConvertTo-Json"`;
  const result = await runCommand(cmd);
  try {
    const data = JSON.parse(result.stdout);
    const total = parseInt(data.Size) || 0;
    const free = parseInt(data.FreeSpace) || 0;
    return { free, total };
  } catch (e) {
    // Default fallback
    return { free: 0, total: 0 };
  }
});

// Helper: Calculate directory size recursively (shallow or deep, catching errors)
function getDirectorySizeRecursive(dirPath) {
  let size = 0;
  try {
    const files = fs.readdirSync(dirPath);
    for (const file of files) {
      const filePath = path.join(dirPath, file);
      const stat = fs.statSync(filePath);
      if (stat.isDirectory()) {
        size += getDirectorySizeRecursive(filePath);
      } else {
        size += stat.size;
      }
    }
  } catch (e) {
    // Suppress permission errors
  }
  return size;
}

// 2. Scan folders
ipcMain.handle('scan-path', async (event, { category, basePath }) => {
  if (!fs.existsSync(basePath)) return [];
  
  const items = [];
  try {
    const stat = fs.statSync(basePath);
    if (!stat.isDirectory()) {
      return [{
        path: basePath,
        name: path.basename(basePath),
        size: stat.size,
        category,
        isDirectory: false,
        isSelected: true
      }];
    }

    const files = fs.readdirSync(basePath);
    for (const file of files) {
      const filePath = path.join(basePath, file);
      try {
        const fileStat = fs.statSync(filePath);
        let size = 0;
        if (fileStat.isDirectory()) {
          size = getDirectorySizeRecursive(filePath);
        } else {
          size = fileStat.size;
        }

        if (size > 0) {
          items.push({
            path: filePath,
            name: file,
            size,
            category,
            isDirectory: fileStat.isDirectory(),
            isSelected: category !== 'downloads' && category !== 'appSupportLeftovers' // Auto check recommended
          });
        }
      } catch (e) {
        // Skip inaccessible sub-items
      }
    }
  } catch (e) {
    print("Scan failed: " + e.message);
  }
  return items.sort((a, b) => b.size - a.size);
});

// 3. Delete files/folders
ipcMain.handle('delete-path', async (event, targetPath) => {
  // Prevent deleting root or system folders
  const protected = [
    'C:\\', 'C:\\Windows', 'C:\\Windows\\System32', 'C:\\Users',
    process.env.USERPROFILE, path.join(process.env.USERPROFILE, 'Desktop'),
    path.join(process.env.USERPROFILE, 'Documents')
  ];
  if (protected.includes(targetPath) || protected.includes(path.normalize(targetPath))) {
    return false;
  }
  try {
    if (fs.existsSync(targetPath)) {
      const stat = fs.statSync(targetPath);
      if (stat.isDirectory()) {
        fs.rmSync(targetPath, { recursive: true, force: true });
      } else {
        fs.unlinkSync(targetPath);
      }
    }
    return true;
  } catch (e) {
    return false;
  }
});

// 4. Large Files Scan (files > 100MB in home subdirectories)
ipcMain.handle('scan-large-files', async () => {
  const home = process.env.USERPROFILE;
  const subdirs = ['Downloads', 'Documents', 'Desktop', 'Videos', 'Music', 'Pictures'];
  const largeFiles = [];
  const minSize = 100 * 1024 * 1024; // 100MB
  
  for (const dir of subdirs) {
    const dirPath = path.join(home, dir);
    if (!fs.existsSync(dirPath)) continue;

    function walk(currentDir) {
      if (largeFiles.count > 100) return; // limit count
      try {
        const files = fs.readdirSync(currentDir);
        for (const file of files) {
          const filePath = path.join(currentDir, file);
          const stat = fs.statSync(filePath);
          if (stat.isDirectory()) {
            // Shallow walk for large user files or skip systems
            if (file !== 'AppData' && file !== 'node_modules' && !file.startsWith('.')) {
              walk(filePath);
            }
          } else {
            if (stat.size >= minSize) {
              largeFiles.push({
                path: filePath,
                name: file,
                size: stat.size,
                category: 'downloads',
                isDirectory: false,
                isSelected: false
              });
            }
          }
        }
      } catch (e) {}
    }
    walk(dirPath);
  }
  return largeFiles.sort((a, b) => b.size - a.size);
});

// 5. Startup Items (Query registry Run and User Startup folder)
ipcMain.handle('scan-startups', async () => {
  const items = [];
  
  // A. Registry: HKCU Run
  const hkcuCmd = `reg query "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Run"`;
  const hkcuResult = await runCommand(hkcuCmd);
  parseRegistryRun(hkcuResult.stdout, "Kullanıcı Başlangıcı (HKCU)", items, true);

  // B. Registry: HKCU Disabled backup (AeroClean)
  const hkcuDisabledCmd = `reg query "HKCU\\Software\\AeroClean\\DisabledRun"`;
  const hkcuDisabledResult = await runCommand(hkcuDisabledCmd);
  parseRegistryRun(hkcuDisabledResult.stdout, "Kullanıcı Başlangıcı (HKCU)", items, false);

  // C. Registry: HKLM Run
  const hklmCmd = `reg query "HKLM\\Software\\Microsoft\\Windows\\CurrentVersion\\Run"`;
  const hklmResult = await runCommand(hklmCmd);
  parseRegistryRun(hklmResult.stdout, "Sistem Genel Ajanı (HKLM)", items, true);

  // D. Startup folder
  const startupPath = path.join(process.env.APPDATA, 'Microsoft\\Windows\\Start Menu\\Programs\\Startup');
  if (fs.existsSync(startupPath)) {
    try {
      const files = fs.readdirSync(startupPath);
      for (const file of files) {
        items.push({
          name: file,
          label: file,
          path: path.join(startupPath, file),
          type: "Startup Klasörü",
          program: path.join(startupPath, file),
          isEnabled: true
        });
      }
    } catch(e) {}
  }
  
  return items;
});

function parseRegistryRun(stdout, type, list, isEnabled) {
  if (!stdout) return;
  const lines = stdout.split('\r\n');
  for (const line of lines) {
    if (line.trim() === '' || line.startsWith('HKEY_')) continue;
    const match = line.match(/^\s*(.*?)\s+REG_(?:SZ|EXPAND_SZ)\s+(.*)$/);
    if (match) {
      const label = match[1].trim();
      const program = match[2].trim();
      list.push({
        name: label,
        label: label,
        path: label, // We use registry label as ID/Path trigger
        type,
        program,
        isEnabled
      });
    }
  }
}

// 6. Toggle Startup (Move between Run and AeroClean\DisabledRun)
ipcMain.handle('toggle-startup', async (event, item) => {
  if (item.type.includes("Startup Klasörü")) {
    // For startup folder, we rename shortcut file or move to temp
    const fileDir = path.dirname(item.program);
    const fileName = path.basename(item.program);
    const newPath = item.isEnabled 
      ? item.program.replace('.lnk', '.lnk.disabled')
      : item.program.replace('.lnk.disabled', '.lnk');
    try {
      fs.renameSync(item.program, newPath);
      return true;
    } catch(e) {
      return false;
    }
  }
  
  const runKey = `HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Run`;
  const disabledKey = `HKCU\\Software\\AeroClean\\DisabledRun`;
  
  if (item.isEnabled) {
    // Disable: Run -> DisabledRun
    const addCmd = `reg add "${disabledKey}" /v "${item.label}" /d "${item.program.replace(/"/g, '\\"')}" /f`;
    const delCmd = `reg delete "${runKey}" /v "${item.label}" /f`;
    await runCommand(addCmd);
    await runCommand(delCmd);
  } else {
    // Enable: DisabledRun -> Run
    const addCmd = `reg add "${runKey}" /v "${item.label}" /d "${item.program.replace(/"/g, '\\"')}" /f`;
    const delCmd = `reg delete "${disabledKey}" /v "${item.label}" /f`;
    await runCommand(addCmd);
    await runCommand(delCmd);
  }
  return true;
});

// 7. Apps list via PowerShell
ipcMain.handle('scan-apps', async () => {
  const cmd = `powershell -Command "Get-ItemProperty HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\*, HKLM:\\Software\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\*, HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\* | Where-Object { $_.DisplayName -and $_.SystemComponent -ne 1 } | Select-Object DisplayName, DisplayVersion, InstallLocation, UninstallString, EstimatedSize | ConvertTo-Json"`;
  const result = await runCommand(cmd);
  try {
    let list = JSON.parse(result.stdout);
    if (!Array.isArray(list)) list = [list];
    
    // Filter and map
    return list
      .filter(app => app && app.DisplayName)
      .map(app => {
        // Size in Registry is KB, convert to bytes
        const size = (app.EstimatedSize ? parseInt(app.EstimatedSize) * 1024 : 0) || (150 * 1024 * 1024); // fallback 150MB
        return {
          name: app.DisplayName,
          path: app.InstallLocation || '',
          bundleId: app.UninstallString || '',
          size,
          version: app.DisplayVersion || '1.0'
        };
      })
      .sort((a, b) => a.name.localeCompare(b.name));
  } catch (e) {
    return [];
  }
});

// 8. Scan App leftovers
ipcMain.handle('scan-app-leftovers', async (event, app) => {
  const local = process.env.LOCALAPPDATA;
  const roaming = process.env.APPDATA;
  const leftovers = [];
  
  const targets = [
    { path: path.join(local, app.name), type: 'Önbellek/Yerel Veri' },
    { path: path.join(roaming, app.name), type: 'Uygulama Ayarları' }
  ];
  
  for (const t of targets) {
    if (fs.existsSync(t.path)) {
      const size = getDirectorySizeRecursive(t.path);
      if (size > 0) {
        leftovers.push({
          path: t.path,
          size,
          type: t.type,
          isSelected: true
        });
      }
    }
  }
  return leftovers;
});
