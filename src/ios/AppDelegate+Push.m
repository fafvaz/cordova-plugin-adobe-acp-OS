//
//  AppDelegate+Push.m
//  BluetoohTest
//
//  Created by Ronelio Oliveira on 12/11/23.
//

#import "AppDelegate+Push.h"
#import <objc/runtime.h>
#import <AEPCore/AEPCore-Swift.h>

@implementation AppDelegate (Push)

+ (void)load {
    Method original = class_getInstanceMethod(self, @selector(application:didRegisterForRemoteNotificationsWithDeviceToken:));
    Method swizzled = class_getInstanceMethod(self, @selector(application:swizzledDidRegisterForRemoteNotificationsWithDeviceToken:));
    method_exchangeImplementations(original, swizzled);
}

- (void)application:(UIApplication *)application swizzledDidRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [AEPMobileCore setPushIdentifier:deviceToken];
    // Forward to the original implementation so Firebase Messaging also receives
    // the APNS token ([FIRMessaging messaging].APNSToken = deviceToken). Without
    // this forward, Firebase never gets the token and push delivery breaks.
    [self application:application swizzledDidRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    NSLog(@"ACPCampaign_didRegisterForRemoteNotificationsWithDeviceToken");
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    application.applicationIconBadgeNumber = 0;
}

@end
