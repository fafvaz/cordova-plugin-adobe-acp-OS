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

    NotificationCenter.default.addObserver(
      self, selector: #selector(handleNotificationDispatched(notification:)),
      name: NSNotification.Name("FirebaseRemoteNotificationReceivedDispatch"), object: nil)
    NotificationCenter.default.addObserver(
      self, selector: #selector(handleClickNotificationDispatched(notification:)),
      name: NSNotification.Name("FirebaseRemoteNotificationClickedDispatch"), object: nil)
  }

  @objc static func handleNotificationDispatched(notification: NSNotification) {
    sendTracking(notification: notification, action: "7")
  }

  @objc static func handleClickNotificationDispatched(notification: NSNotification) {
    sendTracking(notification: notification, action: "2")
  }

  static func sendTracking(notification: NSNotification, action: String) {


     print("sendTracking", notification.object)
    
    if let userInfo = notification.object as? [String: Any] {


      let pushPayloadAps = userInfo["aps"] as! [String: Any]
      print("pushPayloadAps", pushPayloadAps)
      
      let pushPayloadAlert = pushPayloadAps["alert"] as! [String: Any]
      print("pushPayloadAlert", pushPayloadAlert)

      let deliveryId = pushPayloadAlert["_dId"] as? String
      let broadlogId = pushPayloadAlert["_mId"] as? String
      var acsDeliveryTracking = pushPayloadAlert["_acsDeliveryTracking"] as? String

      if acsDeliveryTracking == nil {
        acsDeliveryTracking = "on"
      }

      if deliveryId != nil && broadlogId != nil
        && acsDeliveryTracking?.caseInsensitiveCompare("on") == ComparisonResult.orderedSame
      {
        MobileCore.collectMessageInfo([
          "deliveryId": deliveryId!, "broadlogId": broadlogId!, "action": action,
        ])
      } else {
        print("Trackin not delivered")
      }
    }
  }

}
