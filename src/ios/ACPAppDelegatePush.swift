//#import "AppDelegate+Push.h"
//#import <ACPCore/ACPCore.h>
//#import <ACPCampaign/ACPCampaign.h>
//#import <objc/runtime.h>

extension ACPAppDelegatePush {

    class func load() {
        let original:Method = class_getInstanceMethod(self, Selector("application:didRegisterForRemoteNotificationsWithDeviceToken:"))
        let swizzled:Method = class_getInstanceMethod(self, Selector("application:swizzleddidRegisterForRemoteNotificationsWithDeviceToken:"))
        method_exchangeImplementations(original, swizzled)
    }

    func application(application:UIApplication!, swizzleddidRegisterForRemoteNotificationsWithDeviceToken deviceToken:NSData!) {
      ACPCore.pushIdentifier = deviceToken
      NSLog("ACPCampaign_didRegisterForRemoteNotificationsWithDeviceToken")
    }

    /*- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
        //[ACPCore setPushIdentifier:deviceToken];
        NSLog(@"ACPCampaign_didRegisterForRemoteNotificationsWithDeviceToken");
    }*/

    func application(application:UIApplication!, didFailToRegisterForRemoteNotificationsWithError error:NSError!) {
        NSLog("ACPCampaign_didFailToRegisterForRemoteNotificationsWithError")
    }

    func application(application:UIApplication!, didReceiveRemoteNotification userInfo:NSDictionary!, fetchCompletionHandler handler:(UIBackgroundFetchResult)->Void) {
        NSLog("ACPCampaign_didReceiveNotification")
    }

    func applicationDidBecomeActive(application:UIApplication!) {
        application.applicationIconBadgeNumber = 0
    }
}
