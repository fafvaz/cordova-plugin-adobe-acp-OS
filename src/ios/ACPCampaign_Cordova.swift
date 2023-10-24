import ACPCampaign
import ACPCore
import UserNotifications

@objc(ACPCampaign_Cordova) class ACPCampaign_Cordova: CDVPlugin, UNUserNotificationCenterDelegate {

  var typeId: String!

  @objc(extensionVersion:)
  func extensionVersion(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      var pluginResult: CDVPluginResult! = nil
      let extensionVersion: String! = ACPCampaign.extensionVersion()

      if extensionVersion != nil && extensionVersion.count > 0 {
        pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: extensionVersion)
      } else {
        pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
      }

      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(setPushIdentifier:)
  func setPushIdentifier(command: CDVInvokedUrlCommand!) {

    let center: UNUserNotificationCenter! = UNUserNotificationCenter.current()
    center.delegate = self

    center.requestAuthorization(
      options: [.sound, .alert, .badge],
      completionHandler: {
        granted, error in

        self.typeId = Bundle.main.object(forInfoDictionaryKey: "TypeId") as? String

        if error != nil {

          DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {  // in half a second...
            let _: String! = command.arguments[0] as? String
            let valueTypeId: String! = command.arguments[1] as? String

            ACPCore.collectPii([self.typeId: valueTypeId])
            UIApplication.shared.registerForRemoteNotifications()
          }

          NSLog("Push registration success.")

        } else {
          NSLog("Push registration FAILED")
          NSLog("ERROR: %@ " + (error?.localizedDescription ?? ""))
        }
      })

    ACPCore.setLogLevel(.debug)
    let pluginResult: CDVPluginResult! = CDVPluginResult(status: CDVCommandStatus_OK)
    self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
  }

  func getTypeId(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      let pluginResult: CDVPluginResult! = CDVPluginResult(
        status: CDVCommandStatus_OK, messageAs: self.typeId)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }
}
