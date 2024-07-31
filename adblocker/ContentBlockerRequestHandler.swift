//
//  ContentBlockerRequestHandler.swift
//  adblocker
//
//  Created by iOSProfessionals on 05/01/23.
//

import UIKit
import MobileCoreServices

class ContentBlockerRequestHandler: NSObject, NSExtensionRequestHandling {

    func beginRequest(with context: NSExtensionContext) {
        var attachment : NSItemProvider!
        let suit = UserDefaults(suiteName: "group.com.titanvpn.app.VPNTunnel")
        
        if (suit!.bool(forKey: "ISADBLOCKED")){
            print("Adblockerrrrrr Enabled")
            attachment = NSItemProvider(contentsOf: Bundle.main.url(forResource: "blockerList", withExtension: "json"))!
            
        }else{
            print("Adblockerrrrrr disabled")
            attachment = NSItemProvider(contentsOf: Bundle.main.url(forResource: "blockerListDisabled", withExtension: "json"))!
        
        }
        
        let item = NSExtensionItem()
        item.attachments = [attachment]
        
        context.completeRequest(returningItems: [item], completionHandler: nil)
    }
    
}
