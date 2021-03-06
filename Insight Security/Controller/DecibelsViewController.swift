//
//  DecibelsViewController.swift
//  Insight Security
//
//  Created by Richard Basdeo on 3/12/21.
//

import UIKit
import AVFoundation

class DecibelsViewController: UIViewController {

    //outlets
    @IBOutlet weak var securityButton: UIButton!
    @IBOutlet weak var circleImage: UIImageView!
    @IBOutlet weak var decibelsLabel: UILabel!
    
    //connect to the model
    var decibelBrain = DecibelAppBrain()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Want a white background when user first load the screen
        view.backgroundColor = #colorLiteral(red: 0.9450049996, green: 0.9451631904, blue: 0.9449841976, alpha: 1)
        
        //Want to hide the circle indicating im listeneing
        circleImage.isHidden = true
        
        
        decibelBrain.delegate = self
        Styling.customButton(for: securityButton)
        
    }
    
    
    
    //User clicked start security mode button
    @IBAction func startButtonPressed(_ sender: UIButton) {
        
        //First ask the model if I have permission to record
        if (decibelBrain.checkPermissions()){
            
            //Check to see if recoder is intialized to record
            //If not initialize it
            if (decibelBrain.recorder == nil){
                decibelBrain.recorder = decibelBrain.recorderCreator()
                decibelBrain.recorder?.isMeteringEnabled = true
                decibelBrain.recorder?.delegate = self
            }
            
            
            //The first time the button is pressed we will record
            if (decibelBrain.shouldRecord){
                
                //Dont want user to keep reseting the recorder
                decibelBrain.shouldRecord = false
                
                //Indicate to the user I am recording
                decibelBrain.delegate?.animateBackground()
                
                //Record for 5 seconds
                //5 seconds for demo purposes, suppose to be 30
                decibelBrain.recorder!.record(forDuration: 5)
                
                //Every second get the current decibel levels by calling the model
                let tempTimer = Timer.scheduledTimer(timeInterval: 1,
                                                     target: decibelBrain.self,
                                                     selector: #selector(decibelBrain.getDecibels),
                                                     userInfo: nil,
                                                     repeats: true)
                decibelBrain.aTimer = tempTimer
                decibelBrain.aTimer?.fire()
            }
            
            //If recoder should not be recoder go back to white screen
            
            else {
                decibelBrain.delegate?.getBackToOriginal()
            }
        }
    }
}

//Animations
extension DecibelsViewController: decibelProtocol {
    
    func animateBackground() {
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 2) {
                self.view.backgroundColor = .black
                self.circleImage.isHidden = false
            }
            self.view.backgroundColor = .black
            self.securityButton.setTitle("Security Mode Started", for: .normal)
            self.decibelsLabel.text = "Calculating the average decibels of the room ....."
        }
        
        decibelBrain.delegate?.animateCircle()
        
    }
    
    func animateCircle(){
        
        UIView.animate(withDuration: 3) {
            self.circleImage.transform = CGAffineTransform(scaleX: 0.25, y: 0.25)
        } completion: { (_) in
            
            UIView.animate(withDuration: 3) {
                self.circleImage.transform = CGAffineTransform(scaleX: 2, y: 2)
            }completion: { (_) in
                UIView.animate(withDuration: 3) {
                    self.circleImage.transform = CGAffineTransform(scaleX: 1, y: 1)
                } completion: { (_) in
                    if (self.decibelBrain.continueAnimation){
                        self.decibelBrain.delegate?.animateCircle()
                    }
                }
            }
        }
    }
    
    func endAnimation(){
        
        UIView.animateKeyframes(withDuration: 3,
                                delay: 0) {
            self.circleImage.alpha = 0
        } completion: { (_) in
            
            UIView.animate(withDuration: 2.5) {
                self.circleImage.isHidden = true
                self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                self.securityButton.alpha = 0.3
                self.securityButton.setTitle("Exit Security Mode", for: .normal)
                self.decibelsLabel.text = "Average decibels of the room: \(self.decibelBrain.averageDecibelsOfRoom())"
                
            } completion: { (_) in
                UIView.animate(withDuration: 4) {
                    self.decibelsLabel.alpha = 0
                    self.navigationController?.navigationBar.isHidden = true
                }
            }
        }

        
    }

    func getBackToOriginal(){
        
        UIView.animate(withDuration: 1,
                       delay: 0) {
            
            self.view.backgroundColor = #colorLiteral(red: 0.9450049996, green: 0.9451631904, blue: 0.9449841976, alpha: 1)
            self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 1, green: 0.2923489213, blue: 0.3685441613, alpha: 1)
            self.securityButton.setTitle("Start Security Mode", for: .normal)
            self.securityButton.alpha = 1
            self.decibelsLabel.alpha = 1
            self.decibelsLabel.text = "Decibels:"
            self.navigationController?.navigationBar.isHidden = false
            self.decibelBrain.shouldRecord = true
            
            
        } completion: { (_) in
            
            //self.shouldRecord = true
            DispatchQueue.main.async {
                self.decibelsLabel.text = "Decibels:"
            }
            
        }
        
    }
    
    func updateLabel(){
        
        
        DispatchQueue.main.async {
            self.decibelsLabel.text = "Calculating The Average Decibel: \(self.decibelBrain.decibleContainer.last!)"
        }
        
    }
    
    func showAlert(){
        
        DispatchQueue.main.async {
            
            self.decibelBrain.alert.showAlert(with: "Need Permission",
                                 message: "Go to settings and allow microphone user",
                                 on: self,
                                 wasSuccess: false) {}
        }
    }
}

//Will stop recording for two reasons
//First: the 30 second period to get the average room is up
//Second: there was a noise spike to go to camera class
//MARK:: Audio Recorder Delegate
extension DecibelsViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if (flag){
            
            if (decibelBrain.shouldContinousRecord == false){
                decibelBrain.continueAnimation = false
            endAnimation()
            }
            else {
                performSegue(withIdentifier: "decibelToCamera", sender: self)
            }
        }
    }
}

