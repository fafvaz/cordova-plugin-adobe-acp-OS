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

/********* cordova-acpanalytics.m Cordova Plugin Implementation *******/

//#import <Cordova/CDV.h>
//#import <ACPAnalytics/ACPAnalytics.h>
//#import <Cordova/CDVPluginResult.h>


class ACPAnalytics_Cordova : CDVPlugin {

    func extensionVersion(command:CDVInvokedUrlCommand!) {
        self.commandDelegate.runInBackground({
            var pluginResult:CDVPluginResult! = nil
            let extensionVersion:String! = ACPAnalytics.extensionVersion()

            if extensionVersion != nil && extensionVersion.length() > 0 {
                pluginResult = CDVPluginResult.resultWithStatus(CDVCommandStatus_OK, messageAsString:extensionVersion)
            } else {
                pluginResult = CDVPluginResult.resultWithStatus(CDVCommandStatus_ERROR)
            }

            self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
        })
    }

    func sendQueuedHits(command:CDVInvokedUrlCommand!) {
        self.commandDelegate.runInBackground({
            ACPAnalytics.sendQueuedHits()
            let pluginResult:CDVPluginResult! = CDVPluginResult.resultWithStatus(CDVCommandStatus_OK)
            self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
        })
    }

    func clearQueue(comman:CDVInvokedUrlCommand!) {
        self.commandDelegate.runInBackground({
            ACPAnalytics.clearQueue()
            let pluginResult:CDVPluginResult! = CDVPluginResult.resultWithStatus(CDVCommandStatus_OK)
            self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
        })
    }

    func getQueueSize(command:CDVInvokedUrlCommand!) {
        self.commandDelegate.runInBackground({
            ACPAnalytics.getQueueSize({ (queueSize:UInt) in
                let pluginResult:CDVPluginResult! = CDVPluginResult.resultWithStatus(CDVCommandStatus_OK, messageAsString:String(format:"%@",  queueSize))
                self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
            })
        })
    }

    func getTrackingIdentifier(command:CDVInvokedUrlCommand!) {
        self.commandDelegate.runInBackground({
            ACPAnalytics.getTrackingIdentifier({ (trackingIdentifier:String?) in
                let pluginResult:CDVPluginResult! = CDVPluginResult.resultWithStatus(CDVCommandStatus_OK, messageAsString:trackingIdentifier)
                self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
            })
        })
    }

    func getVisitorIdentifier(command:CDVInvokedUrlCommand!) {
        self.commandDelegate.runInBackground({
            ACPAnalytics.getVisitorIdentifier({ (visitorIdentifier:String?) in
                let pluginResult:CDVPluginResult! = CDVPluginResult.resultWithStatus(CDVCommandStatus_OK, messageAsString:visitorIdentifier)
                self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
            })
        })
    }

    func setVisitorIdentifier(command:CDVInvokedUrlCommand!) {
        self.commandDelegate.runInBackground({
            let vid:String! = command.arguments.objectAtIndex(0)
            ACPAnalytics.visitorIdentifier = vid
            let pluginResult:CDVPluginResult! = CDVPluginResult.resultWithStatus(CDVCommandStatus_OK)
            self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
        })
    }
}
