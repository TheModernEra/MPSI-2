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
import Zip

class ViewController: NSViewController {
    let defaultMessage = "Welcome to MPSI. First, click the Download Game button to download Pavlov: Shack."
    let usernameFilePath = NSString(string: "~").expandingTildeInPath

    
    var pavlovBuildName = "placeholder"
    var obbName = "placeholder"
    var pavlovURL = "placeholder"
    var apkName = "placeholder"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadProgressIndicator.isHidden = true
        progressIndicator.isHidden = true
        installationLabel.stringValue = "\(defaultMessage)"
        let namePath = NSString(string: "~/Downloads/name.txt").expandingTildeInPath
        let folderPath = NSString(string: "~/Downloads/\(pavlovBuildName)").expandingTildeInPath
        let txtPath = NSString(string: "~/Downloads/upsiopts.txt").expandingTildeInPath
        let nameDoesExist = FileManager.default.fileExists(atPath: namePath)
        let folderDoesExist = FileManager.default.fileExists(atPath: folderPath)
        let txtDoesExist = FileManager.default.fileExists(atPath: txtPath)
        if nameDoesExist == true {
            do {
                try FileManager.default.removeItem(atPath: "\(self.usernameFilePath)/Downloads/name.txt")
            }
            catch {
                print(error)
            }
        }
        if txtDoesExist == true {
            do {
                try FileManager.default.removeItem(atPath: "\(self.usernameFilePath)/Downloads/upsiopts.txt")
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
    
    @IBOutlet weak var downloadProgressIndicator: NSProgressIndicator!
    
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    @IBOutlet weak var uninstallButton: NSButton!
    
    @IBOutlet weak var nameTextField: NSTextField!
    
    @IBAction func downloadButtonPressed(_ sender: Any) {
        do {
            // getting array stuff
            let txtPath: String = "\(self.usernameFilePath)/Downloads/upsiopts.txt"
            let txtFile = try String(contentsOfFile: txtPath)
            let txtArray: [String] = txtFile.components(separatedBy: "\n")
            let separator = "END\r"
            let array = txtArray.split(separator: separator)
            let pavlovArray = Array(array[1])
            
            // URL for pavlov
            let firstPavlovURL = pavlovArray.firstIndex(where: { $0.hasPrefix("DOWNLOADFROM=") })!
            let secondPavlovURL = pavlovArray[firstPavlovURL]
            let thirdPavlovURL = secondPavlovURL.replacingOccurrences(of: "DOWNLOADFROM=", with: "")
            pavlovURL = thirdPavlovURL.replacingOccurrences(of: "\r", with: "")
            print(pavlovURL)
            
            // OBB file name
            let firstOBBName = pavlovArray.firstIndex(where: {$0.hasPrefix("OBB=")})!
            let secondOBBName = pavlovArray[firstOBBName]
            let thirdOBBName = secondOBBName.replacingOccurrences(of: "OBB=", with: "")
            obbName = thirdOBBName.replacingOccurrences(of: "\r", with: "")
            print(obbName)
            
            // current build name
            let firstBuildName = pavlovArray.firstIndex(where: {$0.hasPrefix("ZIPNAME=")})!
            let secondBuildName = pavlovArray[firstBuildName]
            let thirdBuildName = secondBuildName.replacingOccurrences(of: "ZIPNAME=", with: "")
            let fourthBuildName = thirdBuildName.replacingOccurrences(of: ".zip", with: "")
            pavlovBuildName = fourthBuildName.replacingOccurrences(of: "\r", with: "")
            print(pavlovBuildName)
            
            // APK file name
            let firstAPKName = pavlovArray.firstIndex(where: {$0.hasPrefix("APK=")})!
            let secondAPKName = pavlovArray[firstAPKName]
            let thirdAPKName = secondAPKName.replacingOccurrences(of: "APK=", with: "")
            apkName = thirdAPKName.replacingOccurrences(of: "\r", with: "")
            print(apkName)
        } catch let error {
            Swift.print("Fatal Error: \(error.localizedDescription)")
        }
        
        self.progressIndicator.startAnimation(self)
        
        let path = NSString(string: "~/Downloads/\(pavlovBuildName).zip").expandingTildeInPath
        let obbPath = NSString(string: "~/Downloads/\(pavlovBuildName)/\(obbName)").expandingTildeInPath
        let fileDoesExist = FileManager.default.fileExists(atPath: path)
        let obbDoesExist = FileManager.default.fileExists(atPath: obbPath)
        if fileDoesExist == true && obbDoesExist == false {
            installationLabel.stringValue = "Looks like you already have the game files downloaded! Unzipping them now..."
            self.progressIndicator.isHidden = false
            Dispatch.background {
                let zipFolderPath = NSString(string: "~/Downloads/\(self.pavlovBuildName).zip").expandingTildeInPath
                let folderPath = NSString(string: "~/Downloads/\(self.pavlovBuildName)").expandingTildeInPath
                let folderURL = URL(fileURLWithPath: folderPath)
                let zipFolderURL = URL(fileURLWithPath: zipFolderPath)
                do {
                    try Zip.unzipFile(zipFolderURL, destination: folderURL, overwrite: true, password: nil)                }
                catch {
                    print(error)
                }
                Dispatch.main {
                    self.installationLabel.stringValue = "Game files unzipped! You can now enter your name in the box in the middle, then press install game."
                    self.progressIndicator.stopAnimation(self)
                    self.progressIndicator.isHidden = true
                }
            }
            
        } else if obbDoesExist == true {
            installationLabel.stringValue = "Seems like you have the game files downloaded and unzipped already! You can go enter your name in the middle box and press install game."
            self.progressIndicator.stopAnimation(self)
            progressIndicator.isHidden = true
        } else {
            installationLabel.stringValue = "Game files not found. Downloading them now. This text will update when the download is finished, please be patient!"
            downloadProgressIndicator.isHidden = false
            let destination: DownloadRequest.Destination = { _, _ in
                let documentsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
                let fileURL = documentsURL.appendingPathComponent("\(self.pavlovBuildName).zip")
                return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
                    }

                AF.download(pavlovURL, to: destination).downloadProgress { progress in
                    self.downloadProgressIndicator.doubleValue = (progress.fractionCompleted * 100)
            }.response { response in
                debugPrint(response)

                if response.error == nil, let imagePath = response.fileURL?.path {
                let image = NSImage(contentsOfFile: imagePath)
                    self.downloadProgressIndicator.isHidden = true
                    self.installationLabel.stringValue = "Download complete! Unzipping downloaded game files..."
                    self.progressIndicator.isHidden = false
                Dispatch.background {
                    let zipFolderPath = NSString(string: "~/Downloads/\(self.pavlovBuildName).zip").expandingTildeInPath
                    let folderPath = NSString(string: "~/Downloads/\(self.pavlovBuildName)").expandingTildeInPath
                    let downloadDirectory = URL(fileURLWithPath: folderPath)
                    let zipPath = URL(fileURLWithPath: zipFolderPath)
                    do {
                        try Zip.unzipFile(zipPath, destination: downloadDirectory, overwrite: true, password: nil)
                    }
                    catch {
                        print(error)
                    }
                Dispatch.main {
                self.installationLabel.stringValue = "Game files downloaded and unzipped! You can now enter your name in the box in the middle, then press install game."
                    self.progressIndicator.stopAnimation(self)
                    self.progressIndicator.isHidden = true
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
            if nameGiven == "" {
                nameGiven = "I Use A Mac"
            }
            
             let data:NSData = nameGiven.data(using: String.Encoding.utf8)! as NSData
             if let dir : NSString = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.downloadsDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).first as NSString? {

                 data.write(toFile: "\(dir)/name.txt", atomically: true)
             }
            installationLabel.stringValue = "Beginning game installation! Looking for Quest. If your Quest is plugged in and you're stuck here, try a different USB port or a different cable."
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
                 
                self.progressIndicator.startAnimation(self)
                self.progressIndicator.isHidden = false
                self.installationLabel.stringValue = "Quest found and previous version deleted! Pushing apk..."
                 
                _ = shell("-d", "install", "\(self.usernameFilePath)/Downloads/\(self.pavlovBuildName)/\(self.apkName)")
                 
                 _ = shell("-d", "shell", "mkdir", "/sdcard/Android/obb/com.vankrupt.pavlov")
                
                self.installationLabel.stringValue = "APK install completed! Beginning OBB push. This may take a while, please be patient!"
                 
                _ = shell("-d", "push", "\(self.usernameFilePath)/Downloads/\(self.pavlovBuildName)/\(self.obbName)", "/sdcard/Android/obb/com.vankrupt.pavlov/")
                 
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
                let txtPath = NSString(string: "~/Downloads/upsiopts.txt").expandingTildeInPath
                let nameDoesExist = FileManager.default.fileExists(atPath: namePath)
                let folderDoesExist = FileManager.default.fileExists(atPath: folderPath)
                let zipDoesExist = FileManager.default.fileExists(atPath: zipPath)
                let txtDoesExist = FileManager.default.fileExists(atPath: txtPath)
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
                if txtDoesExist == true {
                    do {
                        try FileManager.default.removeItem(atPath: "\(self.usernameFilePath)/Downloads/upsiopts.txt")
                    }
                    catch {
                        print(error)
                    }
                }
               
                Dispatch.main {
                    self.installationLabel.stringValue = "Installation complete. You can now close MPSI. Enjoy Pavlov: Shack!"
                    self.progressIndicator.stopAnimation(self)
                    self.progressIndicator.isHidden = true
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
            _ = shell("-d", "kill-server")
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
    _ = shell("-d", "kill-server")
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
    @IBAction func mapsButtonPressed(_ sender: Any) {
    let stringPath = Bundle.main.path(forResource: "adb", ofType: "")
    let path = NSString(string: "~/Downloads/Android_ASTC.pak").expandingTildeInPath
    let fileDoesExist = FileManager.default.fileExists(atPath: path)
    if fileDoesExist == false {
        installationLabel.stringValue = "Android_ASTC.pak not found in Downloads folder."
        let seconds = 5.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            self.installationLabel.stringValue = "\(self.defaultMessage)"
        }
    } else {
        installationLabel.stringValue = "Pushing Android_ATSC.pak..."
    
        @discardableResult
        func shell(_ args: String...) -> Int32 {
        let task = Process()
        task.launchPath = stringPath
        task.arguments = args
        task.launch()
        task.waitUntilExit()
        return task.terminationStatus
        }

        self.progressIndicator.startAnimation(self)
        
        Dispatch.background {
            _ = shell("push", "\(self.usernameFilePath)/Downloads/Android_ASTC.pak", "/sdcard/pavlov/maps/test_map/Android_ASTC.pak")
            _ = shell("-d", "kill-server")
            Dispatch.main {
                self.installationLabel.stringValue = "Test map pushed!"
                self.progressIndicator.stopAnimation(self)
                let seconds = 5.0
                DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                    self.installationLabel.stringValue = "\(self.defaultMessage)"
            
            }
          }
        }
      }
    }
    
    var clickAmount = 0
    @IBAction func uninstallButtonPressed(_ sender: Any) {
        clickAmount += 1
        if clickAmount == 1 {
            uninstallButton.title = "Are you sure?"
        }
        if clickAmount == 2 {
            uninstallButton.title = "Waiting for Quest..."
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
            
            self.progressIndicator.isHidden = false
            self.progressIndicator.startAnimation(self)
            
            Dispatch.background {
                _ = shell("-d", "uninstall", "com.davevillz.pavlov")
                self.uninstallButton.title = "Uninstalling..."
                _ = shell("-d", "uninstall", "com.vankrupt.pavlov")
                _ = shell("-d", "kill-server")
                Dispatch.main {
                    self.uninstallButton.title = "Uninstalled!"
                    self.progressIndicator.stopAnimation(self)
                    self.progressIndicator.isHidden = true
                    self.clickAmount = 0
                    let seconds = 5.0
                    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                        self.uninstallButton.title = "Uninstall"
                }
              }
           }
        }
    }
    @IBAction func deleteMapsFolderButtonPushed(_ sender: Any) {
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
        
        _ = shell("shell", "rm", "-r", "/sdcard/pavlov/maps")
        _ = shell("-d", "kill-server")
        
        self.installationLabel.stringValue = "Maps folder deleted!"
        let seconds = 5.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            self.installationLabel.stringValue = "\(self.defaultMessage)"
        }
    }
}


