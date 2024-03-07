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

class ACPAppDelegatePush {

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
  }
}
