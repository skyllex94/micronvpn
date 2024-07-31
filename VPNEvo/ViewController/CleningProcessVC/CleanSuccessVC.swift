//
//  CleanSuccessVC.swift
//  VPNEvo
//
//  Created by iOSProfessionals on 06/10/22.
//

import UIKit
import LGSideMenuController

class CleanSuccessVC: UIViewController {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    @IBOutlet weak var lblDays: UILabel!
    @IBOutlet weak var lblDaysText: UILabel!
    @IBOutlet weak var lblMinutes: UILabel!
    @IBOutlet weak var lblMinutesText: UILabel!
    @IBOutlet weak var lblSeconds: UILabel!
    @IBOutlet weak var lblSecondsText: UILabel!
    
    @IBOutlet var btnStart:UIButton!
    
    var timer: Timer?
    var totalTime = 300

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lblTitle.text = NSLocalizedString("Success!", comment: "")
        self.lblSubTitle.text = NSLocalizedString("YOUR PHONE IS PROTECTED", comment: "")
        self.lblDescription.text = NSLocalizedString("Do not remove the app. The next analysis will proceed automaticallv in", comment: "")
        //self.lblDaysText.text = NSLocalizedString("Days", comment: "")
        //self.lblMinutesText.text = NSLocalizedString("Minutes", comment: "")
        //self.lblSecondsText.text = NSLocalizedString("Seconds", comment: "")
        
        btnStart.layer.cornerRadius = 10.0
        btnStart.layer.masksToBounds = true
        // Do any additional setup after loading the view.
//        lblDays.layer.cornerRadius = 10.0
//        lblDays.layer.masksToBounds = true
//        lblMinutes.layer.cornerRadius = 10.0
//        lblMinutes.layer.masksToBounds = true
//        lblSeconds.layer.cornerRadius = 10.0
//        lblSeconds.layer.masksToBounds = true
        
        self.btnStart.setTitle(NSLocalizedString("Continue", comment: ""), for: .normal)
        
        //self.startOtpTimer()
    }
    
    func startOtpTimer() {
        self.totalTime = 300
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
//        print(self.totalTime)
//        print(self.timeFormatted(self.totalTime))
        let totaltime = self.timeFormatted(self.totalTime) // will show timer
        let arystr = totaltime.components(separatedBy: ":")
        
        self.lblMinutes.text = arystr[0]
        self.lblSeconds.text = arystr[1]
        
        if totalTime != 0 {
            totalTime -= 1  // decrease counter timer
        } else {
            if let timer = self.timer {
                timer.invalidate()
                self.timer = nil
            }
        }
    }
    
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    @IBAction func continueHome(){
        
        Singleton.sharedInstance.vibrateDevice()
        
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        let navigationController = UINavigationController()
        navigationController.setViewControllers([homeVC], animated: true)
        
        let leftSideMenuViewController: UIViewController = storyboard.instantiateViewController(withIdentifier: "DrawerVC")
        let sideMenuController = LGSideMenuController(rootViewController: navigationController,
                                                      leftViewController: leftSideMenuViewController,
                                                              rightViewController: nil)
        

        sideMenuController.leftViewWidth = 300.0
        sideMenuController.delegate = leftSideMenuViewController as! LGSideMenuDelegate

        sideMenuController.isLeftViewStatusBarBackgroundHidden = true
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = sideMenuController
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
