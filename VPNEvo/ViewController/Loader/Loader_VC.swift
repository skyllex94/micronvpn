//
//  Loader_VC.swift
//  VPNEvo
//
//  Created by Hvapz_iOS on 10/05/22.
//

import UIKit
import NVActivityIndicatorView
import SwiftyGif


class Loader_VC: UIView {

    @IBOutlet weak var vw_loader: UIView!
    
    var activityIndicatorView:NVActivityIndicatorView!
    @IBOutlet weak var NVBaseview: UIView!
    
    
    var vwgif = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        Bundle.main.loadNibNamed("Loader_VC", owner: self, options: nil)
        
        activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 30, height: 30), type: .ballClipRotate, color: UIColor.white, padding: 0)
        self.NVBaseview.addSubview(activityIndicatorView)
        activityIndicatorView.center = self.NVBaseview.center
        activityIndicatorView.startAnimating()
//        self.bringSubviewToFront(activityIndicatorView)
        self.NVBaseview.alpha = 0.7
        addSubview(vw_loader)
//
        //vw_loader.addSubview(vwgif)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraint = activityIndicatorView.centerXAnchor.constraint(equalTo: vw_loader.centerXAnchor)
        let verticalConstraint = activityIndicatorView.centerYAnchor.constraint(equalTo: vw_loader.centerYAnchor)
        let widthConstraint = activityIndicatorView.widthAnchor.constraint(equalToConstant: 30)
        let heightConstraint = activityIndicatorView.heightAnchor.constraint(equalToConstant: 30)
        vw_loader.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
//
//        do {
//            let gif = try UIImage(gifName: "loader.gif")
//            let imageview = UIImageView(gifImage: gif, loopCount: -1) // Will loop 3 times
//            imageview.frame = CGRect(x: 0, y: 0, width: 110, height: 110)
//            //vwgif.addSubview(imageview)
//        } catch {
//            print(error)
//        }
    }
}
