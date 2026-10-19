import AEPCampaign
import AEPCore
import UserNotifications

@objc(ACPCampaign_Cordova) class ACPCampaign_Cordova: CDVPlugin {

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

    guard command.arguments.count >= 2,
          let deviceToken = command.arguments[0] as? String,
          !deviceToken.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
          let emailAddress = command.arguments[1] as? String,
          !emailAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
        let pluginResult = CDVPluginResult(
            status: CDVCommandStatus_ERROR,
            messageAs: "setPushIdentifier requires a non-empty device token and email address")
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        return
    }

    collectPiiData(from: command, emailAddress: emailAddress)

    let center: UNUserNotificationCenter! = UNUserNotificationCenter.current()
    // NOTE: do NOT set center.delegate here - the Firebase plugin must remain the
    // UNUserNotificationCenter delegate; its handlers post the dispatch notifications
    // that drive push tracking (impression/click/open) in ACPAppDelegatePush, and
    // stealing the delegate would silently disable ALL push tracking.

    center.requestAuthorization(
      options: [.sound, .alert, .badge],
      completionHandler: {
        granted, error in

        self.typeId = (Bundle.main.object(forInfoDictionaryKey: "TypeId") as? String)
            // Fallback to the TYPE_ID config.xml preference injected by plugin.xml,
            // then the plugin default, for getTypeId callers.
            ?? (self.commandDelegate.settings["TYPE_ID"] as? String)
            ?? "fiscalnumber"

        guard error == nil && granted else {
            NSLog("Push registration FAILED: %@", error?.localizedDescription ?? "user denied")
            let pluginResult = CDVPluginResult(
                status: CDVCommandStatus_ERROR,
                messageAs: "Push authorization not granted")
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            return
        }

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

    guard command.arguments.count >= 2,
          let deviceToken = command.arguments[0] as? String,
          !deviceToken.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
          let emailAddress = command.arguments[1] as? String,
          !emailAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
        let pluginResult = CDVPluginResult(
            status: CDVCommandStatus_ERROR,
            messageAs: "loadAdobe requires a non-empty device token and email address")
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        return
    }

    collectPiiData(from: command, emailAddress: emailAddress)

    let center: UNUserNotificationCenter! = UNUserNotificationCenter.current()
    // NOTE: do NOT set center.delegate here - see setPushIdentifier above.

    center.requestAuthorization(
      options: [.sound, .alert, .badge],
      completionHandler: {
        granted, error in

        self.typeId = (Bundle.main.object(forInfoDictionaryKey: "TypeId") as? String)
            ?? (self.commandDelegate.settings["TYPE_ID"] as? String)
            ?? "fiscalnumber"

        guard error == nil && granted else {
            NSLog("Push registration FAILED: %@", error?.localizedDescription ?? "user denied")
            let pluginResult = CDVPluginResult(
                status: CDVCommandStatus_ERROR,
                messageAs: "Push authorization not granted")
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            return
        }

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

  private func collectPiiData(from command: CDVInvokedUrlCommand!, emailAddress: String) {
    var contextData: [String: Any] = [:]
    if command.arguments.count >= 3, let data = command.arguments[2] as? [String: Any] {
      contextData = data
    }
    contextData["emailaddress"] = emailAddress
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
