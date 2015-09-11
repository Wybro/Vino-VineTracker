//
//  VineConnection.swift
//  VineTracker
//
//  Created by Connor Wybranowski on 9/4/15.
//  Copyright (c) 2015 Wybro. All rights reserved.
//

import UIKit

let bcUserId = "1240426345918877696"

class VineConnection: NSObject {
    
    class func getUserDataForID(userId: String, completionHandler:(VineUser)->()){
        let url = NSURL(string: "https://api.vineapp.com/users/profiles/\(userId)")
        
        let urlRequest = NSURLRequest(URL: url!)
        
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue()) { (response:NSURLResponse!, data:NSData!, error:NSError!) -> Void in
            if let returnedData = data {
                var userData = JSON(data: data!)
                
                if let user = userData["data"].dictionary {
                    let username = user["username"]!.string
                    let userId = user["userId"]!.int
                    var avatarPic = UIImage(named: "defaultProfPic")
                    if let avatarUrl = user["avatarUrl"]?.string {
                        if let imageUrl = NSURL(string: avatarUrl) {
                            if let data = NSData(contentsOfURL: imageUrl) {
                                avatarPic = UIImage(data: data)
                            }
                        }
                    }
                    let followerCount = user["followerCount"]!.int
                    let loopCount = user["loopCount"]!.int
                    
                    let vineUser = VineUser(username: username!, userId: userId!, avatarPic: avatarPic!, followerCount: followerCount!, loopCount: loopCount!)
                    completionHandler(vineUser)
                }
            }
//            else {
//                println("some error")
//            }
        }
    }
    
    class func getUserDataForName(username: String, completionHandler:(VineUser, error:String)->()){
        let urlSearchString: String = username.stringByReplacingOccurrencesOfString(" ", withString: "-")
        let url = NSURL(string: "https://api.vineapp.com/users/search/\(urlSearchString)")
        
        let urlRequest = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue()) { (response:NSURLResponse!, data:NSData!, error:NSError!) -> Void in
//            println("error: \(error)")
            if let returnedData = data {
//                println("Error: \(error)")
//                println("Data: \(data)")
                var userData = JSON(data: data!)
//                println(userData)
                
                if let firstUser = userData["data"]["records"][0].dictionary {
                    let username = firstUser["username"]!.string
                    let userId = firstUser["userId"]!.int
                    var avatarPic = UIImage(named: "defaultProfPic")
                    if let avatarUrl = firstUser["avatarUrl"]?.string {
                        if let imageUrl = NSURL(string: avatarUrl) {
                            if let data = NSData(contentsOfURL: imageUrl) {
                                avatarPic = UIImage(data: data)
                            }
                        }
                    }
                    let followerCount = firstUser["followerCount"]!.int
                    let loopCount = firstUser["loopCount"]!.int
                    
                    let vineUser = VineUser(username: username!, userId: userId!, avatarPic: avatarPic!, followerCount: followerCount!, loopCount: loopCount!)
                    completionHandler(vineUser, error: "")
                }
                else {
                    // No user found
//                    println("No user found")
                    let emptyVineUser = VineUser()
                    completionHandler(emptyVineUser, error: "No user found")
                }
            }
//            else {
//                println("some error")
//            }
        }
    }

}
