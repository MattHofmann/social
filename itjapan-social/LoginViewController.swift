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
import SwiftKeychainWrapper

class LoginViewController: UIViewController {

    
    @IBOutlet weak var emailField: CustomTextField!
    @IBOutlet weak var pwdField: CustomTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        // if key exist, go directly to FeedViewController
        if let _ = KeychainWrapper.defaultKeychainWrapper().stringForKey(KEY_UID) {
            print("DEV: ID found in keychain")
            performSegue(withIdentifier: "FeedVC", sender: nil)
        }
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
                    if let user = user {
                        let userData = ["provider": user.providerID]
                        self.completeSignIn(id: user.uid, userData: userData)
                    }
                } else {
                    FIRAuth.auth()?.createUser(withEmail: email, password: pwd, completion: { (user, error) in
                        if error != nil {
                            print("DEV: Unable to authenticate with Firebase using email - \(error)")
                        } else {
                            print("DEV: Account created and successfully authenticated with Firebase")
                            if let user = user {
                                let userData = ["provider": user.providerID]
                                self.completeSignIn(id: user.uid, userData: userData)
                            }
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
                if let user = user {
                    let userData = ["provider": credential.provider]
                    self.completeSignIn(id: user.uid, userData: userData)
                }
            }
        })
    }

    func completeSignIn(id: String, userData: Dictionary<String, String>) {
        // create the firebase user
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        // add userid to keychain
        let  keychainResult = KeychainWrapper.defaultKeychainWrapper().setString(id, forKey: KEY_UID)
        print("DEV: Data saved to keychain \(keychainResult)")
        // segue to FeedViewController
        performSegue(withIdentifier: "FeedVC", sender: nil)
    }
    
    
    
}

