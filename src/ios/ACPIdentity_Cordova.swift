import ACPCore

let stateStrings = ["UNKNOWN", "AUTHENTICATED", "LOGGED_OUT"]
let INVALID_AUTH_STATE = 3

@objc(ACPIdentity_Cordova) class ACPIdentity_Cordova: CDVPlugin {

  @objc(extensionVersion:)
  func extensionVersion(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      var pluginResult: CDVPluginResult! = nil

      let version: String! = ACPIdentity.extensionVersion()

      pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: version)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(appendVisitorInfoForUrl:)
  func appendVisitorInfoForUrl(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {

      guard let url = NSURL(string: command.arguments[0] as! String) else {
        self.commandDelegate.send(
          CDVPluginResult(
            status: CDVCommandStatus_ERROR,
            messageAs: "Unable appendVisitorInfoForUrl. Input was malformed"),
          callbackId: command.callbackId)
          return
      }

      ACPIdentity.append(
        to: url.absoluteURL,
        withCallback: { (urlWithVisitorData: URL?) in
          let pluginResult: CDVPluginResult! = CDVPluginResult(
            status: CDVCommandStatus_OK, messageAs: urlWithVisitorData?.absoluteString)
          self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        })

    })
  }

  @objc(getExperienceCloudId:)
  func getExperienceCloudId(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      ACPIdentity.getExperienceCloudId({ (experienceCloudId: String?) in
        let pluginResult: CDVPluginResult! = CDVPluginResult(
          status: CDVCommandStatus_OK, messageAs: experienceCloudId)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
      })
    })
  }

  @objc(getIdentifiers:)
  func getIdentifiers(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      ACPIdentity.getIdentifiers({ (visitorIDs: [AnyObject]?) in
        var visitorIdsString: String! = ""
        if visitorIDs == nil {
          visitorIdsString = "nil"
        } else if visitorIDs?.count == 0 {
          visitorIdsString = "[]"
        } else {

          visitorIDs?.forEach({ (visitorId) in
            visitorIdsString = visitorIdsString.appendingFormat(
              "[Id: %@, Type: %@, Origin: %@, Authentication: %@] ", visitorId.identifier,
              visitorId.idType ?? "", visitorId.idOrigin ?? "",
              stateStrings[Int(visitorId.authenticationState?.rawValue ?? 0)])
          })
        }
        let pluginResult: CDVPluginResult! = CDVPluginResult(
          status: CDVCommandStatus_OK, messageAs: visitorIdsString)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
      })
    })
  }

  @objc(getUrlVariables:)
  func getUrlVariables(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      ACPIdentity.getUrlVariables({ (urlVariables: String?) in
        let pluginResult: CDVPluginResult! = CDVPluginResult(
          status: CDVCommandStatus_OK, messageAs: urlVariables)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
      })
    })
  }

  @objc(syncIdentifier:)
  func syncIdentifier(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      let idType: String! = command.arguments[0] as? String
      let idValue: String! = command.arguments[1] as? String
      let state: Int = self.getAuthenticationStateValue(
        authState: command.arguments[2] as? NSNumber)

      ACPIdentity.syncIdentifier(
        idType, identifier: idValue,
        authentication: self.getAuthenticationStateEnumValue(authState: state as NSNumber))
      let pluginResult: CDVPluginResult! = CDVPluginResult(
        status: CDVCommandStatus_OK,
        messageAs: String(
          format: "Visitor ID synced: Id: %@, Type: %@, Authentication: %@", idType, idValue,
          stateStrings[state]))
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(syncIdentifiers:)
  func syncIdentifiers(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      var pluginResult: CDVPluginResult! = nil
      let identifiers: NSDictionary! = command.arguments[0] as? NSDictionary
      let state: Int = command.arguments[1] as? Int ?? 0

      if state < 3 {
        ACPIdentity.syncIdentifiers(
          identifiers as? [AnyHashable: Any],
          authentication: self.getAuthenticationStateEnumValue(authState: state as NSNumber))
        pluginResult = CDVPluginResult(
          status: CDVCommandStatus_OK,
          messageAs: String(
            format: "Visitor IDs synced: %@, Authentication: %@", identifiers, stateStrings[state]))
      } else {
        ACPIdentity.syncIdentifiers(identifiers as? [AnyHashable: Any])
        pluginResult = CDVPluginResult(
          status: CDVCommandStatus_OK,
          messageAs: String(format: "Visitor IDs synced: %@", identifiers))
      }

      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  /*
     * Helper functions
     */

  func getAuthenticationStateValue(authState: NSNumber!) -> Int {
    var authStateInt: Int = 3  // use 3 as the auth state values range from 0-2
    if authState != nil {
      switch authState.intValue {
      case 0:
        authStateInt = Int(ACPMobileVisitorAuthenticationState.unknown.rawValue)
        break
      case 1:
        authStateInt = Int(ACPMobileVisitorAuthenticationState.authenticated.rawValue)
        break
      case 2:
        authStateInt = Int(ACPMobileVisitorAuthenticationState.loggedOut.rawValue)
        break
      default:
        authStateInt = INVALID_AUTH_STATE
        break
      }
    }
    return authStateInt
  }

  func getAuthenticationStateEnumValue(authState: NSNumber!) -> ACPMobileVisitorAuthenticationState
  {
    var state = ACPMobileVisitorAuthenticationState.unknown
    if authState != nil {
      switch authState.intValue {
      case 0:
        state = ACPMobileVisitorAuthenticationState.unknown
        break
      case 1:
        state = ACPMobileVisitorAuthenticationState.authenticated
        break
      case 2:
        state = ACPMobileVisitorAuthenticationState.loggedOut
        break
      default:
        state = ACPMobileVisitorAuthenticationState.unknown
        break
      }
    }
    return state
  }
}
