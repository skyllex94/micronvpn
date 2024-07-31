//
//  SubcriptionVC.swift
//  VPNEvo
//
//  Created by Rootways on 17/03/22.
//

import UIKit
import RevenueCat
import FirebaseAnalytics
import AppsFlyerLib
import YandexMobileMetrica
import Pastel

class SubcriptionVC: UIViewController {

    @IBOutlet var lblHeader:UILabel!
    
    @IBOutlet var lbl1:UILabel!
    @IBOutlet var lbl2:UILabel!
    @IBOutlet var lbl3:UILabel!
    @IBOutlet var lbl4:UILabel!
    @IBOutlet var lbl5:UILabel!
    @IBOutlet var lbl6:UILabel!
    @IBOutlet var lbl7:UILabel!
    
    @IBOutlet var weekView:UIView!
    @IBOutlet var LabelWeekTitle:UILabel!
    @IBOutlet var LabelWeekPrice:UILabel!
    
    @IBOutlet var yearView:UIView!
    @IBOutlet var LabelYearTitle:UILabel!
    @IBOutlet var LabelYearPrice:UILabel!
    @IBOutlet var LabelBestDeal:UILabel!
    
    @IBOutlet var LabelPrice:UILabel!
    @IBOutlet var btnSubcribeNow:UIButton!
    @IBOutlet var activityView:Loader_VC!
    
    @IBOutlet var btnPrivcy:UIButton!
    @IBOutlet var btnRestore:UIButton!
    @IBOutlet var btnTerms:UIButton!
    
    
    var IAPProducts:NSMutableArray!
    var currentIAP:String!
    var isDynamic:Bool!
    var isDoublePayment:Bool!
    
    var img1:UIView!
    var img2:UIView!
    var img3:UIView!
    var timerAnimation:Timer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        lblHeader.text = NSLocalizedString("Get Full Access", comment: "header")
        lbl1.text = NSLocalizedString("Unlimited & fast servers", comment: "lbl1")
        lbl2.text = NSLocalizedString("Multiple Locations", comment: "lbl2")
        lbl3.text = NSLocalizedString("Secure & private connection", comment: "lbl3")
        lbl4.text = NSLocalizedString("Anonymous surfing", comment: "lbl4")
        lbl5.text = NSLocalizedString("Ad blocker", comment: "Ad blocker")
        lbl6.text = NSLocalizedString("Multi device support", comment: "Multi device support")
        lbl7.text = NSLocalizedString("Kill switch", comment: "Kill switch")
        
        LabelWeekTitle.text = NSLocalizedString("1 Week", comment: "week")
        LabelYearTitle.text = NSLocalizedString("1 Year", comment: "year")
        LabelBestDeal.text = NSLocalizedString("BEST DEAL", comment: "best deal")
        LabelPrice.text = NSLocalizedString("Try Risk Free", comment: "price")
        
        btnSubcribeNow.setTitle(NSLocalizedString("Subcribe now", comment: "subcribe"), for: .normal)
        
        weekView.layer.cornerRadius = 10.0
        weekView.layer.borderWidth = 2.0
        weekView.layer.borderColor = UIColor(red: 8.0/255.0, green: 132.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
        weekView.layer.masksToBounds = true
        weekView.backgroundColor = UIColor(red: 43.0/255.0, green: 43.0/255.0, blue: 43.0/255.0, alpha: 1.0)
        
        yearView.layer.cornerRadius = 10.0
        yearView.layer.borderWidth = 2.0
        yearView.layer.borderColor = UIColor.darkGray.cgColor
        yearView.layer.masksToBounds = true
        
        LabelBestDeal.layer.cornerRadius = 5.0
        LabelBestDeal.layer.masksToBounds = true
        
        btnSubcribeNow.layer.cornerRadius = 10.0
        btnSubcribeNow.layer.masksToBounds = true
        
        btnPrivcy.setTitle(NSLocalizedString("Privacy Policy", comment: "privacypolicy"), for: .normal)
        btnRestore.setTitle(NSLocalizedString("Restore", comment: "restore"), for: .normal)
        btnTerms.setTitle(NSLocalizedString("Terms of Use", comment: "Terms of Use"), for: .normal)
        
        self.currentIAP = kWeeklyIAP
        
        let btnTitle = UserDefaults.standard.value(forKey: "IAP2_button") as? String
        let iap2_middle_text = UserDefaults.standard.value(forKey:"iap2_middle_text") as? String
        
        if(Singleton.sharedInstance.currentLanguage == "en"){
            
            self.btnSubcribeNow.setTitle(btnTitle, for: .normal)
            self.LabelPrice.text = iap2_middle_text
        }
        
        UserDefaults.standard.set(false, forKey:"purchasesales")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        if UserDefaults.standard.bool(forKey: "purchasesales") {
            btnCloseAction()
            return
        }
        
        self.startAnimation()
        
        self.isDoublePayment = false
        
        if(UserDefaults.standard.value(forKey: "doublePayment") as? NSString)?.boolValue ?? false
        {
            self.isDoublePayment = true
        }
        
        let btnTitle = UserDefaults.standard.value(forKey: "IAP2_button") as? String ?? ""
        let isWeekly = (UserDefaults.standard.value(forKey: "show_weekly_price") as? NSString)?.boolValue ?? false
          
        var font = UserDefaults.standard.integer(forKey: "IAP_text_size")
           
        if UIDevice.current.userInterfaceIdiom == .pad {
            font = font + 10;
        }else{
            
            let safeTop = UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0
            if(safeTop > 20){
                font = font + 2
            }
            
        }
        
        
        let iap2_middle_text = UserDefaults.standard.value(forKey: "iap2_middle_text") as? String ?? ""
        
        if(Singleton.sharedInstance.currentLanguage == "en"){
            
            self.btnSubcribeNow.setTitle(btnTitle, for: .normal)
            self.LabelPrice.text = iap2_middle_text
        }
                
        self.loadPricing()
    }
    
    func startAnimation() {
        
        if (self.timerAnimation != nil) {
            self.timerAnimation.invalidate()
            self.timerAnimation = nil
        }
        
        timerAnimation = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true, block: { Timer in
            self.loadAnimation()
        })
    }
    
    func stopAnimation(){
        
        if (self.timerAnimation != nil) {
            self.timerAnimation.invalidate()
            self.timerAnimation = nil
        }
        
        UIView.animate(withDuration: 0.5) {
            self.btnSubcribeNow.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
    }
    
    func loadAnimation() {
        
        UIView.animate(withDuration: 0.5, animations: { [self] in
            btnSubcribeNow.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { [self] finished in
            UIView.animate(withDuration: 0.5, animations: { [self] in
                btnSubcribeNow.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }) { [self] finished in
                spiralAnimation()
            }
        }
    }
    
    func spiralAnimation() {

        let delayInSeconds = 0.0
        let popTime = DispatchTime.now() + Double(Int64(delayInSeconds * Double(NSEC_PER_SEC)))
        DispatchQueue.main.asyncAfter(deadline: popTime, execute: { [self] in
            self.view.addSubview(img1)
            UIView.animate(withDuration: 0.7, animations: { [self] in
                img1.transform = CGAffineTransform(scaleX: 1.1, y: 1.5)
                img1.alpha = 0.0
            }) { [self] finished in
                UIView.animate(withDuration: 0.1, animations: { [self] in
                    img1.alpha = 0.0
                }) { [self] finished in
                    img1.removeFromSuperview()
                    img1.alpha = 1.0
                    img1.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                }

            }
        })
        
        let delayInSeconds2 = 0.3
        let popTime2 = DispatchTime.now() + Double(Int64(delayInSeconds2 * Double(NSEC_PER_SEC)))
        DispatchQueue.main.asyncAfter(deadline: popTime2, execute:{ [self] in
            self.view.addSubview(img2)
            UIView.animate(withDuration: 0.7, animations: { [self] in
                img2.transform = CGAffineTransform(scaleX: 1.1, y: 1.5)
                img2.alpha = 0.0
            }) { [self] finished in
                UIView.animate(withDuration: 0.1, animations: { [self] in
                    img2.alpha = 0.0
                }) { [self] finished in
                    img2.removeFromSuperview()
                    img2.alpha = 1.0
                    img2.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                }
            }
        })
        
        let delayInSeconds3 = 0.6
        let popTime3 = DispatchTime.now() + Double(Int64(delayInSeconds3 * Double(NSEC_PER_SEC)))
        DispatchQueue.main.asyncAfter(deadline: popTime3, execute:{ [self] in
            self.view.addSubview(img3)
            UIView.animate(withDuration: 0.7, animations: { [self] in
                img3.transform = CGAffineTransform(scaleX: 1.1, y: 1.5)
                img3.alpha = 0.0
            }) { [self] finished in
                UIView.animate(withDuration: 0.1, animations: { [self] in
                    img3.alpha = 0.0
                }) { [self] finished in
                    img3.removeFromSuperview()
                    img3.alpha = 1.0
                    img3.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                }
            }
        })
            
      
        img1 = UIView(frame: btnSubcribeNow.frame)
        img1.layer.borderColor = UIColor(red: 8.0 / 255.0, green: 132.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0).cgColor
        img1.layer.borderWidth = 2.0
        img1.layer.cornerRadius = 10.0
        
        img2 = UIView(frame: btnSubcribeNow.frame)
        img2.layer.borderColor = UIColor(red: 8.0 / 255.0, green: 132.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0).cgColor
        img2.layer.borderWidth = 2.0
        img2.layer.cornerRadius = 10.0
        
        img3 = UIImageView(frame: btnSubcribeNow.frame)
        img3.layer.borderColor = UIColor(red: 8.0 / 255.0, green: 132.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0).cgColor
        img3.layer.borderWidth = 2.0
        img3.layer.cornerRadius = 10.0
    }
    
    @IBAction func btnCloseAction(){
        Singleton.sharedInstance.vibrateDevice()
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnWeekAction(){
        Singleton.sharedInstance.vibrateDevice()
        
        weekView.layer.cornerRadius = 10.0
        weekView.layer.borderWidth = 2.0
        weekView.layer.borderColor = UIColor(red: 8.0/255.0, green: 132.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
        weekView.layer.masksToBounds = true
        weekView.backgroundColor = UIColor(red: 43.0/255.0, green: 43.0/255.0, blue: 43.0/255.0, alpha: 1.0)
        
        yearView.layer.cornerRadius = 10.0
        yearView.layer.borderWidth = 2.0
        yearView.layer.borderColor = UIColor.darkGray.cgColor
        yearView.layer.masksToBounds = true
        yearView.backgroundColor = UIColor.clear
        
        self.currentIAP = kWeeklyIAP
    }
    
    @IBAction func btnYearAction(){
        Singleton.sharedInstance.vibrateDevice()
        
        weekView.layer.cornerRadius = 10.0
        weekView.layer.borderWidth = 2.0
        weekView.layer.borderColor = UIColor.darkGray.cgColor
        weekView.layer.masksToBounds = true
        weekView.backgroundColor = UIColor.clear
        
        yearView.layer.cornerRadius = 10.0
        yearView.layer.borderWidth = 2.0
        yearView.layer.borderColor = UIColor(red: 8.0/255.0, green: 132.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
        yearView.layer.masksToBounds = true
        yearView.backgroundColor = UIColor(red: 43.0/255.0, green: 43.0/255.0, blue: 43.0/255.0, alpha: 1.0)
        
        self.currentIAP = kYearlyIAP
    }
    
    @IBAction func btnSubcribeNowAction(){
        Singleton.sharedInstance.vibrateDevice()
        
        if (self.isDoublePayment) {
            
            if(UserDefaults.standard.bool(forKey: "SHOWIAPAGAIN"))
            {
                UserDefaults.standard.set(true, forKey: "SHOWIAPAGAIN")
            }
            else{
                UserDefaults.standard.set(true, forKey: "SHOWIAPAGAIN")
            }
            UserDefaults.standard.synchronize()
        }
        
        if(UserDefaults.standard.bool(forKey: "SHOWIAPAGAIN"))
        {
            Singleton.sharedInstance.vibrateDevice()
        }
        
        self.showLoader()
        
        if (self.currentIAP == nil) {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.hideLoader()
            }
            
    
        }
        
        var productWillPurchase:RevenueCat.Package?
        
        for i in 0 ..< Singleton.sharedInstance.inappItems.count{
            
            let item = Singleton.sharedInstance.inappItems[i] as! NSMutableDictionary
            
            if(item["identifier"] as? String == self.currentIAP){
                
                productWillPurchase = item["package"] as? RevenueCat.Package
            }
        }
        
        
        if(productWillPurchase == nil){
            
            self.hideLoader()
        }
        else{
            
            self.purchasePackage(package: productWillPurchase)
            
        }
       
        
        
    }

    func purchasePackage(package:RevenueCat.Package!){
        
        self.showLoader()
        
        Purchases.shared.purchase(package: package) {
            
            (transaction, purchaserInfo, error, userCancelled) in
        
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
                
                let dic : [String: Any] = ["af_price":package.localizedPriceString,
                                           "af_revenue":package.localizedPriceString]
                AppsFlyerLib.shared().logEvent(AFEventStartTrial, withValues: dic)
                AppsFlyerLib.shared().logEvent(AFEventSubscribe, withValues: dic)
                
                let dicY : [String: Any] = ["Revenue":package.localizedPriceString]
                YMMYandexMetrica.reportEvent("Subscribed", parameters: dicY) { error in
                    print(error.localizedDescription)
                }
                print("Pro feature granted !!")
                self.btnCloseAction()
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
                                    saleVC.issubscribe = true
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
                            saleVC.issubscribe = true
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
                
            }
            
        }
    }
    
    // MARK: - privacy
    
    @IBAction func btnPrivacyAction(){
        Singleton.sharedInstance.vibrateDevice()
        
        let privacyVC = self.storyboard?.instantiateViewController(withIdentifier: "PrivacyVC") as! PrivacyVC
        self.navigationController?.pushViewController(privacyVC, animated: true)
        
    }
    
    // MARK: - Terms of Use
    
    @IBAction func btnTermsAction(){
        Singleton.sharedInstance.vibrateDevice()
        
        let termsVC = self.storyboard?.instantiateViewController(withIdentifier: "TermsVC") as! TermsVC
        self.navigationController?.pushViewController(termsVC, animated: true)
    }
    
    func loadPricing(){
        
        self.IAPProducts = NSMutableArray()
        
        if(Singleton.sharedInstance.inappItems.count >= 2){
            
            for i in 0 ..< Singleton.sharedInstance.inappItems.count{
                
                let product = Singleton.sharedInstance.inappItems[i] as! NSMutableDictionary
                
                if(product["identifier"] as? String == kWeeklyIAP){
                    if(UserDefaults.standard.value(forKey: "iap2_weekly_price_dynamic") as? NSString)?.boolValue ?? false{
                        self.LabelWeekPrice.text = product["price"] as? String ?? ""
                    }else{
                        self.LabelWeekPrice.text = "$3.99"
                    }                    
                }
                if(product["identifier"] as? String == kYearlyIAP){
                    self.LabelYearPrice.text = product["price"] as? String ?? ""
                }
            }
            
        }
        else{
            
            self.showLoader()
            
            Singleton.sharedInstance.loadInappItems()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                
                self.hideLoader()
                
                if Singleton.sharedInstance.inappItems.count >= 2 {
                    
                    for i in 0 ..< Singleton.sharedInstance.inappItems.count{
                    
                        let product = Singleton.sharedInstance.inappItems[i] as! NSMutableDictionary
                        if(product["identifier"] as! String == kWeeklyIAP){
                            if let value = product["price"] {
                                if(UserDefaults.standard.value(forKey: "iap2_weekly_price_dynamic") as? NSString)?.boolValue ?? false{
                                    self.LabelWeekPrice.text = "\(value)"
                                }else{
                                    self.LabelWeekPrice.text = "$3.99"
                                }
                                
                            }
                            
                        }
                        if(product["identifier"] as! String == kYearlyIAP){
                            if let value = product["price"] {
                                self.LabelYearPrice.text = "\(value)"
                            }
                            
                        }
                    }
                    
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
