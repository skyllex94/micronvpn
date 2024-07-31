//
//  SystemScanVC.swift
//  VPNEvo
//
//  Created by Rootways on 16/03/22.
//

import UIKit
import CircleProgressBar

class SystemScanVC: UIViewController {

    @IBOutlet var lblHeader:UILabel!
    @IBOutlet var lblSystemScanning:UILabel!
    @IBOutlet var circleProgressBar:CircleProgressBar!
    @IBOutlet var lblScanningText:UILabel!
    
    var arrayScanningText:NSMutableArray! = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        lblHeader.text = NSLocalizedString("iPhone Security", comment: "header")
        lblSystemScanning.text = NSLocalizedString("System Scanning", comment: "System scanning")
         
        arrayScanningText.add(NSLocalizedString("Granted permissions", comment: ""))
        arrayScanningText.add(NSLocalizedString("Applications folders", comment: ""))
        arrayScanningText.add(NSLocalizedString("Junk", comment: ""))
        arrayScanningText.add(NSLocalizedString("Malware Check", comment: ""))
        arrayScanningText.add(NSLocalizedString("Anonymous request", comment: ""))
        arrayScanningText.add(NSLocalizedString("Safari history", comment: ""))
        arrayScanningText.add(NSLocalizedString("Personal info", comment: ""))
        
        
        circleProgressBar.setProgress(1.0, animated: true, duration: 10.0)
        Timer.scheduledTimer(timeInterval: 12.0, target: self, selector: #selector(self.movetoDetected), userInfo: nil, repeats: false)
        
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [self] timer in
            if lblScanningText.tag < arrayScanningText.count - 1 {
                lblScanningText.tag += 1
                if circleProgressBar.progress == 1.0{
                    return
                }
                changeTexts()
                return
            }
            lblScanningText.tag = 0
        }
    }

    func changeTexts() {
        let text = arrayScanningText[lblScanningText.tag] as? String
        UIView.animate(withDuration: 0.2, animations: { [self] in
            lblScanningText.text = text
        })
    }
    
    @objc func movetoDetected(){
        
        let detectedVC = self.storyboard?.instantiateViewController(withIdentifier: "DetectedVC") as! DetectedVC
        self.navigationController?.pushViewController(detectedVC, animated: false)
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
