//
//  Post.swift
//  itjapan-social
//
//  Created by Matthias Hofmann on 29.09.16.
//  Copyright © 2016 MatthiasHofmann. All rights reserved.
//

import Foundation
import Firebase

class Post {
    
    private var _caption: String!
    private var _imageUrl: String!
    private var _likes: Int!
    private var _postId: String!
    private var _postRef: FIRDatabaseReference!
    private var _postedDate: String!
    
    var caption: String {
        return _caption
    }
    
    var imageUrl: String {
        return _imageUrl
    }
    
    var likes: Int {
        return _likes
    }
    
    var postId: String {
        return _postId
    }
    
    var postedDate: String {
        return _postedDate
    }
    
    init(caption: String, imageUrl: String, likes: Int) {
        self._caption = caption
        self._imageUrl = imageUrl
        self._likes = likes
    }
    
    init(postId: String, postData: Dictionary<String, AnyObject>) {
        self._postId = postId
        
        if let caption = postData["caption"] as? String {
            self._caption = caption
        }
        
        if let imageUrl = postData["imageUrl"] as? String {
            self._imageUrl = imageUrl
        }
        
        if let likes = postData["likes"] as? Int {
            self._likes = likes
        }
        
        if let postedDate = postData["postedDate"] as? String {
            self._postedDate = postedDate
        }
        
        _postRef = DataService.ds.REF_POSTS.child(_postId)

    }
    
    func adjustLikes(addLike: Bool) {
        if addLike {
            _likes = _likes + 1
        } else {
            _likes = _likes - 1
        }
        _postRef.child("likes").setValue(_likes)
    }
    
}
