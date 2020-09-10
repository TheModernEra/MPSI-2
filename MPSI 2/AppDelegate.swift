//
//  AppDelegate.swift
//  MPSI 2
//
//  Copyright © 2020 ModernEra. All rights reserved.
//

import Cocoa
import Alamofire

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
           }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        let usernameFilePath = NSString(string: "~").expandingTildeInPath
        let txtPath = NSString(string: "~/Downloads/MPSI Stuff").expandingTildeInPath
        let txtDoesExist = FileManager.default.fileExists(atPath: txtPath)
        if txtDoesExist == true {
            do {
                try FileManager.default.removeItem(atPath: "\(usernameFilePath)/Downloads/MPSI Stuff")
            }
            catch {
                print(error)
            }
        }
    }


}

