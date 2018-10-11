//
//  AppDelegate.swift
//  Serval Chat
//
//  Created by Alexandre Dorys-Charnalet on 30/08/2018.
//  Copyright © 2018 Alexandre Dorys-Charnalet. All rights reserved.
//

import UIKit
import serval_dna.daemon


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    let servald = ServalD()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        #if IOS_SIMULATOR
        print("SETUP SIMULATOR")
        setupServalSimulator()
        #else
        print("SETUP DEVICE")
        setupServalDevice()
        #endif
        
        servald_features()
        
        // Logging
        servalLogSetup(minimum_level: .debug)
        
        // Start the daemon
        servald.startServer()
        return true
    }
    
    func setupServalDevice() {
        let fm = FileManager.default
        let servalFolders = ["Serval/var/run/serval/proc", "Serval/etc/serval"]
        
        for path: String in servalFolders {
            
            if let tDocumentDirectory = fm.urls(for: .libraryDirectory, in: .userDomainMask).first {
                let filePath =  tDocumentDirectory.appendingPathComponent("\(path)")
                if !fm.fileExists(atPath: filePath.path) {
                    do {
                        try fm.createDirectory(atPath: filePath.path, withIntermediateDirectories: true, attributes: nil)
                    } catch {
                        NSLog("Couldn't create document directory")
                    }
                }
            }
        }
        
        if let tDocumentDirectory = fm.urls(for: .libraryDirectory, in: .userDomainMask).first {
            let filePath =  tDocumentDirectory.appendingPathComponent("Serval/etc/serval")
            if let fromURL = Bundle.main.url(forResource: "serval", withExtension: "conf") {
                let toURL = filePath.appendingPathComponent("serval").appendingPathExtension("conf")

                if fm.fileExists(atPath: toURL.path) {
                    do {
                        NSLog("Removing old serval.conf file")
                        try fm.removeItem(at: toURL)
                    } catch let error {
                        NSLog("Couldn't remove file \(error)")
                    }
                }
                do {
                    try fm.copyItem(at: fromURL, to: toURL)
                } catch let error{
                    NSLog("Couldn't copy file \(error)")
                }
                NSLog("serval.conf file location: \(toURL)")
            }
        }
    }
    
    func setupServalSimulator() {
        // NOT WORKING
        
//        let fm = FileManager.default
//
//        if let fromURL = Bundle.main.url(forResource: "serval", withExtension: "conf") {
//            let toURL = URL(fileURLWithPath: "/tmp/serval-dna/etc/serval/")
//                do {
//                    try fm.copyItem(at: fromURL, to: toURL.absoluteURL)
//                } catch let error{
//                    NSLog("Couldn't copy file \(error)")
//                }
//        }
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
}

