//
//  SaleVC.swift
//  VPNEvo
//
//  Created by iOSProfessionals on 09/05/22.
//

import UIKit
import RevenueCat
import NetworkExtension
import SwiftyGif
import FirebaseAnalytics
import YandexMobileMetrica
import AppsFlyerLib

class SaleVC: UIViewController {
    
    @IBOutlet weak var timerBG : UIView!
    @IBOutlet weak var lblMinutes: UILabel!
    //@IBOutlet weak var lblMinutesText: UILabel!
    @IBOutlet weak var lblSeconds: UILabel!
    //@IBOutlet weak var lblSecondsText: UILabel!
    //@IBOutlet weak var vwWait: UIView!
    //@IBOutlet weak var lbl_monthprice: UILabel!
    @IBOutlet weak var vwContinue: UIView!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet var activityView:Loader_VC!
    
    @IBOutlet weak var lblMainHeader: UILabel!
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    //@IBOutlet weak var lblTimerHeader: UILabel!
    
    var currentIAP:String!
    var isDynamic:Bool!
    var IAPProducts:NSMutableArray!
    var timer: Timer?
    var totalTime = 300

    var isDirectPurchase:Bool!
    var isDoublePayment:Bool!
    var vwgif = UIView()
    var issubscribe = Bool()
    
    var WeeklySaleProduct : RevenueCat.Package!
    var WeeklyProduct : RevenueCat.Package!

    var img1:UIView!
    var img2:UIView!
    var img3:UIView!
    var timerAnimation:Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        timerBG.layer.cornerRadius = 20
        lblMinutes.layer.cornerRadius = 10.0
        lblMinutes.layer.masksToBounds = true
        lblSeconds.layer.cornerRadius = 10.0
        lblSeconds.layer.masksToBounds = true
        
        vwContinue.layer.cornerRadius = 10.0
        vwContinue.layer.masksToBounds = true
                
//        let gradient = CAGradientLayer()
//        gradient.colors = [UIColor(red: 224.0/255.0, green: 155.0/255.0, blue: 93.0/255.0, alpha: 1.0).cgColor, UIColor(red: 254.0/255.0, green: 64.0/255.0, blue: 106.0/255.0, alpha: 1.0).cgColor]
//        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
//        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
//        gradient.frame = vwWait.bounds
//        vwWait.layer.addSublayer(gradient)
        
        self.view.applyGradient(colours: [UIColor.init(_colorLiteralRed: 0/255, green: 8/255, blue: 47/255, alpha: 1.0),UIColor.init(_colorLiteralRed: 81/255, green: 86/255, blue: 112/255, alpha: 1.0)])
        
        
//        let label = UILabel(frame: vwWait.bounds)
//        label.text = "WAIT!"
//        label.font = UIFont(name: "Arial Bold", size: 50.0)
//        label.textAlignment = .center
//        vwWait.addSubview(label)
//        vwWait.mask = label
        
        //Check if double payment ON/OFF
        self.isDoublePayment = false
        
        if(UserDefaults.standard.value(forKey: "doublePayment") as? NSString)?.boolValue ?? false {
            self.isDoublePayment = true
        }
        
        startOtpTimer()
        
        self.lblMainHeader.text = NSLocalizedString("Limited Offer", comment: "Limited Offer")
        self.lblHeader.text = NSLocalizedString("You Have Unlocked Our Secret Offer!", comment: "")
        //self.lblTimerHeader.text = NSLocalizedString("Hurry! We can't hold this offer for too long:", comment: "")
        self.btnContinue.setTitle(NSLocalizedString("Get This Secret Offer", comment: "Get This Secret Offer"), for: .normal)
        self.lblDescription.text = NSLocalizedString("Unlock all Features For Half Price", comment: "Unlock all Features For Half Price")
        //self.lblMinutesText.text = NSLocalizedString("Minutes", comment: "")
        //self.lblSecondsText.text = NSLocalizedString("Seconds", comment: "")
        
        self.startAnimation()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.currentIAP = UserDefaults.standard.value(forKey: "currentPlan") as? String ?? ""
        
        self.isDynamic = (UserDefaults.standard.value(forKey: "dynamic_price") as? NSString)?.boolValue ?? false
        self.isDirectPurchase = (UserDefaults.standard.value(forKey: "direct_purchase") as? NSString)?.boolValue ?? false
        self.loadPricing()
    }
    
    
    func startAnimation() {
        
        if (self.timerAnimation != nil) {
            self.timerAnimation.invalidate()
            self.timerAnimation = nil
        }
        
        timerAnimation = Timer.scheduledTimer(withTimeInterval: 2.3, repeats: true, block: { Timer in
            self.loadAnimation()
        })
    }
    
    func stopAnimation(){
        
        if (self.timerAnimation != nil) {
            self.timerAnimation.invalidate()
            self.timerAnimation = nil
        }
        
        UIView.animate(withDuration: 0.5) {
            self.vwContinue.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
    }
    
    func loadAnimation() {
        
        let speed = 0.2
        
        UIView.animate(withDuration: speed, delay: 0, options: .allowUserInteraction) {
            self.vwContinue.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            self.btnContinue.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        } completion: { Bool in
            UIView.animate(withDuration: speed, delay: 0, options: .allowUserInteraction) {
                self.vwContinue.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                self.btnContinue.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            } completion: { Bool in
                UIView.animate(withDuration: speed, delay: 0, options: .allowUserInteraction) {
                    self.vwContinue.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                    self.btnContinue.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                } completion: { Bool in
                    UIView.animate(withDuration: speed, delay: 0, options: .allowUserInteraction) {
                        self.vwContinue.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                        self.btnContinue.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    } completion: { Bool in
                        
                    }
                }
            }
        }

        
        
//        UIView.animate(withDuration: speed, animations: { [self] in
//            vwContinue.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
//            self.btnContinue.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
//        }) { [self] finished in
//            UIView.animate(withDuration: speed, animations: { [self] in
//                vwContinue.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
//                btnContinue.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
//            }) { [self] finished in
//                //spiralAnimation()
//                UIView.animate(withDuration: speed, animations: { [self] in
//                    vwContinue.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
//                    self.btnContinue.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
//                }) { [self] finished in
//                    UIView.animate(withDuration: speed, animations: { [self] in
//                        vwContinue.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
//                        btnContinue.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
//                    }) { [self] finished in
//                        //spiralAnimation()
//                    }
//                }
//            }
//        }
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
            
      
        img1 = UIView(frame: vwContinue.frame)
        img1.layer.borderColor = UIColor(red: 226.0 / 255.0, green: 151.0 / 255.0, blue: 93.0 / 255.0, alpha: 1.0).cgColor
        img1.layer.borderWidth = 2.0
        img1.layer.cornerRadius = 10.0
        
        img2 = UIView(frame: vwContinue.frame)
        img2.layer.borderColor = UIColor(red: 226.0 / 255.0, green: 151.0 / 255.0, blue: 93.0 / 255.0, alpha: 1.0).cgColor
        img2.layer.borderWidth = 2.0
        img2.layer.cornerRadius = 10.0
        
        img3 = UIImageView(frame: vwContinue.frame)
        img3.layer.borderColor = UIColor(red: 226.0 / 255.0, green: 151.0 / 255.0, blue: 93.0 / 255.0, alpha: 1.0).cgColor
        img3.layer.borderWidth = 2.0
        img3.layer.cornerRadius = 10.0
    
    }
    
    //MARK: - Timer down
        
    func startOtpTimer() {
        self.totalTime = 300
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
//        print(self.totalTime)
//        print(self.timeFormatted(self.totalTime))
        let totaltime = self.timeFormatted(self.totalTime) // will show timer
        let arystr = totaltime.components(separatedBy: ":")
        self.lblMinutes.text = arystr[0]
        self.lblSeconds.text = arystr[1]
        
        if totalTime != 0 {
            totalTime -= 1  // decrease counter timer
        } else {
            if let timer = self.timer {
                timer.invalidate()
                self.timer = nil
                self.close()
            }
        }
    }
    
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        return String(format: "%2d:%02d", minutes, seconds)
    }
    
    func loadPricing(){
        
        
        //self.lbl_monthprice.isHidden = false
        
        let ipaText = UserDefaults.standard.value(forKey: "sale_bottom_text") as? String ?? ""
        //self.lbl_monthprice.text = ipaText
            
        
        
        Purchases.shared.getOfferings { (offerings, error) in
            if let e = error {
                print(e.localizedDescription)
            }
            
            guard let all = offerings?.current?.availablePackages else {
                print("Error finding weekly offering")
                return
            }
            
            let locale = Locale.current
            let currencySymbol = locale.currencySymbol!
            
            for itme in all
            {
                
                if itme.storeProduct.productIdentifier == kWeeklySaleIAP {
                    self.WeeklySaleProduct = itme
                }
            }
        }
    }

    @IBAction func close(){
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK:- continue
    
    @IBAction func btncontinue() {
        startPurchase()
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
      
        if ((self.WeeklySaleProduct == nil)) {
            self.hideLoader()
            return
        }
        self.purchasePackage(package: self.WeeklySaleProduct)
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
            self.hideLoader()
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
                    self.close()
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
                print("Pro feature granted !!")
                let dic : [String: Any] = ["af_price":package.localizedPriceString,
                                           "af_revenue":package.localizedPriceString]
                AppsFlyerLib.shared().logEvent(AFEventStartTrial, withValues: dic)
                AppsFlyerLib.shared().logEvent(AFEventSubscribe, withValues: dic)
                
                let dicY : [String: Any] = ["Revenue":package.localizedPriceString]
                YMMYandexMetrica.reportEvent("Subscribed", parameters: dicY) { error in
                    print(error.localizedDescription)
                }
                self.close()
                
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
    
      func applyGradient(colours: [UIColor]) -> CAGradientLayer {
        return self.Gradient(colours: colours, locations: nil)
    }

    func Gradient(colours: [UIColor], locations: [NSNumber]?) -> CAGradientLayer {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.startPoint = .init(x: 0.5, y: 0.2)
        gradient.endPoint = .init(x: 0.5, y: 1)
        self.layer.insertSublayer(gradient, at: 0)
        return gradient
    }
}
