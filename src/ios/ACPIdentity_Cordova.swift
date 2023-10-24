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
//#import <ACPCore/ACPIdentity.h>
//#import <Cordova/CDV.h>


let stateStrings:[String!]! = {"UNKNOWN", "AUTHENTICATED", "LOGGED_OUT"}
let INVALID_AUTH_STATE:Int = 3

class ACPIdentity_Cordova : CDVPlugin {

    func extensionVersion(command:CDVInvokedUrlCommand!) {
        self.commandDelegate.runInBackground({
            var pluginResult:CDVPluginResult! = nil

            let version:String! = ACPIdentity.extensionVersion()

            pluginResult = CDVPluginResult.resultWithStatus(CDVCommandStatus_OK, messageAsString:version)
            self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
        })
    }

    func appendVisitorInfoForUrl(command:CDVInvokedUrlCommand!) {
        self.commandDelegate.runInBackground({
            let url:NSURL! = NSURL.URLWithString(self.getCommandArg(command.arguments[0]))
            ACPIdentity.appendToUrl(url, withCallback:{ (urlWithVisitorData:NSURL?) in
                let pluginResult:CDVPluginResult! = CDVPluginResult.resultWithStatus(CDVCommandStatus_OK, messageAsString:urlWithVisitorData.absoluteString())
                self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
            })
        })
    }

    func getExperienceCloudId(command:CDVInvokedUrlCommand!) {
        self.commandDelegate.runInBackground({
            ACPIdentity.getExperienceCloudId({ (experienceCloudId:String?) in
                let pluginResult:CDVPluginResult! = CDVPluginResult.resultWithStatus(CDVCommandStatus_OK, messageAsString:experienceCloudId)
                self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
            })
        })
    }

    func getIdentifiers(command:CDVInvokedUrlCommand!) {
        self.commandDelegate.runInBackground({
            ACPIdentity.getIdentifiers({ (visitorIDs:[AnyObject]?) in
                var visitorIdsString:String! = ""
                if !visitorIDs {
                    visitorIdsString = "nil"
                } else if visitorIDs.count() == 0 {
                    visitorIdsString = "[]"
                } else {
                    for visitorId:ACPMobileVisitorId! in visitorIDs {
                        visitorIdsString = visitorIdsString.stringByAppendingFormat("[Id: %@, Type: %@, Origin: %@, Authentication: %@] ", visitorId.identifier(), visitorId.idType(), visitorId.idOrigin(), stateStrings[(visitorId.authenticationState() as! unsigned long)])
                     }
                }
                let pluginResult:CDVPluginResult! = CDVPluginResult.resultWithStatus(CDVCommandStatus_OK, messageAsString:visitorIdsString)
                self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
            })
        })
    }

    func getUrlVariables(command:CDVInvokedUrlCommand!) {
        self.commandDelegate.runInBackground({
            ACPIdentity.getUrlVariables({ (urlVariables:String?) in
                let pluginResult:CDVPluginResult! = CDVPluginResult.resultWithStatus(CDVCommandStatus_OK, messageAsString:urlVariables)
                self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
            })
        })
    }

    func syncIdentifier(command:CDVInvokedUrlCommand!) {
       self.commandDelegate.runInBackground({
           let idType:String! = self.getCommandArg(command.arguments[0])
           let idValue:String! = self.getCommandArg(command.arguments[1])
           let state:Int = self.getAuthenticationStateValue(self.getCommandArg(command.arguments[2]))

           ACPIdentity.syncIdentifier(idType, identifier:idValue, authentication:state)
            let pluginResult:CDVPluginResult! = CDVPluginResult.resultWithStatus(CDVCommandStatus_OK, messageAsString:String(format:"Visitor ID synced: Id: %@, Type: %@, Authentication: %@", idType, idValue, stateStrings[state]))
           self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
       })
    }

    func syncIdentifiers(command:CDVInvokedUrlCommand!) {
       self.commandDelegate.runInBackground({
           var pluginResult:CDVPluginResult! = nil
           let identifiers:NSDictionary! = self.getCommandArg(command.arguments[0])
           let state:Int = self.getAuthenticationStateValue(self.getCommandArg(command.arguments[1]))

            if state < 3 {
                ACPIdentity.syncIdentifiers(identifiers, authentication:state)
                pluginResult = CDVPluginResult.resultWithStatus(CDVCommandStatus_OK, messageAsString:String(format:"Visitor IDs synced: %@, Authentication: %@", identifiers, stateStrings[state]))
            } else {
                ACPIdentity.syncIdentifiers(identifiers)
                pluginResult = CDVPluginResult.resultWithStatus(CDVCommandStatus_OK, messageAsString:String(format:"Visitor IDs synced: %@", identifiers))
            }

           self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
       })
    }

    /*
     * Helper functions
     */

    func getCommandArg(argument:AnyObject!) -> AnyObject! {
        return argument == (NSNull.null() as! id) ? nil : argument
    }

    func getAuthenticationStateValue(authState:NSNumber!) -> Int {
        var authStateInt:Int = 3 // use 3 as the auth state values range from 0-2
        if (authState != nil) {
             switch(authState.integerValue()) {
                 case 0:
                     authStateInt = ACPMobileVisitorAuthenticationStateUnknown
                     break
                 case 1:
                     authStateInt = ACPMobileVisitorAuthenticationStateAuthenticated
                     break
                 case 2:
                     authStateInt = ACPMobileVisitorAuthenticationStateLoggedOut
                     break
                 default:
                     authStateInt = INVALID_AUTH_STATE
                     break
             }
        }
        return authStateInt
    }
}
