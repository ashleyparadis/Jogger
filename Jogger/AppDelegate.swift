//
//  AppDelegate.swift
//  Jogger
//
//  Created by Ashley Paradis on 2018-05-22.
//  Copyright © 2018 Ashley Paradis. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import FirebaseDatabase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var users:[User] = []
    var snapshotArray:[UIImage] = []
    var runHistoryList:[Run] = []
    var profilePic:[UIImage] = [#imageLiteral(resourceName: "imagePlaceholder")]
    var segueFromTableView = true
    var unitKm = true
    var colorChoice:UIColor = UIColor.init(red: 235/255, green: 64/255, blue: 37/255, alpha: 1.0)
    var countryList:[String] = []
    
    let redColor = UIColor.init(red: 235/255, green: 64/255, blue: 37/255, alpha: 1.0)
    let orangeColor = UIColor.init(red: 241/255, green: 151/255, blue: 55/255, alpha: 1.0)
    let yellowColor = UIColor.init(red: 255/255, green: 250/255, blue: 83/255, alpha: 1.0)
    let greenColor = UIColor.init(red: 114/255, green: 244/255, blue: 74/255, alpha: 1.0)
    let blueColor = UIColor.init(red: 115/255, green: 249/255, blue: 253/255, alpha: 1.0)
    let purpleColor = UIColor.init(red: 137/255, green: 69/255, blue: 246/255, alpha: 1.0)
    let pinkColor = UIColor.init(red: 240/255, green: 145/255, blue: 212/255, alpha: 1.0)
    let greyColor = UIColor.init(red: 192/255, green: 192/255, blue: 192/255, alpha: 1.0)
    let blackColor = UIColor.init(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
    
    var paceArray:[Double] = []
    var paceAverage:Double = 0
    var speedArray:[Double] = []
    var speedAverage:Double = 0
    var totalDistance:Double = 0
    var totalDuration:Int = 0

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let handled = FBSDKApplicationDelegate.sharedInstance().application(_: application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        return handled
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        getSavedData()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func getSavedData(){
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "kUnitSelected") != nil{
            let whichUnit:Any
            whichUnit = defaults.value(forKey: "kUnitSelected")!
            let whichUnitString = whichUnit as! String
            if whichUnitString == "km"{
                self.unitKm = true
            } else if whichUnitString == "mi"{
                self.unitKm = false
            }
        
        }
        if defaults.object(forKey: "kColorSelected") != nil{
            let color:Any
            color = defaults.value(forKey: "kColorSelected")!
            let colorString = color as! String
            if colorString == "red"{
                self.colorChoice = redColor
            } else if colorString == "orange"{
                self.colorChoice = orangeColor
            } else if colorString == "yellow"{
                self.colorChoice = yellowColor
            } else if colorString == "green"{
                self.colorChoice = greenColor
            } else if colorString == "blue"{
                self.colorChoice = blueColor
            } else if colorString == "purple"{
                self.colorChoice = purpleColor
            } else if colorString == "pink"{
                self.colorChoice = pinkColor
            } else if colorString == "grey"{
                self.colorChoice = greyColor
            } else if colorString == "black"{
                self.colorChoice = blackColor
            }
            
        }
    }


}

