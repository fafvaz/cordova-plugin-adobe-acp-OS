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

/********* cordova-acpplaces.m Cordova Plugin Implementation *******/

//#import <Cordova/CDV.h>
//#import <ACPPlaces/ACPPlaces.h>
//#import <Cordova/CDVPluginResult.h>


class ACPPlaces_Cordova : CDVPlugin {

    let POI:String! = "POI"
    let LATITUDE:String! = "Latitude"
    let LONGITUDE:String! = "Longitude"
    let LOWERCASE_LATITUDE:String! = "latitude"
    let LOWERCASE_LONGITUDE:String! = "longitude"
    let IDENTIFIER:String! = "Identifier"
    let CENTER:String! = "center"
    let RADIUS:String! = "radius"
    let REQUEST_ID:String! = "requestId"
    let CIRCULAR_REGION:String! = "circularRegion"
    let EMPTY_ARRAY_STRING:String! = "[]"

    func clear(command:CDVInvokedUrlCommand!) {
        self.commandDelegate.runInBackground({
            ACPPlaces.clear()
            let pluginResult:CDVPluginResult! = CDVPluginResult.resultWithStatus(CDVCommandStatus_OK)
            self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
        })
    }

    func extensionVersion(command:CDVInvokedUrlCommand!) {
        self.commandDelegate.runInBackground({
            var pluginResult:CDVPluginResult! = nil
            let extensionVersion:String! = ACPPlaces.extensionVersion()

            if extensionVersion != nil && extensionVersion.length() > 0 {
                pluginResult = CDVPluginResult.resultWithStatus(CDVCommandStatus_OK, messageAsString:extensionVersion)
            } else {
                pluginResult = CDVPluginResult.resultWithStatus(CDVCommandStatus_ERROR)
            }

            self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
        })
    }

    func getCurrentPointsOfInterest(command:CDVInvokedUrlCommand!) {
        self.commandDelegate.runInBackground({
            var currentPoisString:String! = EMPTY_ARRAY_STRING
            let semaphore:dispatch_semaphore_t = dispatch_semaphore_create(0)
            ACPPlaces.getCurrentPointsOfInterest({ (retrievedPois:[AnyObject]?) in
                if retrievedPois != nil && retrievedPois.count != 0 {
                    currentPoisString = self.generatePOIString(retrievedPois)
                    dispatch_semaphore_signal(semaphore)
                }
            })
            dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, ((1 as! int64_t) * NSEC_PER_SEC)))
            let pluginResult:CDVPluginResult! = CDVPluginResult.resultWithStatus(CDVCommandStatus_OK, messageAsString:currentPoisString)
            self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
        })
    }

    func getLastKnownLocation(command:CDVInvokedUrlCommand!) {
        self.commandDelegate.runInBackground({
            ACPPlaces.getLastKnownLocation({ (lastLocation:CLLocation?) in
                let tempDict:NSMutableDictionary! = NSMutableDictionary()
                tempDict.setValue(NSNumber.numberWithDouble(lastLocation.coordinate.latitude), forKey:LATITUDE)
                tempDict.setValue(NSNumber.numberWithDouble(lastLocation.coordinate.longitude), forKey:LONGITUDE)
                let jsonData:NSData! = NSJSONSerialization.dataWithJSONObject(tempDict, options:0, error:nil)
                let pluginResult:CDVPluginResult! = CDVPluginResult.resultWithStatus(CDVCommandStatus_OK, messageAsString:String(data:jsonData, encoding:NSUTF8StringEncoding))
                self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
            })
        })
    }

    func getNearbyPointsOfInterest(command:CDVInvokedUrlCommand!) {
        self.commandDelegate.runInBackground({
            let locationDict:NSDictionary! = self.getCommandArg(command.arguments[0])
            let latitude:CLLocationDegrees = locationDict.valueForKey(LOWERCASE_LATITUDE).doubleValue()
            let longitude:CLLocationDegrees = locationDict.valueForKey(LOWERCASE_LONGITUDE).doubleValue()
            let currentLocation:CLLocation! = CLLocation(latitude:latitude, longitude:longitude)
            let limit:UInt = self.getCommandArg(command.arguments[1]).integerValue()
            var currentPoisString:String! = EMPTY_ARRAY_STRING
            let semaphore:dispatch_semaphore_t = dispatch_semaphore_create(0)
            ACPPlaces.getNearbyPointsOfInterest(currentLocation, limit:limit, callback:{ (retrievedPois:[AnyObject]?) in
                    currentPoisString = self.generatePOIString(retrievedPois)
                    dispatch_semaphore_signal(semaphore)
                },
                    errorCallback:{ (error:ACPPlacesRequestError) in
                self.commandDelegate.sendPluginResult(CDVPluginResult.resultWithStatus(CDVCommandStatus_ERROR, messageAsString:String(format:"Places request error code: %lu", error)), callbackId:command.callbackId)
            })
            dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, ((1 as! int64_t) * NSEC_PER_SEC)))
            let pluginResult:CDVPluginResult! = CDVPluginResult.resultWithStatus(CDVCommandStatus_OK, messageAsString:currentPoisString)
            self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
        })
    }

    func processGeofence(command:CDVInvokedUrlCommand!) {
        self.commandDelegate.runInBackground({
            let geofenceDict:NSDictionary! = self.getCommandArg(command.arguments[0])
            let regionDict:NSDictionary! = geofenceDict.valueForKey(CIRCULAR_REGION)
            let eventType:ACPRegionEventType = self.getCommandArg(command.arguments[1]).integerValue()
            let latitude:CLLocationDegrees = regionDict.valueForKey(LOWERCASE_LATITUDE).doubleValue()
            let longitude:CLLocationDegrees = regionDict.valueForKey(LOWERCASE_LONGITUDE).doubleValue()
            let center:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude,longitude)
            let radius:UInt = regionDict.valueForKey(RADIUS).integerValue()
            let identifier:String! = geofenceDict.valueForKey(REQUEST_ID)
            let region:CLRegion! = CLCircularRegion(center:center, radius:radius, identifier:identifier)
            ACPPlaces.processRegionEvent(region, forRegionEventType:eventType)
            let pluginResult:CDVPluginResult! = CDVPluginResult.resultWithStatus(CDVCommandStatus_OK)
            self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
        })
    }

    func setAuthorizationStatus(command:CDVInvokedUrlCommand!) {
        self.commandDelegate.runInBackground({
            let status:Int = self.getCommandArg(command.arguments[0]).integerValue()
            ACPPlaces.authorizationStatus = self.convertToCLAuthorizationStatus(status)
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

    func generatePOIString(retrievedPois:[AnyObject]!) -> String! {
        let retrievedPoisArray:NSMutableArray! = NSMutableArray()
        if retrievedPois != nil && retrievedPois.count != 0 {
            for var index:Int=0 ; index < retrievedPois.count ; index++ {
                let tempDict:NSMutableDictionary! = NSMutableDictionary()
                let currentPoi:ACPPlacesPoi! = retrievedPois[index]
                tempDict.setValue(currentPoi.name, forKey:POI)
                tempDict.setValue(NSNumber.numberWithDouble(currentPoi.latitude), forKey:LATITUDE)
                tempDict.setValue(NSNumber.numberWithDouble(currentPoi.longitude), forKey:LONGITUDE)
                tempDict.setValue(currentPoi.identifier, forKey:IDENTIFIER)
                retrievedPoisArray[index] = tempDict
             }
            let jsonData:NSData! = NSJSONSerialization.dataWithJSONObject(retrievedPoisArray, options:0, error:nil)
            return String(data:jsonData, encoding:NSUTF8StringEncoding)
        }
        return EMPTY_ARRAY_STRING
    }

    func convertToCLAuthorizationStatus(status:Int) -> CLAuthorizationStatus {
        switch (status) {
        case 0:
            return kCLAuthorizationStatusDenied
            break

        case 1:
            return kCLAuthorizationStatusAuthorizedAlways
            break

        case 2:
            return kCLAuthorizationStatusNotDetermined
            break

        case 3:
            return kCLAuthorizationStatusRestricted
            break

        case 4:
        default:
            return kCLAuthorizationStatusAuthorizedWhenInUse
            break
        }
    }
}
