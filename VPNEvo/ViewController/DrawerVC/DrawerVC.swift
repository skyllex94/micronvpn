//
//  DrawerVC.swift
//  VPNEvo
//
//  Created by Rootways on 14/03/22.
//

import UIKit
import LGSideMenuController
import MessageUI
import RevenueCat
import FirebaseAnalytics
import AppsFlyerLib
import YandexMobileMetrica
import FirebaseAuth

class ModelOptions{
    
    var imgName:String!
    var option:String!
    
    init(imgName:String!,option:String!){
        
        self.imgName = imgName
        self.option = option
    }
}

class DrawerVC: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {
    
    @IBOutlet var tblMenu:UITableView!
    var arrayMenuOption = [ModelOptions]()
    
    @IBOutlet weak var lblBannerTitle: UILabel!
    @IBOutlet weak var lblBannerDescription: UILabel!
    @IBOutlet weak var imgPremiumX: NSLayoutConstraint!
    @IBOutlet weak var lblKillSwitch: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpMenuOptions()
        
        tblMenu.delegate = self
        tblMenu.dataSource = self
        tblMenu.tableFooterView = UIView()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.lblKillSwitch.text = NSLocalizedString("Kill switch", comment: "Kill switch")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setUpMenuOptions() {
        
        arrayMenuOption.removeAll()
        
        var modelOption = ModelOptions(imgName: "home2022", option: NSLocalizedString("HOME", comment: "HOME"))
        arrayMenuOption.append(modelOption)
        
        modelOption = ModelOptions(imgName: "subscription2022", option: NSLocalizedString("SUBSCRIPTION", comment: "SUBCRIPTION"))
        arrayMenuOption.append(modelOption)
        
        modelOption = ModelOptions(imgName: "restore2022", option: NSLocalizedString("RESTORE", comment: "RESTORE"))
        arrayMenuOption.append(modelOption)
        
        modelOption = ModelOptions(imgName: "rating2022", option: NSLocalizedString("RATE APP", comment: "RATE APP"))
        arrayMenuOption.append(modelOption)
        
        modelOption = ModelOptions(imgName: "contactus2022", option: NSLocalizedString("CONTACT US", comment: "CONTACT US"))
        arrayMenuOption.append(modelOption)
        
        modelOption = ModelOptions(imgName: "share2022", option: NSLocalizedString("SHARE APP", comment: "SHARE APP"))
        arrayMenuOption.append(modelOption)
        
        modelOption = ModelOptions(imgName: "privacy2022", option: NSLocalizedString("PRIVACY POLICY", comment: "PRIVACY POLICY"))
        arrayMenuOption.append(modelOption)
        
        modelOption = ModelOptions(imgName: "terms2022", option: NSLocalizedString("TERMS & CONDITIONS", comment: "TERMS & CONDITIONS"))
        arrayMenuOption.append(modelOption)
        
        modelOption = ModelOptions(imgName: "adblocker2022", option: NSLocalizedString("AD BLOCKER", comment: "AD BLOCKER"))
        arrayMenuOption.append(modelOption)
        
        modelOption = ModelOptions(imgName: "login_2022", option: NSLocalizedString("SIGN IN", comment: "SIGN IN"))
        arrayMenuOption.append(modelOption)
        
        tblMenu.reloadData()
    }
    
    func checkIfPaidforBanner(){
        if Singleton.sharedInstance.isPurchased{
            self.lblBannerTitle.text = NSLocalizedString("VPN Premium", comment: "")
            self.lblBannerDescription.isHidden = true
            self.imgPremiumX.constant = 75
        }else{
            self.lblBannerTitle.text = NSLocalizedString("Start your free 3 day trial", comment: "")
            self.lblBannerDescription.text = NSLocalizedString("Go Pro to unlock all countries", comment: "")
            self.lblBannerDescription.isHidden = false
            self.imgPremiumX.constant = 30
        }
    }
    
    @IBAction func changeKillSwitch (sender: UISwitch){
        
        if !Singleton.sharedInstance.isPurchased{
            sender.isOn = false
            self.sideMenuController?.hideLeftView(animated: true) { [self] in
                self.moveToSubscription()
            }
            return
        }
        var msg = ""
        if sender.isOn{
            msg = "Kill switch protection has been enabled."
        }else{
            msg = "Kill switch protection has been disabled."
        }
        let alert = UIAlertController(title:"Message", message:  msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - table view delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arrayMenuOption.count
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "DrawerCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DrawerCell
        
        let modelOption = arrayMenuOption[indexPath.row]
        
        cell.imgView.image = UIImage(named: modelOption.imgName)
        if modelOption.option == "SIGN IN" {
            if Singleton.sharedInstance.currentLoginUserInfo != nil {
                cell.LabelOption.text = Singleton.sharedInstance.currentLoginUserInfo?.email
            }else{
                cell.LabelOption.text = modelOption.option
            }
        }else{
            cell.LabelOption.text = modelOption.option
        }
        
        cell.LabelOption.font = UIFont(name: "BB Anonym Pro Medium", size: 14.0)
       
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(indexPath.row == 0){
            
            self.sideMenuController?.hideLeftView()
            
        }
        else if(indexPath.row == 1){
            
            self.sideMenuController?.hideLeftView(animated: true) { [self] in
                self.moveToSubscription()
            }
        }
        else if(indexPath.row == 2){
            
            Purchases.shared.restorePurchases { (purchaserInfo, error) in
                            
                
                if let e = error {
                                    
                    print(e)
                    return
                }
                
                if purchaserInfo?.entitlements["pro"]?.isActive != true {
                   
                    
                    return
                } else {
                    
                   print("Subscription restored")
                   
                }
            }
        }
        else if(indexPath.row == 3){
            
            self.sideMenuController?.hideLeftView(animated: true) { [self] in

                let rateUsVC = self.storyboard?.instantiateViewController(withIdentifier: "RateUsVC") as! RateUsVC
                (sideMenuController?.rootViewController as? UINavigationController)?.pushViewController(rateUsVC, animated: true)
            }
            
        }
        else if(indexPath.row == 4){
            
            if !MFMailComposeViewController.canSendMail()
            {
                let alert = UIAlertController(title:"Alert", message:  "Email cannot be configure.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
                
            }
            else
            {
                let composeVC = MFMailComposeViewController()
                composeVC.mailComposeDelegate = self
                composeVC.setSubject("MicronVPN Support")
                composeVC.setToRecipients(["zionstudiosapps@gmail.com"])
                self.present(composeVC, animated: true, completion: nil)
            }
            
        }
        else if(indexPath.row == 5){
            
            let text = "Hey, try out this premium VPN I'm using called MicronVPN - http://itunes.apple.com/app/id1459783875"
            
            let dic : [String: Any] = ["af_description":text]
            AppsFlyerLib.shared().logEvent(AFEventShare, withValues: dic)
            
            let dicY : [String: Any] = ["Share":"AppShared"]
            YMMYandexMetrica.reportEvent("AppShared", parameters: dicY) { error in
                print(error.localizedDescription)
            }
            
            let textToShare = [ text ]
            let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            activityViewController.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook]
            self.present(activityViewController, animated: true, completion: nil)
        }
        else if(indexPath.row == 6){
            
            self.sideMenuController?.hideLeftView(animated: true) { [self] in

                let privacyVC = self.storyboard?.instantiateViewController(withIdentifier: "PrivacyVC") as! PrivacyVC
                (sideMenuController?.rootViewController as? UINavigationController)?.pushViewController(privacyVC, animated: true)
            }
            
        }
        else if(indexPath.row == 7){
            
            self.sideMenuController?.hideLeftView(animated: true) { [self] in

                let termsVC = self.storyboard?.instantiateViewController(withIdentifier: "TermsVC") as! TermsVC
                (sideMenuController?.rootViewController as? UINavigationController)?.pushViewController(termsVC, animated: true)
            }
        }
        
        else if(indexPath.row == 8){
            
            self.sideMenuController?.hideLeftView(animated: true) { [self] in
                if Singleton.sharedInstance.isPurchased{
                    let adblockerVC = self.storyboard?.instantiateViewController(withIdentifier: "AdBlockerVC") as! AdBlockerVC
                    (sideMenuController?.rootViewController as? UINavigationController)?.pushViewController(adblockerVC, animated: true)
                }else{
                    self.moveToSubscription()
                }
            }
        }
        
        else if(indexPath.row == 9){
            
            self.sideMenuController?.hideLeftView(animated: true) { [self] in

                if Singleton.sharedInstance.currentLoginUserInfo != nil {
                    
                    let alertController = UIAlertController(title: "Account Information", message: "Email: \(Singleton.sharedInstance.currentLoginUserInfo?.email ?? "")", preferredStyle: .alert)
                    
                    let signOutAction = UIAlertAction(title: "Sign Out", style: .default) { (action) in
                        print("Sign Out tapped")
                        do { try Auth.auth().signOut() }
                        catch { print("already logged out") }
                    }
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                    
                    let deleteAccountAction = UIAlertAction(title: "Delete Account", style: .default) { (action) in
                        print("Delete Account tapped")
                        
                        let alertController = UIAlertController(title: "Delete Account", message: "Is this goodbye? We're sorry to see you go.\nYou'll lose all of your data related to MicronVPN. Do you wish to continue?", preferredStyle: .alert)
                        
                        let keepAccountAction = UIAlertAction(title: "Keep Account", style: .default) { (action) in
                            print("Keep Account tapped")
                        }
                        
                        let deleteAnywayAction = UIAlertAction(title: "Delete Anyway", style: .cancel) { (action) in
                            print("Delete Anyway tapped")
                            Singleton.sharedInstance.currentLoginUserInfo?.delete { error in
                                if let error = error {
                                    print(error)
                                } else {
                                    print("Account deleted.")
                                }
                            }
                        }
                        
                        alertController.addAction(keepAccountAction)
                        alertController.addAction(deleteAnywayAction)
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
                    
                    alertController.addAction(signOutAction)
                    alertController.addAction(deleteAccountAction)
                    alertController.addAction(cancelAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                    
                }else{
                    
                    if Singleton.sharedInstance.isPurchased{
                        let signinVC = self.storyboard?.instantiateViewController(withIdentifier: "SignInVC") as! SignInVC
                        (sideMenuController?.rootViewController as? UINavigationController)?.pushViewController(signinVC, animated: true)
                    }else{
                        self.moveToSubscription()
                    }
                }
            }
        }
    }
    
    func moveToSubscription(){
        let subcriptionVC = self.storyboard?.instantiateViewController(withIdentifier: "SubcriptionVC") as! SubcriptionVC
        (sideMenuController?.rootViewController as? UINavigationController)?.pushViewController(subcriptionVC, animated: true)
    }
    
    
    @IBAction func bannerClick(){
        self.sideMenuController?.hideLeftView(animated: true) { [self] in

            let subcriptionVC = self.storyboard?.instantiateViewController(withIdentifier: "SubcriptionVC") as! SubcriptionVC
            (sideMenuController?.rootViewController as? UINavigationController)?.pushViewController(subcriptionVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 60.0
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Swift.Error?) {
        controller.dismiss(animated: true, completion: nil)
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



extension DrawerVC: LGSideMenuDelegate{
    func didTransformRootView(sideMenuController: LGSideMenuController, percentage: CGFloat) {
        
    }
    
    func didTransformLeftView(sideMenuController: LGSideMenuController, percentage: CGFloat) {
        
    }
    
    func didTransformRightView(sideMenuController: LGSideMenuController, percentage: CGFloat) {
        
    }
    
    func willShowLeftView(sideMenuController: LGSideMenuController) {
        sideMenuController.rootView?.alpha = 0.1
        self.checkIfPaidforBanner()
        setUpMenuOptions()
    }
    
    func willHideLeftView(sideMenuController: LGSideMenuController) {
        sideMenuController.rootView?.alpha = 1
    }
    
}
