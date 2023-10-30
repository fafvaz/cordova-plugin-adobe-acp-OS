import ACPCore

@objc(ACPSignal_Cordova) class ACPSignal_Cordova: CDVPlugin {

  @objc(extensionVersion:)
  func extensionVersion(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      let version: String! = ACPSignal.extensionVersion()

      let pluginResult: CDVPluginResult! = CDVPluginResult(
        status: CDVCommandStatus_OK, messageAs: version)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }
}
