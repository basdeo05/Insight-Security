//
//  ViewController.swift
//  Insight Security
//
//  Created by Richard Basdeo on 3/10/21.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var forgotPasswordOutlet: UIButton!
    var turnTransformation:CGFloat = 4
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //hide forgot password button until they put in wrong password 3 times
        forgotPasswordOutlet.isHidden = true
        animateImage()
    }
    
    func animateImage() {
        UIView.animate(withDuration: 2) {
            self.logoImage.transform = self.logoImage.transform.rotated(by: .pi / self.turnTransformation)
        } completion: { (_) in
            UIView.animate(withDuration: 2) {
                self.logoImage.transform = self.logoImage.transform.rotated(by: -.pi / 2)
            } completion: { (_) in
                self.turnTransformation = 2
                self.animateImage()
            }
        }
    }
}

