import ACPTarget

@objc(ACPTarget_Cordova) class ACPTarget_Cordova: CDVPlugin {

  @objc(clearPrefetchCache:)
  func clearPrefetchCache(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      ACPTarget.clearPrefetchCache()
      let pluginResult: CDVPluginResult! = CDVPluginResult(status: CDVCommandStatus_OK)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(extensionVersion:)
  func extensionVersion(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      var pluginResult: CDVPluginResult! = nil
      let extensionVersion: String! = ACPTarget.extensionVersion()

      if extensionVersion != nil && extensionVersion.count > 0 {
        pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: extensionVersion)
      } else {
        pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
      }

      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(getThirdPartyId:)
  func getThirdPartyId(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      ACPTarget.getThirdPartyId({ (thirdPartyId: String?) in
        let pluginResult: CDVPluginResult! = CDVPluginResult(
          status: CDVCommandStatus_OK, messageAs: thirdPartyId)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
      })
    })
  }

  @objc(getTntId:)
  func getTntId(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      ACPTarget.getTntId({ (tntId: String?) in
        let pluginResult: CDVPluginResult! = CDVPluginResult(
          status: CDVCommandStatus_OK, messageAs: tntId)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
      })
    })
  }

  @objc(resetExperience:)
  func resetExperience(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      ACPTarget.resetExperience()
      let pluginResult: CDVPluginResult! = CDVPluginResult(status: CDVCommandStatus_OK)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(setThirdPartyId:)
  func setThirdPartyId(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      let thirdPartyId: String! = command.arguments[0] as? String

      ACPTarget.setThirdPartyId(thirdPartyId)

      let pluginResult: CDVPluginResult! = CDVPluginResult(status: CDVCommandStatus_OK)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(setPreviewRestartDeepLink:)
  func setPreviewRestartDeepLink(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {

      guard let deepLink = URL(string: command.arguments[0] as! String) else {
        self.commandDelegate.send(
          CDVPluginResult(
            status: CDVCommandStatus_ERROR,
            messageAs: "Unable setPreviewRestartDeepLink. Input was malformed"),
          callbackId: command.callbackId)
        return
      }

      ACPTarget.setPreviewRestartDeeplink(deepLink)

      let pluginResult: CDVPluginResult! = CDVPluginResult(status: CDVCommandStatus_OK)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(retrieveLocationContent:)
  func retrieveLocationContent(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      let locationRequests: NSDictionary! = command.arguments[0] as? NSDictionary
      let requestArray: NSMutableArray! = NSMutableArray.init()
      var profileParam: NSDictionary!
      var mboxParam: NSDictionary!
      var orderParam: NSDictionary!
      var productParam: NSDictionary!
      var profileLocParam: NSDictionary!
      var mboxLocParam: NSDictionary!
      var orderLocParam: NSDictionary!
      var productLocParam: NSDictionary!
      var orderParameters: ACPTargetOrder! = nil
      var targetParameters: ACPTargetParameters! = nil
      var productParameter: ACPTargetProduct! = nil
      var orderLocParameters: ACPTargetOrder! = nil
      var targetLocParameters: ACPTargetParameters! = nil
      var productLocParameter: ACPTargetProduct! = nil

      locationRequests.forEach({ (key: Any, value: Any) in
        let request: NSDictionary! = value as? NSDictionary
        let mboxName: String! = request.object(forKey: "mboxName") as? String

        if request.object(forKey: "mboxParameter") != nil {
          mboxParam = request.object(forKey: "mboxParameter") as? NSDictionary
        }

        if request.object(forKey: "profileParameter") != nil {
          profileParam = request.object(forKey: "profileParameter") as? NSDictionary
        }

        if request.object(forKey: "orderParameter") != nil {
          orderParam = request.object(forKey: "orderParameter") as? NSDictionary
          if orderParam.object(forKey: "orderId") != nil {
            let orderId: String! = orderParam.object(forKey: "orderId") as? String
            let orderTotal: NSNumber! = orderParam.object(forKey: "orderTotal") as? NSNumber
            let orderPurchasedIds: [String]! =
              orderParam.object(forKey: "orderPurchasedIds") as? [String]
            orderParameters = ACPTargetOrder(
              id: orderId, total: orderTotal, purchasedProductIds: orderPurchasedIds)
          }
        }

        if request.object(forKey: "productParameter") != nil {
          productParam = request.object(forKey: "productParameter") as? NSDictionary
          if productParam.object(forKey: "id") != nil {
            let id: String! = productParam.object(forKey: "id") as? String
            let categoryIdValue: String! = productParam.object(forKey: "categoryId") as? String
            productParameter = ACPTargetProduct(id: id, categoryId: categoryIdValue)
          }
        }

        targetParameters = ACPTargetParameters(
          parameters: mboxParam as? [AnyHashable: Any],
          profileParameters: profileParam as? [AnyHashable: Any],
          product: productParameter,
          order: orderParameters)

        let requestObject: ACPTargetRequestObject! = ACPTargetRequestObject(
          name: mboxName, targetParameters: targetParameters,
          defaultContent: "defaultContent",
          callback: { (content: String?) in
            let pluginResult: CDVPluginResult! = CDVPluginResult(status: CDVCommandStatus_OK)
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
          })

        requestArray.add(requestObject)
      })

      let requestLoc: NSDictionary! = command.arguments[1] as? NSDictionary

      if requestLoc.object(forKey: "mboxParameter") != nil {
        mboxLocParam = requestLoc.object(forKey: "mboxParameter") as? NSDictionary
      }

      if requestLoc.object(forKey: "profileParameter") != nil {
        profileLocParam = requestLoc.object(forKey: "profileParameter") as? NSDictionary
      }

      if requestLoc.object(forKey: "orderParameter") != nil {
        orderLocParam = requestLoc.object(forKey: "orderParameter") as? NSDictionary
        if orderLocParam.object(forKey: "orderId") != nil {
          let orderId: String! = orderLocParam.object(forKey: "orderId") as? String
          let orderTotal: NSNumber! = orderLocParam.object(forKey: "orderTotal") as? NSNumber
          let orderPurchasedIds: [String]! =
            orderLocParam.object(forKey: "orderPurchasedIds") as? [String]
          orderLocParameters = ACPTargetOrder(
            id: orderId, total: orderTotal, purchasedProductIds: orderPurchasedIds)
        }

      }

      if requestLoc.object(forKey: "productParameter") != nil {
        productLocParam = requestLoc.object(forKey: "productParameter") as? NSDictionary
        if productLocParam.object(forKey: "id") != nil {
          let id: String! = productLocParam.object(forKey: "id") as? String
          let categoryIdValue: String! = productLocParam.object(forKey: "categoryId") as? String
          productLocParameter = ACPTargetProduct(id: id, categoryId: categoryIdValue)
        }

      }

      targetLocParameters = ACPTargetParameters(
        parameters: mboxLocParam as? [AnyHashable: Any],
        profileParameters: profileLocParam as? [AnyHashable: Any],
        product: productLocParameter,
        order: orderLocParameters)

      ACPTarget.retrieveLocationContent(
        requestArray as! [ACPTargetRequestObject], with: targetLocParameters)

    })
  }

  @objc(locationClicked:)
  func locationClicked(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {

      let mboxName: String! = command.arguments[0] as? String
      let request: NSDictionary! = command.arguments[1] as? NSDictionary
      var profileParam: NSDictionary!
      var mboxParam: NSDictionary!
      var orderParam: NSDictionary!
      var productParam: NSDictionary!
      var orderParameters: ACPTargetOrder! = nil
      var targetParameters: ACPTargetParameters! = nil
      var productParameter: ACPTargetProduct! = nil

      if request.object(forKey: "mboxParameter") != nil {
        mboxParam = request.object(forKey: "mboxParameter") as? NSDictionary
      }
      if request.object(forKey: "profileParameter") != nil {
        profileParam = request.object(forKey: "profileParameter") as? NSDictionary
      }

      if request.object(forKey: "orderParameter") != nil {
        orderParam = request.object(forKey: "orderParameter") as? NSDictionary
        if orderParam.object(forKey: "orderId") != nil {
          let orderId: String! = orderParam.object(forKey: "orderId") as? String
          let orderTotal: NSNumber! = orderParam.object(forKey: "orderTotal") as? NSNumber
          let orderPurchasedIds: [String]! =
            orderParam.object(forKey: "orderPurchasedIds") as? [String]
          orderParameters = ACPTargetOrder(
            id: orderId, total: orderTotal, purchasedProductIds: orderPurchasedIds)
        }
      }

      if request.object(forKey: "productParameter") != nil {
        productParam = request.object(forKey: "productParameter") as? NSDictionary
        if productParam.object(forKey: "id") != nil {
          let id: String! = productParam.object(forKey: "id") as? String
          let categoryIdValue: String! = productParam.object(forKey: "categoryId") as? String
          productParameter = ACPTargetProduct(id: id, categoryId: categoryIdValue)
        }
      }

      targetParameters = ACPTargetParameters(
        parameters: mboxParam as? [AnyHashable: Any],
        profileParameters: profileParam as? [AnyHashable: Any],
        product: productParameter,
        order: orderParameters)

      ACPTarget.locationClicked(withName: mboxName, targetParameters: targetParameters)

      let pluginResult: CDVPluginResult! = CDVPluginResult(status: CDVCommandStatus_OK)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(locationsDisplayed:)
  func locationsDisplayed(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      let mboxLists: [String]! = command.arguments[0] as? [String]
      let request: NSDictionary! = command.arguments[1] as? NSDictionary
      var profileParam: NSDictionary!
      var mboxParam: NSDictionary!
      var orderParam: NSDictionary!
      var productParam: NSDictionary!
      var orderParameters: ACPTargetOrder! = nil
      var targetParameters: ACPTargetParameters! = nil
      var productParameter: ACPTargetProduct! = nil

      if request.object(forKey: "mboxParameter") != nil {
        mboxParam = request.object(forKey: "mboxParameter") as? NSDictionary
      }
      if request.object(forKey: "profileParameter") != nil {
        profileParam = request.object(forKey: "profileParameter") as? NSDictionary
      }

      if request.object(forKey: "orderParameter") != nil {
        orderParam = request.object(forKey: "orderParameter") as? NSDictionary
        if orderParam.object(forKey: "orderId") != nil {
          let orderId: String! = orderParam.object(forKey: "orderId") as? String
          let orderTotal: NSNumber! = orderParam.object(forKey: "orderTotal") as? NSNumber
          let orderPurchasedIds: [String]! =
            orderParam.object(forKey: "orderPurchasedIds") as? [String]
          orderParameters = ACPTargetOrder(
            id: orderId, total: orderTotal, purchasedProductIds: orderPurchasedIds)
        }
      }

      if request.object(forKey: "productParameter") != nil {
        productParam = request.object(forKey: "productParameter") as? NSDictionary
        if productParam.object(forKey: "id") != nil {
          let id: String! = productParam.object(forKey: "id") as? String
          let categoryIdValue: String! = productParam.object(forKey: "categoryId") as? String
          productParameter = ACPTargetProduct(id: id, categoryId: categoryIdValue)
        }
      }

      targetParameters = ACPTargetParameters(
        parameters: mboxParam as? [AnyHashable: Any],
        profileParameters: profileParam as? [AnyHashable: Any],
        product: productParameter,
        order: orderParameters)

      ACPTarget.locationsDisplayed(mboxLists, with: targetParameters)

      let pluginResult: CDVPluginResult! = CDVPluginResult(status: CDVCommandStatus_OK)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(prefetchContent:)
  func prefetchContent(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {

      let locationRequests: NSDictionary! = command.arguments[0] as? NSDictionary
      let requestArray: NSMutableArray! = NSMutableArray.init()
      var profileParam: NSDictionary!
      var mboxParam: NSDictionary!
      var orderParam: NSDictionary!
      var productParam: NSDictionary!
      var profileLocParam: NSDictionary!
      var mboxLocParam: NSDictionary!
      var orderLocParam: NSDictionary!
      var productLocParam: NSDictionary!
      var orderParameters: ACPTargetOrder! = nil
      var targetParameters: ACPTargetParameters! = nil
      var productParameter: ACPTargetProduct! = nil
      var orderLocParameters: ACPTargetOrder! = nil
      var targetLocParameters: ACPTargetParameters! = nil
      var productLocParameter: ACPTargetProduct! = nil

      locationRequests.forEach { (key: Any, valueObj: Any) in
        let request: NSDictionary! = valueObj as? NSDictionary
        let mboxName: String! = request.object(forKey: "mboxName") as? String

        if request.object(forKey: "mboxParameter") != nil {
          mboxParam = request.object(forKey: "mboxParameter") as? NSDictionary
        }
        if request.object(forKey: "profileParameter") != nil {
          profileParam = request.object(forKey: "profileParameter") as? NSDictionary
        }

        if request.object(forKey: "orderParameter") != nil {
          orderParam = request.object(forKey: "orderParameter") as? NSDictionary
          if orderParam.object(forKey: "orderId") != nil {
            let orderId: String! = orderParam.object(forKey: "orderId") as? String
            let orderTotal: NSNumber! = orderParam.object(forKey: "orderTotal") as? NSNumber
            let orderPurchasedIds: [String]! =
              orderParam.object(forKey: "orderPurchasedIds") as? [String]
            orderParameters = ACPTargetOrder(
              id: orderId, total: orderTotal, purchasedProductIds: orderPurchasedIds)
          }
        }

        if request.object(forKey: "productParameter") != nil {
          productParam = request.object(forKey: "productParameter") as? NSDictionary
          if productParam.object(forKey: "id") != nil {
            let id: String! = productParam.object(forKey: "id") as? String
            let categoryIdValue: String! = productParam.object(forKey: "categoryId") as? String
            productParameter = ACPTargetProduct(id: id, categoryId: categoryIdValue)
          }
        }

        targetParameters = ACPTargetParameters(
          parameters: mboxParam as? [AnyHashable: Any],
          profileParameters: profileParam as? [AnyHashable: Any],
          product: productParameter,
          order: orderParameters)

        let requestObject: ACPTargetPrefetchObject! = ACPTargetPrefetchObject(
          name: mboxName,
          targetParameters: targetParameters)

        requestArray.add(requestObject)

      }

      let requestLoc: NSDictionary! = command.arguments[1] as? NSDictionary

      if requestLoc.object(forKey: "mboxParameter") != nil {
        mboxLocParam = requestLoc.object(forKey: "mboxParameter") as? NSDictionary
      }
      if requestLoc.object(forKey: "profileParameter") != nil {
        profileLocParam = requestLoc.object(forKey: "profileParameter") as? NSDictionary
      }

      if requestLoc.object(forKey: "orderParameter") != nil {
        orderLocParam = requestLoc.object(forKey: "orderParameter") as? NSDictionary
        if orderLocParam.object(forKey: "orderId") != nil {
          let orderId: String! = orderLocParam.object(forKey: "orderId") as? String
          let orderTotal: NSNumber! = orderLocParam.object(forKey: "orderTotal") as? NSNumber
          let orderPurchasedIds: [String]! =
            orderLocParam.object(forKey: "orderPurchasedIds") as? [String]
          orderLocParameters = ACPTargetOrder(
            id: orderId, total: orderTotal, purchasedProductIds: orderPurchasedIds)
        }
      }

      if requestLoc.object(forKey: "productParameter") != nil {
        productLocParam = requestLoc.object(forKey: "productParameter") as? NSDictionary
        if productLocParam.object(forKey: "id") != nil {
          let id: String! = productLocParam.object(forKey: "id") as? String
          let categoryIdValue: String! = productLocParam.object(forKey: "categoryId") as? String
          productLocParameter = ACPTargetProduct(id: id, categoryId: categoryIdValue)
        }
      }

      targetLocParameters = ACPTargetParameters(
        parameters: mboxLocParam as? [AnyHashable: Any],
        profileParameters: profileLocParam as? [AnyHashable: Any],
        product: productLocParameter,
        order: orderLocParameters)

      ACPTarget.prefetchContent(
        requestArray as! [ACPTargetPrefetchObject], with: targetLocParameters,
        callback: { (error) in
          let pluginResult: CDVPluginResult! = CDVPluginResult(status: CDVCommandStatus_OK)
          self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        })

    })
  }
}
