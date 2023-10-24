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

//#import <ACPCore/ACPCore.h>
//#import <ACPCore/ACPExtensionEvent.h>
//#import <ACPCore/ACPIdentity.h>
//#import <ACPCore/ACPLifecycle.h>
//#import <ACPCore/ACPSignal.h>
//#import <ACPMobileServices/ACPMobileServices.h>
//#import <ACPTarget/ACPTarget.h>
//#import <ACPAnalytics/ACPAnalytics.h>
//#import <ACPUserProfile/ACPUserProfile.h>
//#import <ACPPlaces/ACPPlaces.h>
//#import <ACPPlacesMonitor/ACPPlacesMonitor.h>
//#import <ACPCampaign/ACPCampaign.h>
//#import <AEPAssurance/AEPAssurance.h>
//#import <Cordova/CDV.h>
//#import <Foundation/Foundation.h>


class ACPCore_Cordova : CDVPlugin {

     var appId:String!
     var initTime:String!

    func dispatchEvent(command:CDVInvokedUrlCommand!) {
        self.commandDelegate.runInBackground({
            let eventInput:NSDictionary! = self.getCommandArg(command.arguments[0])
            if !(eventInput is NSDictionary) {
                self.commandDelegate.sendPluginResult(CDVPluginResult.resultWithStatus(CDVCommandStatus_ERROR, messageAsString:"Unable to dispatch event. Input was malformed"), callbackId:command.callbackId)
            }

            let event:ACPExtensionEvent! = self.getExtensionEventFromJavascriptObject(eventInput)
            let error:NSError! = nil
            ACPCore.dispatchEvent(event, error:&error)

            if (error != nil) {
                self.commandDelegate.sendPluginResult(CDVPluginResult.resultWithStatus(CDVCommandStatus_ERROR, messageAsString:String(format:"Error dispatching event: %@", error.localizedDescription ?error.localizedDescription: "unknown error")), callbackId:command.callbackId)
            }

            let pluginResult:CDVPluginResult! = CDVPluginResult.resultWithStatus(CDVCommandStatus_OK)
            self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
        })
    }

    func dispatchEventWithResponseCallback(command:CDVInvokedUrlCommand!) {
        self.commandDelegate.runInBackground({
            let eventInput:NSDictionary! = self.getCommandArg(command.arguments[0])
            if !(eventInput is NSDictionary) {
                self.commandDelegate.sendPluginResult(CDVPluginResult.resultWithStatus(CDVCommandStatus_ERROR, messageAsString:"Unable to dispatch event. Input was malformed"), callbackId:command.callbackId)
            }

            let event:ACPExtensionEvent! = self.getExtensionEventFromJavascriptObject(eventInput)
            let error:NSError! = nil
            ACPCore.dispatchEventWithResponseCallback(event,
                                      responseCallback:{ (responseEvent:ACPExtensionEvent) in
                if (error != nil) {
                    self.commandDelegate.sendPluginResult(CDVPluginResult.resultWithStatus(CDVCommandStatus_ERROR, messageAsString:String(format:"Error dispatching event: %@", error.localizedDescription ?error.localizedDescription: "unknown error")), callbackId:command.callbackId)
                }

                let response:NSDictionary! = self.getJavascriptDictionaryFromEvent(responseEvent)
                let pluginResult:CDVPluginResult! = CDVPluginResult.resultWithStatus(CDVCommandStatus_OK, messageAsDictionary:response)
                self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
            },
                                                 error:&error)
        })
    }

    func dispatchResponseEvent(command:CDVInvokedUrlCommand!) {
        self.commandDelegate.runInBackground({
            let inputResponseEvent:NSDictionary! = self.getCommandArg(command.arguments[0])
            let inputRequestEvent:NSDictionary! = self.getCommandArg(command.arguments[1])

            if !(inputRequestEvent is NSDictionary) || !(inputResponseEvent is NSDictionary) {
                self.commandDelegate.sendPluginResult(CDVPluginResult.resultWithStatus(CDVCommandStatus_ERROR, messageAsString:"Unable to dispatch event. Input was malformed"), callbackId:command.callbackId)
            }

            let responseEvent:ACPExtensionEvent! = self.getExtensionEventFromJavascriptObject(inputResponseEvent)
            let requestEvent:ACPExtensionEvent! = self.getExtensionEventFromJavascriptObject(inputRequestEvent)
            let error:NSError! = nil
            ACPCore.dispatchResponseEvent(responseEvent,
                              requestEvent:requestEvent,
                                     error:&error)

            if (error != nil) {
                self.commandDelegate.sendPluginResult(CDVPluginResult.resultWithStatus(CDVCommandStatus_ERROR, messageAsString:String(format:"Error dispatching response event: %@", error.localizedDescription ?error.localizedDescription: "unknown error")), callbackId:command.callbackId)
            }

            let pluginResult:CDVPluginResult! = CDVPluginResult.resultWithStatus(CDVCommandStatus_OK)
            self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
        })
    }

    func downloadRules(command:CDVInvokedUrlCommand!) {
        self.commandDelegate.runInBackground({
            ACPCore.downloadRules()

            let pluginResult:CDVPluginResult! = CDVPluginResult.resultWithStatus(CDVCommandStatus_OK)
            self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
        })
    }

    func extensionVersion(command:CDVInvokedUrlCommand!) {
        self.commandDelegate.runInBackground({
            let version:String! = initTime.stringByAppendingString(": ").stringByAppendingString(ACPCore.extensionVersion())

            let pluginResult:CDVPluginResult! = CDVPluginResult.resultWithStatus(CDVCommandStatus_OK, messageAsString:version)
            self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
        })
    }

    func getPrivacyStatus(command:CDVInvokedUrlCommand!) {
        self.commandDelegate.runInBackground({
            ACPCore.getPrivacyStatus({ (status:ACPMobilePrivacyStatus) in
                let pluginResult:CDVPluginResult! = CDVPluginResult.resultWithStatus(CDVCommandStatus_OK, messageAsNSInteger:status)
                self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
            })
        })
    }

    func getSdkIdentities(command:CDVInvokedUrlCommand!) {
        self.commandDelegate.runInBackground({
            ACPCore.getSdkIdentities({ (content:String?) in
                let pluginResult:CDVPluginResult! = CDVPluginResult.resultWithStatus(CDVCommandStatus_OK, messageAsString:content)
                self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
            })
        })
    }

    func setAdvertisingIdentifier(command:CDVInvokedUrlCommand!) {
        self.commandDelegate.runInBackground({
            let newIdentifier:String! = self.getCommandArg(command.arguments[0])

            ACPCore.advertisingIdentifier = newIdentifier

            let pluginResult:CDVPluginResult! = CDVPluginResult.resultWithStatus(CDVCommandStatus_OK)
            self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
        })
    }

    func setLogLevel(command:CDVInvokedUrlCommand!) {
        self.commandDelegate.runInBackground({
            let logLevel:ACPMobileLogLevel = self.getCommandArg(command.arguments[0])

            ACPCore.logLevel = logLevel

            let pluginResult:CDVPluginResult! = CDVPluginResult.resultWithStatus(CDVCommandStatus_OK)
            self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
        })
    }

    func setPrivacyStatus(command:CDVInvokedUrlCommand!) {
        self.commandDelegate.runInBackground({
            let privacyStatus:ACPMobilePrivacyStatus = self.getCommandArg(command.arguments[0]).intValue()

            ACPCore.privacyStatus = privacyStatus

            let pluginResult:CDVPluginResult! = CDVPluginResult.resultWithStatus(CDVCommandStatus_OK)
            self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
        })
    }

    func trackAction(command:CDVInvokedUrlCommand!) {
        self.commandDelegate.runInBackground({
            let firstArg:AnyObject! = self.getCommandArg(command.arguments[0])
            let secondArg:AnyObject! = self.getCommandArg(command.arguments[1])

            // allows the ACPCore.trackAction(cData) call
            if (firstArg is NSDictionary) {
                ACPCore.trackAction(nil, data:firstArg)
            }
            else {
                ACPCore.trackAction(firstArg, data:secondArg)
            }

            let pluginResult:CDVPluginResult! = CDVPluginResult.resultWithStatus(CDVCommandStatus_OK)
            self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
        })
    }

    func trackState(command:CDVInvokedUrlCommand!) {
        self.commandDelegate.runInBackground({
            let firstArg:AnyObject! = self.getCommandArg(command.arguments[0])
            let secondArg:AnyObject! = self.getCommandArg(command.arguments[1])

            // allows the ACPCore.trackState(cData) call
            if (firstArg is NSDictionary) {
                ACPCore.trackState(nil, data:firstArg)
            }
            else {
                ACPCore.trackState(firstArg, data:secondArg)
            }

            let pluginResult:CDVPluginResult! = CDVPluginResult.resultWithStatus(CDVCommandStatus_OK)
            self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
        })
    }

    func updateConfiguration(command:CDVInvokedUrlCommand!) {
        self.commandDelegate.runInBackground({
            let config:NSDictionary! = self.getCommandArg(command.arguments[0])

            ACPCore.updateConfiguration(config)

            let pluginResult:CDVPluginResult! = CDVPluginResult.resultWithStatus(CDVCommandStatus_OK)
            self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
        })
    }

    func getAppId(command:CDVInvokedUrlCommand!) {
        self.commandDelegate.runInBackground({
             let pluginResult:CDVPluginResult! = CDVPluginResult.resultWithStatus(CDVCommandStatus_OK, messageAsString:appId)
            self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
        })
    }

    // ===========================================================================
    // helper functions
    // ===========================================================================
    func getExtensionEventFromJavascriptObject(event:NSDictionary!) -> ACPExtensionEvent! {
        let error:NSError! = nil
        let newEvent:ACPExtensionEvent! = ACPExtensionEvent.extensionEventWithName(event["name"],
                                                                           type:event["type"],
                                                                         source:event["source"],
                                                                           data:event["data"],
                                                                          error:&error)
        if (error != nil) || (newEvent == nil) {
            ACPCore.log(ACPMobileLogLevelWarning, tag:"ACPCore", message:String(format:"Error creating ACPExtensionEvent: %@", error.localizedDescription ?error.localizedDescription: "unknown"))
        }

        return newEvent
    }

    func getJavascriptDictionaryFromEvent(event:ACPExtensionEvent!) -> NSDictionary! {
        return [
            "name" : event.eventName,
            "type" : event.eventType,
            "source" : event.eventSource,
            "data" : event.eventData
        ]
    }

    func getCommandArg(argument:AnyObject!) -> AnyObject! {
        return argument == (NSNull.null() as! id) ? nil : argument
    }

    // ===============================================================
    // Plugin lifecycle events
    // ===============================================================
    func pluginInitialize() {
        appId = NSBundle.mainBundle().infoDictionary().valueForKey("AppId")
        ACPCore.logLevel = ACPMobileLogLevelDebug
        ACPCore.configureWithAppId(appId)

        ACPCampaign.registerExtension()
        ACPPlaces.registerExtension()
        ACPPlacesMonitor.registerExtension()
        ACPAnalytics.registerExtension()
        ACPMobileServices.registerExtension()
        ACPTarget.registerExtension()
        ACPUserProfile.registerExtension()
        ACPIdentity.registerExtension()
        ACPLifecycle.registerExtension()
        ACPSignal.registerExtension()
        AEPAssurance.registerExtension()
        ACPCore.start({
            ACPCore.lifecycleStart(nil)
        })

        let date:NSDate! = NSDate.date()
        let dateFormatter:NSDateFormatter! = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        initTime = dateFormatter.stringFromDate(date)
    }
}
