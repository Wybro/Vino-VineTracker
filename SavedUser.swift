//
//  SavedUser.swift
//  Vino-VineTracker
//
//  Created by Connor Wybranowski on 9/10/15.
//  Copyright (c) 2015 Wybro. All rights reserved.
//

import UIKit

class SavedUser: NSObject {
    var username: String!
    var userId: Int!
    var avatarPic: UIImage!
    
    var followerCount: Int!
    var newFollowers: Int!
    var followerDataPoints: [Int]!
    
    var loopCount: Int!
    var newLoops: Int!
    var loopDataPoints: [Int]!
    
    // Data for updates
    var date: NSDate!
    var startingFollowers: Int!
    var newFollowersFromPreviousDate: Int!
    var startingLoops: Int!
    var newLoopsFromPreviousDate: Int!
    
    
    init(username: String, userId: Int, avatarPic: UIImage, followerCount: Int, newFollowers: Int, followerDataPoints: [Int], loopCount: Int, newLoops: Int, loopDataPoints: [Int], date: NSDate, startingFollowers: Int, newFollowersFromPreviousDate: Int, startingLoops: Int, newLoopsFromPreviousDate: Int) {
        super.init()
        self.username = username
        self.userId = userId
        self.avatarPic = avatarPic
        self.followerCount = followerCount
        self.newFollowers = newFollowers
        self.followerDataPoints = followerDataPoints
        self.loopCount = loopCount
        self.newLoops = newLoops
        self.loopDataPoints = loopDataPoints
        self.date = date
        self.startingFollowers = startingFollowers
        self.newFollowersFromPreviousDate = newFollowersFromPreviousDate
        self.startingLoops = startingLoops
        self.newLoopsFromPreviousDate = newLoopsFromPreviousDate
    }
   
}
