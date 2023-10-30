import ACPPlacesMonitor

@objc(ACPPlacesMonitor_Cordova) class ACPPlacesMonitor_Cordova: CDVPlugin {

  @objc(extensionVersion:)
  func extensionVersion(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      var pluginResult: CDVPluginResult! = nil
      let extensionVersion: String! = ACPPlacesMonitor.extensionVersion()

      if extensionVersion != nil && extensionVersion.count > 0 {
        pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: extensionVersion)
      } else {
        pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
      }

      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(start:)
  func start(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      ACPPlacesMonitor.start()
      let pluginResult: CDVPluginResult! = CDVPluginResult(status: CDVCommandStatus_OK)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(stop:)
  func stop(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      let shouldClearPlacesData: Bool = command.arguments[0] as? Bool ?? false
      ACPPlacesMonitor.stop(shouldClearPlacesData)
      let pluginResult: CDVPluginResult! = CDVPluginResult(status: CDVCommandStatus_OK)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(updateLocation:)
  func updateLocation(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      ACPPlacesMonitor.updateLocationNow()
      let pluginResult: CDVPluginResult! = CDVPluginResult(status: CDVCommandStatus_OK)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(setRequestLocationPermission:)
  func setRequestLocationPermission(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      let authorizationLevel: ACPPlacesMonitorRequestAuthorizationLevel =
        self.convertToAuthorizationLevel(authorization: command.arguments[0] as? Int ?? 0)
      ACPPlacesMonitor.setRequestAuthorizationLevel(authorizationLevel)
      let pluginResult: CDVPluginResult! = CDVPluginResult(status: CDVCommandStatus_OK)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(setPlacesMonitorMode:)
  func setPlacesMonitorMode(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      let mode: ACPPlacesMonitorMode = self.convertToMonitorMode(
        monitorMode: command.arguments[0] as? Int ?? 0)
      ACPPlacesMonitor.setPlacesMonitorMode(mode)
      let pluginResult: CDVPluginResult! = CDVPluginResult(status: CDVCommandStatus_OK)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  /*
     * Helper functions
     */

  func convertToAuthorizationLevel(authorization: Int!) -> ACPPlacesMonitorRequestAuthorizationLevel
  {
    if authorization == 1 {
      return ACPPlacesMonitorRequestAuthorizationLevel.requestMonitorAuthorizationLevelAlways
    } else {
      return ACPPlacesMonitorRequestAuthorizationLevel.monitorRequestAuthorizationLevelWhenInUse
    }
  }

  func convertToMonitorMode(monitorMode: Int!) -> ACPPlacesMonitorMode {
    if monitorMode == 1 {
      return ACPPlacesMonitorMode.significantChanges
    } else {
      return ACPPlacesMonitorMode.continuous
    }
  }
}
