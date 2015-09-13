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
    
    let customGreenBackground = UIColor(red: 19/255, green: 183/255, blue: 121/255, alpha: 1)
    let customPurpleBackground = UIColor(red: 167/255, green: 99/255, blue: 208/255, alpha: 1)
    let customLightPurpleBackground = UIColor(red: 196/255, green: 141/255, blue: 228/255, alpha: 1)
    
    var dataPoints: [Int] = [Int]()
    
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
    @IBOutlet var settingsButton: UIButton!
    @IBOutlet var searchButton: UIButton!
    @IBOutlet var followersSettingButton: UIButton!
    @IBOutlet var loopsSettingButton: UIButton!
    @IBOutlet var followerSettingHorizontalConstraint: NSLayoutConstraint!
    @IBOutlet var loopSettingHorizontalConstraint: NSLayoutConstraint!
    @IBOutlet var settingTypeLabel: UILabel!

    @IBOutlet var actionPopoverView: UIView!
    @IBOutlet var shadowView: UIView!
    @IBOutlet var actionPopoverImageView: UIImageView!
    @IBOutlet var actionPopoverLabel: UILabel!
    
    var isRotating = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        userSearchField.delegate = self
        
        followerLineChartView.dataSource = self
        followerLineChartView.delegate = self
        followerLineChartView.backgroundColor = UIColor.clearColor()
        followerLineChartView.showsLineSelection = false
        followerLineChartView.showsVerticalSelection = false
        followerLineChartView.reloadData()
        
        self.avatarPicImageView.layer.cornerRadius = self.avatarPicImageView.frame.size.width / 2
        self.avatarPicImageView.clipsToBounds = true
        
        infoViewHeightConstraint.constant = 0
        
        // Setup loading view
        actionPopoverView.layer.cornerRadius = 5
        actionPopoverView.layer.shadowOpacity = 1
        actionPopoverView.layer.shadowOffset = CGSize(width: 0, height: 2)
        actionPopoverView.layer.shadowRadius = 3

        checkUserSearchSettings()
        checkUserDisplaySetting()
        fetchNewData(UserDefaultsManager.getUserSearchSettings())
    }
    
    override func viewDidAppear(animated: Bool) {

    }
    
    override func viewWillAppear(animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        var touch = touches.first as! UITouch
        var point = touch.locationInView(self.view)
        
        userSearchField.resignFirstResponder()
        hideUserSearch()
        
        if !actionPopoverView.frame.contains(point) {
            hideActionPopoverView()
        }
    }
    
    override func viewDidLayoutSubviews() {
        UserDefaultsManager.loadUserFromCache { (savedUser) -> () in
            if let displaySetting = UserDefaultsManager.getUserDisplaySetting() as String!{
                if displaySetting == "followerView" {
//                    println("new followers from yesterday: \(savedUser.newFollowersFromPreviousDate)")
                    self.updateInfoViewLabel(savedUser.newFollowersFromPreviousDate)
                }
                else if displaySetting == "loopView" {
//                    println("new loops from yesterday: \(savedUser.newLoopsFromPreviousDate)")
                    self.updateInfoViewLabel(savedUser.newLoopsFromPreviousDate)
                }
            }
        }
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
        fetchNewData(UserDefaultsManager.getUserSearchSettings())
    }
    
    func checkUserSearchSettings() {
        if let searchSetting = UserDefaultsManager.getUserSearchSettings() as String! {
            refreshButton.enabled = true
        }
        else {
            refreshButton.enabled = false
        }
    }
    
    func checkUserDisplaySetting() {
        if let displaySetting = UserDefaultsManager.getUserDisplaySetting() as String! {
            if displaySetting == "followerView" {
                println("followerView display setting")
                followerViewMode()
            }
            else if displaySetting == "loopView" {
                println("loopView display setting")
                loopViewMode()
            }
        }
        // First time entering app
        else {
            // Set default view to followers
            println("first time entering app")
            UserDefaultsManager.updateUserDisplaySetting("followerView")
            followerViewMode()
        }
    }
    
    func followerViewMode() {
        println("followerViewMode")
        UserDefaultsManager.updateUserDisplaySetting("followerView")
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.settingTypeLabel.text = "followers"
            self.userSearchField.textColor = self.customGreenBackground
            self.followersSettingButton.enabled = false
            self.loopsSettingButton.enabled = true
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.view.backgroundColor = self.customGreenBackground
            })
            UserDefaultsManager.loadUserFromCache({ (savedUser) -> () in
                self.updateLabels(savedUser.followerCount, newFollowers: savedUser.newFollowers)
                self.updateGraph(savedUser.followerDataPoints)
            })
        })
    }
    
    func loopViewMode() {
        println("loopViewMode")
        UserDefaultsManager.updateUserDisplaySetting("loopView")
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.settingTypeLabel.text = "loops"
            self.userSearchField.textColor = self.customPurpleBackground
            self.loopsSettingButton.enabled = false
            self.followersSettingButton.enabled = true
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.view.backgroundColor = self.customPurpleBackground
            })
            UserDefaultsManager.loadUserFromCache({ (savedUser) -> () in
                self.updateLabels(savedUser.loopCount, newFollowers: savedUser.newLoops)
                self.updateGraph(savedUser.loopDataPoints)
            })
        })
    }
    
    @IBAction func followerSettingAction(sender: UIButton) {
        followerViewMode()
    }
    
    @IBAction func loopSettingAction(sender: UIButton) {
        loopViewMode()
    }
    
    func fetchNewData(searchString: String?) {
        println("Fetching data")
        if (searchString != nil) {
            if !searchString!.isEmpty {
                
                showActionPopoverView("loading")
                
                VineConnection.getUserDataForName(searchString!, completionHandler: { (vineUser:VineUser, error:String) -> () in

                    if !error.isEmpty {
                        println("error: \(error)")
                        self.stopSpinningAction()
                        self.showActionPopoverView("noUser")
                        return
                    }
                    else {
                        self.hideActionPopoverView()
                        println("search successful - saving search")
                        UserDefaultsManager.updateUserSearchSettings(searchString!)
                    }
                    
                    self.hideUserSearch()

                    // Update settings
                    var foundUser: SavedUser? = nil
                    var newFollowers = 0
                    var newFollowersFromPreviousDate = 0
                    var newLoops = 0
                    var newLoopsFromPreviousDate = 0
                    
                    UserDefaultsManager.getSavedUser("\(vineUser.userId)", completionHandler: { (savedUser) -> () in
                        println("saved user: \(savedUser)")
                        foundUser = savedUser
                    })
                    
                    if foundUser != nil {
                        var followerDataPoints = foundUser!.followerDataPoints
                        followerDataPoints?.append(vineUser.followerCount)
                        if followerDataPoints?.endIndex > 20 {
                            followerDataPoints?.removeAtIndex(0)
                        }
                        
                        var loopDataPoints = foundUser!.loopDataPoints
                        loopDataPoints?.append(vineUser.loopCount)
                        if loopDataPoints?.endIndex > 20 {
                            loopDataPoints?.removeAtIndex(0)
                        }
                        
                        if let displaySetting = UserDefaultsManager.getUserDisplaySetting() as String!{
                            if displaySetting == "followerView" {
                                self.updateGraph(followerDataPoints)
                            }
                            else if displaySetting == "loopView" {
                                self.updateGraph(loopDataPoints)
                            }
                        }
//                        self.updateGraph(followerDataPoints)
                        // Update graphs here
                        
                        let calendar = NSCalendar.currentCalendar()
                        
                        var startingFollowers = foundUser!.startingFollowers
                        var startingLoops = foundUser!.startingLoops
                        newFollowersFromPreviousDate = foundUser!.newFollowersFromPreviousDate!
//                        println("new followers from yesterday: \(foundUser!.newFollowersFromPreviousDate)")
                        newLoopsFromPreviousDate = foundUser!.newLoopsFromPreviousDate!
//                        println("new loops from yesterday: \(foundUser!.newLoopsFromPreviousDate)")
                        
//                        newFollowers = vineUser.followerCount - startingFollowers
//                        newLoops = vineUser.loopCount - startingLoops
                        
                        if !calendar.isDateInToday(foundUser!.date) {
                            startingFollowers = vineUser.followerCount
                            startingLoops = vineUser.loopCount
                            
                            newFollowersFromPreviousDate = newFollowers
                            newLoopsFromPreviousDate = newLoops
                        }
                        
                        newFollowers = vineUser.followerCount - startingFollowers
                        newLoops = vineUser.loopCount - startingLoops
                        
                        var now = NSDate()
                        
                        let userToSave = SavedUser(username: vineUser.username, userId: vineUser.userId, avatarPic: vineUser.avatarPic, followerCount: vineUser.followerCount, newFollowers: newFollowers, followerDataPoints: followerDataPoints, loopCount: vineUser.loopCount, newLoops: newLoops, loopDataPoints: loopDataPoints, date: now, startingFollowers: startingFollowers, newFollowersFromPreviousDate: newFollowersFromPreviousDate, startingLoops: startingLoops, newLoopsFromPreviousDate: newLoopsFromPreviousDate)
                        
                        UserDefaultsManager.saveUser(userToSave, key: "\(vineUser.userId)")
                        UserDefaultsManager.saveUserToCache(userToSave)
                        println("User Found")
                        println(userToSave)
                        
                        
                    }
                    else {
                        println("User not found -- creating new record")
                        var now = NSDate()
                        
                        var newUser = SavedUser(username: vineUser.username, userId: vineUser.userId, avatarPic: vineUser.avatarPic, followerCount: vineUser.followerCount, newFollowers: newFollowersFromPreviousDate, followerDataPoints: [vineUser.followerCount], loopCount: vineUser.loopCount, newLoops: newLoops, loopDataPoints: [vineUser.loopCount], date: now, startingFollowers: vineUser.followerCount, newFollowersFromPreviousDate: 0, startingLoops: vineUser.loopCount, newLoopsFromPreviousDate: 0)
                        UserDefaultsManager.saveUser(newUser, key: "\(vineUser.userId)")
                        UserDefaultsManager.saveUserToCache(newUser)
                        
                        if let displaySetting = UserDefaultsManager.getUserDisplaySetting() as String!{
                            if displaySetting == "followerView" {
                                self.updateGraph([vineUser.followerCount])
                            }
                            else if displaySetting == "loopView" {
                                self.updateGraph([vineUser.loopCount])
                            }
                        }

                        
                    }
                    
                    // Use separate UI update function here
                    if let displaySetting = UserDefaultsManager.getUserDisplaySetting() as String!{
                        if displaySetting == "followerView" {
                            self.updateLabels(vineUser.followerCount, newFollowers: newFollowers)
                        }
                        else if displaySetting == "loopView" {
                            self.updateLabels(vineUser.loopCount, newFollowers: newLoops)
                        }
                    }
//                    self.updateLabels(vineUser.followerCount, newFollowers: newFollowers)
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
    
    @IBAction func searchAction(sender: UIButton) {
        if sender.tag == 0 {
            showUserSearch()
            hideFollowerSettingButton()
            hideLoopSettingButton()
            userSearchField.becomeFirstResponder()
        }
        else {
            hideUserSearch()
        }
    }
    
    @IBAction func settingsAction(sender: UIButton) {
        if sender.tag == 0 {
            showFollowerSettingButton()
            showLoopSettingButton()
//            sender.tag = 1
        }
        else {
            hideFollowerSettingButton()
            hideLoopSettingButton()
            sender.tag = 0
        }
    }
    
    func showFollowerSettingButton() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.settingsButton.tag = 1
            self.followersSettingButton.hidden = false
            self.followersSettingButton.alpha = 0
            self.followerSettingHorizontalConstraint.constant = 0
            self.view.layoutIfNeeded()
            self.followerSettingHorizontalConstraint.constant = 14
            UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseOut, animations: { () -> Void in
                self.view.layoutIfNeeded()
                self.followersSettingButton.alpha = 1
                
                }) { (completed) -> Void in
            }
        })
    }
    
    func hideFollowerSettingButton() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.settingsButton.tag = 0
            self.followerSettingHorizontalConstraint.constant = 0
            UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseOut, animations: { () -> Void in
                self.view.layoutIfNeeded()
                self.followersSettingButton.alpha = 0
                }) { (completed) -> Void in
                    self.followersSettingButton.hidden = true
            }
        })
    }
    
    func showLoopSettingButton() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.loopsSettingButton.hidden = false
            self.loopsSettingButton.alpha = 0
            self.loopSettingHorizontalConstraint.constant = 0
            self.view.layoutIfNeeded()
            self.loopSettingHorizontalConstraint.constant = 8
            UIView.animateWithDuration(0.2, delay: 0.1, options: .CurveEaseOut, animations: { () -> Void in
                self.view.layoutIfNeeded()
                self.loopsSettingButton.alpha = 1
                
                }) { (completed) -> Void in
            }
        })
    }
    
    func hideLoopSettingButton() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.loopSettingHorizontalConstraint.constant = 0
            UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseOut, animations: { () -> Void in
                self.view.layoutIfNeeded()
                self.loopsSettingButton.alpha = 0
                }) { (completed) -> Void in
                    self.loopsSettingButton.hidden = true
            }
        })
    }
    
    func showUserSearch() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.settingsButton.hidden = true
            
            self.userSearchField.enabled = true
            self.userSearchField.alpha = 0
            self.userSearchField.hidden = false
            self.userSearchRightConstraint.constant = 439
            self.view.layoutIfNeeded()
            self.userSearchRightConstraint.constant = 8
            UIView.animateWithDuration(0.4, delay: 0, options: .CurveEaseOut, animations: { () -> Void in
                self.view.layoutIfNeeded()
                self.userSearchField.alpha = 1
                }) { (completed) -> Void in
                    self.searchButton.tag = 1
                    self.userSearchField.becomeFirstResponder()
            }
        })
    }
    
    func hideUserSearch() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.userSearchField.enabled = false
            self.userSearchRightConstraint.constant = 439
            UIView.animateWithDuration(0.4, delay: 0, options: .CurveEaseOut, animations: { () -> Void in
                self.view.layoutIfNeeded()
                self.userSearchField.alpha = 0
                }) { (completed) -> Void in
                    // make fade animation for this
                    self.settingsButton.hidden = false
                    self.userSearchField.text = ""
                    self.userSearchField.hidden = true
                    self.searchButton.tag = 0
            }
        })
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
    
    //MARK: ActionPopoverView Methods
    
    func showActionPopoverView(type: String) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            switch type {
            case "loading":
                self.actionPopoverImageView.image = UIImage(named: "loadingImage")
                self.actionPopoverLabel.text = "loading..."
                self.spinningAction()
            case "error":
                self.actionPopoverImageView.image = UIImage(named: "errorImage")
                self.actionPopoverLabel.text = "Something went wrong"
            case "noUser":
                self.actionPopoverImageView.image = UIImage(named: "errorImage")
                self.actionPopoverLabel.text = "User not found"
            default:
                break
            }
            self.animateActionPopoverIn()
        })
    }
    
    func hideActionPopoverView() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.animateActionPopoverOut()
        })
    }
    
    func animateActionPopoverIn() {
        actionPopoverView.transform = CGAffineTransformMakeScale(0.8, 0.8)
        actionPopoverView.alpha = 0
        shadowView.alpha = 0
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .CurveEaseInOut, animations: { () -> Void in
            self.actionPopoverView.transform = CGAffineTransformMakeScale(1, 1)
            self.actionPopoverView.alpha = 1
            self.shadowView.alpha = 0.3
            }) { (completed) -> Void in
        }
    }
    
    func animateActionPopoverOut() {
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .CurveEaseInOut, animations: { () -> Void in
            self.actionPopoverView.transform = CGAffineTransformMakeScale(0.8, 0.8)
            self.actionPopoverView.alpha = 0
            self.shadowView.alpha = 0
            }) { (completed) -> Void in
                self.stopSpinningAction()
        }
    }
    
    func spinningAction() {
        // check if it is not rotating
        if !isRotating {
            // create a spin animation
            let spinAnimation = CABasicAnimation()
            // starts from 0
            spinAnimation.fromValue = 0
            // goes to 360 ( 2 * π )
            spinAnimation.toValue = M_PI*2
            // define how long it will take to complete a 360
            spinAnimation.duration = 1
            // make it spin infinitely
            spinAnimation.repeatCount = Float.infinity
            // do not remove when completed
            spinAnimation.removedOnCompletion = false
            // specify the fill mode
            spinAnimation.fillMode = kCAFillModeForwards
            // and the animation acceleration
            spinAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            // add the animation to the button layer
            actionPopoverImageView.layer.addAnimation(spinAnimation, forKey: "transform.rotation.z")
            
        } else {
            // remove the animation
            actionPopoverImageView.layer.removeAllAnimations()
            isRotating = false
        }
    }
    
    func stopSpinningAction() {
        isRotating = true
        spinningAction()
    }
    
}

