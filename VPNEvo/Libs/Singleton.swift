//
//  Singleton.swift
//  VPNEvo
//
//  Created by Rootways on 22/03/22.
//

import UIKit
import Firebase
import FirebaseRemoteConfig
import AudioToolbox
import RevenueCat

class Singleton: NSObject {

    var uname:String!
    var upass:String!
    var isPurchased = false
    var selectedServer:NSDictionary!
    var currentCountry:String!
    var currentCountryName:String!
    var currentLanguage:String!

    var inappItems:NSMutableArray!
    var remoteConfig:RemoteConfig!
    
    static let sharedInstance = Singleton()

    var currentLoginUserInfo: User?  {
        get {
            return Auth.auth().currentUser ?? nil
        }
    }
    
    func loadremoteConfig(){
     
        if remoteConfig == nil {
            remoteConfig = RemoteConfig.remoteConfig()
            let remoteConfigSettings = RemoteConfigSettings()
            remoteConfigSettings.minimumFetchInterval = 0
            remoteConfig.configSettings = remoteConfigSettings
            //remoteConfig.defaultsFromPlistFileName = "values_config"
            remoteConfig.setDefaults(fromPlist: "values_config")
        }
        
        let iap1btn = self.remoteConfig["IAP1_button"].stringValue
        let iap2btn = self.remoteConfig["IAP2_button"].stringValue
        let iaptext = self.remoteConfig["IAP_text"].stringValue
        let iapfontsize = self.remoteConfig["IAP_text_size"].stringValue
        let closeTime = self.remoteConfig["close_time"].stringValue
        let isWeeklyPrice = self.remoteConfig["show_weekly_price"].stringValue
        let isIapPrices = self.remoteConfig["show_iap_prices"].stringValue
        let isDynamicPrice = self.remoteConfig["dynamic_price"].stringValue
        let iap2_middle_text = self.remoteConfig["iap2_middle_text"].stringValue
        let is_privacy = self.remoteConfig["is_privacy"].stringValue
        let show_privacy_terms = self.remoteConfig["show_privacy_terms"].stringValue
        let currentPlan = self.remoteConfig["currentPlan"].stringValue
        let doublePayment = self.remoteConfig["doublePayment"].stringValue
        let sideMenu_singleIAP = self.remoteConfig["sideMenu_singleIAP"].stringValue


        let direct_purchase = self.remoteConfig["direct_purchase"].stringValue
        let currentPlan_connectButton = self.remoteConfig["currentPlan_connectButton"].stringValue
        let skip_startup_iap = self.remoteConfig["skip_startup_iap"].stringValue
        let show_addconfig_popup = self.remoteConfig["show_addconfig_popup"].stringValue
        let show_virus = self.remoteConfig["show_virus"].stringValue
        let is_app_free = self.remoteConfig["is_app_free"].stringValue
        let sale_bottom_text = self.remoteConfig["sale_bottom_text"].stringValue
        let show_sale = self.remoteConfig["show_sale"].stringValue
        
        let iap2_weekly_price_dynamic = self.remoteConfig["iap2_weekly_price_dynamic"].stringValue
        
        UserDefaults.standard.setValue(iap1btn, forKey:"IAP1_button")
        UserDefaults.standard.setValue(iap2btn, forKey:"IAP2_button")
        UserDefaults.standard.setValue(iaptext, forKey:"IAP_text")
        UserDefaults.standard.setValue(iapfontsize, forKey:"IAP_text_size")
        UserDefaults.standard.setValue(closeTime, forKey:"close_time")
        UserDefaults.standard.setValue(isWeeklyPrice, forKey:"show_weekly_price")
        UserDefaults.standard.setValue(isIapPrices, forKey:"show_iap_prices")
        UserDefaults.standard.setValue(isDynamicPrice, forKey:"dynamic_price")
        UserDefaults.standard.setValue(iap2_middle_text, forKey:"iap2_middle_text")
        UserDefaults.standard.setValue(is_privacy, forKey:"is_privacy")
        UserDefaults.standard.setValue(show_privacy_terms, forKey:"show_privacy_terms")
        UserDefaults.standard.setValue(currentPlan, forKey:"currentPlan")
        UserDefaults.standard.setValue(doublePayment, forKey:"doublePayment")
        UserDefaults.standard.setValue(direct_purchase, forKey:"direct_purchase")
        UserDefaults.standard.setValue(currentPlan_connectButton, forKey:"currentPlan_connectButton")
        UserDefaults.standard.setValue(skip_startup_iap, forKey:"skip_startup_iap")
        UserDefaults.standard.setValue(show_addconfig_popup, forKey:"show_addconfig_popup")
        UserDefaults.standard.setValue(sideMenu_singleIAP, forKey:"sideMenu_singleIAP")
        UserDefaults.standard.setValue(show_virus, forKey:"show_virus")
        UserDefaults.standard.setValue(is_app_free, forKey:"is_app_free")
        UserDefaults.standard.setValue(sale_bottom_text, forKey:"sale_bottom_text")
        UserDefaults.standard.setValue(show_sale, forKey:"show_sale")
        UserDefaults.standard.setValue(iap2_weekly_price_dynamic, forKey:"iap2_weekly_price_dynamic")
    
        
        UserDefaults.standard.synchronize()
        
        self.remoteConfig.fetch(withExpirationDuration: 0) { (status, error) in
           
            if(status == .success){
                
                self.remoteConfig.activate { changed, error in
                   
                    UserDefaults.standard.set(true, forKey: "REMOETECONFIGLOADED")
                    UserDefaults.standard.synchronize()
                    
                    let iap1btn = self.remoteConfig["IAP1_button"].stringValue
                    let iap2btn = self.remoteConfig["IAP2_button"].stringValue
                    let iaptext = self.remoteConfig["IAP_text"].stringValue
                    let iapfontsize = self.remoteConfig["IAP_text_size"].stringValue
                    let closeTime = self.remoteConfig["close_time"].stringValue
                    let isWeeklyPrice = self.remoteConfig["show_weekly_price"].stringValue
                    let isIapPrices = self.remoteConfig["show_iap_prices"].stringValue
                    let isDynamicPrice = self.remoteConfig["dynamic_price"].stringValue
                    let iap2_middle_text = self.remoteConfig["iap2_middle_text"].stringValue
                    let is_privacy = self.remoteConfig["is_privacy"].stringValue
                    let show_privacy_terms = self.remoteConfig["show_privacy_terms"].stringValue
                    let currentPlan = self.remoteConfig["currentPlan"].stringValue
                    let doublePayment = self.remoteConfig["doublePayment"].stringValue
                    let sideMenu_singleIAP = self.remoteConfig["sideMenu_singleIAP"].stringValue


                    let direct_purchase = self.remoteConfig["direct_purchase"].stringValue
                    let currentPlan_connectButton = self.remoteConfig["currentPlan_connectButton"].stringValue
                    let skip_startup_iap = self.remoteConfig["skip_startup_iap"].stringValue
                    let show_addconfig_popup = self.remoteConfig["show_addconfig_popup"].stringValue
                    let show_virus = self.remoteConfig["show_virus"].stringValue
                    let is_app_free = self.remoteConfig["is_app_free"].stringValue
                    let sale_bottom_text = self.remoteConfig["sale_bottom_text"].stringValue
                    let show_sale = self.remoteConfig["show_sale"].stringValue
                    let iap2_weekly_price_dynamic = self.remoteConfig["iap2_weekly_price_dynamic"].stringValue
                    
                    UserDefaults.standard.setValue(iap1btn, forKey:"IAP1_button")
                    UserDefaults.standard.setValue(iap2btn, forKey:"IAP2_button")
                    UserDefaults.standard.setValue(iaptext, forKey:"IAP_text")
                    UserDefaults.standard.setValue(iapfontsize, forKey:"IAP_text_size")
                    UserDefaults.standard.setValue(closeTime, forKey:"close_time")
                    UserDefaults.standard.setValue(isWeeklyPrice, forKey:"show_weekly_price")
                    UserDefaults.standard.setValue(isIapPrices, forKey:"show_iap_prices")
                    UserDefaults.standard.setValue(isDynamicPrice, forKey:"dynamic_price")
                    UserDefaults.standard.setValue(iap2_middle_text, forKey:"iap2_middle_text")
                    UserDefaults.standard.setValue(is_privacy, forKey:"is_privacy")
                    UserDefaults.standard.setValue(show_privacy_terms, forKey:"show_privacy_terms")
                    UserDefaults.standard.setValue(currentPlan, forKey:"currentPlan")
                    UserDefaults.standard.setValue(doublePayment, forKey:"doublePayment")
                    UserDefaults.standard.setValue(direct_purchase, forKey:"direct_purchase")
                    UserDefaults.standard.setValue(currentPlan_connectButton, forKey:"currentPlan_connectButton")
                    UserDefaults.standard.setValue(skip_startup_iap, forKey:"skip_startup_iap")
                    UserDefaults.standard.setValue(show_addconfig_popup, forKey:"show_addconfig_popup")
                    UserDefaults.standard.setValue(sideMenu_singleIAP, forKey:"sideMenu_singleIAP")
                    UserDefaults.standard.setValue(show_virus, forKey:"show_virus")
                    UserDefaults.standard.setValue(is_app_free, forKey:"is_app_free")
                    UserDefaults.standard.setValue(sale_bottom_text, forKey:"sale_bottom_text")
                    UserDefaults.standard.setValue(show_sale, forKey:"show_sale")
                    UserDefaults.standard.setValue(iap2_weekly_price_dynamic, forKey:"iap2_weekly_price_dynamic")
                                        
                    UserDefaults.standard.synchronize()
                }
            }
            
        }

    }
    
    func vibrateDevice() {
        AudioServicesPlaySystemSound(SystemSoundID(1519))
    }

    func check_for_in_app_purchase() {
        
        Purchases.shared.getCustomerInfo { (purchaserInfo, error) in
                    
            if purchaserInfo?.entitlements.all["pro"]?.isActive == true {
                
                UserDefaults.standard.set(true, forKey: "IAPSTATUS")
                UserDefaults.standard.synchronize()
                Singleton.sharedInstance.isPurchased = true
            }
            else
            {
                UserDefaults.standard.set(false, forKey: "IAPSTATUS")
                UserDefaults.standard.synchronize()
                Singleton.sharedInstance.isPurchased = false
            }
        }
    }
    

    func loadInappItems(){
     
        inappItems = NSMutableArray()
        
        Purchases.shared.getOfferings { (offerings, error) in
          
            if(offerings != nil){
                
                guard let all = offerings?.current?.availablePackages else {
                    print("Error finding weekly offering")
                    return
                }
                
                for pack in all
                {
                    let item:NSMutableDictionary! = NSMutableDictionary()
                    item["price"] = pack.localizedPriceString
                    item["identifier"] = pack.storeProduct.productIdentifier
                    item["package"] = pack
                    self.inappItems.add(item!)
                }
            }
            
        }
    }
}

@IBDesignable
public class Gradient: UIView {
    @IBInspectable var startColor:   UIColor = .black { didSet { updateColors() }}
    @IBInspectable var endColor:     UIColor = .white { didSet { updateColors() }}
    @IBInspectable var startLocation: Double =   0.05 { didSet { updateLocations() }}
    @IBInspectable var endLocation:   Double =   0.95 { didSet { updateLocations() }}
    @IBInspectable var horizontalMode:  Bool =  false { didSet { updatePoints() }}
    @IBInspectable var diagonalMode:    Bool =  false { didSet { updatePoints() }}

    override public class var layerClass: AnyClass { CAGradientLayer.self }

    var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }

    func updatePoints() {
        if horizontalMode {
            gradientLayer.startPoint = diagonalMode ? .init(x: 1, y: 0) : .init(x: 0, y: 0.5)
            gradientLayer.endPoint   = diagonalMode ? .init(x: 0, y: 1) : .init(x: 1, y: 0.5)
        } else {
            gradientLayer.startPoint = diagonalMode ? .init(x: 0, y: 0) : .init(x: 0.5, y: 0)
            gradientLayer.endPoint   = diagonalMode ? .init(x: 1, y: 1) : .init(x: 0.5, y: 1)
        }
    }
    func updateLocations() {
        gradientLayer.locations = [startLocation as NSNumber, endLocation as NSNumber]
    }
    func updateColors() {
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
    }
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updatePoints()
        updateLocations()
        updateColors()
    }

}

extension UIView{
    
    func addShadowWith(name:String,fillColor:UIColor,shadowColor:UIColor,cornerRadius:CGFloat) {
        
        self.layoutIfNeeded()
        self.layoutSubviews()
        var shadowLayer: CAShapeLayer!
        
        self.layer.borderWidth = 0
        self.layer.masksToBounds = false
        for layer in self.layer.sublayers! {
            if layer.name == name {
                layer.removeFromSuperlayer()
            }
        }
        
        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            shadowLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius).cgPath
            shadowLayer.fillColor = fillColor.cgColor
            shadowLayer.shadowColor = shadowColor.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 0.0, height: 17.0)
            shadowLayer.shadowOpacity = 0.2
            shadowLayer.shadowRadius = 33
            shadowLayer.name = name
            self.layer.insertSublayer(shadowLayer, at: 0)
        }
        self.layer.cornerRadius = cornerRadius
    }
    
    enum GlowEffect:Float{
        case small = 0.4, normal = 2, big = 10
    }
    
    func doGlowAnimation(withColor color:UIColor, withEffect effect:GlowEffect = .big) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowRadius = 10
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: 0, height: 4)
        
        let glowAnimation = CABasicAnimation(keyPath: "shadowRadius")
        glowAnimation.fromValue = 5
        glowAnimation.toValue = effect.rawValue
        glowAnimation.beginTime = CACurrentMediaTime()+0.3
        glowAnimation.duration = CFTimeInterval(0.3)
        glowAnimation.fillMode = CAMediaTimingFillMode.removed
        glowAnimation.autoreverses = true
        glowAnimation.isRemovedOnCompletion = true
        layer.add(glowAnimation, forKey: "shadowGlowingAnimation")
    }
}
