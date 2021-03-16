//
//  DecibelsViewController.swift
//  Insight Security
//
//  Created by Richard Basdeo on 3/12/21.
//

import UIKit
import AVFoundation

class DecibelsViewController: UIViewController {


    
    @IBOutlet weak var securityButton: UIButton!
    @IBOutlet weak var circleImage: UIImageView!
    @IBOutlet weak var decibelsLabel: UILabel!
    
    var continueAnimation = true
    var alert = MyAlert()
    var shouldRecord = true
    var recorder: AVAudioRecorder?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.9450049996, green: 0.9451631904, blue: 0.9449841976, alpha: 1)
        circleImage.isHidden = true
        
    }
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
        
        if (checkPermissions()){
            
            //start animations
            animateBackGround()
            
            //create recorder if one has not ben created
            if recorder == nil {
                recorder = recorderCreator()
                recorder?.delegate = self
            }
            
            if shouldRecord {
                recorder!.record(forDuration: 3)
                shouldRecord = false
            }
        }
    }
    
    
    
    
    //MARK:: Animations
    func animateBackGround (){
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 2) {
                self.view.backgroundColor = .black
                self.circleImage.isHidden = false
            }
            self.view.backgroundColor = .black
            self.securityButton.setTitle("Security Mode Started", for: .normal)
            self.decibelsLabel.text = "Calculating the average decibels of the room ....."
        }
        
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
    
    
    //MARK:: Recorder Functions
    func checkPermissions() -> Bool {
        
        var permissionGranted = false
        
        //setting session just active before I need to use it
        let theAudioSession = AVAudioSession.sharedInstance()
        
        do {
            //setting the session to active
            try theAudioSession.setActive(true)
            
            //Check Permissions
            //Iif not allowed return fasle and create an alert
            theAudioSession.requestRecordPermission { (userResponse) in
                if (userResponse == false){
                    
                    self.alert.showAlert(with: "Need Permission",
                                    message: "Go to settings and allow microphone user",
                                    on: self,
                                    wasSuccess: false) {
                        permissionGranted = false
                    }
                }
                else {
                    permissionGranted = true
                }
            }
        }
        catch{
            permissionGranted = false
        }
        
        return permissionGranted
    }
    
    
    func recorderCreator () -> AVAudioRecorder? {
        
        guard let dataPath = FileManager.default.urls(for: .documentDirectory,
                                                      in: .userDomainMask).first?.appendingPathComponent("recording.m4a") else {return nil}
        
        let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
        
        do {
        let returnRecorder = try AVAudioRecorder(url: dataPath, settings: settings)
            return returnRecorder
        }
        catch{
            return nil
        }
    }
}






extension DecibelsViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if (flag){
            print ("Recording Done")
        }
    }
}

