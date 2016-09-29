//
//  FeedViewController.swift
//  itjapan-social
//
//  Created by Matthias Hofmann on 28.09.16.
//  Copyright © 2016 MatthiasHofmann. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // tableView delegates
        tableView.delegate = self
        tableView.dataSource = self
        
        // listener
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            print(snapshot.value)
        })
    
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        //return UITableViewCell()
    }
    
    
    @IBAction func signOutButtonPressed(_ sender: UIButton) {
        let keychainResult = KeychainWrapper.defaultKeychainWrapper().removeObjectForKey(KEY_UID)
        print("DEV: Id removed from keychain - \(keychainResult)")
        try! FIRAuth.auth()?.signOut()
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
