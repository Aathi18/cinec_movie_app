# Deployment Guide

This guide covers the process of deploying the Cinec Movie App to various platforms.

## Android Deployment

### Prerequisites
- Keystore file for signing the app
- Keystore password and key alias
- Google Play Console account (for Play Store deployment)

### Generate Release Build

1. Create keystore if not exists:
```bash
keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. Configure signing in `android/key.properties`:
```
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=upload-keystore.jks
```

3. Update `android/app/build.gradle`:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile file(keystoreProperties['storeFile'])
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

4. Build release APK:
```bash
flutter build apk --release
```

5. Build App Bundle:
```bash
flutter build appbundle
```

### Play Store Deployment

1. Create app in Google Play Console
2. Upload App Bundle
3. Fill store listing details
4. Set up pricing & distribution
5. Submit for review

## iOS Deployment

### Prerequisites
- Apple Developer Account
- Xcode installed
- iOS Provisioning Profile
- App Store Connect setup

### Steps

1. Update version in `pubspec.yaml`:
```yaml
version: 1.0.0+1
```

2. Set up signing in Xcode:
   - Open `ios/Runner.xcworkspace`
   - Select Runner target
   - Set Bundle Identifier
   - Enable Automatic signing or manual
   - Select provisioning profile

3. Create archive:
   - Set iOS device
   - Product > Archive

4. Upload to App Store:
   - In Xcode Organizer
   - Select archive
   - Click "Distribute App"
   - Follow upload steps

### App Store Deployment

1. Configure App Store Connect:
   - Create new app
   - Add screenshots
   - Fill description
   - Set up pricing
   - Privacy policy URL

2. Submit for review:
   - Ensure compliance
   - Answer review questions
   - Submit build

## Web Deployment

### Build

```bash
flutter build web --release
```

### Firebase Hosting

1. Install Firebase CLI:
```bash
npm install -g firebase-tools
```

2. Initialize Firebase:
```bash
firebase login
firebase init hosting
```

3. Deploy:
```bash
firebase deploy --only hosting
```

### Other Hosting Options

#### Netlify
1. Create `netlify.toml`:
```toml
[build]
  command = "flutter build web --release"
  publish = "build/web"
```

2. Connect repository in Netlify dashboard

#### GitHub Pages
1. Create `.github/workflows/web.yml`:
```yaml
name: Web Deploy

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v1
      - run: flutter pub get
      - run: flutter build web
      - uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./build/web
```

## Environment Variables

### Production
```
FIREBASE_API_KEY=your_api_key
FIREBASE_APP_ID=your_app_id
FIREBASE_PROJECT_ID=your_project_id
```

### Staging
```
FIREBASE_API_KEY=staging_api_key
FIREBASE_APP_ID=staging_app_id
FIREBASE_PROJECT_ID=staging_project_id
```

## Post-Deployment Checklist

- [ ] Test app on actual devices
- [ ] Verify Firebase connectivity
- [ ] Check analytics integration
- [ ] Test crash reporting
- [ ] Monitor performance metrics
- [ ] Update documentation
- [ ] Tag release version
- [ ] Create backup
- [ ] Update changelog