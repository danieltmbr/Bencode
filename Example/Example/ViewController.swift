//
//  ViewController.swift
//  Example
//
//  Created by Daniel Tombor on 2017. 09. 14..
//  Copyright © 2017. danieltmbr. All rights reserved.
//

import Cocoa
import Bencode

final class ViewController: NSViewController {
    
    // MARK: - IBOutlets

    @IBOutlet weak private var fileNameLabel: NSTextFieldCell!
    
    @IBOutlet weak private var fileLengthLabel: NSTextFieldCell!
    
    @IBOutlet private var fileContentTextView: NSTextView!
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        guard let url = Bundle.main.url(forResource: "Entourage.S01", withExtension: "torrent"),
            let bencode = Bencode(file: url) else { return }
        
        fileNameLabel.title = bencode["info"]["files"][1]["path"][0].string!
        fileLengthLabel.title = "\(bencode["info"]["files"][1]["length"].int!)"
        fileContentTextView.textStorage?.append(NSAttributedString(string: bencode.debugDescription))
        fileContentTextView.scroll(NSPoint(x: 0, y: 0))
    }

}

