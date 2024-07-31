//
//  DetectedVC.swift
//  VPNEvo
//
//  Created by Rootways on 16/03/22.
//

import UIKit
import RevenueCat
import LGSideMenuController
import FirebaseAnalytics
import AppsFlyerLib
import YandexMobileMetrica

class DetectedVC: UIViewController {

    @IBOutlet var lblHeader:UILabel!
    @IBOutlet var lblVirusDetected:UILabel!
    @IBOutlet var lblCleanimmediately:UILabel!
    
    @IBOutlet var messageView:UIView!
    
    @IBOutlet var lblMessage:UILabel!
    @IBOutlet var lblNow:UILabel!
    @IBOutlet var lblCleanRequied:UILabel!
    @IBOutlet var lblMalware:UILabel!
    
    @IBOutlet var btnStart:UIButton!
   // @IBOutlet var lblPriceInfo:UILabel!
    @IBOutlet var activityView:Loader_VC!
    
    var currentIAP:String!
    var isDoublePayment:Bool!
    var isIAPPricing:Bool!
    var isDynamic:Bool!
    var IAPProducts:NSMutableArray! = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        messageView.layer.cornerRadius = 12.0
        messageView.layer.masksToBounds = true
        
        lblHeader.text = NSLocalizedString("iPhone Security", comment: "header")
        lblVirusDetected.text = NSLocalizedString("Connection is not protected", comment: "detected")
        lblCleanimmediately.text = NSLocalizedString("Please clean iPhone immediately", comment: "clean")
        
        lblMessage.text = NSLocalizedString("MESSAGE", comment: "msg")
        lblNow.text = NSLocalizedString("now", comment: "now")
        lblCleanRequied.text = NSLocalizedString("Protection required", comment: "Protection required")
        lblMalware.text = NSLocalizedString("Personal information, passwords, messages, bank details and photos are at risk.", comment: "malware")
        
        btnStart.setTitle(NSLocalizedString("Turn on VPN", comment: "start"), for: .normal)
        
        btnStart.layer.cornerRadius = 10.0
        btnStart.layer.masksToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.currentIAP = UserDefaults.standard.value(forKey: "currentPlan") as? String ?? ""
        isIAPPricing = (UserDefaults.standard.value(forKey: "show_iap_prices") as? NSString)?.boolValue ?? false
        
        
        //Check if double payment ON/OFF
        self.isDoublePayment = false
        
        if(UserDefaults.standard.value(forKey: "doublePayment") as? NSString)?.boolValue ?? false
        {
            
            self.isDoublePayment = true
        }
        
        self.isDynamic = (UserDefaults.standard.value(forKey: "dynamic_price") as? NSString)?.boolValue ?? false
        let font = (UserDefaults.standard.value(forKey: "IAP_text_size") as? NSString)?.integerValue
        
        self.loadPricing()
        
        /*self.lblPriceInfo.isHidden = true
        if (isIAPPricing) {
            self.lblPriceInfo.isHidden = false
        }*/
    }
    
    @IBAction func btnStartAction(){
        Singleton.sharedInstance.vibrateDevice()
        
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
        
        var PurchasePackage:RevenueCat.Package!
        
        for i in 0 ..< Singleton.sharedInstance.inappItems.count{
            
            let item = Singleton.sharedInstance.inappItems[i] as! NSMutableDictionary
            
            if item["identifier"] as? String == self.currentIAP {
            
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

    func purchasePackage(package:RevenueCat.Package){
     
        self.showLoader()
        
        Purchases.shared.purchase(package: package) {
            
            (transaction, purchaserInfo, error, userCancelled) in
        
            self.hideLoader()
            
            if(error != nil){
                
                if (self.isDoublePayment) {
                    
                    if(UserDefaults.standard.bool(forKey: "SHOWIAPAGAIN"))
                    {
                        
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
                self.moveToCleaning()
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
                print("Pro feature granted !!")
                let dic : [String: Any] = ["af_price":package.localizedPriceString,
                                           "af_revenue":package.localizedPriceString]
                AppsFlyerLib.shared().logEvent(AFEventStartTrial, withValues: dic)
                AppsFlyerLib.shared().logEvent(AFEventSubscribe, withValues: dic)
                
                let dicY : [String: Any] = ["Revenue":package.localizedPriceString]
                YMMYandexMetrica.reportEvent("Subscribed", parameters: dicY) { error in
                    print(error.localizedDescription)
                }
                self.moveToCleaning()
            }
            
        }
    }

    
    func loadPricing(){
        
        self.IAPProducts = NSMutableArray()
        
        if(Singleton.sharedInstance.inappItems.count >= 2){
            
            for i in 0 ..< Singleton.sharedInstance.inappItems.count{
                
                let product = Singleton.sharedInstance.inappItems[i] as! NSMutableDictionary
                if(product["identifier"] as? String == self.currentIAP){
                    
                    let ipaText = UserDefaults.standard.value(forKey: "IAP_text") as? String ?? ""
                    if(self.isDynamic){
                        
                        var tempstr:String!
                        
                        if(self.currentIAP == kMonthlyIAP){
                            tempstr = String(format:"%@ %@/month",ipaText,product["price"] as? String ?? "")
                        }else if (self.currentIAP == kWeeklyIAP){
                            tempstr = String(format:"%@ %@/week",ipaText,product["price"] as? String ?? "")
                        }else if (self.currentIAP == k6MonthIAP){
                            tempstr = String(format:"%@ %@/6 months",ipaText,product["price"] as? String ?? "")
                        }else if (self.currentIAP == k3MonthIAP){
                            tempstr = String(format:"%@ %@/3 months",ipaText,product["price"] as? String ?? "");
                        }else if (self.currentIAP == kYearlyIAP){
                            tempstr = String(format:"%@ %@/year",ipaText,product["price"] as? String ?? "")
                        }
                        
                    }
                }

            }
            
        }
        else{
         
            //self.showLoader()
            
            Singleton.sharedInstance.loadInappItems()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                
                if Singleton.sharedInstance.inappItems.count >= 2 {
                    
                    for i in 0 ..< Singleton.sharedInstance.inappItems.count{
                        
                        let product = Singleton.sharedInstance.inappItems[i] as! NSMutableDictionary
                        if(product["identifier"] as? String == self.currentIAP){
                            
                            let ipaText = UserDefaults.standard.value(forKey: "IAP_text") as? String ?? ""
                            if(self.isDynamic){
                                
                                var tempstr:String!
                                
                                if(self.currentIAP == kMonthlyIAP){
                                    tempstr = String(format:"%@ %@/month",ipaText,product["price"] as? String ?? "")
                                }else if (self.currentIAP == kWeeklyIAP){
                                    tempstr = String(format:"%@ %@/week",ipaText,product["price"] as? String ?? "")
                                }else if (self.currentIAP == k6MonthIAP){
                                    tempstr = String(format:"%@ %@/6 months",ipaText,product["price"] as? String ?? "")
                                }else if (self.currentIAP == k3MonthIAP){
                                    tempstr = String(format:"%@ %@/3 months",ipaText,product["price"] as? String ?? "");
                                }else if (self.currentIAP == kYearlyIAP){
                                    tempstr = String(format:"%@ %@/year",ipaText,product["price"] as? String ?? "")
                                }
                                 
                                //self.lblPriceInfo.text = tempstr
                                
                            }
                        }

                    }
                    
                }
            }
        }
    }
    
    @IBAction func action_close(){
        self.movetoIntro()
    }
    
    func movetoIntro(){
        Singleton.sharedInstance.vibrateDevice()
        
        let introVC = self.storyboard?.instantiateViewController(withIdentifier: "IntroVC") as! IntroVC
        self.navigationController?.pushViewController(introVC, animated: false)
    }
    
    func close(){
        
        Singleton.sharedInstance.vibrateDevice()
        
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        let navigationController = UINavigationController()
        navigationController.setViewControllers([homeVC], animated: true)
        
        let leftSideMenuViewController: UIViewController = storyboard.instantiateViewController(withIdentifier: "DrawerVC")
        let sideMenuController = LGSideMenuController(rootViewController: navigationController,
                                                      leftViewController: leftSideMenuViewController,
                                                              rightViewController: nil)
        

        sideMenuController.leftViewWidth = 300.0
        sideMenuController.delegate = leftSideMenuViewController as! LGSideMenuDelegate

        sideMenuController.isLeftViewStatusBarBackgroundHidden = true
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = sideMenuController
        
        sideMenuController.view.alpha = 0.0
        
        
        let show_sale = (UserDefaults.standard.value(forKey: "show_sale") as? NSString)?.boolValue ?? false
        
        if show_sale{
            if !Singleton.sharedInstance.isPurchased{
                
                
                if !UserDefaults.standard.bool(forKey: "IS_SALE_DONE"){
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        sideMenuController.view.alpha = 1.0
                    }
                    UserDefaults.standard.set(true, forKey: "IS_SALE_DONE")
                    let storyboard = UIStoryboard.init(name: "Main", bundle: .main)
                    let saleVC = storyboard.instantiateViewController(withIdentifier: "SaleVC") as! SaleVC
                    saleVC.modalPresentationStyle = .fullScreen
                    appDelegate.window?.rootViewController?.present(saleVC, animated: false, completion: nil)
                    
                }else{
                    sideMenuController.view.alpha = 1.0
                }
            }else{
                sideMenuController.view.alpha = 1.0
            }
        }else{
            sideMenuController.view.alpha = 1.0
        }
    }
    
    func moveToCleaning(){
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let cleaningVC = storyboard.instantiateViewController(withIdentifier: "CleaningProcessVC") as! CleaningProcessVC
        self.navigationController?.pushViewController(cleaningVC, animated: false)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

