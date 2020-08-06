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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        installationLabel.stringValue = "\(defaultMessage)"
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
        installationLabel.stringValue = "pog button in disguise baby"
    }
    
    @IBAction func installButtonPressed(_ sender: Any) {
    
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
    
    }
}

