import ACPAnalytics

@objc(ACPAnalytics_Cordova) class ACPAnalytics_Cordova: CDVPlugin {

  @objc(extensionVersion:)
  func extensionVersion(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      var pluginResult: CDVPluginResult! = nil
      let extensionVersion: String! = ACPAnalytics.extensionVersion()

      if extensionVersion != nil && extensionVersion.count > 0 {
        pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: extensionVersion)
      } else {
        pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
      }

      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(sendQueuedHits:)
  func sendQueuedHits(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      ACPAnalytics.sendQueuedHits()
      let pluginResult: CDVPluginResult! = CDVPluginResult(status: CDVCommandStatus_OK)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(clearQueue:)
  func clearQueue(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      ACPAnalytics.clearQueue()
      let pluginResult: CDVPluginResult! = CDVPluginResult(status: CDVCommandStatus_OK)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(getQueueSize:)
  func getQueueSize(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      ACPAnalytics.getQueueSize({ (queueSize: UInt) in
        let pluginResult: CDVPluginResult! = CDVPluginResult(
          status: CDVCommandStatus_OK, messageAs: String(format: "%@", queueSize))
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
      })
    })
  }

  @objc(getTrackingIdentifier:)
  func getTrackingIdentifier(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      ACPAnalytics.getTrackingIdentifier({ (trackingIdentifier: String?) in
        let pluginResult: CDVPluginResult! = CDVPluginResult(
          status: CDVCommandStatus_OK, messageAs: trackingIdentifier)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
      })
    })
  }

  @objc(getVisitorIdentifier:)
  func getVisitorIdentifier(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      ACPAnalytics.getVisitorIdentifier({ (visitorIdentifier: String?) in
        let pluginResult: CDVPluginResult! = CDVPluginResult(
          status: CDVCommandStatus_OK, messageAs: visitorIdentifier)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
      })
    })
  }

  @objc(setVisitorIdentifier:)
  func setVisitorIdentifier(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      let vid: String! = command.arguments[0] as? String
      ACPAnalytics.setVisitorIdentifier(vid)
      let pluginResult: CDVPluginResult! = CDVPluginResult(status: CDVCommandStatus_OK)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }
}
