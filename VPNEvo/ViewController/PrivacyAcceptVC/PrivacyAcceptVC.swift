//
//  PrivacyAcceptVC.swift
//  VPNEvo
//
//  Created by Rootways on 23/03/22.
//

import UIKit

class PrivacyAcceptVC: UIViewController {

    @IBOutlet var btnAgree:UIButton!
    @IBOutlet var txtView:UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        btnAgree.layer.cornerRadius = 10.0
        btnAgree.layer.masksToBounds = true
        
        btnAgree.setTitle(NSLocalizedString("Agree & Continue", comment: "Agree & Continue"), for: .normal)
        txtView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 200, right: 0)
        txtView.text = NSLocalizedString("p_policy", comment: "")
    }
    
    @IBAction func agreedTerms(){
        
        UserDefaults.standard.set("Y", forKey: "ISAGREED")
        UserDefaults.standard.synchronize()
        
        let isSkip = (UserDefaults.standard.value(forKey: "skip_startup_iap") as? NSString)?.boolValue ?? false
        if isSkip{
            
            self.movetoHome()
        }
        else{
            self.movetoIntro()
        }
    }
    
    func movetoHome(){
        
    }
    
    func movetoIntro(){
        
        let introVC = self.storyboard?.instantiateViewController(withIdentifier: "IntroVC") as! IntroVC
        self.navigationController?.pushViewController(introVC, animated: true)
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
