//
//  ShowAlert.swift
//  Insight Security
//
//  Created by Richard Basdeo on 3/12/21.
//

import Foundation
import UIKit

class MyAlert: UIViewController {
    
    
    struct Constants {
        
        //What we want the background to animate to
        static let backgroundAlphaTo: CGFloat = 0.6
    }
    
    
    
    //create backgroundView that will dim the current view
    private let backgroundView: UIView = {
        
        //create the view
        let backgroundView = UIView()
        
        //give the view a color and alpha
        backgroundView.backgroundColor = .black
        
        //Want the background to be invisible then we will animate it in
        backgroundView.alpha = 0
        
        //return the view
        return backgroundView
    }()
    
    
    
    
    //Now create the view for the alert
    private let alertView: UIView = {
        
        let alert = UIView()
        alert.backgroundColor = #colorLiteral(red: 1, green: 0.2627159357, blue: 0.295563668, alpha: 1)
        
        //round corners for alert
        alert.layer.masksToBounds = true
        alert.layer.cornerRadius = 12
        
        
        return alert
    }()
    
    
    
    
    
    
    
    func showAlert (with title: String,
                    message: String,
                    on viewController: UIViewController,
                    wasSuccess: Bool,
                    completionHandler: @escaping () -> ()){
        
        //1. Add the background view and the view to the viewController's view
        guard let targetView = viewController.view else {return}
        
        //want the frame of the background view to entirely cover the target view
        //get viewController bounds then add it
        backgroundView.frame = targetView.bounds
        targetView.addSubview(backgroundView)
        
        //add alert to the view
        targetView.addSubview(alertView)
        
        //give the alert view a size and add label
        //Want Y to be negative to be off screen then will animate it in
        alertView.frame = CGRect(x: targetView.frame.width / 4,
                                 y: -300,
                                 width: targetView.frame.size.width / 2,
                                 height: 100)
        
        
        //create label to display text
        //Width will be the width of the alert view
        let titleLabel = UILabel(frame: CGRect(x: 0,
                                               y: 0,
                                               width: alertView.frame.size.width,
                                               height: 30))
        titleLabel.text = title
        titleLabel.textColor = #colorLiteral(red: 0.2434413433, green: 0.3513373435, blue: 0.4444853067, alpha: 1)
        titleLabel.textAlignment = .center
        alertView.addSubview(titleLabel)
        
        
        
        //create message label to display text
        //Width will be the width of the alert view
        //I know 220 by subtracting alert frame height from title lable height
        let messageLabel = UILabel(frame: CGRect(x: 0,
                                               y: 30,
                                               width: alertView.frame.size.width,
                                               height: 80))
        messageLabel.numberOfLines = 0
        messageLabel.text = message
        messageLabel.textColor = #colorLiteral(red: 0.2434413433, green: 0.3513373435, blue: 0.4444853067, alpha: 1)
        messageLabel.backgroundColor = .white
        messageLabel.textAlignment = .center
        alertView.addSubview(messageLabel)
        
        
        //now we want to animate to raise alpha to sliglty see black blackground
        UIView.animate(withDuration: 0.25) {
            self.backgroundView.alpha = Constants.backgroundAlphaTo
            
        } completion: { (done) in
            if done {
                //animation to bring in alertView
                //can do this by changing its frame
                UIView.animate(withDuration: 0.25) {
                    //Will have alert view come down from the top and be centered
                    self.alertView.center = targetView.center
                    
                    
                } completion: { (done) in
                    
                    
                    if (done){
                        var delayTime: TimeInterval = 0
                        
                        if (wasSuccess){
                            delayTime = 1
                        }
                        else {
                            delayTime = 3
                        }
                        
                        UIView.animate(withDuration: 1, delay: delayTime) {
                            self.alertView.frame = CGRect(x: targetView.frame.width / 4,
                                                           y: targetView.frame.size.height,
                                                     width: targetView.frame.size.width / 2,
                                                     height: 100)
                            self.backgroundView.alpha = 0
                        } completion: { (done) in
                            if (done){
                                
                                self.alertView.removeFromSuperview()
                                self.backgroundView.removeFromSuperview()
                                messageLabel.text = ""
                                titleLabel.text = ""
                                completionHandler()
                            }
                        }
                    }
                }
            }
        }
    }
}
