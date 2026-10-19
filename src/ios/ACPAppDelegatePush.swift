import AEPAnalytics
import AEPAssurance
import AEPCampaign
import AEPCore
import AEPIdentity
import AEPLifecycle
import AEPMobileServices
import AEPPlaces
import AEPSignal
import AEPTarget
import AEPUserProfile
import FirebaseMessaging
import UserNotifications

@objc(ACPAppDelegatePush) class ACPAppDelegatePush: NSObject {

  static func registerExtensions() {

    let appId = Bundle.main.object(forInfoDictionaryKey: "AppId") as! String
    let appState = UIApplication.shared.applicationState

    MobileCore.setLogLevel(.trace)
    MobileCore.registerExtensions(
      [
        Signal.self,
        Lifecycle.self,
        UserProfile.self,
        Identity.self,
        Assurance.self,
        Campaign.self,
        Places.self,
        Analytics.self,
        AEPMobileServices.self,
        Target.self,
        Assurance.self,
      ],
      {
        MobileCore.setPrivacyStatus(.optedIn)
        MobileCore.configureWith(appId: appId)
        if appState != .background {
          MobileCore.lifecycleStart(additionalContextData: nil)
        }
      })

    // Register the notification category used for Adobe Campaign Standard dismiss
    // tracking: .customDismissAction makes iOS deliver the dismiss response to
    // UNUserNotificationCenterDelegate when the user clears the notification.
    // The push payload must reference the same category (aps.category = "DEFAULT").
    let pushTrackingCategory = UNNotificationCategory(
      identifier: "DEFAULT",
      actions: [],
      intentIdentifiers: [],
      options: .customDismissAction)
    UNUserNotificationCenter.current().setNotificationCategories([pushTrackingCategory])

    NotificationCenter.default.addObserver(
      self, selector: #selector(handleNotificationDispatched(notification:)),
      name: NSNotification.Name("FirebaseRemoteNotificationReceivedDispatch"), object: nil)
    NotificationCenter.default.addObserver(
      self, selector: #selector(handleClickNotificationDispatched(notification:)),
      name: NSNotification.Name("FirebaseRemoteNotificationClickedDispatch"), object: nil)
    // Dismiss (swipe-away): Push Click only (action "2") - never Push Open ("1")
    NotificationCenter.default.addObserver(
      self, selector: #selector(handleDismissDispatched(notification:)),
      name: NSNotification.Name("FirebaseRemoteNotificationDismissedDispatch"), object: nil)
  }

  @objc static func handleDismissDispatched(notification: NSNotification) {
    // User cleared the notification: Push Click tracking (action "2") only.
    // skipDeepLink = "true": the app was not opened, so no payload forwarding here.
    sendTracking(notification: notification, action: "2", skipDeepLink: "true")
  }

  @objc static func handleNotificationDispatched(notification: NSNotification) {
    sendTracking(notification: notification, action: "7", skipDeepLink: "false")
  }

  @objc static func handleClickNotificationDispatched(notification: NSNotification) {
    sendTracking(notification: notification, action: "2", skipDeepLink: "true")
    sendTracking(notification: notification, action: "1", skipDeepLink: "false")
  }

    static func sendTracking(notification: NSNotification, action: String, skipDeepLink: String) {

    print("sendTracking", notification.object as Any)

    guard let userInfo = notification.object as? [String: Any] else {
        print("sendTracking: no userInfo")
        return
    }

    let deliveryId = userInfo["_dId"] as? String
    let broadlogId = userInfo["_mId"] as? String
    var acsDeliveryTracking = userInfo["_acsDeliveryTracking"] as? String

    if acsDeliveryTracking == nil {
        acsDeliveryTracking = "on"
    }

    if deliveryId != nil && broadlogId != nil
        && acsDeliveryTracking?.caseInsensitiveCompare("on") == ComparisonResult.orderedSame
    {
        MobileCore.collectMessageInfo([
            "deliveryId": deliveryId!,
            "broadlogId": broadlogId!,
            "action": action,
        ])

        // Build contextData from custom keys in the push payload (excluding Adobe system keys)
        var contextData: [String: Any] = [:]
        let excludedKeys: Set<String> = ["_dId", "_mId", "_acsDeliveryTracking", "aps",
                                         "google.message_id", "from", "collapse_key"]
        for (key, value) in userInfo {
            if !excludedKeys.contains(key) {
                contextData[key] = value
            }
        }
        if !contextData.isEmpty {
            MobileCore.collectPii(contextData)
        }
    } else {
        print("Tracking not delivered")
    }

    if skipDeepLink == "false" {
        handleCallback(userInfo)
    }
  }
    
    
    static func handleCallback(_ payload: [String: Any] ) {
        DispatchQueue.main.async{
            ACPCore_Cordova.instance.subscribe(payload)
        }
    }
    
    static func openScreenByDeepLink(_ deepLink: String) {
        print("Abrindo o deeplink " + deepLink)

        guard let url = URL(string: deepLink) else {
          return //be safe
        }

        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    

}




