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

@objc class AppACPDelegate: CDVAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let appState = application.applicationState
    let appId = Bundle.main.object(forInfoDictionaryKey: "AppId") as! String

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
        MobileCore.configureWith(appId: appId)
        if appState != .background {
          // only start lifecycle if the application is not in the background
          MobileCore.lifecycleStart(additionalContextData: nil)
        }
      })
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    MobileCore.setPushIdentifier(deviceToken)
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

}
