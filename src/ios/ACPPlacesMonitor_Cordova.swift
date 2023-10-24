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

/********* cordova-acpprofilemonitor.m Cordova Plugin Implementation *******/

//#import <Cordova/CDV.h>
//#import <ACPPlacesMonitor/ACPPlacesMonitor.h>
//#import <Cordova/CDVPluginResult.h>


class ACPPlacesMonitor_Cordova : CDVPlugin {

    func extensionVersion(command:CDVInvokedUrlCommand!) {
        self.commandDelegate.runInBackground({
            var pluginResult:CDVPluginResult! = nil
            let extensionVersion:String! = ACPPlacesMonitor.extensionVersion()

            if extensionVersion != nil && extensionVersion.length() > 0 {
                pluginResult = CDVPluginResult.resultWithStatus(CDVCommandStatus_OK, messageAsString:extensionVersion)
            } else {
                pluginResult = CDVPluginResult.resultWithStatus(CDVCommandStatus_ERROR)
            }

            self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
        })
    }

    func start(command:CDVInvokedUrlCommand!) {
        self.commandDelegate.runInBackground({
            ACPPlacesMonitor.start()
            let pluginResult:CDVPluginResult! = CDVPluginResult.resultWithStatus(CDVCommandStatus_OK)
            self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
        })
    }

    func stop(command:CDVInvokedUrlCommand!) {
        self.commandDelegate.runInBackground({
            let shouldClearPlacesData:Bool = self.getCommandArg(command.arguments[0])
            ACPPlacesMonitor.stop(shouldClearPlacesData)
            let pluginResult:CDVPluginResult! = CDVPluginResult.resultWithStatus(CDVCommandStatus_OK)
            self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
        })
    }

    func updateLocation(command:CDVInvokedUrlCommand!) {
        self.commandDelegate.runInBackground({
            ACPPlacesMonitor.updateLocationNow()
            let pluginResult:CDVPluginResult! = CDVPluginResult.resultWithStatus(CDVCommandStatus_OK)
            self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
        })
    }

    func setRequestLocationPermission(command:CDVInvokedUrlCommand!) {
        self.commandDelegate.runInBackground({
            let authorizationLevel:ACPPlacesMonitorRequestAuthorizationLevel = self.convertToAuthorizationLevel(self.getCommandArg(command.arguments[0]))
            ACPPlacesMonitor.requestAuthorizationLevel = authorizationLevel
            let pluginResult:CDVPluginResult! = CDVPluginResult.resultWithStatus(CDVCommandStatus_OK)
            self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
        })
    }

    func setPlacesMonitorMode(command:CDVInvokedUrlCommand!) {
        self.commandDelegate.runInBackground({
            let mode:ACPPlacesMonitorMode = self.convertToMonitorMode(self.getCommandArg(command.arguments[0]))
            ACPPlacesMonitor.placesMonitorMode = mode
            let pluginResult:CDVPluginResult! = CDVPluginResult.resultWithStatus(CDVCommandStatus_OK)
            self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
        })
    }

    /*
     * Helper functions
     */

    func getCommandArg(argument:AnyObject!) -> AnyObject! {
        return argument == (NSNull.null() as! id) ? nil : argument
    }

    func convertToAuthorizationLevel(authorization:NSNumber!) -> ACPPlacesMonitorRequestAuthorizationLevel {
        if authorization.integerValue == 1 {
            return ACPPlacesRequestMonitorAuthorizationLevelAlways
        } else {
            return ACPPlacesMonitorRequestAuthorizationLevelWhenInUse
        }
    }

    func convertToMonitorMode(monitorMode:NSNumber!) -> ACPPlacesMonitorMode {
        if monitorMode.integerValue == 1 {
            return ACPPlacesMonitorModeSignificantChanges
        } else {
            return ACPPlacesMonitorModeContinuous
        }
    }
}
