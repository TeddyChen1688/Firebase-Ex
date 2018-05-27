//
//  AppDelegate.swift
//  FBtest
//
//  Created by eva on 2018/5/24.
//  Copyright © 2018年 Lextronic. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        // Configure Facebook Login
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Configure Google Sign in
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        print("現在的 storyboard \(storyboard)")
        
//        Auth.auth().addStateDidChangeListener{ auth, user in
//            if let user = user {
//                print("使用者已經登入: \(user.email)")
//                let viewController = storyboard.instantiateViewController(withIdentifier: "MainFlow")
//                self.window?.rootViewController = viewController
//
//            }
//            else {
//                print("使用者已經登出, 現在沒有登入使用者!!")
//                let viewController = storyboard.instantiateViewController(withIdentifier: "SigninFlow")
//                self.window?.rootViewController = viewController
//            }
//        }
        
        
        
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
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        var handled = false
        
        if url.absoluteString.contains("fb") {
            handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
            
        } else {
            handled = GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
        }
        
        return handled
    }


}

