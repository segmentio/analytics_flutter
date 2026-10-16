import Flutter
import UIKit
import Foundation

public class AnalyticsPlugin: NSObject, FlutterPlugin, NativeContextApi, FlutterStreamHandler, FlutterApplicationLifeCycleDelegate, FlutterSceneLifeCycleDelegate {
    private var pendingDeeplinkEventsQueue:[[String:String?]] = []
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        _eventSink = events
        processPendingDeeplinkEventsQueue();
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        _eventSink = nil
        return nil
    }
    
    var _eventSink:FlutterEventSink?;
    private func handleDeeplink(url: URL, sourceApplication: String?) {
        let event: [String:String?] = ["url": url.absoluteString, "referring_application": sourceApplication]
        if (_eventSink != nil) {
            _eventSink?(event)
        } else {
            pendingDeeplinkEventsQueue.append(event)
        }
    }

    // UIApplicationDelegate path (apps that have not adopted the UIScene life cycle).
    public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool{
        handleDeeplink(url: url, sourceApplication: options[.sourceApplication] as? String)
        return false
    }

    // UIScene path: Flutter forwards both warm URLs and the cold-start launch URL here.
    public func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) -> Bool {
        for context in URLContexts {
            handleDeeplink(url: context.url, sourceApplication: context.options.sourceApplication)
        }
        return false
    }

    private func processPendingDeeplinkEventsQueue() -> Void{
        if(_eventSink == nil){
            return;
        }
        while(!pendingDeeplinkEventsQueue.isEmpty){
            let eventData:[String:String?] = pendingDeeplinkEventsQueue.removeFirst();
            _eventSink?(eventData);
        }
    }
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
            screen: NativeContextScreen(
                height: Int32(screen.height),
                width: Int32(screen.width)),
            timezone: TimeZone.current.identifier,
            userAgent: userAgent)))
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let messenger : FlutterBinaryMessenger = registrar.messenger()
        let plugin = AnalyticsPlugin.init();
        let api : NativeContextApi & NSObjectProtocol & AnalyticsPlugin = plugin
        NativeContextApiSetup.setUp(binaryMessenger: messenger, api: api)
        
        let channel:FlutterEventChannel = FlutterEventChannel(name: "analytics/deep_link_events", binaryMessenger: registrar.messenger())
        channel.setStreamHandler(api)
        registrar.addApplicationDelegate(plugin)
        registrar.addSceneDelegate(plugin)
    }
}
