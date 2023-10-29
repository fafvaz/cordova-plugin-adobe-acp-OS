import ACPCore


func application(application:UIApplication!, swizzleddidRegisterForRemoteNotificationsWithDeviceToken deviceToken:Data!) {
  ACPCore.setPushIdentifier(deviceToken)
  NSLog("ACPCampaign_didRegisterForRemoteNotificationsWithDeviceToken")
}

func application(application:UIApplication!, didFailToRegisterForRemoteNotificationsWithError error:NSError!) {
    NSLog("ACPCampaign_didFailToRegisterForRemoteNotificationsWithError")
}

func application(application:UIApplication!, didReceiveRemoteNotification userInfo:NSDictionary!, fetchCompletionHandler handler:(UIBackgroundFetchResult)->Void) {
    NSLog("ACPCampaign_didReceiveNotification")
}

func applicationDidBecomeActive(application:UIApplication!) {
    application.applicationIconBadgeNumber = 0
}
