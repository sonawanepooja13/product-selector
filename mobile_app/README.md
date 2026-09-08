# Mobile Biometric Attendance App (Flutter)

A native, responsive mobile conversion of the desktop **`attendance_window.py`** application built with Flutter and Material 3.

---

## 📁 Project Structure

```
mobile_app/
├── analysis_options.yaml           # Lint and static analysis configuration
├── pubspec.yaml                    # Flutter project configuration & dependencies
├── README.md                       # Documentation and usage instructions
└── lib/
    ├── main.dart                   # Application entry point with Material 3 theming
    ├── models/
    │   └── attendance_record.dart  # Data model with status formatting and helpers
    ├── services/
    │   └── biometric_sync_service.dart # Simulated TCP/IP socket connection & sync
    └── views/
        ├── attendance_screen.dart  # Responsive primary screen (Search, Filter, List)
        └── widgets/
            ├── attendance_card.dart              # Material 3 attendance item card
            ├── device_config_bottom_sheet.dart  # Device IP/Port/Password config sheet
            ├── metrics_overview.dart             # Responsive present/late/absent badges
            └── record_detail_bottom_sheet.dart  # Tap-to-view record details
```

---

## 📱 Desktop to Mobile Conversions

| Desktop Tkinter Element (`attendance_window.py`) | Mobile Flutter Equivalent |
| :--- | :--- |
| **7-column `ttk.Treeview` spreadsheet** | **`ListView.separated` of `AttendanceCard`s** with avatar, time chips, status tags, and detail modal |
| **Horizontal IP/Port/Password entry bar** | **Modal `DeviceConfigBottomSheet`** with 48dp touch targets and mobile numeric keyboards |
| **"Sync Biometric Device" header button** | **FloatingActionButton.extended** positioned for one-handed thumb interaction |
| **Desktop Window Header & Menu** | **Material 3 `NavigationBar`** (bottom) and **`NavigationDrawer`** (hamburger menu) |
| **Desktop "Refresh" button** | **`RefreshIndicator` (Pull-to-refresh)** and Top AppBar action |
| **Fixed desktop pixels (`width=20`)** | **`LayoutBuilder`, `Wrap`, `Expanded`, and `TextOverflow.ellipsis`** |

---

## 🚀 How to Run

### 1. Prerequisites
Ensure you have the Flutter SDK installed on your system. If not already installed:
- Download Flutter from [flutter.dev](https://flutter.dev/docs/get-started/install).
- Add Flutter to your system `PATH`.

### 2. Run the App
Navigate into the `mobile_app` folder:
```bash
cd mobile_app
flutter pub get
flutter run
```
You can run it on:
* An Android device / emulator
* An iOS simulator / iPhone
* Chrome (Flutter Web)
