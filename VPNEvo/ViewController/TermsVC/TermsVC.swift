//
//  TermsVC.swift
//  VPNEvo
//
//  Created by Rootways on 21/03/22.
//

import UIKit

class TermsVC: UIViewController {

    @IBOutlet var LabelTitle:UILabel!
    @IBOutlet weak var txtText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        LabelTitle.text = NSLocalizedString("Terms of Use", comment: "Terms of Use")
        self.txtText.text = NSLocalizedString("t_terms", comment: "")
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
