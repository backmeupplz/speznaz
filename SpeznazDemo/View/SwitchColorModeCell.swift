//
//  SwitchColorModeCell.swift
//  SpeznazDemo
//
//  Created by Nikita Kolmogorov on 2019-03-14.
//  Copyright © 2019 Nikita Kolmogorov. All rights reserved.
//

import UIKit

class SwitchColorModeCell: UITableViewCell {
    
    @IBOutlet weak var switchColorButton: UIButton?
    
    @IBAction func switchColorMode(_ sender: UIButton) {
        Colors.mode = Colors.mode == .day ? .night : .day
        
        updateTitle()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        updateTitle()
    }
    
    func updateTitle() {
        self.switchColorButton?.setTitle(Colors.mode == .day ?
            "Switch to Night Mode" : "Switch to Day Mode", for: .normal)
    }
}
