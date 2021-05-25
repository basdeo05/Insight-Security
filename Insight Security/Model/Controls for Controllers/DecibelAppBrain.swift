//
//  DecibelAppBrain.swift
//  Insight Security
//
//  Created by Richard Basdeo on 3/18/21.
//

import Foundation
import AVFoundation

protocol decibelProtocol {
    func animateBackground()
    func animateCircle()

    func endAnimation()
    func getBackToOriginal()
    func updateLabel()
    func showAlert()
}

class DecibelAppBrain {
    
    var delegate: decibelProtocol?
    
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
    
    
    
    func continousRecording () {
        
        shouldContinousRecord = true
        if (recorder != nil){
         
            recorder?.record()
            aTimer = Timer.scheduledTimer(timeInterval: 1,
                                          target: self,
                                          selector: #selector(getContinouseDecibels),
                                          userInfo: nil,
                                          repeats: true)
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
            
            delegate?.updateLabel()
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
        print ("Average decibles of the room: \(String(describing: theAverageDecibleOfTheRoom))")
        
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
                    
                    permissionGranted = false
                    self.delegate?.showAlert()
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
}
