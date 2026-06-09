# AeroClean - macOS Storage Optimizer & Cleaner

AeroClean is a premium, fully native macOS application built with **SwiftUI** designed to scan, analyze, and safely clean unnecessary storage hogs on MacBook systems. It provides deep visibility into the macOS "System Data" (Sistem Verileri), handles developer caches, optimizes startup items, and completely removes applications along with their hidden library leftovers.

Designed and developed by **Uğur Yaşayan**.

---

## 🚀 Key Features

* **🟢 Smart Safety Advice System**: Evaluates each scanned folder and file, providing clear warnings and safety recommendations (Recommended to delete, Proceed with Caution, Danger/Do Not Delete) in Turkish.
* **🧹 System Data Cleaner**: Scans standard macOS Caches, Application Caches, User/System Logs, and the Trash bin.
* **⏰ Time Machine Snapshots Purge**: Executes native `tmutil` processes to locate and delete local Time Machine backups that silently consume gigabytes of storage.
* **⚡ Startup Applications Optimizer**: Lists and lets you toggle startup launch agents (`~/Library/LaunchAgents`, `/Library/LaunchAgents`, `/Library/LaunchDaemons`) to accelerate macOS boot times.
* **📦 Application Uninstaller**: Performs deep matching directory scans for application bundle names and identifiers in `Application Support`, `Caches`, and `Preferences` to cleanly uninstall third-party apps without leaving leftovers.
* **💻 Developer Caches Tool**: A specialized utility for software engineers to clear Xcode Derived Data, CoreSimulator device logs, and Package Manager caches (Homebrew, npm, Cargo, CocoaPods).
* **🔍 Large Files Visualizer**: Finds files larger than 100MB in user folders (Downloads, Documents, Desktop, Movies) with extension-based categories.
* **✨ Glassmorphic UI**: High-fidelity translucent sidebars, custom-drawn nested circular disk usage rings, and smooth micro-animations.

---

## 📥 Installation

1. Go to the [Releases](https://github.com/kuarezma/AeroClean/releases) tab.
2. Download the latest **`AeroClean.dmg`** installer.
3. Double-click the DMG and drag **AeroClean** to your **Applications** folder.

### 🛡️ Gatekeeper Warning (Ad-hoc Signature)
Since the app is codesigned locally using an ad-hoc signature, macOS Gatekeeper may show a warning on first launch ("AeroClean is damaged and cannot be opened" or "Unidentified Developer"). 
To launch the app:
1. Right-click (or Control-click) **AeroClean.app** in your `/Applications` folder and select **Open**.
2. Click **Open** in the confirmation dialog.
*(Alternatively, you can run `xattr -cr /Applications/AeroClean.app` in Terminal to clear the quarantine flag).*

### 🔒 Granting Full Disk Access
To scan files like Mail attachments, browser caches, and system logs, AeroClean requires permission:
1. Open **System Settings** .
2. Go to **Privacy & Security** > **Full Disk Access**.
3. Toggle the switch next to **AeroClean** to **On** (or click the "+" button and select it from your `/Applications` folder).

---

## 🛠️ Build from Source

AeroClean has zero external dependencies and compiles directly using standard command line tools.

### Prerequisites
- macOS 14.0+
- Apple Command Line Tools / Xcode (check using `swiftc --version`)

### Compilation Steps
Clone the repository and run the build script:
```bash
git clone https://github.com/kuarezma/AeroClean.git
cd AeroClean
chmod +x build.sh
./build.sh
```

The script will:
1. Assemble the `.app` bundle directory structure.
2. Package the custom high-resolution iconset into `AppIcon.icns`.
3. Compile all Swift/SwiftUI components.
4. Perform local ad-hoc codesigning.
5. Create a double-clickable installer disk image **`AeroClean.dmg`**.

---

## 📝 License & Credits
Developed by **Uğur Yaşayan**. All rights reserved. Built as a native SwiftUI utility for macOS.
