const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('electronAPI', {
  // Window actions
  minimize: () => ipcRenderer.send('window-minimize'),
  maximize: () => ipcRenderer.send('window-maximize'),
  close: () => ipcRenderer.send('window-close'),

  // Disk operations
  getDiskSpace: () => ipcRenderer.invoke('get-disk-space'),
  scanPath: (category, basePath) => ipcRenderer.invoke('scan-path', { category, basePath }),
  deletePath: (targetPath) => ipcRenderer.invoke('delete-path', targetPath),
  scanLargeFiles: () => ipcRenderer.invoke('scan-large-files'),

  // Startup items optimizer
  scanStartups: () => ipcRenderer.invoke('scan-startups'),
  toggleStartup: (item) => ipcRenderer.invoke('toggle-startup', item),

  // Application Uninstaller
  scanApps: () => ipcRenderer.invoke('scan-apps'),
  scanAppLeftovers: (app) => ipcRenderer.invoke('scan-app-leftovers', app),
  
  // Open external links
  openExternalUrl: (url) => ipcRenderer.send('open-external-url', url)
});
