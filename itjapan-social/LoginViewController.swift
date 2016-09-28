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

    
    @IBOutlet weak var emailField: CustomTextField!
    @IBOutlet weak var pwdField: CustomTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // facebook authentification
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
    
    // email authentication
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        // TODO: add alert if the user dont enter anything
        // TODO: the password for firebase has to be at least 6 characters long
        
        //
        if let email = emailField.text, let pwd = pwdField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: pwd, completion: { (user, error) in
                if error == nil {
                    print("DEV: Email user authenticated with Firebase")
                } else {
                    FIRAuth.auth()?.createUser(withEmail: email, password: pwd, completion: { (user, error) in
                        if error != nil {
                            print("DEV: Unable to authenticate with Firebase using email - \(error)")
                        } else {
                            print("DEV: Account created and successfully authenticated with Firebase")
                        }
                    })
                }
            })
        }
    }
    
    // firebase authentication method
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

