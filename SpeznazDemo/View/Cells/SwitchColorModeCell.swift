//
//  SwitchColorModeCell.swift
//  SpeznazDemo
//
//  Created by Nikita Kolmogorov on 2019-03-14.
//  Copyright © 2019 Nikita Kolmogorov. All rights reserved.
//

import UIKit

class SwitchColorModeCell: UITableViewCell {
    
    // MARK: - Outlets -
    
    @IBOutlet weak var switchColorButton: UIButton?
    
    // MARK: - Actions -
    
    @IBAction func switchColorMode(_ sender: UIButton) {
        Colors.mode = Colors.mode == .day ? .night : .day
        
        updateTitle()
    }
    
    // MARK: - View Life Cycle -
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        updateTitle()
    }
    
    // MARK: - Private Functions -
    
    func updateTitle() {
        self.switchColorButton?.setTitle(Colors.mode == .day ?
            "Switch to Night Mode" : "Switch to Day Mode", for: .normal)
    }
}
