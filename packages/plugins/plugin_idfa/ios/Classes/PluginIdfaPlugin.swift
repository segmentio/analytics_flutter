import Flutter
import UIKit
import AdSupport
import AppTrackingTransparency

public class PluginIdfaPlugin: NSObject, FlutterPlugin, NativeIdfaApi {
  func getTrackingAuthorizationStatus(completion: @escaping (Result<NativeIdfaData, Error>) -> Void) {
    if #available(iOS 14, *) {
        ATTrackingManager.requestTrackingAuthorization { status in
            let idfa = status == .authorized ? ASIdentifierManager.shared().advertisingIdentifier.uuidString : self.fallbackValue

            completion(.success(NativeIdfaData(
              adTrackingEnabled: status == .authorized,
              advertisingId: idfa!,
              trackingStatus: status == .authorized ? TrackingStatus.authorized : status == .denied ? TrackingStatus.denied : status == .notDetermined ? TrackingStatus.notDetermined : status == .restricted ? TrackingStatus.restricted : TrackingStatus.unknown //self.statusToString(status)
            )));
        }
    } else {
        let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        
        completion(.success(NativeIdfaData(
          adTrackingEnabled: true,
          advertisingId: idfa,
          trackingStatus: TrackingStatus.authorized
        )));
    }

  }

  var fallbackValue: String? {
        get {
            // fallback to the IDFV value.
            // this is also sent in event.context.device.id,
            // feel free to use a value that is more useful to you.
            return UIDevice.current.identifierForVendor?.uuidString
        }
    }
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let messenger : FlutterBinaryMessenger = registrar.messenger()
    let api : NativeIdfaApi & NSObjectProtocol = PluginIdfaPlugin.init()
    NativeIdfaApiSetup.setUp(binaryMessenger: messenger, api: api)
  }
}
