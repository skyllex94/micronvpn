//
//  SignInVC.swift
//  VPNEvo
//
//  Created by iOSProfessionals on 04/01/23.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseCore
import LGSideMenuController

class SignInVC: UIViewController {
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var btnSignup: UIButton!
    @IBOutlet weak var txtUname: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    @IBOutlet var activityView:Loader_VC!

    override func viewDidLoad() {
        super.viewDidLoad()

        txtUname.setPlaceholderColor(.white)
        txtPassword.setPlaceholderColor(.white)
        
        btnContinue.layer.cornerRadius = 10.0
        // Do any additional setup after loading the view.
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("kCloseLogin"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(close), name: NSNotification.Name("kCloseLogin"), object: nil)
        self.localize()
    }
    
    func localize(){
        self.lblTitle.text = NSLocalizedString("Login To Your Acccount", comment: "Login To Your Acccount")
        self.txtUname.placeholder = NSLocalizedString("Enter your email", comment: "Enter your email")
        self.txtPassword.placeholder = NSLocalizedString("Enter your password", comment: "Enter your password")
        self.btnContinue.setTitle(NSLocalizedString("Sign In", comment: "Sign In"), for: .normal)
        self.btnSignup.setTitle(NSLocalizedString("Don't have an account? Sign Up", comment: "Don't have an account? Sign Up"), for: .normal)
    }
    
    @IBAction func signIn(){
        
        if !self.isValidEmail(self.txtUname.text ?? ""){
            self.showAlert(title: "Error!", msg: "Invalid Email, Please enter correct email address.")
            return
        }
        
        if !self.isValidPassword(self.txtPassword.text ?? ""){
            self.showAlert(title: "Error!", msg: "Minimum password length must be 6")
            return
        }
        
        let loginManager = FirebaseAuthManager()
        
        guard let email = txtUname.text, let password = txtPassword.text else { return }
        
        self.showLoader()
        
        loginManager.signIn(email: email, pass: password) {[weak self] (success) in
        
            self?.hideLoader()
            
            guard let `self` = self else { return }
            var message: String = ""
            if (success) {
                message = "Welcome back to the VPN, You are logged in successfully."
                let alertController = UIAlertController(title: "Welcome", message: message, preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: "Continue", style: .cancel, handler: { UIAlertAction in
                    self.navigationController?.popViewController(animated: true)
                }))
                self.present(alertController, animated: true)
            } else {
                message = "Email is not registered with the app, Please signup."
                self.showAlert(title: "Opps!", msg: message)
            }
            
        }
    }
    
    @objc @IBAction func close(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func openRegistration(){
        let stryboard = UIStoryboard.init(name: "Main", bundle: .main)
        let signUpVC = stryboard.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
        signUpVC.modalPresentationStyle = .fullScreen
        self.present(signUpVC, animated: true, completion: nil)
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

extension UITextField {
    func setPlaceholderColor(_ color: UIColor) {
        guard let placeholder = self.placeholder else { return }
        self.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: color]
        )
    }
}
