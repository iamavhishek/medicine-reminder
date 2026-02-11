---
description: How to package the app as MSIX for Windows
---

# Packaging Medicine Reminder as MSIX for Windows

This workflow packages the Flutter app as an MSIX installer for Windows.

## Prerequisites

1. You must be running on a Windows machine
2. Flutter must be installed and configured for Windows development
3. The `msix` dev dependency must be installed (already configured in pubspec.yaml)

## Steps

### 1. Clean Previous Build (Optional)

```bash
flutter clean
flutter pub get
```

### 2. Build the Windows Release

```bash
flutter build windows --release
```

### 3. Create the MSIX Package

```bash
dart run msix:create
```

This will create an MSIX installer in the `build/windows/x64/runner/Release/` directory.

## Configuration Details

The MSIX configuration is in `pubspec.yaml`:

```yaml
msix_config:
  display_name: Medicine Reminder
  publisher_display_name: Medicine Reminder
  identity_name: np.com.abhishekd.medRemind
  msix_version: 1.0.0.0
  logo_path: assets/images/app_icon.png
  capabilities: internetClient, notifications
```

## Important Notes

### Why MSIX Packaging is Important

1. **Notification Cancellation**: Without MSIX, the `cancel()` method does nothing on Windows
2. **Active Notifications**: `getActiveNotifications()` returns an empty list without MSIX
3. **System Tray**: Works better with proper app identity

### For Production Distribution

For production, you'll need to:

1. Add a proper publisher certificate:

   ```yaml
   msix_config:
     certificate_path: <path-to-your-certificate.pfx>
     certificate_password: <your-password>
   ```

2. Or sign with a Microsoft Store certificate if distributing through the Store

### Installing the MSIX

1. Double-click the generated `.msix` file
2. Windows will prompt to install
3. For unsigned packages, you may need to enable "Sideload apps" in Windows Settings → Apps → Advanced features

## Troubleshooting

- If notifications don't work after packaging, ensure the `appUserModelId` in `notification_service.dart` matches the `identity_name` in `pubspec.yaml`
- If the tray icon doesn't appear, check that `assets/images/app_icon.png` exists
