//
//  ViewController.swift
//  VineTracker
//
//  Created by Connor Wybranowski on 9/3/15.
//  Copyright (c) 2015 Wybro. All rights reserved.
//

import UIKit
//import JBChartView

class ViewController: UIViewController, JBLineChartViewDelegate, JBLineChartViewDataSource, UITextFieldDelegate {
    
    let followerRecords = [7000, 7200, 7100, 7036, 7250, 7312, 6900, 7400, 7233, 7166]
//    var dataPoints = NSMutableArray()
    var dataPoints: [Int] = [Int]()
    var cachedUser: [String:AnyObject] = [String:AnyObject]()
    
    @IBOutlet var followerLineChartView: JBLineChartView!
    
    @IBOutlet var avatarPicImageView: UIImageView!
    @IBOutlet var followerCountLabel: UILabel!
    @IBOutlet var newFollowersLabel: UILabel!
    @IBOutlet var userSearchField: UITextField!
    @IBOutlet var userSearchRightConstraint: NSLayoutConstraint!
    @IBOutlet var refreshButton: UIButton!
    @IBOutlet var toggleInfoButton: UIButton!
    @IBOutlet var infoViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var infoView: UIView!
    @IBOutlet var newFollowersFromPreviousDayLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userSearchField.delegate = self

        followerLineChartView.dataSource = self
        followerLineChartView.delegate = self
        followerLineChartView.backgroundColor = UIColor.clearColor()
        followerLineChartView.showsLineSelection = false
        followerLineChartView.showsVerticalSelection = false
        followerLineChartView.reloadData()
        
        println("Launched")
        
        self.avatarPicImageView.layer.cornerRadius = self.avatarPicImageView.frame.size.width / 2
        self.avatarPicImageView.clipsToBounds = true
        
        infoViewHeightConstraint.constant = 0
        
        checkUserSearchSettings()
        fetchNewData(self.getUserSearchSettings())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        userSearchField.resignFirstResponder()
        hideUserSearch()
    }
    
    override func viewDidLayoutSubviews() {
//        println("viewDidLayout")
//        println(self.cachedUser)
        if let actualCachedUserFollowerData = cachedUser["newFollowersData"] as? [String: AnyObject] {
            if let cachedFollowersFromPreviousDay = actualCachedUserFollowerData["newFollowersFromPreviousDate"] as? Int {
                println("cached user found - updating view")
                updateInfoViewLabel(cachedFollowersFromPreviousDay)
            }
        }
        else {
            println("No cached user")
        }
//        if let cachedFollowersFromPreviousDay = cachedUser["newFollowersData"]!["newFollowersFromPreviousDate"] as? Int {
//            updateInfoViewLabel(cachedFollowersFromPreviousDay)
//        }
    }
    
    func numberOfLinesInLineChartView(lineChartView: JBLineChartView!) -> UInt {
        return 1
    }
    
    func lineChartView(lineChartView: JBLineChartView!, numberOfVerticalValuesAtLineIndex lineIndex: UInt) -> UInt {
        return UInt(dataPoints.count)
    }
    
    func lineChartView(lineChartView: JBLineChartView!, verticalValueForHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> CGFloat {
        return CGFloat(dataPoints[Int(horizontalIndex)] as NSNumber)
    }
    
//    func lineChartView(lineChartView: JBLineChartView!, smoothLineAtLineIndex lineIndex: UInt) -> Bool {
//        return true
//    }
    
    func lineChartView(lineChartView: JBLineChartView!, verticalSelectionColorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        return UIColor.redColor()
    }
    
    func lineChartView(lineChartView: JBLineChartView!, colorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        return UIColor.whiteColor()
    }
    
    func lineChartView(lineChartView: JBLineChartView!, widthForLineAtLineIndex lineIndex: UInt) -> CGFloat {
        return 3
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        fetchNewData(textField.text)
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        refreshButton.enabled = false
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        refreshButton.enabled = true
    }
    
    @IBAction func refresh(sender: AnyObject) {
        println("Refreshing")
        refreshAnimation()
        fetchNewData(self.getUserSearchSettings())
    }
    
    func updateUserSearchSettings(searchString: String) {
        let sharedDefaults = NSUserDefaults(suiteName: "group.com.Wybro.Vino-VineTracker")
        sharedDefaults?.setObject(searchString, forKey: "userSearchString")
        sharedDefaults?.synchronize()
        checkUserSearchSettings()
    }
    
    func getUserSearchSettings() -> String? {
        let sharedDefaults = NSUserDefaults(suiteName: "group.com.Wybro.Vino-VineTracker")
        var returnString = sharedDefaults?.objectForKey("userSearchString") as? String
        println(returnString)
        return returnString
    }
    
    func checkUserSearchSettings() {
        if let searchSetting = getUserSearchSettings() as String! {
            refreshButton.enabled = true
        }
        else {
            refreshButton.enabled = false
        }
    }
    
    func fetchNewData(searchString: String?) {
        println("Fetching data")
        //        VineConnection.getUserDataForID(bcUserId, completionHandler: { (vineUser:VineUser) -> () in
        if (searchString != nil) {
            if !searchString!.isEmpty {
                self.updateUserSearchSettings(searchString!)
                VineConnection.getUserDataForName(searchString!, completionHandler: { (vineUser:VineUser) -> () in
                    // Update settings
                    //                self.updateUserSearchSettings(searchString!)
                    
                                println(vineUser.username)
                                println(vineUser.followerCount)
                    //            println(vineUser.loopCount)
                    
                    let sharedDefaults = NSUserDefaults(suiteName: "group.com.Wybro.Vino-VineTracker")
                    
                    var newFollowers = 0
                    var newFollowersFromPreviousDate = 0
                    
                    if let foundUser = sharedDefaults?.objectForKey("\(vineUser.userId)") as? [String:AnyObject] {
                        //                println("User found!")
                        //                println(foundUser)
                        
                        var newDataPoints = foundUser["dataPoints"] as! [Int]
                        newDataPoints.append(vineUser.followerCount)
                        if newDataPoints.endIndex >= 20 {
                            newDataPoints.removeAtIndex(0)
                        }
                        self.updateGraph(newDataPoints)
                        
                        let calendar = NSCalendar.currentCalendar()
                        
                        var startingFollowers = foundUser["newFollowersData"]!["startingFollowers"] as! Int
                        newFollowersFromPreviousDate = foundUser["newFollowersData"]!["newFollowersFromPreviousDate"] as! Int // CHANGED
                        
                        newFollowers = vineUser.followerCount - startingFollowers
                        
                        if let savedDate = foundUser["newFollowersData"]!["date"] as? NSDate {
                            // Saved date is not in today - change startingFollowers
                            if !calendar.isDateInToday(savedDate) {
                                startingFollowers = vineUser.followerCount
                                newFollowersFromPreviousDate = newFollowers
                            }
                        }
                        
//                        self.updateInfoViewLabel(newFollowersFromPreviousDate)
                        
                        var now = NSDate()
                        
                        var user = ["username": vineUser.username, "userId": vineUser.userId, "followerCount": vineUser.followerCount, "loopCount": vineUser.loopCount, "dataPoints":newDataPoints, "newFollowersData": ["date": now, "startingFollowers": startingFollowers, "newFollowersFromPreviousDate": newFollowersFromPreviousDate]]
                        //                println(user)
                        sharedDefaults?.setObject(user, forKey: "\(vineUser.userId)")
                        sharedDefaults?.synchronize()
                        
                        // Cache user to update more info label
                        if let userToSave = user as? [String: AnyObject] {
                            println("caching user")
                            self.cachedUser = userToSave
//                            println(self.cachedUser)
                        }
                        
                        println("Saved user")
//                        println(user)
                    }
                    else {
                        println("User not found -- creating new record")
                        var now = NSDate()
                        var user = ["username": vineUser.username, "userId": vineUser.userId, "followerCount": vineUser.followerCount, "loopCount": vineUser.loopCount, "dataPoints":[vineUser.followerCount], "newFollowersData": ["date": now, "startingFollowers": vineUser.followerCount, "newFollowersFromPreviousDate": newFollowers]]
                        sharedDefaults?.setObject(user, forKey: "\(vineUser.userId)")
                        sharedDefaults?.synchronize()
                        
                        // Cache user to update more info label
                        if let userToSave = user as? [String: AnyObject] {
                            println("caching user")
                            self.cachedUser = userToSave
//                            println(self.cachedUser)
                        }
                        
                        println("New user")
//                        println(user)
                    }
                    
                    // Use separate UI update function here
//                    self.updateInfoViewLabel(newFollowersFromPreviousDate)
                    self.updateLabels(vineUser.followerCount, newFollowers: newFollowers)
                    self.updateAvatarPic(vineUser.avatarPic)
                })
            }
        }
    }
        
    func updateLabels(followers: Int, newFollowers: Int) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            var followersFormatted = NSNumberFormatter.localizedStringFromNumber(followers, numberStyle: NSNumberFormatterStyle.DecimalStyle)
            var newFollowersFormatted = NSNumberFormatter.localizedStringFromNumber(newFollowers, numberStyle: NSNumberFormatterStyle.DecimalStyle)
            
            self.followerCountLabel.text = followersFormatted
            
            if newFollowers >= 0 {
                self.newFollowersLabel.text = "+\(newFollowersFormatted)"
            }
            else if newFollowers < 0 {
                self.newFollowersLabel.text = "\(newFollowersFormatted)"
            }
        })
    }
    
    
    func updateInfoViewLabel(newFollowers: Int) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            var newFollowersFormatted = NSNumberFormatter.localizedStringFromNumber(newFollowers, numberStyle: NSNumberFormatterStyle.DecimalStyle)
            
            if newFollowers >= 0 {
                self.newFollowersFromPreviousDayLabel.text = "+\(newFollowersFormatted)"
            }
            else if newFollowers < 0 {
                self.newFollowersFromPreviousDayLabel.text = "\(newFollowersFormatted)"
            }
        })
    }
    
    func updateAvatarPic(image: UIImage) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.avatarPicImageView.image = image
        })
    }
    
    func updateGraph(dataPointsArr: [Int]) {
        dataPoints.removeAll(keepCapacity: false)
        println("Updating graph")
        println(dataPointsArr)
        for entry in dataPointsArr {
            dataPoints.append(Int(entry as NSNumber))
        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.followerLineChartView.reloadData()
        })
    }
    
    @IBAction func settingsAction(sender: UIButton) {
        if sender.tag == 0 {
            showUserSearch()
            userSearchField.becomeFirstResponder()
            sender.tag = 1
        }
        else {
            hideUserSearch()
            sender.tag = 0
        }
    }
    
    func showUserSearch() {
        userSearchField.enabled = true
        userSearchField.alpha = 0
        userSearchField.hidden = false
        userSearchRightConstraint.constant = 439
        self.view.layoutIfNeeded()
        userSearchRightConstraint.constant = 8
        UIView.animateWithDuration(0.4, delay: 0, options: .CurveEaseOut, animations: { () -> Void in
            self.view.layoutIfNeeded()
            self.userSearchField.alpha = 1
        }) { (completed) -> Void in
            //
        }
    }
    
    func hideUserSearch() {
        userSearchField.enabled = false
        userSearchRightConstraint.constant = 439
        UIView.animateWithDuration(0.4, delay: 0, options: .CurveEaseOut, animations: { () -> Void in
            self.view.layoutIfNeeded()
            self.userSearchField.alpha = 0
            }) { (completed) -> Void in
                self.userSearchField.hidden = true
        }
    }
    
    func refreshAnimation() {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            let transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
            self.refreshButton.transform = transform
            }) { (completed) -> Void in
                self.closingRefreshAnimation()
        }

    }
    
    func closingRefreshAnimation() {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            let transform = CGAffineTransformMakeRotation(0)
            self.refreshButton.transform = transform
        }) { (completed) -> Void in
            //
        }
        
    }
    
    @IBAction func toggleInfo(sender: UIButton) {
        // Hidden - show view
        if sender.tag == 0 {
            showMoreInfo()
            sender.tag = 1
        }
        // Visible - hide view
        else {
            hideMoreInfo()
            sender.tag = 0
        }
    }
    
    func showMoreInfo() {
        infoView.alpha = 0
        infoView.hidden = false
        infoViewHeightConstraint.constant = 80
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: { () -> Void in
            self.view.layoutIfNeeded()
            self.infoView.alpha = 1
            
            let transform = CGAffineTransformMakeRotation(CGFloat(180.0 * M_PI/180.0))
            self.toggleInfoButton.transform = transform
            }) { (completed) -> Void in
                //
        }
    }
    
    func hideMoreInfo() {
        infoViewHeightConstraint.constant = 60
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: { () -> Void in
            self.view.layoutIfNeeded()
            self.infoView.alpha = 0
            
            let transform = CGAffineTransformMakeRotation(0)
            self.toggleInfoButton.transform = transform
            }) { (completed) -> Void in
                self.infoView.hidden = true
        }
    }

}

