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
    var amountOfLogin = 0
    var delegate: loginAttempts?
    let k = K()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //hide forgot password button until they put in wrong password 3 times
        forgotPasswordOutlet.isHidden = true
        animateImage()
        delegate = self
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == k.homeSignIn){
            let destinationVC = segue.destination as! LoginViewController
            destinationVC.delegate = self
        }
        else {
            _ = segue.destination as! SignUpViewController
        }
    }
}

extension HomeViewController: loginAttempts {
    func showForgotPassword() {
        
        print("Delegate called")
        amountOfLogin += 1
        
        if (amountOfLogin == 3){
            UIView.animate(withDuration: 2) {
                self.forgotPasswordOutlet.isHidden = false
            }
        }
    }
}

