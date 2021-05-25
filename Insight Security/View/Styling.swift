//
//  Styling.swift
//  Insight Security
//
//  Created by Richard Basdeo on 5/25/21.
//

import UIKit
class Styling {
    
    static let tier1 = #colorLiteral(red: 1, green: 0.2619006038, blue: 0.3000560105, alpha: 1) //nav bar
    static let tier2 = #colorLiteral(red: 0.8940294385, green: 0.8941795826, blue: 0.8940096498, alpha: 1) //background
    static let tier3 = #colorLiteral(red: 0.1685162485, green: 0.2090681195, blue: 0.2551903427, alpha: 1) //
    static let tier4 = #colorLiteral(red: 0.2090408504, green: 0.3567248583, blue: 0.4520696998, alpha: 1) //Text color
    
    static func customButton (for aButton: UIButton){
        aButton.layer.cornerRadius = aButton.frame.height / 2
        aButton.backgroundColor = tier1
        aButton.setTitleColor(tier4, for: .normal)
    }
    
    static func customTextField (for aTextField: UITextField){
        aTextField.layer.cornerRadius = aTextField.frame.height / 2
        aTextField.backgroundColor = .white
        aTextField.textColor = .black
        
    }
    
    
    
    
}
