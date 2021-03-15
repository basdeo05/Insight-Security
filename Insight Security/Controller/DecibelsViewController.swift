//
//  DecibelsViewController.swift
//  Insight Security
//
//  Created by Richard Basdeo on 3/12/21.
//

import UIKit

class DecibelsViewController: UIViewController {


    
    @IBOutlet weak var securityButton: UIButton!
    @IBOutlet weak var circleImage: UIImageView!
    @IBOutlet weak var decibelsLabel: UILabel!
    
    var continueAnimation = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.9450049996, green: 0.9451631904, blue: 0.9449841976, alpha: 1)
        circleImage.isHidden = true
        
    }
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
        UIView.animate(withDuration: 2) {
            self.view.backgroundColor = .black
            self.circleImage.isHidden = false
        }
        view.backgroundColor = .black
        securityButton.setTitle("Security Mode Started", for: .normal)
        decibelsLabel.text = "Calculating the average decibels of the room ....."
        circleAnimation()
    }
    
    func circleAnimation (){
        
        UIView.animate(withDuration: 3) {
            self.circleImage.transform = CGAffineTransform(scaleX: 0.25, y: 0.25)
        } completion: { (_) in
            
            UIView.animate(withDuration: 3) {
                self.circleImage.transform = CGAffineTransform(scaleX: 2, y: 2)
            }completion: { (_) in
                UIView.animate(withDuration: 3) {
                    self.circleImage.transform = CGAffineTransform(scaleX: 1, y: 1)
                } completion: { (_) in
                    if (self.continueAnimation){
                        self.circleAnimation()
                    }
                }
            }
        }
    }
}

