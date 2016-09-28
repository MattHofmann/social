//
//  LoginViewController.swift
//  itjapan-social
//
//  Created by Matthias Hofmann on 27.09.16.
//  Copyright © 2016 MatthiasHofmann. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // facebook auth
    @IBAction func facebookButtonPressed(_ sender: AnyObject) {
        // create loginmanager
        let facebookLogin = FBSDKLoginManager()
        // request email
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print("DEV: Unable to authenticate with Facebook - \(error)")
            } else if result?.isCancelled == true {
                print("DEV: User cancelled Facebook authentication")
            } else {
                print("DEV: Successfully authenticated with Facebook")
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuth(credential)
            }
        }
    }
    
    // firebase auth method
    func firebaseAuth(_ credential: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("DEV: Unable to authenticate with Firebase - \(error)")
            } else {
                print("DEV: Successfully authenticated with Firebase")
            }
        })
    }

}

