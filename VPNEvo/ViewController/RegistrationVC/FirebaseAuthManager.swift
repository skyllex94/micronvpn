//
//  FirebaseAuthManager.swift
//  VPNEvo
//
//  Created by iOSProfessionals on 06/01/23.
//

import Foundation
import FirebaseAuth
import UIKit

class FirebaseAuthManager {
    func createUser(email: String, password: String, completionBlock: @escaping (_ success: Bool) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) {(authResult, error) in
            if let user = authResult?.user {
                print(user)
                
                UserDefaults.standard.setValue(user.email, forKey:"LoginUserEmail")
                UserDefaults.standard.setValue(user.displayName, forKey:"LoginUserDisplayName")
                UserDefaults.standard.setValue(user.phoneNumber, forKey:"LoginUserPhoneNumber")
                
                completionBlock(true)
            } else {
                completionBlock(false)
            }
        }
    }
    
    func signIn(email: String, pass: String, completionBlock: @escaping (_ success: Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: pass) { (result, error) in
            if let user = result?.user {
                print(user)
                
                UserDefaults.standard.setValue(user.email, forKey:"LoginUserEmail")
                UserDefaults.standard.setValue(user.displayName, forKey:"LoginUserDisplayName")
                UserDefaults.standard.setValue(user.phoneNumber, forKey:"LoginUserPhoneNumber")
                
                completionBlock(true)
            } else {
                completionBlock(false)
            }
        }
    }
 
}
