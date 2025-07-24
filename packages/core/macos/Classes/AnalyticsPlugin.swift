import Cocoa
import FlutterMacOS

public class AnalyticsPlugin: NSObject, FlutterPlugin, NativeContextApi {
internal static var device = VendorSystem.current
    
    func getContext(collectDeviceId: Bool, completion: @escaping (Result<NativeContext, Error>) -> Void) {
        let info = Bundle.main.infoDictionary
        let localizedInfo = Bundle.main.localizedInfoDictionary
        var app = [String: Any]()
        if let info = info {
            app.merge(info) { (_, new) in new }
        }
        if let localizedInfo = localizedInfo {
            app.merge(localizedInfo) { (_, new) in new }
        }
        let device = Self.device
        let screen = device.screenSize
        let userAgent = device.userAgent
        let status = device.connection
        
        var cellular = false
        var wifi = false
        var bluetooth = false
        
        switch status {
        case .online(.cellular):
            cellular = true
        case .online(.wifi):
            wifi = true
        case .online(.bluetooth):
            bluetooth = true
        default:
            break
        }
        
        completion(.success(NativeContext(
            app: app.count != 0 ? NativeContextApp(
                build: app["CFBundleVersion"] as! String? ?? "",
                name: app["CFBundleDisplayName"] as! String? ?? "",
                namespace: Bundle.main.bundleIdentifier ?? "",
                version: app["CFBundleShortVersionString"] as! String? ?? "") : nil,
            device: NativeContextDevice(
                id: collectDeviceId ? (device.identifierForVendor ?? "") : nil,
                manufacturer: device.manufacturer,
                model: device.model,
                name: device.name,
                type: device.type),
            locale: Locale.preferredLanguages.count > 0 ? Locale.preferredLanguages[0] : nil,
            network: NativeContextNetwork(
                cellular: cellular,
                wifi: wifi,
                bluetooth: bluetooth),
            os: NativeContextOS(
                name: device.systemName,
                version: device.systemVersion),
            referrer: nil,
            screen: NativeContextScreen(
                height: Int32(screen.height),
                width: Int32(screen.width)),
            timezone: TimeZone.current.identifier,
            userAgent: userAgent)))
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let messenger : FlutterBinaryMessenger = registrar.messenger //()
        let api : NativeContextApi & NSObjectProtocol = AnalyticsPlugin.init()
        NativeContextApiSetup.setUp(binaryMessenger: messenger, api: api)
    }
}
