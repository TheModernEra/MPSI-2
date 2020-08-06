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

    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    }
    
    @IBAction func nameButtonPressed(_ sender: Any) {
    
    }
}

