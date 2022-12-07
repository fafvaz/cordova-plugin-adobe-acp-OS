
#import "AppDelegate+Push.h"
#import <ACPCore/ACPCore.h>
#import <ACPCampaign/ACPCampaign.h>
#import <objc/runtime.h>

@implementation AppDelegate (Push)

+ (void)load {
    Method original = class_getInstanceMethod(self, @selector(application:didRegisterForRemoteNotificationsWithDeviceToken:));
    Method swizzled = class_getInstanceMethod(self, @selector(application:swizzleddidRegisterForRemoteNotificationsWithDeviceToken:));
    method_exchangeImplementations(original, swizzled);
}

- (void)application:(UIApplication *)application swizzleddidRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
  [ACPCore setPushIdentifier:deviceToken];
  NSLog(@"ACPCampaign_didRegisterForRemoteNotificationsWithDeviceToken");
}

/*- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    //[ACPCore setPushIdentifier:deviceToken];
    NSLog(@"ACPCampaign_didRegisterForRemoteNotificationsWithDeviceToken");
}*/

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"ACPCampaign_didFailToRegisterForRemoteNotificationsWithError");
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler
{
    NSLog(@"ACPCampaign_didReceiveNotification");
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    application.applicationIconBadgeNumber = 0;
}

@end
