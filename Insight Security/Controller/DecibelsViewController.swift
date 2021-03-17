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
    
    //Stop the circle animation
    var continueAnimation = true
    
    //crete an alert if i need user to allow access to the microphone
    var alert = MyAlert()
    
    //when tapping the record button for the first time I should start recording
    var shouldRecord = true
    
    //recorder to be set when user clicks start security mode
    var recorder: AVAudioRecorder?
    
    //holds the decibels of the room
    //will have 30 items for 30 seconds
    var decibleContainer = [Float]()
    
    //Know when to stop the timer
    var timerCounter = 0
    var aTimer: Timer?
    
    //variable to hold the average decibels
    var theAverageDecibleOfTheRoom: Float? {
        didSet{
            continousRecording()
        }
    }
    
    var shouldContinousRecord = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.9450049996, green: 0.9451631904, blue: 0.9449841976, alpha: 1)
        circleImage.isHidden = true
        
    }
    
    //User clicked start security mode button
    @IBAction func startButtonPressed(_ sender: UIButton) {
        
        //Check to see if we have permissions first
        //If we have permissions continue eles do show an alert telling the user what to do
        if (checkPermissions()){
            
            
            //create recorder if one has not ben created
            if recorder == nil {
                recorder = recorderCreator()
                recorder?.isMeteringEnabled = true
                recorder?.delegate = self
            }
            
            //first time user press button should record for 30 seconds to get average decibels of the room
            if shouldRecord {
                
                shouldRecord = false
                
                //start animations
                animateBackGround()
                
                recorder!.record(forDuration: 5)
                
                //timer to trigger get decibel function which will save the decible of the room for 30 seconds
                let tempTimer = Timer.scheduledTimer(timeInterval: 1,
                                     target: self,
                                     selector: #selector(getDecibels),
                                     userInfo: nil, repeats: true)
                aTimer = tempTimer
                aTimer?.fire()
            }
            
            else {
                
                getBackToOriginal()
            }
        }
    }
    
    
    
    func continousRecording () {
        
        shouldContinousRecord = true
        if (recorder != nil){
         
            recorder?.record()
            aTimer = Timer.scheduledTimer(timeInterval: 1,
                                          target: self,
                                          selector: #selector(getContinouseDecibels),
                                          userInfo: nil, repeats: true)
            aTimer?.fire()
            
            
        }
    }
    
    
    
    
    //get the decibels for the room for 30 seconds
    @objc func getContinouseDecibels(){
        print ("Contunous Called")
        
        recorder?.updateMeters()
        if let decibels = recorder?.peakPower(forChannel: 0){
            
            if let average = theAverageDecibleOfTheRoom {
                
                if (decibels < average - 20 || decibels > average + 20){
                    aTimer?.invalidate()
                    recorder?.stop()
                    print("Noise Spike detected! \(decibels) : \(average)")
                }
                
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //get the decibels for the room for 30 seconds
    @objc func getDecibels(){
        print ("Called")
        
        recorder?.updateMeters()
        if let decibels = recorder?.peakPower(forChannel: 0){
            decibleContainer.append(decibels)
            
            DispatchQueue.main.async {
                self.decibelsLabel.text = "Calculating The Average Decibel: \(String(format:"%.2f",decibels))"
            }
        }
        
        //counter to stop timer
        timerCounter += 1
        if (timerCounter == 5){
            aTimer?.invalidate()
            timerCounter = 0
        }
    }
    
    
    //Return the average decibels of the room
    func averageDecibelsOfRoom () ->String {
        
        var temp: Float = 0
        for number in decibleContainer {
            temp += number
        }
        
        temp = temp / Float(decibleContainer.count)
        
        theAverageDecibleOfTheRoom = temp
        print ("Average decibles of the room: \(theAverageDecibleOfTheRoom)")
        
        return String(format: "%.2f", temp)
    }
    
    
    //MARK:: Recorder Functions
    //Check to see if we have permission to record
    //If we dont create an alert
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
    
    //create a recorder to set public recorder
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
                self.decibelsLabel.text = "Average decibels of the room: \(self.averageDecibelsOfRoom())"
                
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
            self.shouldRecord = true
            
            
        } completion: { (_) in
            
            //self.shouldRecord = true
            DispatchQueue.main.async {
                self.decibelsLabel.text = "Decibels:"
            }
            
        }
    }
}


//MARK:: Audio Recorder Delegate
extension DecibelsViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if (flag){
            
            if (shouldContinousRecord == false){
            continueAnimation = false
            endAnimation()
            }
            else {
                print ("Continous Recording stopped! ")
                print ("Is recording reording ? \(recorder.isRecording)")
            }
            
        }
    }
}

