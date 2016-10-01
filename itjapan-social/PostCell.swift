//
//  PostCell.swift
//  itjapan-social
//
//  Created by Matthias Hofmann on 28.09.16.
//  Copyright © 2016 MatthiasHofmann. All rights reserved.
//

import UIKit
import Firebase

class PostCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var likeImage: UIImageView!
    
    var post: Post!
    var likesRef: FIRDatabaseReference!

    
    override func awakeFromNib() {
        super.awakeFromNib()

        // add tapGestureRecognizers for the like button programmatically
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(likeButtonPressed))
        singleTap.numberOfTouchesRequired = 1
        likeImage.addGestureRecognizer(singleTap)

        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(likeButtonPressed))
        doubleTap.numberOfTouchesRequired = 2
        likeImage.addGestureRecognizer(doubleTap)
        
        // remove singleTap if there is a doubleTap (preventing counting a like twice)
        singleTap.require(toFail: doubleTap)
        
        likeImage.isUserInteractionEnabled = true

        
    }

    func configureCell(post: Post, image: UIImage? = nil) {
        self.post = post
        likesRef = DataService.ds.REF_USER_CURRENT.child("likes").child(post.postId)
        
        self.caption.text = post.caption
        self.likesLabel.text = "\(post.likes)"
        // TODO profileImage and usernameLabel
        
        // if there is an image in the cache, use that image.
        // otherwise downlaod the image and save it to chache.
        if image != nil {
            self.postImage.image = image
        } else {
            let ref = FIRStorage.storage().reference(forURL: post.imageUrl)
            ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("DEV: Unable to download image from Firebase storage")
                } else {
                    print("DEV: Image downloaded from Firebase storage")
                    if let imageData = data {
                        if let image = UIImage(data: imageData) {
                            self.postImage.image = image
                            FeedViewController.imageCache.setObject(image, forKey: post.imageUrl as NSString)
                        }
                    }
                }
            })
        }
        // likes
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likeImage.image = UIImage(named: "empty-heart")
            } else {
                self.likeImage.image = UIImage(named: "filled-heart")
            }

        })
    }
    
    func likeButtonPressed(sender: UITapGestureRecognizer) {
        // likes
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likeImage.image = UIImage(named: "filled-heart")
                self.post.adjustLikes(addLike: true)
                self.likesRef.setValue(true)
            } else {
                self.likeImage.image = UIImage(named: "empty-heart")
                self.post.adjustLikes(addLike: false)
                self.likesRef.removeValue()
            }
            
        })
    }

    
}
