//
//  IntroVC.swift
//  VPNEvo
//
//  Created by Rootways on 14/03/22.
//

import UIKit
import AdvancedPageControl
import LGSideMenuController
import RevenueCat

class ModelIntroduction
{
    var imageName:String!
    var strTitle:String!
    var strDescription:String!
}

class IntroVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet var introCollection:UICollectionView!
    @IBOutlet var btnContinue:UIButton!
    @IBOutlet var btnRestore:UIButton!
    @IBOutlet var btnPrivacy:UIButton!
    @IBOutlet var btnTerms:UIButton!
    @IBOutlet var LabelPrice:UILabel!
    @IBOutlet var paging:AdvancedPageControlView!
    @IBOutlet var activityView:Loader_VC!
    
    var arrayIntroduction:NSMutableArray! = NSMutableArray()
    
    var img1:UIView!
    var img2:UIView!
    var img3:UIView!
    var timerAnimation:Timer!
    
    var isDynamic:Bool!
    var isDoublePayment:Bool!
    var currentIAP:String!
    var IAPProducts:NSMutableArray!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        introCollection.delegate = self
        introCollection.dataSource = self
        
        btnContinue.layer.cornerRadius = 10.0
        btnContinue.setTitle(NSLocalizedString("Continue", comment: "Continue"), for: .normal)
        //btnContinue.titleLabel?.font = UIFont(name: "AllrounderGrotesk", size: 18.0)
        
        //self.LabelPrice.isHidden = true
        
        btnRestore.setTitle(NSLocalizedString("Restore", comment: "Restore"), for: .highlighted)
        //btnRestore.titleLabel?.font = UIFont(name: "AllrounderGrotesk", size: 18.0)
        
        var modelIntroduction = ModelIntroduction()
        modelIntroduction.imageName = "intro2022_1"
        modelIntroduction.strTitle = NSLocalizedString("point1", comment: "point1")
        modelIntroduction.strDescription = NSLocalizedString("point1desc", comment: "point1")
        self.arrayIntroduction.add(modelIntroduction)
        
        modelIntroduction = ModelIntroduction()
        modelIntroduction.imageName = "intro2022_2"
        modelIntroduction.strTitle = NSLocalizedString("point2", comment: "point2")
        modelIntroduction.strDescription = NSLocalizedString("point2desc", comment: "point2desc")
        self.arrayIntroduction.add(modelIntroduction)
        
        modelIntroduction = ModelIntroduction()
        modelIntroduction.imageName = "intro2022_3"
        modelIntroduction.strTitle = NSLocalizedString("point3", comment: "point3")
        modelIntroduction.strDescription = NSLocalizedString("point3desc", comment: "point3desc")
        self.arrayIntroduction.add(modelIntroduction)
        
        paging.drawer = ExtendedDotDrawer(numberOfPages: arrayIntroduction.count, height: 5.0, width: 5.0, space: 15.0, raduis: 2.5, currentItem: 0, indicatorColor: UIColor(red: 8.0/255.0, green: 132.0/225.0, blue: 255.0/255.0, alpha: 1.0), dotsColor: UIColor(red: 132.0/255.0, green: 132.0/255.0, blue: 132.0/255.0, alpha: 1.0), isBordered: false, borderColor: .clear, borderWidth: 0.0, indicatorBorderColor: .clear, indicatorBorderWidth: 0.0)
        
        let ipaText = UserDefaults.standard.value(forKey:"IAP_text") as? String ?? ""
        self.LabelPrice.text = String(format:"%@",ipaText)
        
        var font = (UserDefaults.standard.value(forKey:"IAP_text_size") as? NSString)!.integerValue
           
        if UIDevice.current.userInterfaceIdiom == .pad {
            font = font + 10;
        }else{
            
            let safeTop = UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0
            if(safeTop > 20){
                font = font + 2
            }
            
        }
        self.LabelPrice.font = UIFont(name: "Arial", size: CGFloat(font))
        
    }
  
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        self.currentIAP = UserDefaults.standard.value(forKey: "currentPlan") as? String ?? ""
        
        self.btnPrivacy.alpha = 0.0
        self.btnTerms.alpha = 0.0
        self.btnRestore.alpha = 0.0
        self.LabelPrice.alpha = 0.0
        
        self.btnPrivacy.setTitle(NSLocalizedString("Privacy Policy", comment: "Privacy Policy"), for: .normal)
        self.btnTerms.setTitle(NSLocalizedString("Terms of Use", comment: "Terms of Use"), for: .normal)
        
        if(UserDefaults.standard.value(forKey: "show_privacy_terms") as? NSString)?.boolValue ?? false{
            
            self.btnPrivacy.alpha = 1.0
            self.btnTerms.alpha = 1.0
        }
        
        self.isDoublePayment = false
        if(UserDefaults.standard.value(forKey: "doublePayment") as? NSString)?.boolValue ?? false{
            self.isDoublePayment = true
        }
        
        self.isDynamic = (UserDefaults.standard.value(forKey: "dynamic_price") as? NSString)?.boolValue ?? false
        var font = (UserDefaults.standard.value(forKey: "IAP_text_size") as! NSString).integerValue
           
        if UIDevice.current.userInterfaceIdiom == .pad {
            font = font + 10
        }else{
            let safeTop = UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0
            if (safeTop > 20) {
                font = font + 2
            }
        }
        
        
        self.LabelPrice.font = UIFont(name: "Arial", size: CGFloat(font))
        self.loadPricing()

    }
    
    func loadPricing(){
        
        self.IAPProducts = NSMutableArray()
        
        if(Singleton.sharedInstance.inappItems.count >= 2){
            
            for i in 0 ..< Singleton.sharedInstance.inappItems.count{
                
                let product = Singleton.sharedInstance.inappItems[i] as! NSMutableDictionary
                if(product["identifier"] as? String == self.currentIAP){
                    
                    print(product)
                    
                    let ipaText = UserDefaults.standard.value(forKey: "IAP_text") as? String ?? ""
                    self.LabelPrice.text = ipaText
                    if(self.isDynamic){
                        
                        var tempstr:String!
                        
                        if(self.currentIAP == kMonthlyIAP){
                            tempstr = String(format:"%@ %@/month",ipaText,product["price"] as? String ?? "")
                        }else if (self.currentIAP == kWeeklyIAP || self.currentIAP == kWeeklySaleIAP){
                            tempstr = String(format:"%@ %@/week",ipaText,product["price"] as? String ?? "")
                        }else if (self.currentIAP == k6MonthIAP){
                            tempstr = String(format:"%@ %@/6 months",ipaText,product["price"] as? String ?? "")
                        }else if (self.currentIAP == k3MonthIAP){
                            tempstr = String(format:"%@ %@/3 months",ipaText,product["price"] as? String ?? "");
                        }else if (self.currentIAP == kYearlyIAP){
                            tempstr = String(format:"%@ %@/year",ipaText,product["price"] as? String ?? "")
                        }
                         
                        self.LabelPrice.text = tempstr
                        
                    }
                }

            }
            
        }
        else{
         
            //self.showLoader()
            
            Singleton.sharedInstance.loadInappItems()
              
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                
                if Singleton.sharedInstance.inappItems.count >= 2 {
                    
                    for i in 0 ..< Singleton.sharedInstance.inappItems.count{
                        
                        let product = Singleton.sharedInstance.inappItems[i] as! NSMutableDictionary
                        if(product["identifier"] as? String == self.currentIAP){
                            
                            let ipaText = UserDefaults.standard.value(forKey: "IAP_text") as? String ?? ""
                            self.LabelPrice.text = ipaText
                            if(self.isDynamic){
                                
                                var tempstr:String!
                                
                                if(self.currentIAP == kMonthlyIAP){
                                    tempstr = String(format:"%@ %@/month",ipaText,product["price"] as? String ?? "")
                                }else if (self.currentIAP == kWeeklyIAP){
                                    tempstr = String(format:"%@ %@/week",ipaText,product["price"] as? String ?? "")
                                }else if (self.currentIAP == k6MonthIAP){
                                    tempstr = String(format:"%@ %@/6 months",ipaText,product["price"] as? String ?? "")
                                }else if (self.currentIAP == k3MonthIAP){
                                    tempstr = String(format:"%@ %@/3 months",ipaText,product["price"] as? String ?? "");
                                }else if (self.currentIAP == kYearlyIAP){
                                    tempstr = String(format:"%@ %@/year",ipaText,product["price"] as? String ?? "")
                                }
                                 
                                self.LabelPrice.text = tempstr
                                
                            }
                        }

                    }
                    
                }
            }
          
        }
        
    }
    
    // MARK: - table view delegate
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return arrayIntroduction.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : IntroCell = collectionView.dequeueReusableCell(withReuseIdentifier: "IntroCell", for: indexPath) as! IntroCell
        
        let modelIntro = arrayIntroduction[indexPath.row] as! ModelIntroduction
        
        cell.introImage.image = UIImage(named: modelIntro.imageName)
        cell.LabelTitle.text = modelIntro.strTitle
        cell.LabelDescription.text = modelIntro.strDescription
        
        if(indexPath.row == arrayIntroduction.count - 1){
            //cell.btnClose.isHidden = false
            UIView.animate(withDuration: 0.5) {
                cell.btnClose.alpha = 1.0
            }
        }else{
            //cell.btnClose.isHidden = true
            UIView.animate(withDuration: 0.5) {
                cell.btnClose.alpha = 0.0
            }
        }
        cell.btnClose.addTarget(self, action: #selector(btnCloseAction), for: .touchUpInside)
        
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width:collectionView.frame.size.width, height:collectionView.frame.size.height)
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        let offSet = scrollView.contentOffset.x
        let width = scrollView.frame.width

        paging.setPage(Int(round(offSet / width)))
        paging.setPage(Int(round(offSet / width)))
        
        let currentPage = Int((scrollView.contentOffset.x + width / 2) / width)
        
        if currentPage < 2 {
            
            
            //self.LabelPrice.alpha = 0.0
            UIView.animate(withDuration: 0.5) {
                self.stopAnimation()
                self.btnRestore.alpha = 0.0
                self.btnPrivacy.alpha = 0.0
                self.btnTerms.alpha = 0.0
                self.LabelPrice.alpha = 0.0
                self.btnContinue.setTitle(NSLocalizedString("Continue", comment: ""), for: .normal)
            }
            
        }else{
            
            
            
            if(UserDefaults.standard.value(forKey: "show_privacy_terms") as? NSString)?.boolValue ?? false
            {
                UIView.animate(withDuration: 0.5) {
                    self.btnPrivacy.alpha = 1.0
                    self.btnTerms.alpha = 1.0
                }
            }
            UIView.animate(withDuration: 0.5) {
                self.startAnimation()
                //self.btnContinue.setTitle(NSLocalizedString("Start Trial", comment: ""), for: .normal)
                self.btnRestore.alpha = 1.0
                let isIAPPricing = (UserDefaults.standard.value(forKey: "show_iap_prices") as? NSString)?.boolValue ?? false
                if (isIAPPricing) {
                    self.LabelPrice.alpha = 1.0
                }
            }
        }
    }
    
    // MARK: - close action
    
    @objc func btnCloseAction(){
        Singleton.sharedInstance.vibrateDevice()
        
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        let navigationController = UINavigationController()
        navigationController.setViewControllers([homeVC], animated: true)
        
        let leftSideMenuViewController: UIViewController = storyboard.instantiateViewController(withIdentifier: "DrawerVC")
        let sideMenuController = LGSideMenuController(rootViewController: navigationController,
                                                      leftViewController: leftSideMenuViewController,
                                                              rightViewController: nil)
        sideMenuController.delegate = leftSideMenuViewController as! LGSideMenuDelegate
        
        sideMenuController.leftViewWidth = 300.0
        sideMenuController.isLeftViewStatusBarBackgroundHidden = true
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = sideMenuController
        sideMenuController.view.alpha = 0.0
        
        
        let show_sale = (UserDefaults.standard.value(forKey: "show_sale") as? NSString)?.boolValue ?? false
        
    
        if show_sale {
            
            if !UserDefaults.standard.bool(forKey: "IS_SALE_DONE"){
                                
                UserDefaults.standard.set(true, forKey: "IS_SALE_DONE")
                
                if !Singleton.sharedInstance.isPurchased{
                    let storyboard = UIStoryboard.init(name: "Main", bundle: .main)
                    let saleVC = storyboard.instantiateViewController(withIdentifier: "SaleVC") as! SaleVC
                    saleVC.modalPresentationStyle = .fullScreen
                    appDelegate.window?.rootViewController?.present(saleVC, animated: false, completion: nil)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        sideMenuController.view.alpha = 1.0
                    }
                }else{
                    sideMenuController.view.alpha = 1.0
                }
            }else{
                sideMenuController.view.alpha = 1.0
            }
        }else{
                sideMenuController.view.alpha = 1.0
        }
    }
    
    // MARK:- continue
    
    @IBAction func btnContinueAction()
    {
        Singleton.sharedInstance.vibrateDevice()
        
        let visibleItems: NSArray = self.introCollection.indexPathsForVisibleItems as NSArray
        var minItem: NSIndexPath = visibleItems.object(at: 0) as! NSIndexPath
        for itr in visibleItems {

            if minItem.row > (itr as AnyObject).row {
                    minItem = itr as! NSIndexPath
            }
        }
        
        let nextItem = NSIndexPath(row: minItem.row + 1, section: 0)
       // pageControl.currentPage = nextItem.row
        
        if(nextItem.row == arrayIntroduction.count - 1){
                        
            self.introCollection.scrollToItem(at: nextItem as IndexPath, at: .left, animated: true)
            //btnContinue.setTitle(NSLocalizedString("Start Trail", comment: ""), for: .normal)
            //self.animatreView(viewToAnimate: btnContinue)
            loadAnimation()
            //self.LabelPrice.isHidden = false
            
        }
        else if(nextItem.row < arrayIntroduction.count - 1)
        {
            btnContinue.setTitle(NSLocalizedString("Continue", comment: ""), for: .normal)
            //self.LabelPrice.isHidden = true
            
            self.introCollection.scrollToItem(at: nextItem as IndexPath, at: .left, animated: true)
        }
        else{
            
            self.subscribe()
            
        }
      
        
    }
    
    // MARK: - restore
    
    @IBAction func btnRestoreAction(){
        showLoader()
        Singleton.sharedInstance.vibrateDevice()
        
        Purchases.shared.restorePurchases { (purchaserInfo, error) in
                        
            self.hideLoader()
            
            if let e = error {
                                
                print(e)
                return
            }
            
            if purchaserInfo?.entitlements["pro"]?.isActive != true {
               
                
                return
            } else {
                
               print("Subscription restored")
               
            }
        }
    }
    
    func subscribe(){
        
        self.showLoader()
        
        if (self.isDoublePayment) {
            
            if(UserDefaults.standard.bool(forKey: "SHOWIAPAGAIN"))
            {
                UserDefaults.standard.set(true, forKey: "SHOWIAPAGAIN")
            }
            else{
                UserDefaults.standard.set(true, forKey: "SHOWIAPAGAIN")
            }
            UserDefaults.standard.synchronize()
        }
        
        if(UserDefaults.standard.bool(forKey: "SHOWIAPAGAIN"))
        {
            Singleton.sharedInstance.vibrateDevice()
        }
        
        
        if ((self.currentIAP == nil)) {
            self.hideLoader()
        }
        
        var productWillPurchase:RevenueCat.Package?
        
        for i in 0 ..< Singleton.sharedInstance.inappItems.count{
            
            let item = Singleton.sharedInstance.inappItems[i] as! NSMutableDictionary
            
            if(item["identifier"] as? String == self.currentIAP){
                
                productWillPurchase = item["package"] as? RevenueCat.Package
            }
        }
        
        
        if(productWillPurchase == nil){
            
            self.hideLoader()
        }
        else{
            
            self.purchasePackage(package: productWillPurchase)
            
        }
        
    }
    
    func purchasePackage(package:RevenueCat.Package!){
        
            
        Purchases.shared.purchase(package: package) {
            
            (transaction, purchaserInfo, error, userCancelled) in
        
            if(error != nil){
                
                if (self.isDoublePayment) {
                    
                    if(UserDefaults.standard.bool(forKey: "SHOWIAPAGAIN"))
                    {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                            self.purchaseAgain(package: package)
                        }
                    }else{
                        self.hideLoader()
                    }
                    
                }else{
                    self.hideLoader()
                }
                return
            }
            
            if purchaserInfo?.entitlements.all["pro"]?.isActive == true {
                self.hideLoader()
                Singleton.sharedInstance.isPurchased = true
                
                print("Pro feature granted !!")
                self.btnCloseAction()
            }
        }
    }
    
    func purchaseAgain(package:RevenueCat.Package!){
        
        Purchases.shared.purchase(package: package) {
            
            (transaction, purchaserInfo, error, userCancelled) in
        
            self.hideLoader()
            
            if(error != nil){
                print("Error in purchase")
                
            }
            
            if purchaserInfo?.entitlements.all["pro"]?.isActive == true {
                
                Singleton.sharedInstance.isPurchased = true
                print("Pro feature granted !!")
                self.btnCloseAction()
                
            }
        }
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
    
    func startAnimation() {
        
        if (self.timerAnimation != nil) {
            self.timerAnimation.invalidate()
            self.timerAnimation = nil
        }
        
        timerAnimation = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true, block: { Timer in
            self.loadAnimation()
        })
    }
    
    func stopAnimation(){
        
        if (self.timerAnimation != nil) {
            self.timerAnimation.invalidate()
            self.timerAnimation = nil
        }
        
        UIView.animate(withDuration: 0.5) {
            self.btnContinue.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
    }
    
    func loadAnimation() {
        
        UIView.animate(withDuration: 0.5, animations: { [self] in
            btnContinue.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { [self] finished in
            UIView.animate(withDuration: 0.5, animations: { [self] in
                btnContinue.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }) { [self] finished in
                spiralAnimation()
            }
        }
    }
    
    func spiralAnimation() {

        let delayInSeconds = 0.0
        let popTime = DispatchTime.now() + Double(Int64(delayInSeconds * Double(NSEC_PER_SEC)))
        DispatchQueue.main.asyncAfter(deadline: popTime, execute: { [self] in
            self.view.addSubview(img1)
            UIView.animate(withDuration: 0.7, animations: { [self] in
                img1.transform = CGAffineTransform(scaleX: 1.1, y: 1.5)
                img1.alpha = 0.0
            }) { [self] finished in
                UIView.animate(withDuration: 0.1, animations: { [self] in
                    img1.alpha = 0.0
                }) { [self] finished in
                    img1.removeFromSuperview()
                    img1.alpha = 1.0
                    img1.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                }

            }
        })
        
        let delayInSeconds2 = 0.3
        let popTime2 = DispatchTime.now() + Double(Int64(delayInSeconds2 * Double(NSEC_PER_SEC)))
        DispatchQueue.main.asyncAfter(deadline: popTime2, execute:{ [self] in
            self.view.addSubview(img2)
            UIView.animate(withDuration: 0.7, animations: { [self] in
                img2.transform = CGAffineTransform(scaleX: 1.1, y: 1.5)
                img2.alpha = 0.0
            }) { [self] finished in
                UIView.animate(withDuration: 0.1, animations: { [self] in
                    img2.alpha = 0.0
                }) { [self] finished in
                    img2.removeFromSuperview()
                    img2.alpha = 1.0
                    img2.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                }
            }
        })
        
        let delayInSeconds3 = 0.6
        let popTime3 = DispatchTime.now() + Double(Int64(delayInSeconds3 * Double(NSEC_PER_SEC)))
        DispatchQueue.main.asyncAfter(deadline: popTime3, execute:{ [self] in
            self.view.addSubview(img3)
            UIView.animate(withDuration: 0.7, animations: { [self] in
                img3.transform = CGAffineTransform(scaleX: 1.1, y: 1.5)
                img3.alpha = 0.0
            }) { [self] finished in
                UIView.animate(withDuration: 0.1, animations: { [self] in
                    img3.alpha = 0.0
                }) { [self] finished in
                    img3.removeFromSuperview()
                    img3.alpha = 1.0
                    img3.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                }
            }
        })
            
      
        img1 = UIView(frame: btnContinue.frame)
        img1.layer.borderColor = UIColor(red: 8.0 / 255.0, green: 132.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0).cgColor
        img1.layer.borderWidth = 2.0
        img1.layer.cornerRadius = 10.0
        
        img2 = UIView(frame: btnContinue.frame)
        img2.layer.borderColor = UIColor(red: 8.0 / 255.0, green: 132.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0).cgColor
        img2.layer.borderWidth = 2.0
        img2.layer.cornerRadius = 10.0
        
        img3 = UIImageView(frame: btnContinue.frame)
        img3.layer.borderColor = UIColor(red: 8.0 / 255.0, green: 132.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0).cgColor
        img3.layer.borderWidth = 2.0
        img3.layer.cornerRadius = 10.0
    }
    
    // MARK: - privacy
    
    @IBAction func btnPrivacyAction(){
        
        let privacyVC = self.storyboard?.instantiateViewController(withIdentifier: "PrivacyVC") as! PrivacyVC
        self.navigationController?.pushViewController(privacyVC, animated: true)
        
    }
    
    // MARK: - Terms of Use
    
    @IBAction func btnTermsAction(){
        
        let termsVC = self.storyboard?.instantiateViewController(withIdentifier: "TermsVC") as! TermsVC
        self.navigationController?.pushViewController(termsVC, animated: true)
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
