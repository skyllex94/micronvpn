//
//  CountryVC.swift
//  VPNEvo
//
//  Created by Hvapz_iOS on 09/05/22.
//

import UIKit
import RevenueCat
import NetworkExtension
import FirebaseAnalytics
import AppsFlyerLib
import YandexMobileMetrica

class CountryVC: UIViewController {

    @IBOutlet weak var lblHeader: UILabel!
    
    @IBOutlet var tbl_country : UITableView!
    
    @IBOutlet var activityView:Loader_VC!
        
    var arrayQuickAccess = NSMutableArray()
    var arrayCountry = NSMutableArray()
    
    var isDirectPurchase:Bool!
    var isDoublePayment:Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        //Check if double payment ON/OFF
        self.isDoublePayment = false
        
        if(UserDefaults.standard.value(forKey: "doublePayment") as? NSString)?.boolValue ?? false {
            self.isDoublePayment = true
        }
        self.lblHeader.text = NSLocalizedString("Country List", comment: "Country List")
        
        self.getCountryList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.isDirectPurchase = (UserDefaults.standard.value(forKey: "direct_purchase") as? NSString)?.boolValue ?? false
        
        //self.showLoader()
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
    
//    func saveCustomObject() {
////        let defaults = UserDefaults.standard
////        if((defaults.object(forKey: "CURRENTSERVER")) != nil) {
////            let myEncodedObject = defaults.object(forKey: "CURRENTSERVER") as? Data
////            let obj = NSKeyedUnarchiver.unarchiveObject(with: myEncodedObject!) as? ModelCountry
//////            self.countyImg.image = UIImage(named: obj!.flag)
//////            self.LabelCountryName.text = obj!.name
//////            self.checkMarkImg.image = UIImage(named: "check")
////
////        }
//    }
    
    //MARK: - action call
    
    @IBAction func action_back() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - country list
    
    func getCountryList(){
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let filePath = documentsDirectory.appendingPathComponent("servers_new.json")
        
        if filePath.isFileURL{
        //if let path = Bundle.main.path(forResource: "servers", ofType: "json") {
            //do {
                let jsonData = try? NSData(contentsOf: filePath)
                //let jsonData = try NSData(contentsOfFile: filePath.absoluteString, options: NSData.ReadingOptions.mappedIfSafe)
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
                        
                        self.tbl_country.reloadData()
                        
                        if arrayCountry.count > 0{
                        
                            if((UserDefaults.standard.object(forKey: "CURRENTSERVER")) == nil)
                            {
                                let modelCountry = arrayCountry[0] as! NSDictionary
                                UserDefaults.standard.set(modelCountry, forKey: "CURRENTSERVER")
                                UserDefaults.standard.synchronize()
                            }
                        }
                    }
                } catch {}
        }
    }
    
    // MARK: - Purchase
    
    func showIAP(){
        
        let subscriptionVC = self.storyboard?.instantiateViewController(withIdentifier: "SubcriptionVC") as! SubcriptionVC
        let navController = UINavigationController(rootViewController: subscriptionVC)
        navController.isNavigationBarHidden = true
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated:true, completion: nil)
    }
    
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
              
        self.showLoader()
        
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
        
            self.hideLoader()
            
            if(error != nil){
                
                if (self.isDoublePayment) {
                    
                    if(UserDefaults.standard.bool(forKey: "SHOWIAPAGAIN")) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                            self.purchaseagain(package: package)
                        }
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
                DispatchQueue.main.async {
                    self.action_back()
                }
                
            }
            
        }
    }
    
    func purchaseagain(package:RevenueCat.Package){
        
        
        Purchases.shared.purchase(package: package) {
            
            (transaction, purchaserInfo, error, userCancelled) in
        
            self.hideLoader()
            
            if(error != nil){
                
                print(error!)
                if userCancelled {
                    if UserDefaults.standard.bool(forKey: "ShowSales") {
                        if UserDefaults.standard.value(forKey: "opendate") != nil && !UserDefaults.standard.bool(forKey: "isOpensale") {
                            let dtprev = UserDefaults.standard.value(forKey: "opendate") as! String
                            let formatter = DateFormatter()
                            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            formatter.timeZone = TimeZone(identifier: "UTC")
                            let datePRev = formatter.date(from: dtprev)
//                            print(datePRev)
                            let formatter1 = DateComponentsFormatter()
                            formatter1.unitsStyle = .positional
                            formatter1.allowedUnits = [.day] //[.minute] //[.month, .day, .hour, .minute, .second]
                            formatter1.maximumUnitCount = 2
                            let diff = formatter1.string(from: datePRev!, to: Date())!
                            let new = diff.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
//                            print(new)
                            if Int(new)! > 6 { // 10080 min = 168 hour = 7 day
//                                if !UserDefaults.standard.bool(forKey: "isOpensale") {
                                if !Singleton.sharedInstance.isPurchased{
                                    let saleVC = self.storyboard?.instantiateViewController(withIdentifier: "SaleVC") as! SaleVC
                                    saleVC.modalPresentationStyle = .fullScreen
                                    self.present(saleVC, animated: true, completion: nil)
                                    UserDefaults.standard.set(true, forKey:"isOpensale")
                                }
                                    
//                                }
                            }
                        }
                    }
                    else{
                        if !Singleton.sharedInstance.isPurchased{
                            let saleVC = self.storyboard?.instantiateViewController(withIdentifier: "SaleVC") as! SaleVC
                            saleVC.modalPresentationStyle = .fullScreen
                            self.present(saleVC, animated: true, completion: nil)
                            
                            let date = Date()
                            let formatter = DateFormatter()
                            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            formatter.timeZone = TimeZone(identifier: "UTC")
                            let today = formatter.string(from: date)
                            UserDefaults.standard.set(today, forKey: "opendate")
                            
                            UserDefaults.standard.set(true, forKey:"ShowSales")
                        }
                        
                    }
                    UserDefaults.standard.synchronize()
                }
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
                DispatchQueue.main.async {
                    self.action_back()
                }
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
extension CountryVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(section == 0){
            
            print(arrayQuickAccess.count)
            return arrayQuickAccess.count
        }
        else{
            return arrayCountry.count
        }
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCell", for: indexPath) as? CountryCell else { return UITableViewCell() }
        
        var modelCountry:NSDictionary!
        
        if(indexPath.section == 0){
            
            modelCountry = (arrayQuickAccess[indexPath.row] as! NSDictionary)
        }
        else{
            
            modelCountry = (arrayCountry[indexPath.row] as! NSDictionary)
        }
        
        let name = modelCountry["name"]! as? String
        let flag = modelCountry["flag"]! as? String
        
        cell.countyImg.image = UIImage(named: flag ?? "us.png")
        cell.LabelCountryName.text = name
        
        if (UserDefaults.standard.object(forKey: "CURRENTSERVER") != nil)
        {
            let currentCountry = UserDefaults.standard.value(forKey: "CURRENTSERVER")
            
            let currentname = (currentCountry as! NSDictionary)["name"]! as? String
            
            if(name == currentname){
                
                cell.checkMarkImg.image = UIImage(named: "check")
            }
            else{
                cell.checkMarkImg.image = UIImage(named: "uncheck")
            }
        }
        else
        {
            cell.checkMarkImg.image = UIImage(named: "uncheck")
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        Singleton.sharedInstance.vibrateDevice()
        
        var modelCountry:NSDictionary!
        
        if(indexPath.section == 0){
            
            modelCountry = (arrayQuickAccess[indexPath.row] as! NSDictionary)
        }
        else{
            
            modelCountry = (arrayCountry[indexPath.row] as! NSDictionary)
        }
        
        if(Singleton.sharedInstance.isPurchased){

            if VPNManager.shared.status == NEVPNStatus.connected{
                VPNManager.shared.disconnect()
                NotificationCenter.default.post(name: NSNotification.Name("CONENCTFROMSERVER"), object: nil)
            }
           
            UserDefaults.standard.set(modelCountry, forKey: "CURRENTSERVER")
            UserDefaults.standard.synchronize()
            action_back()
        }
        else{
            
            if (self.isDirectPurchase) {
                
                self.startPurchase()
                return
                
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                self.showIAP()
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        if(section == 0){
            
            return NSLocalizedString("Quick Access", comment: "")
        }
        else{
            
            return NSLocalizedString("All Servers", comment: "")
        }
        
    }
        
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor(red: 16.0/255.0, green: 16.0/255.0, blue: 16.0/255.0, alpha: 1.0)
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.lightGray
        header.backgroundColor = UIColor(red: 16.0/255.0, green: 16.0/255.0, blue: 16.0/255.0, alpha: 1.0)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 40.0
    }
}
