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
    var decibleContainer = [Float]()
    var timerCounter = 0
    var aTimer: Timer?
    
    
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
                recorder?.isMeteringEnabled = true
                recorder?.delegate = self
            }
            
            if shouldRecord {
                recorder!.record(forDuration: 30)
                
                let tempTimer = Timer.scheduledTimer(timeInterval: 1,
                                     target: self,
                                     selector: #selector(getDecibels),
                                     userInfo: nil, repeats: true)
                aTimer = tempTimer
                aTimer?.fire()
            }
        }
    }
    
    
    @objc func getDecibels(){
        recorder?.updateMeters()
        if let decibels = recorder?.peakPower(forChannel: 0){
            decibleContainer.append(decibels)
            
            DispatchQueue.main.async {
                self.decibelsLabel.text = "Calculating The Average Decibel: \(String(format: "%.2f", decibels))"
            }
        }
        
        timerCounter += 1
        if (timerCounter == 30){
            aTimer?.invalidate()
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
    
    func endAnimation () {
        UIView.animateKeyframes(withDuration: 3,
                                delay: 0) {
            self.circleImage.alpha = 0
        } completion: { (_) in
            
            UIView.animate(withDuration: 2.5) {
                self.circleImage.isHidden = true
                self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                self.securityButton.alpha = 0.3
                self.securityButton.setTitle("Exit Security Mode", for: .normal)
                self.decibelsLabel.text = "Average decibels of the room: 50"
                
            } completion: { (_) in
                UIView.animate(withDuration: 4) {
                    self.decibelsLabel.alpha = 0
                    self.navigationController?.navigationBar.isHidden = true
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
                AVNumberOfChannelsKey: 1 as NSNumber,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ] as [String : Any]
        
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
            continueAnimation = false
            endAnimation()
            
        }
    }
}

