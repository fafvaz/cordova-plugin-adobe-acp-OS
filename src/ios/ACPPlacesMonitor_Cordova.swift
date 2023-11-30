import AEPCore
import AEPLifecycle
import AEPPlaces
import CoreLocation

@objc(ACPPlacesMonitor_Cordova) class ACPPlacesMonitor_Cordova: CDVPlugin, CLLocationManagerDelegate
{

  var locationManager: CLLocationManager?
  var started = false

  @objc(start:)
  func start(command: CDVInvokedUrlCommand!) {

    locationManager?.requestWhenInUseAuthorization()

    let authorizationStatus = CLLocationManager.authorizationStatus()

    if authorizationStatus == CLAuthorizationStatus.notDetermined {
      locationManager?.requestWhenInUseAuthorization()
      let pluginResult: CDVPluginResult! = CDVPluginResult(
        status: CDVCommandStatus_ERROR, messageAs: "GPS Permission ISsues")
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    } else {
      self.started = true
      locationManager?.startUpdatingLocation()
      let pluginResult: CDVPluginResult! = CDVPluginResult(
        status: CDVCommandStatus_OK, messageAs: "Monitoring")
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }
  }

  @objc(updateLocation:)
  func updateLocation(command: CDVInvokedUrlCommand!) {

    if self.started {
      self.commandDelegate.run(inBackground: {

        self.locationManager?.requestLocation()
        self.locationManager?.startUpdatingLocation()
        let pluginResult: CDVPluginResult! = CDVPluginResult(
          status: CDVCommandStatus_OK, messageAs: "Monitoring")
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)

      })

    } else {
      let pluginResult: CDVPluginResult! = CDVPluginResult(
        status: CDVCommandStatus_ERROR, messageAs: "Monitor not started")
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }

  }

  @objc(startMonitoringForRegion:)
  func startMonitoringForRegion(command: CDVInvokedUrlCommand!) {

    if self.started {
      self.commandDelegate.run(inBackground: {

        let lat = command.arguments[0] as! Double
        let lng = command.arguments[1] as! Double
        let radius = command.arguments[2] as! Double
        let identifier = command.arguments[3] as! String
        let center = CLLocationCoordinate2D(latitude: lat, longitude: lng)

        let currentRegion = CLCircularRegion(center: center, radius: radius, identifier: identifier)

        currentRegion.notifyOnEntry = command.arguments[4] as! Bool
        currentRegion.notifyOnExit = command.arguments[5] as! Bool

        self.locationManager?.startMonitoring(for: currentRegion)

        let pluginResult: CDVPluginResult! = CDVPluginResult(
          status: CDVCommandStatus_OK, messageAs: "Monitoring Region")
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)

      })
    } else {
      let pluginResult: CDVPluginResult! = CDVPluginResult(
        status: CDVCommandStatus_ERROR, messageAs: "Monitor not started")
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }
  }

  @objc(stop:)
  func stop(command: CDVInvokedUrlCommand!) {
    self.locationManager?.stopUpdatingLocation()
    self.started = false
    let pluginResult: CDVPluginResult! = CDVPluginResult(
      status: CDVCommandStatus_OK, messageAs: "Stopped")
    self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
  }

  override func pluginInitialize() {
    locationManager = CLLocationManager()
    locationManager?.delegate = self
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("error:: \(error.localizedDescription)")
  }

  func locationManager(
    _ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus
  ) {
    if status == .authorizedWhenInUse {
      locationManager?.requestLocation()
    }
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

    if locations.first != nil {
      print("location:: (location)")
    }

  }

  func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
    Places.processRegionEvent(.entry, forRegion: region)
  }

  func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
    Places.processRegionEvent(.exit, forRegion: region)
  }

}
