//
//  CleaningProcessVC.swift
//  VPNEvo
//
//  Created by iOSProfessionals on 06/10/22.
//

import UIKit
import CircleProgressBar


class CleaningProcessVC: UIViewController {
    
    @IBOutlet var lblHeader:UILabel!
    @IBOutlet var lblSubHeader:UILabel!
    @IBOutlet var lblSystemScanning:UILabel!
    @IBOutlet var circleProgressBar:CircleProgressBar!
    
    @IBOutlet var lblBottomtext1:UILabel!
    @IBOutlet var lblBottomtext2:UILabel!
    
    @IBOutlet weak var progressbar: UISlider!
    @IBOutlet weak var lblProgressText: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblHeader.text = NSLocalizedString("Protecting iPhone", comment: "Protecting iPhone")
        lblSubHeader.text = NSLocalizedString("Don't remove the app", comment: "Don't remove the app")
        lblSystemScanning.text = NSLocalizedString("Don't remove the app", comment: "Don't remove the app")
        lblBottomtext1.text = NSLocalizedString("The process will continue Automatically. You can close the app to proceed", comment: "")
        lblBottomtext2.text = NSLocalizedString("Do not remove the app. Your iPhone is still unprotected", comment: "")
        
        circleProgressBar.setProgress(1.0, animated: true, duration: 10.0)
        
        self.progressbar.value = 0

        let img = UIImage()
        self.progressbar.setThumbImage(img, for: .normal)
        self.progressbar.setThumbImage(img, for: .highlighted)
        
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { Timer in
            self.progressbar.value = self.progressbar.value + 0.1
            self.lblProgressText.text = String(format: "%.0f", self.progressbar.value) + "%"
        }
        
        Timer.scheduledTimer(timeInterval: 12.0, target: self, selector: #selector(self.movetoCleanDone), userInfo: nil, repeats: false)

        // Do any additional setup after loading the view.
    }
    
    @objc func movetoCleanDone(){
        let cleanSuccess = self.storyboard?.instantiateViewController(withIdentifier: "CleanSuccessVC") as! CleanSuccessVC
        self.navigationController?.pushViewController(cleanSuccess, animated: false)
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
