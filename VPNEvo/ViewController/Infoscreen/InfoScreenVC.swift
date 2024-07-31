//
//  InfoScreenVC.swift
//  VPNEvo
//
//  Created by iOSProfessionals on 27/11/23.
//

import UIKit

class InfoScreenVC: UIViewController {
    
    @IBOutlet weak var btnContinue: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        btnContinue.layer.cornerRadius = 10.0
        // Do any additional setup after loading the view.
    }
    
    @IBAction func action_close(){
        self.dismiss(animated: true)
    }

}
