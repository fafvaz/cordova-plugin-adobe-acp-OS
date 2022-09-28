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

#import <Cordova/CDV.h>
#import <ACPTarget/ACPTarget.h>
#import <ACPTarget/ACPTargetOrder.h>
#import <ACPTarget/ACPTargetParameters.h>
#import <ACPTarget/ACPTargetRequestObject.h>
#import <ACPTarget/ACPTargetProduct.h>
#import <ACPTarget/ACPTargetPrefetchObject.h>
#import <Cordova/CDVPluginResult.h>


@interface ACPTarget_Cordova : CDVPlugin

- (void)clearPrefetchCache:(CDVInvokedUrlCommand*)command;
- (void)extensionVersion:(CDVInvokedUrlCommand*)command;
- (void)getThirdPartyId:(CDVInvokedUrlCommand*)comman;
- (void)getTntId:(CDVInvokedUrlCommand*)command;
- (void)resetExperience:(CDVInvokedUrlCommand*)command;
- (void)setPreviewRestartDeepLink:(CDVInvokedUrlCommand*)command;
- (void)setThirdPartyId:(CDVInvokedUrlCommand*)command;
- (void)retrieveLocationContent:(CDVInvokedUrlCommand*)command;
- (void)locationClicked:(CDVInvokedUrlCommand*)command;
- (void)locationsDisplayed:(CDVInvokedUrlCommand*)command;
- (void)prefetchContent:(CDVInvokedUrlCommand*)command;


@end

@implementation ACPTarget_Cordova

- (void)clearPrefetchCache:(CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        [ACPTarget clearPrefetchCache];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)extensionVersion:(CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        CDVPluginResult* pluginResult = nil;
        NSString* extensionVersion = [ACPTarget extensionVersion];

        if (extensionVersion != nil && [extensionVersion length] > 0) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:extensionVersion];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        }

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}


- (void) getThirdPartyId:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        [ACPTarget getThirdPartyId:^(NSString * _Nullable thirdPartyId) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:thirdPartyId];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }];
}

- (void) getTntId:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        [ACPTarget getTntId:^(NSString * _Nullable tntId) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:tntId];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }];
}

- (void) resetExperience:(CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        [ACPTarget resetExperience];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void) setThirdPartyId:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        NSString *thirdPartyId = [self getCommandArg:command.arguments[0]];

         [ACPTarget setThirdPartyId:thirdPartyId];

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void) setPreviewRestartDeepLink:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        NSURL *deepLink = [self getCommandArg:command.arguments[0]];

		[ACPTarget setPreviewRestartDeeplink:deepLink];

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void) retrieveLocationContent:(CDVInvokedUrlCommand*)command {
  [self.commandDelegate runInBackground:^{
    NSError *error;
    NSDictionary *locationRequests = (NSDictionary *)command.arguments[0];
    NSMutableArray *requestArray = [NSMutableArray array];
    NSDictionary *profileParam;
    NSDictionary *mboxParam;
    NSDictionary *orderParam;
    NSDictionary *productParam;
    NSDictionary *profileLocParam;
    NSDictionary *mboxLocParam;
    NSDictionary *orderLocParam;
    NSDictionary *productLocParam;
    ACPTargetOrder *orderParameters = nil;
    ACPTargetParameters *targetParameters = nil;
    ACPTargetProduct *productParameter = nil;
    ACPTargetOrder *orderLocParameters = nil;
    ACPTargetParameters *targetLocParameters = nil;
    ACPTargetProduct *productLocParameter = nil;
    for(id key in locationRequests){
        NSDictionary *request =[locationRequests objectForKey:key];
        NSString *mboxName = [request objectForKey:@"mboxName"];
        if([[request objectForKey:@"mboxParameter"] count] > 0){
            mboxParam = [request objectForKey:@"mboxParameter"];            
        }
        if([[request objectForKey:@"profileParameter"] count] > 0){
            profileParam = [request objectForKey:@"profileParameter"];         
        }
        
        if([[request objectForKey:@"orderParameter"] count] > 0){
            orderParam = [request objectForKey:@"orderParameter"];
            if([orderParam objectForKey:@"orderId"] != nil){
                NSString *orderId = [orderParam objectForKey:@"orderId"];
                NSNumber *orderTotal = [orderParam objectForKey:@"orderTotal"];
                NSArray *orderPurchasedIds = [orderParam objectForKey:@"orderPurchasedIds"];
                orderParameters = [ACPTargetOrder targetOrderWithId:orderId total:orderTotal purchasedProductIds:orderPurchasedIds];
            }
          
        }

        if([[request objectForKey:@"productParameter"] count] > 0){
            productParam = [request objectForKey:@"productParameter"];
            if([productParam objectForKey:@"id"]  != nil){
              NSString *id = [productParam objectForKey:@"id"];
              NSString *categoryIdValue = [productParam objectForKey:@"categoryId"];
              productParameter = [ACPTargetProduct targetProductWithId:id categoryId:categoryIdValue];
            }
        }


        targetParameters = [ACPTargetParameters targetParametersWithParameters:mboxParam
            profileParameters:profileParam
            product:productParameter
            order:orderParameters];
            
        ACPTargetRequestObject *requestObject = [ACPTargetRequestObject targetRequestObjectWithName:mboxName targetParameters:targetParameters
            defaultContent:@"defaultContent" callback:^(NSString * _Nullable content) {
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
            
        [requestArray addObject:requestObject];
        
    }
    
    
    NSDictionary *requestLoc = (NSDictionary *)command.arguments[1];
    
    if([[requestLoc objectForKey:@"mboxParameter"] count] > 0){
        mboxLocParam = [requestLoc objectForKey:@"mboxParameter"];
        
    }
    if([[requestLoc objectForKey:@"profileParameter"] count] > 0){
        profileLocParam = [requestLoc objectForKey:@"profileParameter"];
        
    }
  
    if([[requestLoc objectForKey:@"orderParameter"] count] > 0){
        orderLocParam = [requestLoc objectForKey:@"orderParameter"];
        if([orderLocParam objectForKey:@"orderId"]  != nil){
            NSString *orderId = [orderLocParam objectForKey:@"orderId"];
            NSNumber *orderTotal = [orderLocParam objectForKey:@"orderTotal"];
            NSArray *orderPurchasedIds = [orderLocParam objectForKey:@"orderPurchasedIds"];
            orderLocParameters = [ACPTargetOrder targetOrderWithId:orderId total:orderTotal purchasedProductIds:orderPurchasedIds];
        }
       
    }

    if([[requestLoc objectForKey:@"productParameter"] count] > 0){
        productLocParam = [requestLoc objectForKey:@"productParameter"];
        if([productLocParam objectForKey:@"id"]  != nil){
          NSString *id = [productLocParam objectForKey:@"id"];
          NSString *categoryIdValue = [productLocParam objectForKey:@"categoryId"];
          productLocParameter = [ACPTargetProduct targetProductWithId:id categoryId:categoryIdValue];
        }
        
    }
    
    targetLocParameters = [ACPTargetParameters targetParametersWithParameters:mboxLocParam
                                                    profileParameters:profileLocParam
                                                              product:productLocParameter
                                                                order:orderLocParameters];
                                                                
    [ACPTarget retrieveLocationContent:requestArray withParameters:targetLocParameters];

  }];
}

- (void) locationClicked:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
    
        NSString *mboxName = [self getCommandArg:command.arguments[0]];
        NSDictionary *request = [self getCommandArg:command.arguments[1]];
        NSDictionary *profileParam;
        NSDictionary *mboxParam;
        NSDictionary *orderParam;
        NSDictionary *productParam;
        ACPTargetOrder *orderParameters = nil;
        ACPTargetParameters *targetParameters = nil;
        ACPTargetProduct *productParameter = nil;
        
      
        if([[request objectForKey:@"mboxParameter"] count] > 0){
            mboxParam = [request objectForKey:@"mboxParameter"];
        }
        if([[request objectForKey:@"profileParameter"] count] > 0){
            profileParam = [request objectForKey:@"profileParameter"];
        }
      
        if([[request objectForKey:@"orderParameter"] count] > 0){
            orderParam = [request objectForKey:@"orderParameter"];
            if([orderParam objectForKey:@"orderId"] != nil){
                NSString *orderId = [orderParam objectForKey:@"orderId"];
                NSNumber *orderTotal = [orderParam objectForKey:@"orderTotal"];
                NSArray *orderPurchasedIds = [orderParam objectForKey:@"orderPurchasedIds"];
                orderParameters = [ACPTargetOrder targetOrderWithId:orderId total:orderTotal purchasedProductIds:orderPurchasedIds];
            }
        }
        
        if([[request objectForKey:@"productParameter"] count] > 0){
            productParam = [request objectForKey:@"productParameter"];
            if([productParam objectForKey:@"id"]  != nil){
              NSString *id = [productParam objectForKey:@"id"];
              NSString *categoryIdValue = [productParam objectForKey:@"categoryId"];
              productParameter = [ACPTargetProduct targetProductWithId:id categoryId:categoryIdValue];
            }
        }
        
        targetParameters = [ACPTargetParameters targetParametersWithParameters:mboxParam
            profileParameters:profileParam
            product:productParameter
            order:orderParameters];
                                                                
        [ACPTarget locationClickedWithName:mboxName targetParameters:targetParameters];
        
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void) locationsDisplayed:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        NSArray *mboxLists = [self getCommandArg:command.arguments[0]];
        NSDictionary *request = [self getCommandArg:command.arguments[1]];
        NSDictionary *profileParam;
        NSDictionary *mboxParam;
        NSDictionary *orderParam;
        NSDictionary *productParam;
        ACPTargetOrder *orderParameters = nil;
        ACPTargetParameters *targetParameters = nil;
        ACPTargetProduct *productParameter = nil;
        

        
        if([[request objectForKey:@"mboxParameter"] count] > 0){
            mboxParam = [request objectForKey:@"mboxParameter"];
        }
        if([[request objectForKey:@"profileParameter"] count] > 0){
            profileParam = [request objectForKey:@"profileParameter"];
        }
      
        if([[request objectForKey:@"orderParameter"] count] > 0){
            orderParam = [request objectForKey:@"orderParameter"];
            if([orderParam objectForKey:@"orderId"] != nil){
                NSString *orderId = [orderParam objectForKey:@"orderId"];
                NSNumber *orderTotal = [orderParam objectForKey:@"orderTotal"];
                NSArray *orderPurchasedIds = [orderParam objectForKey:@"orderPurchasedIds"];
                orderParameters = [ACPTargetOrder targetOrderWithId:orderId total:orderTotal purchasedProductIds:orderPurchasedIds];
            }
        }
        
        if([[request objectForKey:@"productParameter"] count] > 0){
            productParam = [request objectForKey:@"productParameter"];
            if([productParam objectForKey:@"id"]  != nil){
              NSString *id = [productParam objectForKey:@"id"];
              NSString *categoryIdValue = [productParam objectForKey:@"categoryId"];
              productParameter = [ACPTargetProduct targetProductWithId:id categoryId:categoryIdValue];
            }
        }
        
        targetParameters = [ACPTargetParameters targetParametersWithParameters:mboxParam
            profileParameters:profileParam
            product:productParameter
            order:orderParameters];
        
        
        [ACPTarget locationsDisplayed:mboxLists withTargetParameters:targetParameters];
        
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void) prefetchContent:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        NSError *error;
        NSDictionary *locationRequests = (NSDictionary *)command.arguments[0];
        NSMutableArray *requestArray = [NSMutableArray array];
        NSDictionary *profileParam;
        NSDictionary *mboxParam;
        NSDictionary *orderParam;
        NSDictionary *productParam;
        NSDictionary *profileLocParam;
        NSDictionary *mboxLocParam;
        NSDictionary *orderLocParam;
        NSDictionary *productLocParam;
        ACPTargetOrder *orderParameters = nil;
        ACPTargetParameters *targetParameters = nil;
        ACPTargetProduct *productParameter = nil;
        ACPTargetOrder *orderLocParameters = nil;
        ACPTargetParameters *targetLocParameters = nil;
        ACPTargetProduct *productLocParameter = nil;
        for(id key in locationRequests){
            NSDictionary *request =[locationRequests objectForKey:key];
            NSString *mboxName = [request objectForKey:@"mboxName"];
            if([[request objectForKey:@"mboxParameter"] count] > 0){
                mboxParam = [request objectForKey:@"mboxParameter"];
            }
            if([[request objectForKey:@"profileParameter"] count] > 0){
                profileParam = [request objectForKey:@"profileParameter"];
            }
          
            if([[request objectForKey:@"orderParameter"] count] > 0){
                orderParam = [request objectForKey:@"orderParameter"];
                if([orderParam objectForKey:@"orderId"] != nil){
                    NSString *orderId = [orderParam objectForKey:@"orderId"];
                    NSNumber *orderTotal = [orderParam objectForKey:@"orderTotal"];
                    NSArray *orderPurchasedIds = [orderParam objectForKey:@"orderPurchasedIds"];
                    orderParameters = [ACPTargetOrder targetOrderWithId:orderId total:orderTotal purchasedProductIds:orderPurchasedIds];
                }
            }

            if([[request objectForKey:@"productParameter"] count] > 0){
                productParam = [request objectForKey:@"productParameter"];
                if([productParam objectForKey:@"id"]  != nil){
                  NSString *id = [productParam objectForKey:@"id"];
                  NSString *categoryIdValue = [productParam objectForKey:@"categoryId"];
                  productParameter = [ACPTargetProduct targetProductWithId:id categoryId:categoryIdValue];
                }
            }


            targetParameters = [ACPTargetParameters targetParametersWithParameters:mboxParam
                profileParameters:profileParam
                product:productParameter
                order:orderParameters];
            
            ACPTargetPrefetchObject *requestObject = [ACPTargetPrefetchObject targetPrefetchObjectWithName:mboxName
                targetParameters:targetParameters];
                
            [requestArray addObject:requestObject];
        }
        
        
        NSDictionary *requestLoc = (NSDictionary *)command.arguments[1];
        
        
        if([[requestLoc objectForKey:@"mboxParameter"] count] > 0){
            mboxLocParam = [requestLoc objectForKey:@"mboxParameter"];
        }
        if([[requestLoc objectForKey:@"profileParameter"] count] > 0){
            profileLocParam = [requestLoc objectForKey:@"profileParameter"];
        }
      
        if([[requestLoc objectForKey:@"orderParameter"] count] > 0){
            orderLocParam = [requestLoc objectForKey:@"orderParameter"];
            if([orderLocParam objectForKey:@"orderId"]  != nil){
                NSString *orderId = [orderLocParam objectForKey:@"orderId"];
                NSNumber *orderTotal = [orderLocParam objectForKey:@"orderTotal"];
                NSArray *orderPurchasedIds = [orderLocParam objectForKey:@"orderPurchasedIds"];
                orderLocParameters = [ACPTargetOrder targetOrderWithId:orderId total:orderTotal purchasedProductIds:orderPurchasedIds];
            }
        }

        if([[requestLoc objectForKey:@"productParameter"] count] > 0){
            productLocParam = [requestLoc objectForKey:@"productParameter"];
            if([productLocParam objectForKey:@"id"]  != nil){
              NSString *id = [productLocParam objectForKey:@"id"];
              NSString *categoryIdValue = [productLocParam objectForKey:@"categoryId"];
              productLocParameter = [ACPTargetProduct targetProductWithId:id categoryId:categoryIdValue];
            }
        }
        
        targetLocParameters = [ACPTargetParameters targetParametersWithParameters:mboxLocParam
                                                        profileParameters:profileLocParam
                                                                  product:productLocParameter
                                                                    order:orderLocParameters];
                                                                    
        [ACPTarget prefetchContent:requestArray withParameters:targetLocParameters callback:^(NSError * _Nullable error) {
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
        
        

      }];
}

/*
 * Helper functions
 */

- (id) getCommandArg:(id) argument {
    return argument == (id)[NSNull null] ? nil : argument;
}

@end
