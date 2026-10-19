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
            let pluginResult = CDVPluginResult(
                status: CDVCommandStatus_ERROR,
                messageAs: "Push authorization not granted")
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            return
        }

        let deviceToken = (command.arguments[0] as? String) ?? ""

        // Build contextData: start with any user-provided data from arguments[2]
        var contextData: [String: Any] = [:]
        if command.arguments.count >= 3 {
            if let data = command.arguments[2] as? [String: Any] {
                contextData = data
            }
        }

        // Read email from typeId parameter (arguments[1]) and add to contextData
        // self.typeId is the key name (e.g. "emailAddress") from Info.plist
        if let typeId = self.typeId, !typeId.isEmpty,
           let emailValue = (command.arguments[1] as? String) {
            contextData[typeId] = emailValue
        }

        // Store contextData for later use by push notification handlers
        // (same pattern as Android: contextData is sent when handling push, not at registration)
        ACPCampaign_Cordova.sendPushTrackingContextData(contextData)

        // Register the push identifier (device token)
        MobileCore.setPushIdentifier(identifier: deviceToken)

        NSLog("Push registration success.")

        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
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

        let deviceToken = (command.arguments[0] as? String) ?? ""

        // Build contextData: start with any user-provided data from arguments[2]
        var contextData: [String: Any] = [:]
        if command.arguments.count >= 3 {
            if let data = command.arguments[2] as? [String: Any] {
                contextData = data
            }
        }

        // Read email from typeId parameter (arguments[1]) and add to contextData
        if let typeId = self.typeId, !typeId.isEmpty,
           let emailValue = (command.arguments[1] as? String) {
            contextData[typeId] = emailValue
        }

        // Store contextData for later use by push notification handlers
        // (same pattern as Android: contextData is sent when handling push, not at registration)
        ACPCampaign_Cordova.sendPushTrackingContextData(contextData)

        // Register the push identifier (device token)
        MobileCore.setPushIdentifier(identifier: deviceToken)

        NSLog("Push registration success.")

        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
      })
  }

  static func sendPushTrackingContextData(_ contextData: [String: Any]) {
    // Store contextData for later use by push notification handlers.
    // This mirrors the Android pattern where contextData is sent when handling
    // push notifications (via collectMessageInfo), not just at registration time.
    //
    // NOTE: In iOS, we also send contextData directly via collectMessageInfo here
    // to mirror Android's behavior of sending contextData with push tracking.
    MobileCore.collectPii(contextData)
  }

  func getTypeId(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      let pluginResult: CDVPluginResult! = CDVPluginResult(
        status: CDVCommandStatus_OK, messageAs: self.typeId)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }
}
