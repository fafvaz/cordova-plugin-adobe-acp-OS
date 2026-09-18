### Unreleased
- MABS 12+ compatibility: cordova-android 13 renamed `res/values/strings.xml` to `res/values/cdv_strings.xml` and MABS ignores plugin config-file injections targeting `res/values/*strings*.xml`, so the `AppId`/`TypeId` string resources were never present in the APK (crash: `Resources$NotFoundException: String resource ID #0x0` on startup in `ACPCore_Cordova.initialize`).
- `ACPCore_Cordova` and `ACPCampaign_Cordova` now read `APP_ID` / `TYPE_ID` from the config.xml preferences (plugin variables), keeping the string resources only as a legacy fallback. A missing value no longer crashes the app; it is logged and the Adobe SDK is simply not configured.
- Still compatible with MABS 11 (cordova-android 12), where the string-resource injection continues to work.

### 0.0.1 (21 Apr, 2020)
- Initial release of Adobe Experience Platform - Core plugin for Cordova apps
