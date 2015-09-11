//
//  UserDefaultsManager.swift
//  Vino-VineTracker
//
//  Created by Connor Wybranowski on 9/10/15.
//  Copyright (c) 2015 Wybro. All rights reserved.
//

import UIKit

class UserDefaultsManager: NSObject {
    
    class func getUserSearchSettings() -> String? {
        let sharedDefaults = NSUserDefaults(suiteName: "group.com.Wybro.Vino-VineTracker")
        var returnString = sharedDefaults?.objectForKey("userSearchString") as? String
//        println(returnString)
        return returnString
    }
    
    class func updateUserSearchSettings(searchString: String) {
        let sharedDefaults = NSUserDefaults(suiteName: "group.com.Wybro.Vino-VineTracker")
        sharedDefaults?.setObject(searchString, forKey: "userSearchString")
        sharedDefaults?.synchronize()
//        checkUserSearchSettings() -- call this after class func in view
    }
    
    class func getUserDisplaySetting() -> String? {
        let sharedDefaults = NSUserDefaults(suiteName: "group.com.Wybro.Vino-VineTracker")
        var returnString = sharedDefaults?.objectForKey("userDisplaySetting") as? String
        return returnString
    }
    
    class func updateUserDisplaySetting(displaySetting: String) {
        let sharedDefaults = NSUserDefaults(suiteName: "group.com.Wybro.Vino-VineTracker")
        sharedDefaults?.setObject(displaySetting, forKey: "userDisplaySetting")
        sharedDefaults?.synchronize()
    }
    
    class func saveUser(user: SavedUser, key: String) {
        let sharedDefaults = NSUserDefaults(suiteName: "group.com.Wybro.Vino-VineTracker")
        let imageData: NSData = UIImageJPEGRepresentation(user.avatarPic, 1)
        
        let userToSave: [String: AnyObject] = ["username": user.username, "userId": user.userId, "imageData": imageData, "followerCount": user.followerCount, "newFollowers": user.newFollowers, "followerDataPoints": user.followerDataPoints, "loopCount": user.loopCount, "newLoops": user.newLoops, "loopDataPoints": user.loopDataPoints, "date": user.date, "startingFollowers": user.startingFollowers, "newFollowersFromPreviousDate": user.newFollowersFromPreviousDate, "startingLoops": user.startingLoops, "newLoopsFromPreviousDate": user.newLoopsFromPreviousDate]
        sharedDefaults?.setObject(userToSave, forKey: key)
        sharedDefaults?.synchronize()
    }
    
    class func getSavedUser(key: String, completionHandler:(SavedUser) ->()) {
        let sharedDefaults = NSUserDefaults(suiteName: "group.com.Wybro.Vino-VineTracker")
        if let foundUser = sharedDefaults?.objectForKey(key) as? [String:AnyObject] {
            let username: String = foundUser["username"] as! String
            let userId: Int = foundUser["userId"] as! Int
            let imageData: NSData = foundUser["imageData"] as! NSData
            let avatarPic: UIImage = UIImage(data: imageData)! as UIImage
            
            let followerCount: Int = foundUser["followerCount"] as! Int
            let newFollowers: Int = foundUser["newFollowers"] as! Int
            let followerDataPoints: [Int] = foundUser["followerDataPoints"] as! [Int]
            
            let loopCount: Int = foundUser["loopCount"] as! Int
            let newLoops: Int = foundUser["newLoops"] as! Int
            let loopDataPoints: [Int] = foundUser["loopDataPoints"] as! [Int]
            
            let date: NSDate = foundUser["date"] as! NSDate
            let startingFollowers: Int = foundUser["startingFollowers"] as! Int
            let newFollowersFromPreviousDate: Int = foundUser["newFollowersFromPreviousDate"] as! Int
            let startingLoops: Int = foundUser["startingLoops"] as! Int
            let newLoopsFromPreviousDate: Int = foundUser["newLoopsFromPreviousDate"] as! Int
            
            let loadedUser = SavedUser(username: username, userId: userId, avatarPic: avatarPic, followerCount: followerCount, newFollowers: newFollowers, followerDataPoints: followerDataPoints, loopCount: loopCount, newLoops: newLoops, loopDataPoints: loopDataPoints, date: date, startingFollowers: startingFollowers, newFollowersFromPreviousDate: newFollowersFromPreviousDate, startingLoops: startingLoops, newLoopsFromPreviousDate: newLoopsFromPreviousDate)
            completionHandler(loadedUser)
        }
    }
    
    class func saveUserToCache(user: SavedUser) {
        let sharedDefaults = NSUserDefaults(suiteName: "group.com.Wybro.Vino-VineTracker")

        let imageData: NSData = UIImageJPEGRepresentation(user.avatarPic, 1)
        
        let userToSave: [String: AnyObject] = ["username": user.username, "userId": user.userId, "imageData": imageData, "followerCount": user.followerCount, "newFollowers": user.newFollowers, "followerDataPoints": user.followerDataPoints, "loopCount": user.loopCount, "newLoops": user.newLoops, "loopDataPoints": user.loopDataPoints, "date": user.date, "startingFollowers": user.startingFollowers, "newFollowersFromPreviousDate": user.newFollowersFromPreviousDate, "startingLoops": user.startingLoops, "newLoopsFromPreviousDate": user.newLoopsFromPreviousDate]
        
        sharedDefaults?.setObject(userToSave, forKey: "cachedUser")
        sharedDefaults?.synchronize()
    }

    class func loadUserFromCache(completionHandler:(SavedUser)->()){
        let sharedDefaults = NSUserDefaults(suiteName: "group.com.Wybro.Vino-VineTracker")
        if let userFromCache = sharedDefaults?.objectForKey("cachedUser") as? [String: AnyObject] {
            let username: String = userFromCache["username"] as! String
            let userId: Int = userFromCache["userId"] as! Int
            let imageData: NSData = userFromCache["imageData"] as! NSData
            let avatarPic: UIImage = UIImage(data: imageData)! as UIImage
            
            let followerCount: Int = userFromCache["followerCount"] as! Int
            let newFollowers: Int = userFromCache["newFollowers"] as! Int
            let followerDataPoints: [Int] = userFromCache["followerDataPoints"] as! [Int]
            
            let loopCount: Int = userFromCache["loopCount"] as! Int
            let newLoops: Int = userFromCache["newLoops"] as! Int
            let loopDataPoints: [Int] = userFromCache["loopDataPoints"] as! [Int]
            
            let date: NSDate = userFromCache["date"] as! NSDate
            let startingFollowers: Int = userFromCache["startingFollowers"] as! Int
            let newFollowersFromPreviousDate: Int = userFromCache["newFollowersFromPreviousDate"] as! Int
            let startingLoops: Int = userFromCache["startingLoops"] as! Int
            let newLoopsFromPreviousDate: Int = userFromCache["newLoopsFromPreviousDate"] as! Int
            
            let cachedUser = SavedUser(username: username, userId: userId, avatarPic: avatarPic, followerCount: followerCount, newFollowers: newFollowers, followerDataPoints: followerDataPoints, loopCount: loopCount, newLoops: newLoops, loopDataPoints: loopDataPoints, date: date, startingFollowers: startingFollowers, newFollowersFromPreviousDate: newFollowersFromPreviousDate, startingLoops: startingLoops, newLoopsFromPreviousDate: newLoopsFromPreviousDate)

            completionHandler(cachedUser)
        }
    }
    
   
}
