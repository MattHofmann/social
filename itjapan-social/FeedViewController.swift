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

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addImage: CircleView!
    
    // MARK: Variables
    
    var posts = [Post]()
    var imagePicker: UIImagePickerController!
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    
    // MARK: VC Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // tableView delegates
        tableView.delegate = self
        tableView.dataSource = self
        
        // initalize image picker
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        // listener to get post data
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            // print(snapshot.value)
            self.posts = []
            // parse firebase post data
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    print("SNAP: \(snap)")
                    
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Post(postId: key, postData: postDict)
                        self.posts.append(post)
                    }
                }
            }
            self.tableView.reloadData()
        })
    
    }

    // MARK: TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell {
            
            if let image = FeedViewController.imageCache.object(forKey: post.imageUrl as NSString) {
                cell.configureCell(post: post, image: image)
                return cell
            } else {
                cell.configureCell(post: post)
                return cell
            }
        } else {
            return PostCell()
        }
    }
    
    // MARK: Imagepicker
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            addImage.image = image
        } else {
            print("DEV: Invalid image selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: IBActions
    
    @IBAction func signOutButtonPressed(_ sender: UIButton) {
        let keychainResult = KeychainWrapper.defaultKeychainWrapper().removeObjectForKey(KEY_UID)
        print("DEV: Id removed from keychain - \(keychainResult)")
        try! FIRAuth.auth()?.signOut()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addImagePressed(_ sender: AnyObject) {
        present(imagePicker, animated: true, completion: nil)
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
