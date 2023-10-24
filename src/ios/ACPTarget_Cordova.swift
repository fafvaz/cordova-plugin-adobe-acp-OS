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

/********* cordova-acptarget.m Cordova Plugin Implementation *******/

//#import <Cordova/CDV.h>
//#import <ACPTarget/ACPTarget.h>
//#import <ACPTarget/ACPTargetOrder.h>
//#import <ACPTarget/ACPTargetParameters.h>
//#import <ACPTarget/ACPTargetRequestObject.h>
//#import <ACPTarget/ACPTargetProduct.h>
//#import <ACPTarget/ACPTargetPrefetchObject.h>
//#import <Cordova/CDVPluginResult.h>


class ACPTarget_Cordova : CDVPlugin {

    func clearPrefetchCache(command:CDVInvokedUrlCommand!) {
        self.commandDelegate.runInBackground({
            ACPTarget.clearPrefetchCache()
            let pluginResult:CDVPluginResult! = CDVPluginResult.resultWithStatus(CDVCommandStatus_OK)
            self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
        })
    }

    func extensionVersion(command:CDVInvokedUrlCommand!) {
        self.commandDelegate.runInBackground({
            var pluginResult:CDVPluginResult! = nil
            let extensionVersion:String! = ACPTarget.extensionVersion()

            if extensionVersion != nil && extensionVersion.length() > 0 {
                pluginResult = CDVPluginResult.resultWithStatus(CDVCommandStatus_OK, messageAsString:extensionVersion)
            } else {
                pluginResult = CDVPluginResult.resultWithStatus(CDVCommandStatus_ERROR)
            }

            self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
        })
    }


    func getThirdPartyId(comman:CDVInvokedUrlCommand!) {
        self.commandDelegate.runInBackground({
            ACPTarget.getThirdPartyId({ (thirdPartyId:String?) in
                let pluginResult:CDVPluginResult! = CDVPluginResult.resultWithStatus(CDVCommandStatus_OK, messageAsString:thirdPartyId)
                self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
            })
        })
    }

    func getTntId(command:CDVInvokedUrlCommand!) {
        self.commandDelegate.runInBackground({
            ACPTarget.getTntId({ (tntId:String?) in
                let pluginResult:CDVPluginResult! = CDVPluginResult.resultWithStatus(CDVCommandStatus_OK, messageAsString:tntId)
                self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
            })
        })
    }

    func resetExperience(command:CDVInvokedUrlCommand!) {
        self.commandDelegate.runInBackground({
            ACPTarget.resetExperience()
            let pluginResult:CDVPluginResult! = CDVPluginResult.resultWithStatus(CDVCommandStatus_OK)
            self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
        })
    }

    func setThirdPartyId(command:CDVInvokedUrlCommand!) {
        self.commandDelegate.runInBackground({
            let thirdPartyId:String! = self.getCommandArg(command.arguments[0])

             ACPTarget.thirdPartyId = thirdPartyId

            let pluginResult:CDVPluginResult! = CDVPluginResult.resultWithStatus(CDVCommandStatus_OK)
            self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
        })
    }

    func setPreviewRestartDeepLink(command:CDVInvokedUrlCommand!) {
        self.commandDelegate.runInBackground({
            let deepLink:NSURL! = self.getCommandArg(command.arguments[0])

            ACPTarget.previewRestartDeeplink = deepLink

            let pluginResult:CDVPluginResult! = CDVPluginResult.resultWithStatus(CDVCommandStatus_OK)
            self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
        })
    }

    func retrieveLocationContent(command:CDVInvokedUrlCommand!) {
      self.commandDelegate.runInBackground({
        var error:NSError!
        let locationRequests:NSDictionary! = command.arguments[0]
        let requestArray:NSMutableArray! = NSMutableArray.array()
        var profileParam:NSDictionary!
        var mboxParam:NSDictionary!
        var orderParam:NSDictionary!
        var productParam:NSDictionary!
        var profileLocParam:NSDictionary!
        var mboxLocParam:NSDictionary!
        var orderLocParam:NSDictionary!
        var productLocParam:NSDictionary!
        var orderParameters:ACPTargetOrder! = nil
        var targetParameters:ACPTargetParameters! = nil
        var productParameter:ACPTargetProduct! = nil
        var orderLocParameters:ACPTargetOrder! = nil
        var targetLocParameters:ACPTargetParameters! = nil
        var productLocParameter:ACPTargetProduct! = nil
        for key:AnyObject! in locationRequests {
            let request:NSDictionary! = locationRequests.objectForKey(key)
            let mboxName:String! = request.objectForKey("mboxName")
            if request.objectForKey("mboxParameter").count() > 0 {
                mboxParam = request.objectForKey("mboxParameter")
            }
            if request.objectForKey("profileParameter").count() > 0 {
                profileParam = request.objectForKey("profileParameter")
            }

            if request.objectForKey("orderParameter").count() > 0 {
                orderParam = request.objectForKey("orderParameter")
                if orderParam.objectForKey("orderId") != nil {
                    let orderId:String! = orderParam.objectForKey("orderId")
                    let orderTotal:NSNumber! = orderParam.objectForKey("orderTotal")
                    let orderPurchasedIds:[AnyObject]! = orderParam.objectForKey("orderPurchasedIds")
                    orderParameters = ACPTargetOrder.targetOrderWithId(orderId, total:orderTotal, purchasedProductIds:orderPurchasedIds)
                }

            }

            if request.objectForKey("productParameter").count() > 0 {
                productParam = request.objectForKey("productParameter")
                if productParam.objectForKey("id")  != nil {
                  let id:String! = productParam.objectForKey("id")
                  let categoryIdValue:String! = productParam.objectForKey("categoryId")
                  productParameter = ACPTargetProduct.targetProductWithId(AnyObject, categoryId:categoryIdValue)
                }
            }


            targetParameters = ACPTargetParameters.targetParametersWithParameters(mboxParam,
                profileParameters:profileParam,
                product:productParameter,
                order:orderParameters)

            let requestObject:ACPTargetRequestObject! = ACPTargetRequestObject.targetRequestObjectWithName(mboxName, targetParameters:targetParameters,
                defaultContent:"defaultContent", callback:{ (content:String?) in
                    let pluginResult:CDVPluginResult! = CDVPluginResult.resultWithStatus(CDVCommandStatus_OK)
                    self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
            })

            requestArray.addObject(requestObject)

         }


        let requestLoc:NSDictionary! = command.arguments[1]

        if requestLoc.objectForKey("mboxParameter").count() > 0 {
            mboxLocParam = requestLoc.objectForKey("mboxParameter")

        }
        if requestLoc.objectForKey("profileParameter").count() > 0 {
            profileLocParam = requestLoc.objectForKey("profileParameter")

        }

        if requestLoc.objectForKey("orderParameter").count() > 0 {
            orderLocParam = requestLoc.objectForKey("orderParameter")
            if orderLocParam.objectForKey("orderId")  != nil {
                let orderId:String! = orderLocParam.objectForKey("orderId")
                let orderTotal:NSNumber! = orderLocParam.objectForKey("orderTotal")
                let orderPurchasedIds:[AnyObject]! = orderLocParam.objectForKey("orderPurchasedIds")
                orderLocParameters = ACPTargetOrder.targetOrderWithId(orderId, total:orderTotal, purchasedProductIds:orderPurchasedIds)
            }

        }

        if requestLoc.objectForKey("productParameter").count() > 0 {
            productLocParam = requestLoc.objectForKey("productParameter")
            if productLocParam.objectForKey("id")  != nil {
              let id:String! = productLocParam.objectForKey("id")
              let categoryIdValue:String! = productLocParam.objectForKey("categoryId")
              productLocParameter = ACPTargetProduct.targetProductWithId(AnyObject, categoryId:categoryIdValue)
            }

        }

        targetLocParameters = ACPTargetParameters.targetParametersWithParameters(mboxLocParam,
                                                        profileParameters:profileLocParam,
                                                                  product:productLocParameter,
                                                                    order:orderLocParameters)

        ACPTarget.retrieveLocationContent(requestArray, withParameters:targetLocParameters)

      })
    }

    func locationClicked(command:CDVInvokedUrlCommand!) {
        self.commandDelegate.runInBackground({

            let mboxName:String! = self.getCommandArg(command.arguments[0])
            let request:NSDictionary! = self.getCommandArg(command.arguments[1])
            var profileParam:NSDictionary!
            var mboxParam:NSDictionary!
            var orderParam:NSDictionary!
            var productParam:NSDictionary!
            var orderParameters:ACPTargetOrder! = nil
            var targetParameters:ACPTargetParameters! = nil
            var productParameter:ACPTargetProduct! = nil


            if request.objectForKey("mboxParameter").count() > 0 {
                mboxParam = request.objectForKey("mboxParameter")
            }
            if request.objectForKey("profileParameter").count() > 0 {
                profileParam = request.objectForKey("profileParameter")
            }

            if request.objectForKey("orderParameter").count() > 0 {
                orderParam = request.objectForKey("orderParameter")
                if orderParam.objectForKey("orderId") != nil {
                    let orderId:String! = orderParam.objectForKey("orderId")
                    let orderTotal:NSNumber! = orderParam.objectForKey("orderTotal")
                    let orderPurchasedIds:[AnyObject]! = orderParam.objectForKey("orderPurchasedIds")
                    orderParameters = ACPTargetOrder.targetOrderWithId(orderId, total:orderTotal, purchasedProductIds:orderPurchasedIds)
                }
            }

            if request.objectForKey("productParameter").count() > 0 {
                productParam = request.objectForKey("productParameter")
                if productParam.objectForKey("id")  != nil {
                  let id:String! = productParam.objectForKey("id")
                  let categoryIdValue:String! = productParam.objectForKey("categoryId")
                  productParameter = ACPTargetProduct.targetProductWithId(AnyObject, categoryId:categoryIdValue)
                }
            }

            targetParameters = ACPTargetParameters.targetParametersWithParameters(mboxParam,
                profileParameters:profileParam,
                product:productParameter,
                order:orderParameters)

            ACPTarget.locationClickedWithName(mboxName, targetParameters:targetParameters)

            let pluginResult:CDVPluginResult! = CDVPluginResult.resultWithStatus(CDVCommandStatus_OK)
            self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
        })
    }

    func locationsDisplayed(command:CDVInvokedUrlCommand!) {
        self.commandDelegate.runInBackground({
            let mboxLists:[AnyObject]! = self.getCommandArg(command.arguments[0])
            let request:NSDictionary! = self.getCommandArg(command.arguments[1])
            var profileParam:NSDictionary!
            var mboxParam:NSDictionary!
            var orderParam:NSDictionary!
            var productParam:NSDictionary!
            var orderParameters:ACPTargetOrder! = nil
            var targetParameters:ACPTargetParameters! = nil
            var productParameter:ACPTargetProduct! = nil


            if request.objectForKey("mboxParameter").count() > 0 {
                mboxParam = request.objectForKey("mboxParameter")
            }
            if request.objectForKey("profileParameter").count() > 0 {
                profileParam = request.objectForKey("profileParameter")
            }

            if request.objectForKey("orderParameter").count() > 0 {
                orderParam = request.objectForKey("orderParameter")
                if orderParam.objectForKey("orderId") != nil {
                    let orderId:String! = orderParam.objectForKey("orderId")
                    let orderTotal:NSNumber! = orderParam.objectForKey("orderTotal")
                    let orderPurchasedIds:[AnyObject]! = orderParam.objectForKey("orderPurchasedIds")
                    orderParameters = ACPTargetOrder.targetOrderWithId(orderId, total:orderTotal, purchasedProductIds:orderPurchasedIds)
                }
            }

            if request.objectForKey("productParameter").count() > 0 {
                productParam = request.objectForKey("productParameter")
                if productParam.objectForKey("id")  != nil {
                  let id:String! = productParam.objectForKey("id")
                  let categoryIdValue:String! = productParam.objectForKey("categoryId")
                  productParameter = ACPTargetProduct.targetProductWithId(AnyObject, categoryId:categoryIdValue)
                }
            }

            targetParameters = ACPTargetParameters.targetParametersWithParameters(mboxParam,
                profileParameters:profileParam,
                product:productParameter,
                order:orderParameters)


            ACPTarget.locationsDisplayed(mboxLists, withTargetParameters:targetParameters)

            let pluginResult:CDVPluginResult! = CDVPluginResult.resultWithStatus(CDVCommandStatus_OK)
            self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
        })
    }

    func prefetchContent(command:CDVInvokedUrlCommand!) {
        self.commandDelegate.runInBackground({
            var error:NSError!
            let locationRequests:NSDictionary! = command.arguments[0]
            let requestArray:NSMutableArray! = NSMutableArray.array()
            var profileParam:NSDictionary!
            var mboxParam:NSDictionary!
            var orderParam:NSDictionary!
            var productParam:NSDictionary!
            var profileLocParam:NSDictionary!
            var mboxLocParam:NSDictionary!
            var orderLocParam:NSDictionary!
            var productLocParam:NSDictionary!
            var orderParameters:ACPTargetOrder! = nil
            var targetParameters:ACPTargetParameters! = nil
            var productParameter:ACPTargetProduct! = nil
            var orderLocParameters:ACPTargetOrder! = nil
            var targetLocParameters:ACPTargetParameters! = nil
            var productLocParameter:ACPTargetProduct! = nil
            for key:AnyObject! in locationRequests {
                let request:NSDictionary! = locationRequests.objectForKey(key)
                let mboxName:String! = request.objectForKey("mboxName")
                if request.objectForKey("mboxParameter").count() > 0 {
                    mboxParam = request.objectForKey("mboxParameter")
                }
                if request.objectForKey("profileParameter").count() > 0 {
                    profileParam = request.objectForKey("profileParameter")
                }

                if request.objectForKey("orderParameter").count() > 0 {
                    orderParam = request.objectForKey("orderParameter")
                    if orderParam.objectForKey("orderId") != nil {
                        let orderId:String! = orderParam.objectForKey("orderId")
                        let orderTotal:NSNumber! = orderParam.objectForKey("orderTotal")
                        let orderPurchasedIds:[AnyObject]! = orderParam.objectForKey("orderPurchasedIds")
                        orderParameters = ACPTargetOrder.targetOrderWithId(orderId, total:orderTotal, purchasedProductIds:orderPurchasedIds)
                    }
                }

                if request.objectForKey("productParameter").count() > 0 {
                    productParam = request.objectForKey("productParameter")
                    if productParam.objectForKey("id")  != nil {
                      let id:String! = productParam.objectForKey("id")
                      let categoryIdValue:String! = productParam.objectForKey("categoryId")
                      productParameter = ACPTargetProduct.targetProductWithId(AnyObject, categoryId:categoryIdValue)
                    }
                }


                targetParameters = ACPTargetParameters.targetParametersWithParameters(mboxParam,
                    profileParameters:profileParam,
                    product:productParameter,
                    order:orderParameters)

                let requestObject:ACPTargetPrefetchObject! = ACPTargetPrefetchObject.targetPrefetchObjectWithName(mboxName,
                    targetParameters:targetParameters)

                requestArray.addObject(requestObject)
             }


            let requestLoc:NSDictionary! = command.arguments[1]


            if requestLoc.objectForKey("mboxParameter").count() > 0 {
                mboxLocParam = requestLoc.objectForKey("mboxParameter")
            }
            if requestLoc.objectForKey("profileParameter").count() > 0 {
                profileLocParam = requestLoc.objectForKey("profileParameter")
            }

            if requestLoc.objectForKey("orderParameter").count() > 0 {
                orderLocParam = requestLoc.objectForKey("orderParameter")
                if orderLocParam.objectForKey("orderId")  != nil {
                    let orderId:String! = orderLocParam.objectForKey("orderId")
                    let orderTotal:NSNumber! = orderLocParam.objectForKey("orderTotal")
                    let orderPurchasedIds:[AnyObject]! = orderLocParam.objectForKey("orderPurchasedIds")
                    orderLocParameters = ACPTargetOrder.targetOrderWithId(orderId, total:orderTotal, purchasedProductIds:orderPurchasedIds)
                }
            }

            if requestLoc.objectForKey("productParameter").count() > 0 {
                productLocParam = requestLoc.objectForKey("productParameter")
                if productLocParam.objectForKey("id")  != nil {
                  let id:String! = productLocParam.objectForKey("id")
                  let categoryIdValue:String! = productLocParam.objectForKey("categoryId")
                  productLocParameter = ACPTargetProduct.targetProductWithId(AnyObject, categoryId:categoryIdValue)
                }
            }

            targetLocParameters = ACPTargetParameters.targetParametersWithParameters(mboxLocParam,
                                                            profileParameters:profileLocParam,
                                                                      product:productLocParameter,
                                                                        order:orderLocParameters)

            ACPTarget.prefetchContent(requestArray, withParameters:targetLocParameters, callback:{ (error:NSError?) in
                    let pluginResult:CDVPluginResult! = CDVPluginResult.resultWithStatus(CDVCommandStatus_OK)
                    self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
            })


          })
    }

    /*
     * Helper functions
     */

    func getCommandArg(argument:AnyObject!) -> AnyObject! {
        return argument == (NSNull.null() as! id) ? nil : argument
    }
}
