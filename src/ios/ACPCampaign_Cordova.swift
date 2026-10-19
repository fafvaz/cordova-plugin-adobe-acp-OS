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

        // Register the push identifier (device token).
        // AEPCore signature is MobileCore.setPushIdentifier(_ deviceToken: Data):
        // no argument label, and it expects the raw token bytes.
        if let tokenData = ACPCampaign_Cordova.pushTokenData(from: deviceToken) {
            MobileCore.setPushIdentifier(tokenData)
        } else {
            NSLog("setPushIdentifier: empty device token, skipping push registration.")
        }

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
        if let typeId = self.typeId, !typeId.isEmpty,
           let emailValue = (command.arguments[1] as? String) {
            contextData[typeId] = emailValue
        }

        // Store contextData for later use by push notification handlers
        // (same pattern as Android: contextData is sent when handling push, not at registration)
        ACPCampaign_Cordova.sendPushTrackingContextData(contextData)

        // Register the push identifier (device token).
        // AEPCore signature is MobileCore.setPushIdentifier(_ deviceToken: Data):
        // no argument label, and it expects the raw token bytes.
        if let tokenData = ACPCampaign_Cordova.pushTokenData(from: deviceToken) {
            MobileCore.setPushIdentifier(tokenData)
        } else {
            NSLog("loadAdobe: empty device token, skipping push registration.")
        }

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

  /// Converts the push device token received from JavaScript into the `Data`
  /// expected by `MobileCore.setPushIdentifier(_:)`.
  ///
  /// * APNs-style hex tokens (optionally wrapped in `<>` or containing spaces)
  ///   are decoded into their raw bytes, which is what the Adobe SDK expects.
  /// * Tokens in any other format (e.g. an opaque FCM registration token) are
  ///   forwarded as UTF-8 bytes, mirroring the Android SDK which accepts the
  ///   raw token string.
  /// * Returns `nil` when the token is empty or missing.
  static func pushTokenData(from token: String) -> Data? {
    let trimmed = token.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return nil }

    let hex = trimmed
        .replacingOccurrences(of: "<", with: "")
        .replacingOccurrences(of: ">", with: "")
        .replacingOccurrences(of: " ", with: "")

    if hex.count % 2 == 0,
       hex.range(of: "^[0-9a-fA-F]+$", options: .regularExpression) != nil {
        var bytes = [UInt8]()
        bytes.reserveCapacity(hex.count / 2)
        var index = hex.startIndex
        while index < hex.endIndex {
            let next = hex.index(index, offsetBy: 2)
            if let byte = UInt8(hex[index..<next], radix: 16) {
                bytes.append(byte)
            }
            index = next
        }
        return Data(bytes)
    }

    return trimmed.data(using: .utf8)
  }

  func getTypeId(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      let pluginResult: CDVPluginResult! = CDVPluginResult(
        status: CDVCommandStatus_OK, messageAs: self.typeId)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }
}
