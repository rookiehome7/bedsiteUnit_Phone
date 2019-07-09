import Foundation
import UIKit

struct theLinphone {
    static var lc: OpaquePointer?
    static var lct: LinphoneCoreVTable?
    static var manager: LinphoneManager?
    
}

// Make SIP Registration Status from ApplicationStatus
var sipRegistrationStatus: SipRegistrationStatus = SipRegistrationStatus.unknown

// Registration Callback function
let registrationStateChanged: LinphoneCoreRegistrationStateChangedCb  = {
    (lc: Optional<OpaquePointer>, proxyConfig: Optional<OpaquePointer>, state: _LinphoneRegistrationState, message: Optional<UnsafePointer<Int8>>) in
    switch state{
    case LinphoneRegistrationNone: /**<Initial state for registrations */
        NSLog("LinphoneRegistrationNone")
        sipRegistrationStatus = .unknown
        
    case LinphoneRegistrationProgress:
        NSLog("LinphoneRegistrationProgress")
        sipRegistrationStatus = .unknown
        
    case LinphoneRegistrationOk:
        NSLog("LinphoneRegistrationOk")
        sipRegistrationStatus = .ok
        
    case LinphoneRegistrationCleared:
        NSLog("LinphoneRegistrationCleared")
        sipRegistrationStatus = .unregister
        
    case LinphoneRegistrationFailed:
        NSLog("LinphoneRegistrationFailed")
        sipRegistrationStatus = .fail
        
    default:
        NSLog("Unkown registration state")
    }
} as LinphoneCoreRegistrationStateChangedCb


// CallState Callback function
// Call state library
// https://www.linphone.org/docs/liblinphone-javadoc/org/linphone/core/LinphoneCall.State.html
let callStateChanged: LinphoneCoreCallStateChangedCb = {
    (lc: Optional<OpaquePointer>, call: Optional<OpaquePointer>, callSate: LinphoneCallState,  message: Optional<UnsafePointer<Int8>>) in
    switch callSate{
    case LinphoneCallIncomingReceived: /**<This is a new incoming call */
        NSLog("callStateChanged: LinphoneCallIncomingReceived")
        // Run ReceiveCallViewController to handle Incoming call
        if var controller = UIApplication.shared.keyWindow?.rootViewController{
            while let presentedViewController = controller.presentedViewController {
                controller = presentedViewController
            }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ReceiveCallViewController")
            controller.present(vc, animated: true, completion: nil)
            
        }

    case LinphoneCallStreamsRunning: /**<The media streams are established and running*/
        NSLog("callStateChanged: LinphoneCallStreamsRunning")
        
    case LinphoneCallError: /**<The call encountered an error*/
        NSLog("callStateChanged: LinphoneCallError")
        
    default:
        NSLog("Default call state")
    }
}

// outgoingCallStateChanged: Default call state _LinphoneCallState(rawValue: 5)
class LinphoneManager {
    static var iterateTimer: Timer?
    static var isInit: Bool = false
    
    func startLinphone() {
        if LinphoneManager.isInit {
            NSLog("Linphone already init")
        }
        else{
            NSLog("Linphone init")
            initLinphone()
            let proxyConfig = setIdentify()
            register(proxyConfig!)
            setTimer()
        }
    }
    
     func initLinphone(){
        theLinphone.lct = LinphoneCoreVTable()
        // Enable debug log to stdout
        linphone_core_set_log_file(nil)
        linphone_core_set_log_level(ORTP_DEBUG)
        // Load config
        let configFilename = documentFile("linphonerc222")
        let factoryConfigFilename = bundleFile("linphonerc-factory")

        let configFilenamePtr: UnsafePointer<Int8> = configFilename.cString(using: String.Encoding.utf8.rawValue)!
        let factoryConfigFilenamePtr: UnsafePointer<Int8> = factoryConfigFilename.cString(using: String.Encoding.utf8.rawValue)!
        let lpConfig = lp_config_new_with_factory(configFilenamePtr, factoryConfigFilenamePtr)
        
        // Set Callback Function
        theLinphone.lct!.registration_state_changed = registrationStateChanged
        theLinphone.lct!.call_state_changed = callStateChanged
        
        theLinphone.lc = linphone_core_new_with_config(&theLinphone.lct!, lpConfig, nil)
        LinphoneManager.isInit = true
        
        // Set ring asset
        let ringbackPath = URL(fileURLWithPath: Bundle.main.bundlePath).appendingPathComponent("/ringback.wav").absoluteString
        linphone_core_set_ringback(theLinphone.lc!, ringbackPath)

        let localRingPath = URL(fileURLWithPath: Bundle.main.bundlePath).appendingPathComponent("/toy-mono.wav").absoluteString
        linphone_core_set_ring(theLinphone.lc!, localRingPath)
    }
    
    @objc func iterate(){
        if let lc = theLinphone.lc{
            linphone_core_iterate(lc); /* first iterate initiates registration */
        }
    }
    
    fileprivate func bundleFile(_ file: NSString) -> NSString{
        return Bundle.main.path(forResource: file.deletingPathExtension, ofType: file.pathExtension)! as NSString
    }
    
    fileprivate func documentFile(_ file: NSString) -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        
        let documentsPath: NSString = paths[0] as NSString
        return documentsPath.appendingPathComponent(file as String) as NSString
    }
    
    
    func setIdentify() -> OpaquePointer? {
        // Reference: http://www.linphone.org/docs/liblinphone/group__registration__tutorials.html
        
        // Create Local User Data Class
        let accountData = LocalUserData()
    
        // IF you want to load data from Plist file use this function
        //accountData.loadSettingPlist()
        
        // Get the User setting data
        let account = accountData.getSipUsername()!
        let password = accountData.getSipPassword()!
        let domain = accountData.getSipServerIp()! + ":" + accountData.getSipServerPort()!
        let identity = "sip:" + String(account) + "@" + String(domain);

        // create proxy config
        let proxy_cfg = linphone_proxy_config_new();
        // parse identity
        let from = linphone_address_new(identity);
        if (from == nil){
            //NSLog("\(identity) not a valid sip uri, must be like sip:toto@sip.linphone.org");
            return nil
        }
        let info = linphone_auth_info_new(linphone_address_get_username(from), nil, password, nil, nil, nil);
        /*create authentication structure from identity*/
        linphone_core_add_auth_info(theLinphone.lc!, info); /*add authentication info to LinphoneCore*/
        // configure proxy entries
        linphone_proxy_config_set_identity(proxy_cfg, identity); /*set identity with user name and domain*/
        let server_addr = String(cString: linphone_address_get_domain(from)); /*extract domain address from identity*/
        linphone_address_destroy(from); /*release resource*/
        
        linphone_proxy_config_set_server_addr(proxy_cfg, server_addr); /* we assume domain = proxy server address*/
        //linphone_proxy_config_enable_register(proxy_cfg, 0); /* activate registration for this proxy config*/
        linphone_proxy_config_set_expires(proxy_cfg, 60)
        linphone_core_add_proxy_config(theLinphone.lc!, proxy_cfg); /*add proxy config to linphone core*/
        linphone_core_set_default_proxy_config(theLinphone.lc!, proxy_cfg); /*set to default proxy*/
        return proxy_cfg!
    }
    
    func register(_ proxy_cfg: OpaquePointer){
        linphone_proxy_config_enable_register(proxy_cfg, 1); /* activate registration for this proxy config*/
    }
    
    
    fileprivate func setTimer(){
        LinphoneManager.iterateTimer = Timer.scheduledTimer(
            timeInterval: 0.02, target: self, selector: #selector(iterate), userInfo: nil, repeats: true)
    }
    
    
    // Restart Linphone service
    func restartService(){
        NSLog("Re-Register Linphone service")
        // Un-Register Linphone Service
        if let timer = LinphoneManager.iterateTimer{
            timer.invalidate()
        }
        let proxy_cfg = linphone_core_get_default_proxy_config(theLinphone.lc!); /* get default proxy config*/

        if linphone_proxy_config_get_state(proxy_cfg) !=  LinphoneRegistrationFailed {
            linphone_proxy_config_edit(proxy_cfg); /*start editing proxy configuration*/
            linphone_proxy_config_enable_register(proxy_cfg, 0); /*de-activate registration for this proxy config*/
            linphone_proxy_config_done(proxy_cfg); /*initiate REGISTER with expire = 0*/
            while(linphone_proxy_config_get_state(proxy_cfg) !=  LinphoneRegistrationCleared){
                linphone_core_iterate(theLinphone.lc!); /*to make sure we receive call backs before shutting down*/
                ms_usleep(50000);
            }
        }
        
        linphone_core_remove_listener(theLinphone.lc!, &theLinphone.lct!)
        linphone_core_destroy(theLinphone.lc!);
        LinphoneManager.isInit = false
        
        // Run function to restart service
        startLinphone()

    }
    
}
