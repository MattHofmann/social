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
    
    var post: Post!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(post: Post, image: UIImage? = nil) {
        self.post = post
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
        
    }
    
}
