# Deep Linking & Sharing Setup Guide

This guide explains how to configure deep linking and sharing functionality for your Tanzania BnB Flutter app.

## What Has Been Implemented

✅ **Share Service** - Share properties and rooms with deep links  
✅ **Deep Link Handler** - Navigate directly to properties/rooms from links  
✅ **UI Integration** - Share buttons in property and room detail pages  

## How It Works

### 1. Sharing
- Users can share properties and rooms via WhatsApp, SMS, Email, etc.
- Shared links follow the format:
  - Property: `https://bnb.co.tz/property/{propertyId}`
  - Room: `https://bnb.co.tz/property/{propertyId}/room/{roomId}`

### 2. Deep Linking
- When a user clicks a shared link, the app opens directly to that property or room
- Works from WhatsApp, SMS, browsers, and other apps

---

## Android Configuration

### Step 1: Update `android/app/src/main/AndroidManifest.xml`

Add intent filters inside your `<activity>` tag:

```xml
<activity
    android:name=".MainActivity"
    android:exported="true"
    android:launchMode="singleTop"
    android:theme="@style/LaunchTheme">
    
    <!-- Existing intent filter for app launch -->
    <intent-filter>
        <action android:name="android.intent.action.MAIN"/>
        <category android:name="android.intent.category.LAUNCHER"/>
    </intent-filter>
    
    <!-- Deep Link Intent Filter -->
    <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        
        <!-- Handle https://bnb.co.tz URLs -->
        <data
            android:scheme="https"
            android:host="bnb.co.tz" />
            
        <!-- Also handle app:// URLs (optional, for custom scheme) -->
        <data
            android:scheme="bnb"
            android:host="app" />
    </intent-filter>
</activity>
```

### Step 2: Create Digital Asset Links File (for App Links)

Create a file at: `https://bnb.co.tz/.well-known/assetlinks.json`

The file should contain:

```json
[{
  "relation": ["delegate_permission/common.handle_all_urls"],
  "target": {
    "namespace": "android_app",
    "package_name": "com.yourcompany.bnbfrontendflutter",
    "sha256_cert_fingerprints": [
      "YOUR_APP_SHA256_FINGERPRINT"
    ]
  }
}]
```

**To get your SHA256 fingerprint:**
```bash
# For debug keystore
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# For release keystore (when you have one)
keytool -list -v -keystore path/to/your/keystore.jks -alias your-key-alias
```

### Step 3: Verify App Links (Testing)

After deploying `assetlinks.json`, verify it:
```
https://digitalassetlinks.googleapis.com/v1/statements:list?source.web.site=https://bnb.co.tz&relation=delegate_permission/common.handle_all_urls
```

---

## iOS Configuration

### Step 1: Update `ios/Runner/Info.plist`

Add URL scheme and Universal Links support:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>com.yourcompany.bnbfrontendflutter</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>bnb</string>
            <string>https</string>
        </array>
    </dict>
</array>

<key>FlutterDeepLinkingEnabled</key>
<true/>
```

### Step 2: Enable Associated Domains

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select the **Runner** target
3. Go to **Signing & Capabilities** tab
4. Click **+ Capability**
5. Add **Associated Domains**
6. Add domain: `applinks:bnb.co.tz`

### Step 3: Create Apple App Site Association File

Create a file at: `https://bnb.co.tz/.well-known/apple-app-site-association`

The file should contain:

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAM_ID.com.yourcompany.bnbfrontendflutter",
        "paths": [
          "/property/*",
          "/property/*/room/*"
        ]
      }
    ]
  }
}
```

**Important Notes:**
- Replace `TEAM_ID` with your Apple Developer Team ID
- File must be served with `Content-Type: application/json` header
- File must be accessible via HTTPS
- No file extension (`.json`)

### Step 4: Verify Universal Links

Test your Universal Links:
```bash
# Using Apple's tool
curl -I https://bnb.co.tz/.well-known/apple-app-site-association
```

---

## Testing Deep Links

### Android Testing

**Test from ADB:**
```bash
# Test property link
adb shell am start -W -a android.intent.action.VIEW -d "https://bnb.co.tz/property/123" com.yourcompany.bnbfrontendflutter

# Test room link
adb shell am start -W -a android.intent.action.VIEW -d "https://bnb.co.tz/property/123/room/456" com.yourcompany.bnbfrontendflutter
```

**Test from WhatsApp:**
1. Share a link via WhatsApp
2. Click the link
3. App should open directly to the property/room

### iOS Testing

**Test from Terminal:**
```bash
xcrun simctl openurl booted "https://bnb.co.tz/property/123"
```

**Test from Safari:**
1. Open Safari on device
2. Type: `https://bnb.co.tz/property/123`
3. Long press and select "Open in Tanzania BnB"

---

## Troubleshooting

### Android Issues

**Links not opening app:**
- Verify `assetlinks.json` is accessible
- Check SHA256 fingerprint matches
- Ensure `android:autoVerify="true"` is set
- Clear app data and reinstall

**App opens but wrong screen:**
- Check deep link handler logs
- Verify URL format matches expected pattern

### iOS Issues

**Links opening in Safari instead of app:**
- Verify `apple-app-site-association` file is accessible
- Check Associated Domains is enabled
- Ensure file has correct Content-Type header
- Try reinstalling the app

**Universal Links not working:**
- Check Team ID in AASA file
- Verify paths match URL patterns
- Test file accessibility: `curl -I https://bnb.co.tz/.well-known/apple-app-site-association`

---

## Current Implementation

### Files Created/Modified:

1. **`lib/services/share_service.dart`**
   - `shareProperty()` - Share property with deep link
   - `shareRoom()` - Share room with deep link
   - `generatePropertyUrl()` - Generate property share URL
   - `generateRoomUrl()` - Generate room share URL

2. **`lib/services/deep_link_service.dart`**
   - `init()` - Initialize deep link handling
   - `_handleDeepLink()` - Process incoming deep links
   - `_navigateToProperty()` - Navigate to property page
   - `_navigateToRoom()` - Navigate to room page

3. **`lib/main.dart`**
   - Integrated deep link initialization
   - Added deep link service cleanup

4. **`lib/bnb/bnbhome/bnbdetails.dart`**
   - Added share button functionality

5. **`lib/bnb/bnbhome/bnbroomdetails.dart`**
   - Added share button functionality

6. **`pubspec.yaml`**
   - Added `share_plus: ^7.2.1`
   - Added `app_links: ^6.3.3` (modern alternative to uni_links)

---

## Next Steps

1. ✅ Install dependencies: `flutter pub get`
2. ⚠️ Configure Android manifest (see above)
3. ⚠️ Configure iOS Info.plist (see above)
4. ⚠️ Deploy `assetlinks.json` to your website
5. ⚠️ Deploy `apple-app-site-association` to your website
6. ✅ Test deep links on both platforms

---

## Notes

- Deep links use `https://bnb.co.tz` domain (from `lib/services/bnbconnection.dart`)
- Ensure your backend/website serves the asset links files correctly
- Test thoroughly on both platforms before production release
- For production, use release keystore fingerprints in `assetlinks.json`


