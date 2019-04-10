//
//  AppDelegate.swift
//  NoteStack
//
//  Created by Mai Nguyen on 4/5/19.
//  Copyright © 2019 Mai Nguyen. All rights reserved.
//

import UIKit
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    let realmDataPersistence = RealmDataPersistence()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let onboarding: NotesOnboardingViewController = ViewControllerFactor.createViewControler(in: "OnboardingStoryboard", id: "NotesOnboardingViewController") as! NotesOnboardingViewController
        if Defaults.getUserFirstOpenStatus.firstTimeOpen == true {
            window?.rootViewController = onboarding
        } else {
            window?.rootViewController = UINavigationController(rootViewController: CategoryViewController(realmDataPersistence: realmDataPersistence))
        }
        
        window?.makeKeyAndVisible()
        // Increate count for app open
        StoreReviewHelper.incrementAppOpenedCount()
        
        Thread.sleep(forTimeInterval: 1.0)
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
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let dict = userInfo as! [String: NSObject]
        let notification = CKNotification(fromRemoteNotificationDictionary: dict)
        let db = CloudKitNoteDatabase.shared
        if notification.subscriptionID == db.subscriptionID {
            db.handleNotification()
            completionHandler(.newData)
        }
        else {
            completionHandler(.noData)
        }
    }
    
    
}


