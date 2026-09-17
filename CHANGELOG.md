### 0.0.1 (21 Apr, 2020)
- Initial release of Adobe Experience Platform - Core plugin for Cordova apps

### 0.0.3 (2026)
- Fixed `NotificationDismissedReceiver` package mismatch (was hardcoded to `com.galp.bluetooh`, breaking the build for any other app id); it is now registered in the manifest by its fully qualified name
- Removed `jcenter()` from the Gradle file (Bintray/JCenter is shut down and randomly fails MABS builds); now uses `mavenCentral()` + `google()`
- Pinned Adobe AEP Android extensions to the latest 2.x releases (core 2.6.4, analytics 2.0.3, target 2.0.3, identity 2.0.3, lifecycle 2.0.4, signal 2.0.1, places 2.1.0, campaign 2.0.6, userprofile 2.0.1, assurance 2.2.2, mobileservices 1.1.5) for deterministic MABS builds. Note: Android 3.x / iOS 5.x exist but are not adopted yet because MobileServices was never released past 1.x/3.0.3
- Removed deprecated `com.google.firebase:firebase-core` and upgraded `firebase-messaging` from 19.0.1 to 23.4.1 (matches the version pinned by the cordova-plugin-firebase bundle, avoiding duplicate-class conflicts)
- Upgraded `play-services-location` from 21.0.1 to 21.3.0 and migrated to the new `LocationRequest.Builder` API
- Registered `ACPFirebaseMessagingService` with the Firebase plugin's receiver manager. It relies on the self-registering `FirebasePluginMessageReceiver` constructor of `cordova-plugin-firebase` (not the `addReceiver()` API of cordova-plugin-firebasex, which is NOT used)
- `ACPFirebaseMessagingService.onMessageReceived` now returns `false` after tracking so the Firebase plugin still displays the notification (returning `true` suppressed foreground notifications)
- Removed `center.delegate = self` from `ACPCampaign_Cordova.swift` (iOS): it overwrote the Firebase plugin's `UNUserNotificationCenter` delegate, silently breaking foreground notification presentation and tap callbacks
- Removed invalid `import static android.content.Intent.getIntent;` and unused imports from `ACPCore_Cordova.java`
- Removed dead, app-specific `<activity>` deep-link config from `plugin.xml` (it sat outside `<config-file>` so Cordova always ignored it)
