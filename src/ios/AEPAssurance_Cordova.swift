import AEPAssurance

@objc(AEPAssurance_Cordova) class AEPAssurance_Cordova: CDVPlugin {

  @objc(extensionVersion:)
  func extensionVersion(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      var pluginResult: CDVPluginResult! = nil
      let extensionVersion: String! = AEPAssurance.extensionVersion()

      if extensionVersion != nil && extensionVersion.count > 0 {
        pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: extensionVersion)
      } else {
        pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
      }

      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(startSession:)
  func startSession(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      let url: URL! = URL.init(string: command.arguments[0] as! String)
      AEPAssurance.startSession(url)
      self.commandDelegate.send(nil, callbackId: command.callbackId)
    })
  }
}
