//
//  SplashVC.swift
//  VPNEvo
//
//  Created by Rootways on 21/03/22.
//

import UIKit
import LGSideMenuController
import Firebase

class SplashVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Temporary logout
//        do { let lgout = try Auth.auth().signOut() }
//        catch{}
        
        
        Singleton.sharedInstance.loadremoteConfig()
        Singleton.sharedInstance.loadInappItems()
        Singleton.sharedInstance.check_for_in_app_purchase()
    
        let currentLocale = NSLocale.current as NSLocale // get the current locale.
        let countryCode = currentLocale.object(forKey: .countryCode) as? String
        let languageCode = currentLocale.object(forKey: .languageCode) as? String
        let countryName = currentLocale.displayName(forKey: .countryCode, value: countryCode ?? "")

        Singleton.sharedInstance.currentCountry = countryCode
        Singleton.sharedInstance.currentCountryName = countryName
        Singleton.sharedInstance.currentLanguage = languageCode
        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { [self] timer in

            if Singleton.sharedInstance.isPurchased {
                loadApp()
                return
            }
            
            if !UserDefaults.standard.bool(forKey: "REMOETECONFIGLOADED") {
                Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { [self] timer in
                    loadApp()
                }
            } else {
                loadApp()
            }
        }
    }
    
    func checkLogin(){
        
//      do { let lgout = try Auth.auth().signOut() }
//        catch{}
//        return
        
        if Auth.auth().currentUser != nil {
            self.loadApp()
        } else {
            self.showSignIn()
        }
    }
    
    func showSignIn(){
        let stryboard = UIStoryboard.init(name: "Main", bundle: .main)
        let signinVC = stryboard.instantiateViewController(withIdentifier: "SignInVC") as! SignInVC
        self.navigationController?.pushViewController(signinVC, animated: true)
    }
    
    func loadApp(){
        
//        var showvirus = true
//        
//        if(Singleton.sharedInstance.currentLanguage == "en"){
//            
//            showvirus = (UserDefaults.standard.value(forKey: "show_virus") as? NSString)?.boolValue ?? false
//        }
        
        let showvirus = (UserDefaults.standard.value(forKey: "show_virus") as? NSString)?.boolValue ?? false
        
        
        if (showvirus){
            if (Singleton.sharedInstance.isPurchased) {
                
            }else{
                if(!(UserDefaults.standard.bool(forKey: "SeenVirus"))){
                    
                    UserDefaults.standard.set("Y", forKey: "ISAGREED")
                    UserDefaults.standard.set(true, forKey: "ISINTRODONE")
                    UserDefaults.standard.set(true, forKey: "SeenVirus")
                    UserDefaults.standard.synchronize()
                    self.showDetection()
                    return
                }
            }
        }
        
        
        if(UserDefaults.standard.object(forKey: "ISAGREED") == nil){
            
            if(UserDefaults.standard.value(forKey: "is_privacy") as? String == "Y"){
                
                self.movetoAgreement()
            }
            else{
                
                UserDefaults.standard.set("Y", forKey: "ISAGREED")
                UserDefaults.standard.synchronize()
                
                if(UserDefaults.standard.value(forKey: "skip_startup_iap") as? NSString)?.boolValue ?? false
                {
                    self.movetoHome(isFromStartup: true)
                }else{
                    
                    if(UserDefaults.standard.value(forKey: "ISINTRODONE") as? NSString)?.boolValue ?? false{
                        self.movetoHome(isFromStartup: true)
                    }
                    UserDefaults.standard.set(false, forKey: "ISINTRODONE")
                    UserDefaults.standard.synchronize()
                    self.movetoIntro()
                }
                
            }
        }
        else{
            self.movetoHome(isFromStartup: false)
        }
    }
    
    
    func movetoAgreement(){
        
        let privacyAcceptVC = self.storyboard?.instantiateViewController(withIdentifier: "PrivacyAcceptVC") as! PrivacyAcceptVC
        self.navigationController?.pushViewController(privacyAcceptVC, animated: true)
    }
    
    func movetoHome(isFromStartup:Bool!){
        
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        let navigationController = UINavigationController()
        navigationController.setViewControllers([homeVC], animated: true)
        
        let leftSideMenuViewController: UIViewController = storyboard.instantiateViewController(withIdentifier: "DrawerVC")
        let sideMenuController = LGSideMenuController(rootViewController: navigationController,
                                                      leftViewController: leftSideMenuViewController,
                                                              rightViewController: nil)
        

        sideMenuController.leftViewWidth = 300.0
        sideMenuController.isLeftViewStatusBarBackgroundHidden = true
        sideMenuController.delegate = leftSideMenuViewController as! LGSideMenuDelegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = sideMenuController
    }
    
    func movetoIntro(){
        
        let introVC = self.storyboard?.instantiateViewController(withIdentifier: "IntroVC") as! IntroVC
        self.navigationController?.pushViewController(introVC, animated: true)
    }


    func showDetection(){
        
        let systemScanVC = self.storyboard?.instantiateViewController(withIdentifier: "SystemScanVC") as! SystemScanVC
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.navigationController?.pushViewController(systemScanVC, animated: false)
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

