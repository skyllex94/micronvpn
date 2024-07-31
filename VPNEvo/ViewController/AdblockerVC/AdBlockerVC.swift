//
//  AdBlockerVC.swift
//  VPNEvo
//
//  Created by iOSProfessionals on 05/01/23.
//

import UIKit
import SafariServices


class AdBlockerVC: UIViewController {
    
    @IBOutlet weak var imgStatus: UIImageView!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    @IBOutlet weak var imgSwitch: UIImageView!
    @IBOutlet weak var imgArrowOff: UIImageView!
    @IBOutlet weak var imgArrowOn: UIImageView!
    @IBOutlet weak var btnSwitch: UIButton!
    
    @IBOutlet weak var imgSwitchTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var viewDisabled: UIView!
    
    @IBOutlet var activityView:Loader_VC!

    override func viewDidLoad() {
        super.viewDidLoad()

        //TO check the status each time app open
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(checkContentBlocker), name: NSNotification.Name("CheckBlockerStatus"), object: nil)
        
        self.lblStatus.text = NSLocalizedString("Disabled", comment: "Disabled")
        self.lblDescription.text = NSLocalizedString("Adblocker is disabled \n and ads are not blocked", comment: "Adblocker is disabled \n and ads are not blocked")
        
        //Check if blocker is enabled is settings or not
        checkContentBlocker()
        
        // Do any additional setup after loading the view.
    }
    
    @objc func checkContentBlocker(){
        
        self.showLoader()
        
        SFContentBlockerManager.getStateOfContentBlocker(withIdentifier: kadblockerIdentifier, completionHandler: { (state, error) in
            if let error = error {
                // TODO: handle the error
            }
            if let state = state {
                
                if state.isEnabled{
                    DispatchQueue.main.async {
                        self.hideGuide()
                    }
                }else{
                    DispatchQueue.main.async {
                        self.showGuide()
                    }
                }
            }
            self.hideLoader()
        })
    }
    
    
    func showGuide(){
        UIView.animate(withDuration: 1.0) {
            self.viewDisabled.alpha = 1.0
        }
    }
    
    func hideGuide(){
        UIView.animate(withDuration: 1.0) {
            self.viewDisabled.alpha = 0.0
        }
        
        let suit = UserDefaults(suiteName: kappGroupName)
                
        if (suit!.bool(forKey: "ISADBLOCKED")){
            self.turnOnAdBlocker()
            
        }else{
            self.turnOffAdBlocker()
        }
    }
    
    
    @IBAction func changeStatus(_sender: UIButton){
       
        let suit = UserDefaults(suiteName: kappGroupName)
        if _sender.tag == 1 {
            suit?.set(false, forKey: "ISADBLOCKED")
            self.turnOffAdBlocker()
            self.btnSwitch.tag = 0
        }else{
            suit?.set(true, forKey: "ISADBLOCKED")
            self.turnOnAdBlocker()
            self.btnSwitch.tag = 1
        }
        suit?.synchronize()
        self.reloadContentBlocker()
    }
    
    //Reload Content blocker after changes
    func reloadContentBlocker(){
        SFContentBlockerManager.reloadContentBlocker(withIdentifier: kadblockerIdentifier, completionHandler: { error in
            if let error = error {
                // do something here when an error is thrown
                print(error.localizedDescription)
            }
        })
        
    }
    
    @IBAction func actionSettings(){
        
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                print("Settings opened: \(success)") // Prints true
            })
        }
    }
    
    func turnOnAdBlocker(){
        
        let switchHeight = self.imgSwitch.frame.size.height
        let percentage = (switchHeight * 60 ) / 100
        
        self.btnSwitch.tag = 1
        
        UIView.animate(withDuration: 0.5) {
            self.imgSwitchTopConstraint.constant = percentage
            self.imgArrowOff.alpha = 0.0
            self.imgArrowOn.alpha = 1.0
            
            self.view.layoutIfNeeded()
        }completion: { Bool in
            self.lblStatus.text = NSLocalizedString("Enabled", comment: "Enabled")
            self.lblDescription.text = NSLocalizedString("Adblocker is enabled \n and ads are blocked", comment: "Adblocker is enabled \n and ads are blocked")
            UIView.transition(with: self.imgSwitch,
                              duration: 0.5,
                              options: .transitionCrossDissolve,
                              animations: { self.imgSwitch.image = UIImage(named: "adblock_onSwtich")},
                              completion: nil)
            
            UIView.transition(with: self.imgStatus,
                              duration: 0.5,
                              options: .transitionCrossDissolve,
                              animations: {
                            self.imgStatus.image = UIImage(named: "adblock_on")},
                              completion: nil)
        }
    }
    
    func turnOffAdBlocker(){
        
        let switchHeight = self.imgSwitch.frame.size.height
        let percentage = (switchHeight * 16 ) / 100
        
        self.btnSwitch.tag = 0
        
        UIView.animate(withDuration: 0.5) {
            self.imgSwitchTopConstraint.constant = percentage
            self.imgArrowOff.alpha = 1.0
            self.imgArrowOn.alpha = 0.0
            
            self.view.layoutIfNeeded()
        } completion: { Bool in
            self.lblStatus.text = NSLocalizedString("Disabled", comment: "Disabled")
            self.lblDescription.text = NSLocalizedString("Adblocker is disabled \n and ads are not blocked", comment: "Adblocker is disabled \n and ads are not blocked")
            
            UIView.transition(with: self.imgSwitch,
                              duration: 0.2,
                              options: .transitionCrossDissolve,
                              animations: { self.imgSwitch.image = UIImage(named: "adblock_offSwtich")
                            
            },
                              completion: nil)
            
            UIView.transition(with: self.imgStatus,
                              duration: 0.2,
                              options: .transitionCrossDissolve,
                              animations: {                             self.imgStatus.image = UIImage(named: "adblock_off")
            },
                              completion: nil)
        }
    }
    
    @IBAction func close(){
        self.navigationController?.popViewController(animated: true)
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
