//
//  AppDelegate.swift
//  VPNEvo
//
//  Created by Rootways on 14/03/22.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseCore
import FirebaseAnalytics
import RevenueCat
import YandexMobileMetrica
import AppsFlyerLib
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate, AppsFlyerLibDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        IQKeyboardManager.shared.enable = true
                
        FirebaseApp.configure()
        Analytics.logEvent("AppLaunched", parameters: nil)
        
        //Settings.isAutoLogAppEventsEnabled = true
        
        Purchases.debugLogsEnabled = true
        Purchases.configure(withAPIKey: "appl_AmHuhPRBvoceKVGYurzHxAffrgw", appUserID: nil)
        
        if #available(iOS 14.3, *) {
            Purchases.shared.attribution.enableAdServicesAttributionTokenCollection()
        } else {
            // Fallback on earlier versions
        }
        
        AppsFlyerLib.shared().appsFlyerDevKey = "m4UYz9kLdG9CnrJ3zLGAHP"
        AppsFlyerLib.shared().appleAppID = "1459783875"
        AppsFlyerLib.shared().delegate = self
        AppsFlyerLib.shared().isDebug = false
        
        let configuration = YMMYandexMetricaConfiguration.init(apiKey: "b847da78-4a41-48d1-af92-b9d966f03058")
        YMMYandexMetrica.activate(with: configuration!)
        
//        kAppMetricaKey @"b847da78-4a41-48d1-af92-b9d966f03058"
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let splashVC = storyboard.instantiateViewController(withIdentifier: "SplashVC") as! SplashVC
        let navigationController = UINavigationController()
        navigationController.setViewControllers([splashVC], animated: true)
        navigationController.isNavigationBarHidden = true
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
        return true
    }
    
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }

    
    func downloadServers(){
                
        let filename = getDocumentsDirectory().appendingPathComponent("servers_new.json")
        
        let downloadTask = Storage.storage().reference(forURL: "gs://titan-vpn.appspot.com/servers_V4.4.json").write(toFile: filename)

            downloadTask.observe(.resume) { snapshot in
                // Download resumed, also fires when the download starts
                print("Download resumed, also fires when the download starts")
            }

            downloadTask.observe(.pause) { snapshot in
                // Download paused
                print("Download paused")
            }

            downloadTask.observe(.progress) { snapshot in
                // Download reported progress
            }

            downloadTask.observe(.success) { snapshot in
                // Download completed successfully
                print("Download completed successfully")
                self.getCountryList()
            }

            // Errors only occur in the "Failure" case
            downloadTask.observe(.failure) { snapshot in
            }
    }
    
    func getCountryList(){
        
        let filename = getDocumentsDirectory().appendingPathComponent("servers_new.json")
        
        if FileManager().fileExists(atPath: filename.path){
            let configurationFileContent = try? Data(contentsOf: filename)
                    do {
                        let jsonResult: NSDictionary = try JSONSerialization.jsonObject(with: configurationFileContent! as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                        
                        if((UserDefaults.standard.object(forKey: "CURRENTSERVER")) == nil){
                            if let quick : [NSDictionary] = jsonResult["quick"] as? [NSDictionary] {
                                if quick.count > 0 {
                                    let item = quick[3]
                                    UserDefaults.standard.set(item, forKey: "CURRENTSERVER")
                                    UserDefaults.standard.synchronize()
                                    //break
                                }
    //                            for tmpDict in quick {
    //                                if tmpDict.count > 0 {
    //                                    let item = tmpDict[0]
    //
    //                                }
    //                            }
                            }
                        }
                    }
            catch {}
        }
        else{
            //Copy file from resources to document directory because file not downloaded.
            let docName = "servers_new"
            let docExt = "json"
            copyFileToDocumentsFolder(nameForFile: docName, extForFile: docExt)
        }
    }
    
    func copyFileToDocumentsFolder(nameForFile: String, extForFile: String) {

        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let destURL = documentsURL!.appendingPathComponent(nameForFile).appendingPathExtension(extForFile)
        guard let sourceURL = Bundle.main.url(forResource: nameForFile, withExtension: extForFile)
            else {
                print("Source File not found.")
                return
        }
            let fileManager = FileManager.default
            do {
                try fileManager.copyItem(at: sourceURL, to: destURL)
            } catch {
                print("Unable to copy file")
            }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
        self.downloadServers()
        Singleton.sharedInstance.check_for_in_app_purchase()
        Singleton.sharedInstance.loadremoteConfig()
        
        NotificationCenter.default.post(name: NSNotification.Name("CheckBlockerStatus"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name("FetchConfig"), object: nil)
        
    }
        
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        
    }
    
    func onConversionDataFail(_ error: Error) {
        print(error)
    }
    
    

}

