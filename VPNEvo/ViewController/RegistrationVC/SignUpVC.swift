//
//  SignUpVC.swift
//  VPNEvo
//
//  Created by iOSProfessionals on 04/01/23.
//

import UIKit
import LGSideMenuController

class SignUpVC: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var btnSignIn: UIButton!
    
    @IBOutlet weak var txtUname: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    @IBOutlet var activityView:Loader_VC!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        txtUname.setPlaceholderColor(.white)
        txtPassword.setPlaceholderColor(.white)
        
        btnContinue.layer.cornerRadius = 10.0
        // Do any additional setup after loading the view.
        self.localize()
    }
    
    func localize(){
        self.lblTitle.text = NSLocalizedString("Create Your Account", comment: "Create Your Account")
        self.txtUname.placeholder = NSLocalizedString("Enter your email", comment: "Enter your email")
        self.txtPassword.placeholder = NSLocalizedString("Enter your password", comment: "Enter your password")
        self.btnContinue.setTitle(NSLocalizedString("Sign Up", comment: "Sign Up"), for: .normal)
        self.btnSignIn.setTitle(NSLocalizedString("Already have an account? Sign In", comment: "Already have an account? Sign In"), for: .normal)
    }
    
    @IBAction func alreadyHaveAccount(){
        self.dismiss(animated: true)
    }
    
    @IBAction func signUpNow(){
        
        if !self.isValidEmail(self.txtUname.text ?? ""){
            self.showAlert(title: "Error!", msg: "Invalid Email, Please enter correct email address.")
            return
        }
        
        if !self.isValidPassword(self.txtPassword.text ?? ""){
            self.showAlert(title: "Error!", msg: "Minimum password length must be 6")
            return
        }
        
        let signUpManager = FirebaseAuthManager()
        if let email = self.txtUname.text, let password = txtPassword.text {
            self.showLoader()
            signUpManager.createUser(email: email, password: password) {[weak self] (success) in
                self?.hideLoader()
            guard let `self` = self else { return }
            var message: String = ""
            if (success) {
                message = "Welcome to the MicronVPN, Your account has been created."
                let alertController = UIAlertController(title: "Welcome", message: message, preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: "Continue", style: .cancel, handler: { UIAlertAction in
                    self.dismiss(animated: true) {
                        NotificationCenter.default.post(name: NSNotification.Name("kCloseLogin"), object: nil)
                    }
                    
                }))
                self.present(alertController, animated: true)

            } else {
                message = "There was an error."
                self.showAlert(title: "Error!", msg: message)
            }
                
            }
        }
    }
    
    func loadApp(){
        
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
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
      }
      
      func isValidPassword(_ password: String) -> Bool {
        let minPasswordLength = 6
        return password.count >= minPasswordLength
      }
    
    func showAlert(title: String, msg: String){
        
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
