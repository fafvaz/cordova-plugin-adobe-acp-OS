import AEPCampaign
import AEPCore
import UserNotifications

@objc(ACPCampaign_Cordova) class ACPCampaign_Cordova: CDVPlugin, UNUserNotificationCenterDelegate {

  var typeId: String!

  @objc(extensionVersion:)
  func extensionVersion(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      var pluginResult: CDVPluginResult! = nil
      let extensionVersion: String! = Campaign.extensionVersion

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

    // Guard: require at least deviceToken and fiscalNumber
    guard command.arguments.count >= 2 else {
        let pluginResult = CDVPluginResult(
            status: CDVCommandStatus_ERROR,
            messageAs: "setPushIdentifier requires at least deviceToken and fiscalNumber")
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        return
    }

    let center: UNUserNotificationCenter! = UNUserNotificationCenter.current()
    center.delegate = self

    center.requestAuthorization(
      options: [.sound, .alert, .badge],
      completionHandler: {
        granted, error in

        self.typeId = Bundle.main.object(forInfoDictionaryKey: "TypeId") as? String

        guard error == nil && granted else {
            NSLog("Push registration FAILED: %@", error?.localizedDescription ?? "user denied")
            return
        }

        let deviceToken = (command.arguments[0] as? String) ?? ""
        let valueTypeId = (command.arguments[1] as? String) ?? ""
        MobileCore.setPushIdentifier(identifier: deviceToken)
              
        var contextData: [String: Any] = [:]
        if command.arguments.count >= 3,
           let data = command.arguments[2] as? [String: Any] {
            contextData = data
        }

        if let typeId = self.typeId, !typeId.isEmpty {
            contextData[typeId] = valueTypeId
        }

        MobileCore.collectPii(contextData)
        UIApplication.shared.registerForRemoteNotifications()

        NSLog("Push registration success.")
      })

  }

  @objc(loadAdobe:)
  func loadAdobe(command: CDVInvokedUrlCommand!) {

    guard command.arguments.count >= 2 else {
        let pluginResult = CDVPluginResult(
            status: CDVCommandStatus_ERROR,
            messageAs: "loadAdobe requires deviceToken and fiscalNumber")
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        return
    }

    let center: UNUserNotificationCenter! = UNUserNotificationCenter.current()
    center.delegate = self

    center.requestAuthorization(
      options: [.sound, .alert, .badge],
      completionHandler: {
        granted, error in

        guard error == nil && granted else {
            NSLog("Push registration FAILED: %@", error?.localizedDescription ?? "user denied")
            let pluginResult = CDVPluginResult(
                status: CDVCommandStatus_ERROR,
                messageAs: "Push authorization not granted")
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            return
        }

        self.typeId = Bundle.main.object(forInfoDictionaryKey: "TypeId") as? String

        let deviceToken = (command.arguments[0] as? String) ?? ""
        let valueTypeId = (command.arguments[1] as? String) ?? ""

        MobileCore.setPushIdentifier(identifier: deviceToken)

        var contextData: [String: Any] = [:]
        if let typeId = self.typeId, !typeId.isEmpty {
            contextData[typeId] = valueTypeId
        }

        MobileCore.collectPii(contextData)

        UIApplication.shared.registerForRemoteNotifications()

        NSLog("Push registration success.")

        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
      })
  }

  func getTypeId(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      let pluginResult: CDVPluginResult! = CDVPluginResult(
        status: CDVCommandStatus_OK, messageAs: self.typeId)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }
}
