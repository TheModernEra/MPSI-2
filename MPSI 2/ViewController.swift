//
//  ViewController.swift
//  MPSI 2
//
//  Copyright © 2020 ModernEra. All rights reserved.
//

//
//  ViewController.swift
//  MPSI 2
//
//  Copyright © 2020 ModernEra. All rights reserved.
//

import Cocoa
import Foundation
import Alamofire
import SSZipArchive

class ViewController: NSViewController {
    let defaultMessage = "Welcome to MPSI. First, click the Download Game button to download Pavlov: Shack."
    let pavlovBuildName = "PreReleaseBuild23_PavlovShack_A"
    let usernameFilePath = NSString(string: "~").expandingTildeInPath
    let obbName = "main.22.com.vankrupt.pavlov.obb"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        installationLabel.stringValue = "\(defaultMessage)"
        let namePath = NSString(string: "~/Downloads/name.txt").expandingTildeInPath
        let folderPath = NSString(string: "~/Downloads/\(pavlovBuildName)").expandingTildeInPath
        let nameDoesExist = FileManager.default.fileExists(atPath: namePath)
        let folderDoesExist = FileManager.default.fileExists(atPath: folderPath)
        if nameDoesExist == true {
            do {
                try FileManager.default.removeItem(atPath: "\(self.usernameFilePath)/Downloads/name.txt")
            }
            catch {
                print(error)
            }
        }
        if folderDoesExist == true {
            do {
                try FileManager.default.removeItem(atPath: "\(self.usernameFilePath)/Downloads/\(pavlovBuildName)")
            }
            catch {
                print(error)
            }
        }
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    @IBOutlet weak var installationLabel: NSTextField!
    
    @IBOutlet weak var nameTextField: NSTextField!
    
    @IBAction func downloadButtonPressed(_ sender: Any) {
        let path = NSString(string: "~/Downloads/\(pavlovBuildName).zip").expandingTildeInPath
        let fileDoesExist = FileManager.default.fileExists(atPath: path)
        if fileDoesExist == true {
            installationLabel.stringValue = "Looks like you already have the game files downloaded! Unzipping them now..."
            Dispatch.background {
                SSZipArchive.unzipFile(atPath: "\(self.usernameFilePath)/Downloads/\(self.pavlovBuildName).zip", toDestination: "\(self.usernameFilePath)/Downloads/\(self.pavlovBuildName)")

                Dispatch.main {
                    self.installationLabel.stringValue = "Game files unzipped! You can now enter your name in the box in the middle, then press install game."
                }
            }
            
        } else {
            installationLabel.stringValue = "Game files not found. Downloading them now. This text will update when the download is finished, please be patient!"
                let destination: DownloadRequest.Destination = { _, _ in
                let documentsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
                let fileURL = documentsURL.appendingPathComponent("\(self.pavlovBuildName).zip")
                return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
                    }

                AF.download("http://34.98.81.223/\(self.pavlovBuildName).zip", to: destination).response { response in
                debugPrint(response)

                if response.error == nil, let imagePath = response.fileURL?.path {
                let image = NSImage(contentsOfFile: imagePath)
                self.installationLabel.stringValue = "Download complete! Unzipping downloaded game files..."
                Dispatch.background {
                SSZipArchive.unzipFile(atPath: "\(self.usernameFilePath)/Downloads/\(self.pavlovBuildName).zip", toDestination: "\(self.usernameFilePath)/Downloads/\(self.pavlovBuildName)")

                Dispatch.main {
                self.installationLabel.stringValue = "Game files downloaded and unzipped! You can now enter your name in the box in the middle, then press install game."
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func installButtonPressed(_ sender: Any) {
        let path = NSString(string: "~/Downloads/\(pavlovBuildName)/\(obbName)").expandingTildeInPath
        let fileDoesExist = FileManager.default.fileExists(atPath: path)
        if fileDoesExist == false {
            installationLabel.stringValue = "Unzipped game files not found. Please press Download Game to download the game or unzip already downloaded game files."
        } else {
            var nameGiven = "null"
            nameGiven = nameTextField.stringValue
            
             let data:NSData = nameGiven.data(using: String.Encoding.utf8)! as NSData
             if let dir : NSString = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.downloadsDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).first as NSString? {

                 data.write(toFile: "\(dir)/name.txt", atomically: true)
             }
            installationLabel.stringValue = "Beginning game installation! Deleting previous installations..."
            let stringPath = Bundle.main.path(forResource: "adb", ofType: "")
            
            @discardableResult
            func shell(_ args: String...) -> Int32 {
                let task = Process()
                task.launchPath = stringPath
                task.arguments = args
                task.launch()
                task.waitUntilExit()
                return task.terminationStatus
            }
            
            Dispatch.background {
                 _ = shell("-d", "uninstall", "com.davevillz.pavlov")
                 _ = shell("-d", "uninstall", "com.vankrupt.pavlov")
                 
                 _ = shell("-d", "shell", "rm", "-rf", "/sdcard/UE4Game")
                 _ = shell("-d", "shell", "rm", "-r", "/sdcard/UE4Game/Pavlov")
                 _ = shell("-d", "shell", "rm", "-r", "/sdcard/UE4Game/UE4CommandLine.txt")
                 _ = shell("-d", "shell", "rm", "-r", "/sdcard/obb/com.vankrupt.pavlov")
                 _ = shell("-d", "shell", "rm", "-r", "/sdcard/Android/obb/com.vankrupt.pavlov")
                 
                self.installationLabel.stringValue = "Previous installs deleted! Pushing apk..."
                 
                _ = shell("-d", "install", "\(self.usernameFilePath)/Downloads/\(self.pavlovBuildName)/Pavlov-Android-Shipping-arm64-es2.apk")
                 
                 _ = shell("-d", "shell", "mkdir", "/sdcard/Android/obb/com.vankrupt.pavlov")
                
                self.installationLabel.stringValue = "APK install completed! Beginning OBB push. This may take a while, please be patient!"
                 
                _ = shell("-d", "push", "\(self.usernameFilePath)/Downloads/\(self.pavlovBuildName)/main.22.com.vankrupt.pavlov.obb", "/sdcard/Android/obb/com.vankrupt.pavlov/")
                 
                self.installationLabel.stringValue = "OBB push complete! Setting permissions and setting name..."
                 
                 _ = shell("-d", "shell", "pm", "grant", "com.vankrupt.pavlov", "android.permission.RECORD_AUDIO")
                 _ = shell("-d", "shell", "pm", "grant", "com.vankrupt.pavlov", "android.permission.READ_EXTERNAL_STORAGE")
                 _ = shell("-d", "shell", "pm", "grant", "com.vankrupt.pavlov", "android.permission.WRITE_EXTERNAL_STORAGE")
                _ = shell("-d", "push", "\(self.usernameFilePath)/Downloads/name.txt", "/sdcard/pavlov.name.txt")
                 _ = shell("-d", "kill-server")
                
                self.installationLabel.stringValue = "Permissions set! Cleaning up files..."
                
                let namePath = NSString(string: "~/Downloads/name.txt").expandingTildeInPath
                let folderPath = NSString(string: "~/Downloads/\(self.pavlovBuildName)").expandingTildeInPath
                let zipPath = NSString(string: "~/Downloads/\(self.pavlovBuildName).zip").expandingTildeInPath
                let nameDoesExist = FileManager.default.fileExists(atPath: namePath)
                let folderDoesExist = FileManager.default.fileExists(atPath: folderPath)
                let zipDoesExist = FileManager.default.fileExists(atPath: zipPath)
                if nameDoesExist == true {
                    do {
                        try FileManager.default.removeItem(atPath: "\(self.usernameFilePath)/Downloads/name.txt")
                    }
                    catch {
                        print(error)
                    }
                }
                if folderDoesExist == true {
                    do {
                        try FileManager.default.removeItem(atPath: "\(self.usernameFilePath)/Downloads/\(self.pavlovBuildName)")
                    }
                    catch {
                        print(error)
                    }
                }
                if zipDoesExist == true {
                    do {
                        try FileManager.default.removeItem(atPath:"\(self.usernameFilePath)/Downloads/\(self.pavlovBuildName).zip")
                    }
                    catch {
                        print(error)
                    }
                }
               
                Dispatch.main {
                     self.installationLabel.stringValue = "Installation complete. You can now close MPSI. Enjoy Pavlov: Shack!"
                    let seconds = 10.0
                    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                        self.installationLabel.stringValue = "\(self.defaultMessage)"
                    }
                }
            }
        }
    }
    
    @IBAction func permsButtonPressed(_ sender: Any) {
        let stringPath = Bundle.main.path(forResource: "adb", ofType: "")
        
        @discardableResult
        func shell(_ args: String...) -> Int32 {
            let task = Process()
            task.launchPath = stringPath
            task.arguments = args
            task.launch()
            task.waitUntilExit()
            return task.terminationStatus
        }
        installationLabel.stringValue = "Setting permissions..."
        Dispatch.background {
            _ = shell("-d", "shell", "pm", "grant", "com.vankrupt.pavlov", "android.permission.RECORD_AUDIO")
            _ = shell("-d", "shell", "pm", "grant", "com.vankrupt.pavlov", "android.permission.READ_EXTERNAL_STORAGE")
            _ = shell("-d", "shell", "pm", "grant", "com.vankrupt.pavlov", "android.permission.WRITE_EXTERNAL_STORAGE")
            Dispatch.main {
                self.installationLabel.stringValue = "Permissions set!"
                let seconds = 3.0
                DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                    self.installationLabel.stringValue = "\(self.defaultMessage)"
                }
            }
        }
    }
    
    @IBAction func nameButtonPressed(_ sender: Any) {
    let stringPath = Bundle.main.path(forResource: "adb", ofType: "")
           
    @discardableResult
    func shell(_ args: String...) -> Int32 {
    let task = Process()
    task.launchPath = stringPath
    task.arguments = args
    task.launch()
    task.waitUntilExit()
    return task.terminationStatus
    }
        
     var nameGiven = "null"
     nameGiven = nameTextField.stringValue
    
     let data:NSData = nameGiven.data(using: String.Encoding.utf8)! as NSData
     if let dir : NSString = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.downloadsDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).first as NSString? {

         data.write(toFile: "\(dir)/name.txt", atomically: true)
     }
    _ = shell("-d", "push", "\(usernameFilePath)/Downloads/name.txt", "/sdcard/pavlov.name.txt")
        do {
            let fileManager = FileManager.default
            try fileManager.removeItem(atPath: "\(usernameFilePath)/Downloads/name.txt")
        }
        catch {
            print("name.txt deletion failed.")
        }
        installationLabel.stringValue = "Name set!"
        let seconds = 3.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            self.installationLabel.stringValue = "\(self.defaultMessage)"
        }
    }
}

