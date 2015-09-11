//
//  VineUser.swift
//  VineTracker
//
//  Created by Connor Wybranowski on 9/4/15.
//  Copyright (c) 2015 Wybro. All rights reserved.
//

import UIKit

class VineUser: NSObject {
    
    var username: String!
    var userId: Int!
    var avatarPic: UIImage!
    var followerCount: Int!
    var loopCount: Int!
    
    override init() {
        self.username = ""
        self.userId = 0
        self.avatarPic = UIImage(named: "defaultProfPic")
        self.followerCount = 0
        self.loopCount = 0
    }
    
    init (username: String, userId: Int, avatarPic: UIImage, followerCount: Int, loopCount: Int) {
        super.init()
        
        self.username = username
        self.userId = userId
        self.avatarPic = avatarPic
        self.followerCount = followerCount
        self.loopCount = loopCount
    }
    
//    init(coder aDecoder: NSCoder!) {
//        self.username = aDecoder.decodeObjectForKey("username") as! String
//        self.avatarPic = aDecoder.decodeObjectForKey("avatarPic")as! UIImage
//        self.followerCount = aDecoder.decodeObjectForKey("followerCount") as! Int
//        self.loopCount = aDecoder.decodeObjectForKey("loopCount") as! Int
//    }
//    
//    func initWithCoder(aDecoder: NSCoder) -> VineUser {
//        self.username = aDecoder.decodeObjectForKey("username") as! String
//        self.avatarPic = aDecoder.decodeObjectForKey("avatarPic")as! UIImage
//        self.followerCount = aDecoder.decodeObjectForKey("followerCount") as! Int
//        self.loopCount = aDecoder.decodeObjectForKey("loopCount") as! Int
//        return self
//    }
//    
//    func encodeWithCoder(aCoder: NSCoder!) {
//        aCoder.encodeObject(username, forKey: "username")
//        aCoder.encodeObject(avatarPic, forKey: "avatarPic")
//        aCoder.encodeObject(followerCount, forKey: "followerCount")
//        aCoder.encodeObject(loopCount, forKey: "loopCount")
//        
//    }

}
