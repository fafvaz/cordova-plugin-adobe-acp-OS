import ACPAnalytics
import ACPCampaign
import ACPCore
import ACPMobileServices
import ACPPlaces
import ACPPlacesMonitor
import ACPTarget
import ACPUserProfile
import AEPAssurance

@objc(ACPCampaign_Cordova) class ACPCore_Cordova: CDVPlugin {

  var appId: String!
  var initTime: String!

  @objc(dispatchEvent:)
  func dispatchEvent(command: CDVInvokedUrlCommand!) {

    self.commandDelegate.run(inBackground: {

      guard let eventInput = command.arguments[0] as? NSDictionary else {
        self.commandDelegate.send(
          CDVPluginResult(
            status: CDVCommandStatus_ERROR,
            messageAs: "Unable to dispatch event. Input was malformed"),
          callbackId: command.callbackId)
      }

      let event: ACPExtensionEvent! = self.getExtensionEventFromJavascriptObject(event: eventInput)

      do {
        try ACPCore.dispatchEvent(event)
        let pluginResult: CDVPluginResult! = CDVPluginResult(status: CDVCommandStatus_OK)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
      } catch let error {
        self.commandDelegate.send(
          CDVPluginResult(
            status: CDVCommandStatus_ERROR,
            messageAs: String(format: "Error dispatching event: %@", error.localizedDescription)),
          callbackId: command.callbackId)
      }

    })
  }

  @objc(dispatchEventWithResponseCallback:)
  func dispatchEventWithResponseCallback(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {

      guard let eventInput = command.arguments[0] as? NSDictionary else {
        self.commandDelegate.send(
          CDVPluginResult(
            status: CDVCommandStatus_ERROR,
            messageAs: "Unable to dispatch event. Input was malformed"),
          callbackId: command.callbackId)
      }

      let event: ACPExtensionEvent! = self.getExtensionEventFromJavascriptObject(event: eventInput)

      do {
        try ACPCore.dispatchEvent(
          withResponseCallback: event,
          responseCallback: { (response: ACPExtensionEvent) in
            let responseEvent: NSDictionary! = self.getJavascriptDictionaryFromEvent(
              event: response)
            let pluginResult: CDVPluginResult! = CDVPluginResult(
              status: CDVCommandStatus_OK, messageAs: responseEvent as? [AnyHashable: Any])
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
          })
      } catch let error {
        self.commandDelegate.send(
          CDVPluginResult(
            status: CDVCommandStatus_ERROR,
            messageAs: String(format: "Error dispatching event: %@", error.localizedDescription)),
          callbackId: command.callbackId)
      }
    })
  }

  @objc(dispatchResponseEvent:)
  func dispatchResponseEvent(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {

      guard let inputResponseEvent = command.arguments[0] as? NSDictionary else {
        self.commandDelegate.send(
          CDVPluginResult(
            status: CDVCommandStatus_ERROR,
            messageAs: "Unable to dispatch event. InputResponse was malformed"),
          callbackId: command.callbackId)
      }

      guard let inputRequestEvent = command.arguments[1] as? NSDictionary else {
        self.commandDelegate.send(
          CDVPluginResult(
            status: CDVCommandStatus_ERROR,
            messageAs: "Unable to dispatch event. InputResquest was malformed"),
          callbackId: command.callbackId)
      }

      let responseEvent: ACPExtensionEvent! = self.getExtensionEventFromJavascriptObject(
        event: inputResponseEvent)
      let requestEvent: ACPExtensionEvent! = self.getExtensionEventFromJavascriptObject(
        event: inputRequestEvent)

      do {
        try ACPCore.dispatchResponseEvent(responseEvent, request: requestEvent)
        let pluginResult: CDVPluginResult! = CDVPluginResult(status: CDVCommandStatus_OK)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
      } catch let error {
        self.commandDelegate.send(
          CDVPluginResult(
            status: CDVCommandStatus_ERROR,
            messageAs: String(
              format: "Error dispatching response event: %@", error.localizedDescription)),
          callbackId: command.callbackId)
      }

    })
  }

  @objc(downloadRules:)
  func downloadRules(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      ACPCore.downloadRules()

      let pluginResult: CDVPluginResult! = CDVPluginResult(status: CDVCommandStatus_OK)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(extensionVersion:)
  func extensionVersion(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {

      let version: String! = self.initTime.appending(": ").appending(ACPCore.extensionVersion())
      let pluginResult: CDVPluginResult! = CDVPluginResult(
        status: CDVCommandStatus_OK, messageAs: version)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(getPrivacyStatus:)
  func getPrivacyStatus(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      ACPCore.getPrivacyStatus({ (status: ACPMobilePrivacyStatus) in
        let pluginResult: CDVPluginResult! = CDVPluginResult(
          status: CDVCommandStatus_OK, messageAs: status.rawValue)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
      })
    })
  }

  @objc(getSdkIdentities:)
  func getSdkIdentities(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      ACPCore.getSdkIdentities({ (content: String?) in
        let pluginResult: CDVPluginResult! = CDVPluginResult(
          status: CDVCommandStatus_OK, messageAs: content)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
      })
    })
  }

  @objc(setAdvertisingIdentifier:)
  func setAdvertisingIdentifier(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {

      let newIdentifier: String! = command.arguments[0] as? String
      ACPCore.setAdvertisingIdentifier(newIdentifier)

      let pluginResult: CDVPluginResult! = CDVPluginResult(status: CDVCommandStatus_OK)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(setLogLevel:)
  func setLogLevel(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      let logLevel: ACPMobileLogLevel =
        command.arguments[0] as? ACPMobileLogLevel ?? ACPMobileLogLevel.warning

      ACPCore.setLogLevel(logLevel)

      let pluginResult: CDVPluginResult! = CDVPluginResult(status: CDVCommandStatus_OK)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(setPrivacyStatus:)
  func setPrivacyStatus(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      let privacyStatus: ACPMobilePrivacyStatus =
        command.arguments[0] as? ACPMobilePrivacyStatus ?? ACPMobilePrivacyStatus.unknown

      ACPCore.setPrivacyStatus(privacyStatus)
      let pluginResult: CDVPluginResult! = CDVPluginResult(status: CDVCommandStatus_OK)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(trackAction:)
  func trackAction(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {

      let firstArg: AnyObject! = command.arguments[0] as AnyObject
      let secondArg: AnyObject! = command.arguments[1] as AnyObject

      // allows the ACPCore.trackAction(cData) call
      if firstArg is NSDictionary {
        ACPCore.trackAction(nil, data: firstArg as? [String: String])
      } else {
        ACPCore.trackAction(firstArg as? String, data: secondArg as? [String: String])
      }

      let pluginResult: CDVPluginResult! = CDVPluginResult(status: CDVCommandStatus_OK)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(trackState:)
  func trackState(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {

      let firstArg: AnyObject! = command.arguments[0] as AnyObject
      let secondArg: AnyObject! = command.arguments[1] as AnyObject

      // allows the ACPCore.trackAction(cData) call
      if firstArg is NSDictionary {
        ACPCore.trackState(nil, data: firstArg as? [String: String])
      } else {
        ACPCore.trackState(firstArg as? String, data: secondArg as? [String: String])
      }

      let pluginResult: CDVPluginResult! = CDVPluginResult(status: CDVCommandStatus_OK)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(updateConfiguration:)
  func updateConfiguration(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {

      guard let config = command.arguments[0] as? [AnyHashable: Any] else {
        self.commandDelegate.send(
          CDVPluginResult(
            status: CDVCommandStatus_ERROR,
            messageAs: "Unable to dispatch event. InputResponse was malformed"),
          callbackId: command.callbackId)
      }

      ACPCore.updateConfiguration(config)

      let pluginResult: CDVPluginResult! = CDVPluginResult(status: CDVCommandStatus_OK)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(getAppId:)
  func getAppId(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      let pluginResult: CDVPluginResult! = CDVPluginResult(
        status: CDVCommandStatus_OK, messageAs: self.appId)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  // ===========================================================================
  // helper functions
  // ===========================================================================

  func getExtensionEventFromJavascriptObject(event: NSDictionary!) -> ACPExtensionEvent! {

    do {
      let newEvent = try ACPExtensionEvent.init(
        name: event.value(forKey: "name") as! String,
        type: event.value(forKey: "type") as! String,
        source: event.value(forKey: "source") as! String,
        data: event.value(forKey: "data") as? [AnyHashable: String])
      return newEvent
    } catch let error {
      ACPCore.log(
        ACPMobileLogLevel.warning, tag: "ACPCore",
        message: String(format: "Error creating ACPExtensionEvent: %@", error.localizedDescription))
    }
  }

  func getJavascriptDictionaryFromEvent(event: ACPExtensionEvent!) -> NSDictionary! {
    return [
      "name": event.eventName,
      "type": event.eventType,
      "source": event.eventSource,
      "data": event.eventData!,
    ]
  }

  // ===============================================================
  // Plugin lifecycle events
  // ===============================================================
  override func pluginInitialize() {

    self.appId = Bundle.main.object(forInfoDictionaryKey: "AppId") as? String
    ACPCore.setLogLevel(ACPMobileLogLevel.debug)
    ACPCore.configure(withAppId: appId)

    ACPCampaign.registerExtension()
    ACPPlaces.registerExtension()
    ACPPlacesMonitor.registerExtension()
    ACPAnalytics.registerExtension()
    ACPMobileServices.registerExtension()
    ACPTarget.registerExtension()
    ACPUserProfile.registerExtension()
    ACPIdentity.registerExtension()
    ACPLifecycle.registerExtension()
    ACPSignal.registerExtension()
    AEPAssurance.registerExtension()
    ACPCore.start({
      ACPCore.lifecycleStart(nil)
    })

    let date: NSDate! = NSDate()
    let dateFormatter: DateFormatter! = DateFormatter()
    dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
    initTime = dateFormatter.string(from: date as Date)
  }
}
