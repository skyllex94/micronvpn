//
//  RateUsVC.swift
//  VPNEvo
//
//  Created by Rootways on 17/03/22.
//

import UIKit
import StoreKit

class RateUsVC: UIViewController {

    @IBOutlet var lblTitle:UILabel!
    @IBOutlet var lblDescription:UILabel!
    
    @IBOutlet var btnRate:UIButton!
    @IBOutlet var btnMaybeLater:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        btnRate.layer.cornerRadius = 10.0
        btnRate.layer.masksToBounds = true
        
        btnMaybeLater.layer.borderWidth = 1.0
        btnMaybeLater.layer.borderColor = UIColor.white.cgColor
        btnMaybeLater.layer.cornerRadius = 10.0
        btnMaybeLater.layer.masksToBounds = true
        
        lblTitle.text = NSLocalizedString("We work 24/7 to give the best, most reliable VPN", comment: "title")
        lblDescription.text = NSLocalizedString("Please take a moment to rate our app and tell us how we’re doing", comment: "detail")
        
        btnRate.setTitle(NSLocalizedString("rate_the_app", comment: "rate"), for: .normal)
        btnMaybeLater.setTitle(NSLocalizedString("maybelater", comment: "later"), for: .normal)
        
    }
    
    @IBAction func btnRateAction(){
        SKStoreReviewController.requestReview()
    }
    
    @IBAction func btnLaterAction(){
        
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
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
