/*
 Copyright 2020 Adobe. All rights reserved.
 This file is licensed to you under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License. You may obtain a copy
 of the License at http://www.apache.org/licenses/LICENSE-2.0
 Unless required by applicable law or agreed to in writing, software distributed under
 the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
 OF ANY KIND, either express or implied. See the License for the specific language
 governing permissions and limitations under the License.
 */

/********* cordova-acpcampaign.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>

#import <ACPCampaign/ACPCampaign.h>
#import <Cordova/CDVPluginResult.h>
#import "ACPCore.h"
#import "ACPIdentity.h"
#import "ACPLifecycle.h"
#import "ACPSignal.h"
#import "ACPUserProfile.h"

@import UserNotifications;

@interface ACPCampaign_Cordova : CDVPlugin

- (void)extensionVersion:(CDVInvokedUrlCommand*)command;
- (void)setPushIdentifier:(CDVInvokedUrlCommand*)command;


@end

@implementation ACPCampaign_Cordova

- (void)extensionVersion:(CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        CDVPluginResult* pluginResult = nil;
        NSString* extensionVersion = [ACPCampaign extensionVersion];

        if (extensionVersion != nil && [extensionVersion length] > 0) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:extensionVersion];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        }

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)setPushIdentifier:(CDVInvokedUrlCommand*)command
{

    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];  
      center.delegate = self;  
      [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            
        if( !error ) {
            // required to get the app to do anything at all about push notifications  
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *deviceToken = command.arguments[0];
                NSString *fiscalNumber = command.arguments[1];

                NSData* data = [deviceToken dataUsingEncoding:NSUTF8StringEncoding];

                [ACPCore collectPii:@{@"fiscalnumber": fiscalNumber}]; 
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            });
             
            NSLog( @"Push registration success." );  

        } else {
            NSLog( @"Push registration FAILED" );  
            NSLog( @"ERROR: %@ - %@", error.localizedFailureReason, error.localizedDescription );  
            NSLog( @"SUGGESTIONS: %@ - %@", error.localizedRecoveryOptions, error.localizedRecoverySuggestion );  
        }
        }];
      
    [ACPCore setLogLevel:ACPMobileLogLevelDebug];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
