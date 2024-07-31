//
//  PrivacyVC.swift
//  VPNEvo
//
//  Created by Rootways on 21/03/22.
//

import UIKit

class PrivacyVC: UIViewController {

    @IBOutlet var LabelTitle:UILabel!
    @IBOutlet weak var txtText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        LabelTitle.text = NSLocalizedString("Privacy Policy", comment: "Privacy Policy")
        txtText.text = NSLocalizedString("p_policy", comment: "")
    }
    
    @IBAction func btnCloseAction(){
        
        self.navigationController?.popViewController(animated: true)
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
