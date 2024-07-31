//
//  HomeVC.swift
//  VPNEvo
//
//  Created by Rootways on 14/03/22.
//

import UIKit
import RevenueCat
import NetworkExtension
import KAProgressLabel
import MZTimerLabel
import FirebaseAnalytics
import AppsFlyerLib
import YandexMobileMetrica

class HomeVC: UIViewController {

//    @IBOutlet var tableCountry:UITableView!
//    @IBOutlet weak var bottomview : UIView!
    @IBOutlet weak var headerview : UIView!
    
    @IBOutlet var LabelConnect : UILabel!
    @IBOutlet var btnConnect : UIButton!
    @IBOutlet weak var lblInstruction: UILabel!
    
    @IBOutlet var countyImg:UIImageView!
    @IBOutlet var LabelCountryName:UILabel!
    @IBOutlet var signalImg:UIImageView!
    @IBOutlet var checkMarkImg:UIImageView!
    
    @IBOutlet var progresslbl:KAProgressLabel!
    @IBOutlet var timeConnected:MZTimerLabel!
    
    @IBOutlet var activityView:Loader_VC!
    
    var progress:KAProgressLabel!
    
    var arrayQuickAccess = NSMutableArray()//[ModelCountry]()
    var arrayCountry = NSMutableArray()//[ModelCountry]()
    
    var isOpen: Bool!
    
    var isDoublePayment:Bool!
    
    var isDirectPurchase:Bool!
    
    var lastVelocityYSign = 0
    var isScrolling = false
    var allowDisconnect = true
    
    @IBOutlet weak var lblTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.closeServerList()
        
        self.progress = KAProgressLabel.init(frame: self.progresslbl.frame)
                
        self.navigationController?.navigationBar.isHidden = true        
        //addPullUpController(animated: true)
        
        //LabelConnect.text = NSLocalizedString("Disconnected", comment: "Disconnected")
              
        self.isOpen = false
        
        self.getCountryList()
        
        VPNManager.shared.statusEvent.attach(self, HomeVC.vpnStateChanged)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.vpnStateChanged(status: VPNManager.shared.status)
        }
        progresslbl.alpha = 0
        
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(connectFromServerlits), name: NSNotification.Name("CONENCTFROMSERVER"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        let saleVC = self.storyboard?.instantiateViewController(withIdentifier: "SaleVC") as! SaleVC
//        saleVC.modalPresentationStyle = .fullScreen
//        self.present(saleVC, animated: true, completion: nil)
//        return
        
        UserDefaults.standard.set(false, forKey: "SHOWIAPAGAIN")
        UserDefaults.standard.synchronize()
        
        self.isDirectPurchase = (UserDefaults.standard.value(forKey: "direct_purchase") as? NSString)?.boolValue ?? false
        
        //Check if double payment ON/OFF
        self.isDoublePayment = false
        
        if(UserDefaults.standard.value(forKey: "doublePayment") as? NSString)?.boolValue ?? false
        {
            self.isDoublePayment = true
        }
        
        
        if (UserDefaults.standard.object(forKey: "CURRENTSERVER") != nil) {
            
            guard let currentCountry = UserDefaults.standard.value(forKey: "CURRENTSERVER") else {
                return
            }
            
            let name = (currentCountry as! NSDictionary)["name"]! as? String
            let flag = (currentCountry as! NSDictionary)["flag"]! as? String
            
            self.LabelCountryName.text = name
            self.countyImg.image = UIImage(named:flag!)
            
        }else{
            self.LabelCountryName.text = "United States"
            self.countyImg.image = UIImage(named:"usaflag.png")
        }
    }
    
    override func viewDidLayoutSubviews() {
        
        //self.bottomview.roundCorners(corners: [.topLeft,.topRight], radius: 20.0)
    }
    
    func vpnStateChanged(status: NEVPNStatus) {
        switch status {
        case .disconnected, .invalid:
            self.changeStateToDisconnected()
        case .connected:
            self.changeStateToConnected()
        case .connecting:
            self.startProgress()
        case .disconnecting:
           break
        case .reasserting:
            print("Reconnecting...")
            break
        @unknown default: break
            //self.changeStateToDisconnected()
        }
    }
    
    func changeStateToConnected(){
        self.allowDisconnect = true
        
        if !UserDefaults.standard.bool(forKey: "ISREVIEWASKED"){
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                UserDefaults.standard.set(true, forKey: "ISREVIEWASKED")
                let rateUsVC = self.storyboard?.instantiateViewController(withIdentifier: "RateUsVC") as! RateUsVC
                rateUsVC.modalPresentationStyle = .fullScreen
                self.present(rateUsVC, animated: true, completion: nil)
            }
        }
        
        self.lblInstruction.text = NSLocalizedString("Tap to Disconnect", comment: "Tap to Disconnect")
        
        let count = UserDefaults.standard.integer(forKey: "CONNECTEDTIME") + 1
        UserDefaults.standard.set(count, forKey: "CONNECTEDTIME")
        UserDefaults.standard.synchronize()
        self.stopProress(from: "CONNECTED")
    }
    
    func changeStateToDisconnected(){
        if self.allowDisconnect{
            self.stopProress(from: "DISCONNECTED")
            self.lblInstruction.text = NSLocalizedString("Tap to Connect", comment: "Tap to Connect")
        }else{
            var failcount = UserDefaults.standard.integer(forKey: "failcount")
            failcount = failcount + 1
            
            if failcount >= 2{
                failcount = 0
                self.allowDisconnect = true
                VPNManager.shared.disconnect()
            
            }else{
                //Retry connection
                print("RECONNECTINNNNNGGGGGGGGGGGGGGGGGGGGG")
                if ((UserDefaults.standard.object(forKey: "CURRENTSERVER")) != nil) {
                    guard let currentCountry = UserDefaults.standard.value(forKey: "CURRENTSERVER") else {
                        return
                    }
                    self.connectVPN(modelServer: (currentCountry as! NSDictionary))
                }else{
                    let us = arrayQuickAccess[0]
                    self.connectVPN(modelServer: (us as! NSDictionary))
                }
                UserDefaults.standard.set(true, forKey: "ISRECONNECT")
            }
            UserDefaults.standard.set(failcount, forKey: "failcount")
        }
    }
    
    func changeStateToConnecting(){
        print("Vishal connecting.....")
        UIView.animate(withDuration: 0.5) {
            self.LabelConnect.text = NSLocalizedString("Connecting...", comment: "")
        }
        self.startProgress()
        
    }
    
    func startProgress(){
        
        self.allowDisconnect = false
        
        if UserDefaults.standard.bool(forKey: "ISRECONNECT"){
            UserDefaults.standard.set(false, forKey: "ISRECONNECT")
            return
        }
        
        print("Vishal start progresss...")
        
        self.LabelConnect.text = NSLocalizedString("Connecting...", comment: "Connecting...")
        
        if self.progress != nil{
            self.progress = KAProgressLabel.init(frame: self.progresslbl.frame)
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            self.progress.addGestureRecognizer(tap)
        }
        
        self.progress.trackColor = self.progresslbl.trackColor;
        self.progress.trackWidth = self.progresslbl.trackWidth;
        self.progress.progressWidth = self.progresslbl.progressWidth;
        self.progress.roundedCornersWidth = self.progresslbl.roundedCornersWidth;
        self.progress.progressColor  = self.progresslbl.progressColor;
        self.progress.startDegree = 0
        self.progress.endDegree = 360
        self.progress.progress = 0.0
        self.progress.alpha = 0.0
        self.view.addSubview(self.progress)
        progress.center = btnConnect.center
        
        UIView.transition(with: btnConnect, duration: 0.5, options: .transitionCrossDissolve, animations: {

            self.progress.alpha = 1.0
            
            self.view.bringSubviewToFront(self.progress)
            self.btnConnect.setImage(UIImage(named: "Connected.png"), for: .normal)
            
        }) { [self] finished in
           // progress.startLabel
            progress.setProgress(100.0, timing: TPPropertyAnimationTimingEaseInEaseOut, duration: 20.0, delay: 0.1)
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil){
        Singleton.sharedInstance.vibrateDevice()
        print("Tappedddd while connecting....")
        self.allowDisconnect = true
        VPNManager.shared.disconnect()
        self.changeStateToDisconnected()
    }
    
    @IBAction func openInfo(){
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "InfoScreenVC") as! InfoScreenVC
        VC.modalPresentationStyle = .fullScreen
        self.present(VC, animated: true)
        //self.navigationController?.pushViewController(VC, animated: true)
    }
    
    
    func stopProress(from:String!){
        
        var delayInSeconds: TimeInterval
        if from == "CONNECTED" {
            delayInSeconds = 0.7
        } else {
            if progress.progress < 100 {
                delayInSeconds = 1.0
            } else {
                delayInSeconds = 0.1
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds) {
            
            UIView.transition(with: self.btnConnect, duration: 1.0, options: .transitionCrossDissolve, animations: {

                if(from != "CONNECTED"){
                    
                    self.view.bringSubviewToFront(self.btnConnect)
                    
                    UIView.animate(withDuration: 0.1) {
                        self.LabelConnect.alpha = 0.0
                    } completion: { Bool in
                        
                        self.LabelConnect.text = NSLocalizedString("Disconnected", comment: "Disconnected")
                        self.LabelConnect.textColor = UIColor.white
                        UIView.animate(withDuration: 0.1) {
                            self.LabelConnect.alpha = 1.0
                        }
                    }
                    
                    UIView.animate(withDuration: 1.0, animations: { [self] in
                        progress.alpha = 0.0
                    })
                    
                    self.btnConnect.setImage(UIImage(named: "Disconnected.png"), for: .normal)
                    
                    let dic : [AnyHashable : Any] = ["Country":self.LabelCountryName.text!]
                    AppsFlyerLib.shared().logEvent("VPN Disconnected", withValues: dic)
                    Analytics.logEvent("VPN_Disconnected", parameters: nil)
                    
                    if(UserDefaults.standard.integer(forKey: "CONNECTEDTIME") >= 1){

                        if(!UserDefaults.standard.bool(forKey: "ISFIRSTDISCONNECT")){
                            UserDefaults.standard.set(true, forKey: "ISFIRSTDISCONNECT")
                            UserDefaults.standard.synchronize()

                            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                    self.askForNotification()
                            }
                        }
                    }

                    self.timeConnected.alpha = 0.0
                    self.timeConnected.text = "00:00:00"
                    self.timeConnected.stop()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        //[self getCurrentIP];
                    }
                    
                }
                else{
                    
                    self.checkForconnectedTime()
                    self.view.bringSubviewToFront(self.btnConnect)
                    self.btnConnect.setImage(UIImage(named: "Connected.png"), for: .normal)
                    let dic : [String: Any] = ["Country":self.LabelCountryName.text!]
                    AppsFlyerLib.shared().logEvent("VPN Connected", withValues: dic)
                    Analytics.logEvent("VPN_Connected", parameters: nil)
                    
                    UIView.animate(withDuration: 0.1) {
                        self.LabelConnect.alpha = 0.0
                    } completion: { Bool in
                        self.LabelConnect.text = NSLocalizedString("Connected", comment: "Connected")
                        self.LabelConnect.textColor = UIColor(red: 1.0/255.0, green: 255/255.0, blue: 176/255.0, alpha: 1.0)
                        UIView.animate(withDuration: 0.1) {
                            self.LabelConnect.alpha = 1.0
                        }
                    }

                    UIView.animate(withDuration: 1.0, animations: { [self] in
                        progress.alpha = 0.0
                        self.timeConnected.alpha = 1.0
                    })
                                        
                    Singleton.sharedInstance.vibrateDevice()
                    
                }

                }) { finished in
        
                }
           
        }
        
    }
    
    func checkForconnectedTime(){
        
        if VPNManager.shared.manager.connection.status == NEVPNStatus.connected{
            let time = -(VPNManager.shared.manager.connection.connectedDate?.timeIntervalSinceNow ?? 0)
            self.timeConnected.setStopWatchTime(time)
            self.timeConnected.start()
            self.timeConnected.alpha = 1.0
        }else{
            self.timeConnected.stop()
            self.timeConnected.alpha = 0.0
        }
        
        VPNManager.shared.manager.loadFromPreferences { Error in
            if (Error != nil){
                
            }
        }
    }
    
    func changeControlEnabled(state: Bool) {
    }
    
    func askForNotification(){
        
    }
    
    //MARK: - action call
    
    @IBAction func action_countrylist() {
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "CountryVC") as! CountryVC
        self.navigationController?.pushViewController(VC, animated: true)
//        rateUsVC.modalPresentationStyle = .fullScreen
//        self.present(rateUsVC, animated: true, completion: nil)
    }
    
    @IBAction func btnMenuAction(){
        
        sideMenuController?.showLeftView()
    }
    
    @IBAction func btnConnectedAction(){
        
        Singleton.sharedInstance.vibrateDevice()
        
        if VPNManager.shared.status == NEVPNStatus.connected{
            VPNManager.shared.disconnect()
            return
        }
        
        if(!Singleton.sharedInstance.isPurchased){
            
            if(UserDefaults.standard.value(forKey: "is_app_free") as? String == "Y"){
                
                guard let currentCountry = UserDefaults.standard.value(forKey: "CURRENTSERVER") else {
                    return
                }
                let isFree = (currentCountry as! NSDictionary)["isFree"]! as? String
                
                if isFree == "Y"{
                    self.connectVPN(modelServer: (currentCountry as! NSDictionary))
                    return
                }
            }
         
            if(UserDefaults.standard.value(forKey: "show_addconfig_popup") as? NSString)?.boolValue ?? false
            {
                if(UserDefaults.standard.integer(forKey: "ConnectCount") == 0){
                    self.addConfig()
                    UserDefaults.standard.set(1, forKey: "ConnectCount")
                }
                else if(UserDefaults.standard.integer(forKey: "ConnectCount") == 1){
                    self.showIAP()
                    UserDefaults.standard.set(2, forKey: "ConnectCount")
                }
                else if(UserDefaults.standard.integer(forKey: "ConnectCount") == 2){
                    self.startPurchase()
                    UserDefaults.standard.set(0, forKey: "ConnectCount")
                }
                UserDefaults.standard.synchronize()
                return
            }
            if (self.isDirectPurchase) {
                self.startPurchase()
            }else{
                self.showIAP()
            }
            return
        }
        
        if ((UserDefaults.standard.object(forKey: "CURRENTSERVER")) != nil) {
            guard let currentCountry = UserDefaults.standard.value(forKey: "CURRENTSERVER") else {
                return
            }
            self.connectVPN(modelServer: (currentCountry as! NSDictionary))
        }else{
            let us = arrayQuickAccess[0]
            self.connectVPN(modelServer: (us as! NSDictionary))
        }
    }
    
    @objc func connectFromServerlits(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard let currentCountry = UserDefaults.standard.value(forKey: "CURRENTSERVER") else {
                return
            }
            self.connectVPN(modelServer: (currentCountry as! NSDictionary))
        }
    }
    
    func connectVPN(modelServer:NSDictionary!){
        
        if (VPNManager.shared.isDisconnected) {
            
            let ip = modelServer["ip"]! as? String
            let un = modelServer["un"]! as? String
            let ps = modelServer["ps"]! as? String
            
            let config = Configuration(
                server: ip ?? "",
                account: un ?? "",
                password: ps ?? "",
                onDemand: true,
                psk: false ? "false" : nil)
            VPNManager.shared.connectIKEv2(config: config) { error in
                let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            }
            config.saveToDefaults()
        } else {
            VPNManager.shared.disconnect()
        }
    }
    
//    func loadCustomObject()-> ModelCountry! {
//        let defaults = UserDefaults.standard
//        if((defaults.object(forKey: "CURRENTSERVER")) != nil) {
//            let myEncodedObject = defaults.object(forKey: "CURRENTSERVER") as? Data
//            let obj = NSKeyedUnarchiver.unarchiveObject(with: myEncodedObject!) as? ModelCountry
//            return obj
//        } else {
//            return nil
//        }
//    }
    
    func showIAP(){
        
        let subscriptionVC = self.storyboard?.instantiateViewController(withIdentifier: "SubcriptionVC") as! SubcriptionVC
        let navController = UINavigationController(rootViewController: subscriptionVC)
        navController.isNavigationBarHidden = true
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated:true, completion: nil)
    }
    
    func addConfig(){
     
        let alertController = UIAlertController(title: NSLocalizedString("Warning", comment: "Warning"), message: NSLocalizedString("VPN Profile is necessary! Click Start and enter Touch/Face ID to start.", comment: "VPN Profile is necessary! Click Start and enter Touch/Face ID to start."), preferredStyle:.alert)

        alertController.addAction(UIAlertAction(title: NSLocalizedString("Start",comment: "Start"), style: .default)
                  { action -> Void in
                    self.startPurchase()
                  })
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel",comment: "Cancel"), style: .default)
                  { action -> Void in
                    self.cancelFirstAlert()
                  })
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func cancelFirstAlert(){
        let alertController = UIAlertController(title: NSLocalizedString("Warning", comment: "Warning"), message: NSLocalizedString("You have to add VPN Configuration to start.", comment: "You have to add VPN Configuration to start."), preferredStyle:.alert)

        alertController.addAction(UIAlertAction(title: NSLocalizedString("Add",comment: "Add"), style: .default)
                  { action -> Void in
                    self.startPurchase()
                  })
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel",comment: "Cancel"), style: .default))
        self.present(alertController, animated: true, completion: nil)
        
    }
    
//    func saveCustomObject() {
//        let defaults = UserDefaults.standard
//        if((defaults.object(forKey: "CURRENTSERVER")) != nil) {
//            //let myEncodedObject = defaults.object(forKey: "CURRENTSERVER") as? Data
//            //let obj = NSKeyedUnarchiver.unarchiveObject(with: myEncodedObject!) as? ModelCountry
////            self.countyImg.image = UIImage(named: obj!.flag)
////            self.LabelCountryName.text = obj!.name
////            self.checkMarkImg.image = UIImage(named: "check")
//
//        }
//    }
    
    // MARK: - country list
    
    func getCountryList(){
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let filePath = documentsDirectory.appendingPathComponent("servers_new.json")
        
        if filePath.isFileURL{
            //do {
                let jsonData = try? NSData(contentsOf: filePath)
                //let jsonData = try NSData(contentsOfFile: path, options: NSData.ReadingOptions.mappedIfSafe)
                do {
                    let jsonResult: NSDictionary = try JSONSerialization.jsonObject(with: jsonData! as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    if let quick : [NSDictionary] = jsonResult["quick"] as? [NSDictionary] {
                        
                        for server in quick {
                            self.arrayQuickAccess.add(server)
                        }
                    }
                    if let servers : [NSDictionary] = jsonResult["servers"] as? [NSDictionary] {
                        for server in servers {
                            self.arrayCountry.add(server)
                        }
                        if arrayQuickAccess.count > 0{
                        
                            if((UserDefaults.standard.object(forKey: "CURRENTSERVER")) == nil)
                            {
                                let modelCountry = arrayQuickAccess[0] as! NSDictionary
                                UserDefaults.standard.set(modelCountry, forKey: "CURRENTSERVER")
                                UserDefaults.standard.synchronize()

                            }
                        }
                    }
                } catch {
                    
                    if let path = Bundle.main.path(forResource: "servers_new", ofType: "json") {
                        do {
                            let jsonResult: NSDictionary = try JSONSerialization.jsonObject(with: jsonData! as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                            if let quick : [NSDictionary] = jsonResult["quick"] as? [NSDictionary] {
                                
                                for server in quick {
                                    self.arrayQuickAccess.add(server)
                                }
                            }
                            if let servers : [NSDictionary] = jsonResult["servers"] as? [NSDictionary] {
                                for server in servers {
                                    self.arrayCountry.add(server)
                                }
                                if arrayQuickAccess.count > 0{
                                
                                    if((UserDefaults.standard.object(forKey: "CURRENTSERVER")) == nil)
                                    {
                                        let modelCountry = arrayQuickAccess[0] as! NSDictionary
                                        UserDefaults.standard.set(modelCountry, forKey: "CURRENTSERVER")
                                        UserDefaults.standard.synchronize()

                                    }
                                }
                            }
                        } catch {}
                    }
                }
            //}
        }
    }
    
    // MARK: - Purchase
        
    func startPurchase(){
        
        if (self.isDoublePayment) {
            if(UserDefaults.standard.bool(forKey: "SHOWIAPAGAIN"))
            {
                UserDefaults.standard.set(true, forKey: "SHOWIAPAGAIN")
            }
            else{
                UserDefaults.standard.set(true, forKey:"SHOWIAPAGAIN")
            }
            UserDefaults.standard.synchronize()
        }
        
        if(!UserDefaults.standard.bool(forKey: "SHOWIAPAGAIN")){
            Singleton.sharedInstance.vibrateDevice()
        }
              
        
        let currentPlan = UserDefaults.standard.value(forKey:"currentPlan_connectButton") as? String ?? ""
        
        var PurchasePackage:RevenueCat.Package!
        
        for i in 0 ..< Singleton.sharedInstance.inappItems.count{
            
            let item = Singleton.sharedInstance.inappItems[i] as! NSMutableDictionary
            
            if item["identifier"] as? String == currentPlan {
            
                if let object = item["package"] as? RevenueCat.Package {
                    PurchasePackage = object
                }
            }
        }
        
        if ((PurchasePackage == nil)) {
            self.hideLoader()
            return
        }
        self.purchasePackage(package: PurchasePackage)
    }
    
    func purchasePackage(package:RevenueCat.Package){
     
        self.showLoader()
        
        Purchases.shared.purchase(package: package) {
            
            (transaction, purchaserInfo, error, userCancelled) in
            
            if(error != nil){
                
                if (self.isDoublePayment) {
                    
                    if(UserDefaults.standard.bool(forKey: "SHOWIAPAGAIN"))
                    {
                        self.purchaseagain(package: package)
                    }
                    else{
                        
                        self.hideLoader()
                    }
                    return
                }else{
                    self.hideLoader()
                }
                return
            }
            
            if purchaserInfo?.entitlements.all["pro"]?.isActive == true {
                self.hideLoader()
                
                Singleton.sharedInstance.isPurchased = true
                //[[NSNotificationCenter defaultCenter] postNotificationName:@"SETUSERPAID" object:nil];
                //[self setUserAsPaid];
                let dic : [String: Any] = ["af_price":package.localizedPriceString,
                                           "af_revenue":package.localizedPriceString]
                AppsFlyerLib.shared().logEvent(AFEventStartTrial, withValues: dic)
                AppsFlyerLib.shared().logEvent(AFEventSubscribe, withValues: dic)
                
                let dicY : [String: Any] = ["Revenue":package.localizedPriceString]
                YMMYandexMetrica.reportEvent("Subscribed", parameters: dicY) { error in
                    print(error.localizedDescription)
                }
                
                print("Pro feature granted !!")
                
            }
            
        }
    }
    
    func purchaseagain(package:RevenueCat.Package){
        
        Purchases.shared.purchase(package: package) {
            
            (transaction, purchaserInfo, error, userCancelled) in
        
            self.hideLoader()
            
            if(error != nil){
                
                print(error!)
            }
            
            if purchaserInfo?.entitlements.all["pro"]?.isActive == true {
                self.hideLoader()
                
                Singleton.sharedInstance.isPurchased = true
                //[[NSNotificationCenter defaultCenter] postNotificationName:@"SETUSERPAID" object:nil];
                //[self setUserAsPaid];
                let dic : [String: Any] = ["af_price":package.localizedPriceString,
                                           "af_revenue":package.localizedPriceString]
                AppsFlyerLib.shared().logEvent(AFEventStartTrial, withValues: dic)
                AppsFlyerLib.shared().logEvent(AFEventSubscribe, withValues: dic)
                
                let dicY : [String: Any] = ["Revenue":package.localizedPriceString]
                YMMYandexMetrica.reportEvent("Subscribed", parameters: dicY) { error in
                    print(error.localizedDescription)
                }
                print("Pro feature granted !!")
                
            }
            
        }
    }
    
    func showLoader() {
        activityView.alpha = 0.0
        self.activityView.isHidden = false
        UIView.animate(withDuration: 0.5, animations: { [self] in
            activityView.alpha = 1
        })
    }
        
    func hideLoader() {
        UIView.animate(withDuration: 0.5, animations: { [self] in
            activityView.alpha = 0
        }) { [self] finished in
            self.activityView.isHidden = true
        }
    }
}
extension UIView {
   func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
