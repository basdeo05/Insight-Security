//
//  AppBrain.swift
//  Insight Security
//
//  Created by Richard Basdeo on 3/18/21.
//

import Foundation
import Firebase
import Photos

protocol cameraProtcol {
    func setupCameraPreview()
    func takePicture()
}

struct notificationTriggerUpdate {
    var theURL: [String]
    var theDate: [String]
    var timeSince: [Double]
}

class CameraAppBrain {
    
    var delegate: cameraProtcol?
    let captureSession = AVCaptureSession()
    let settings = AVCapturePhotoSettings()
    let photoOutput = AVCapturePhotoOutput()
    let storage = Storage.storage()
    let db = Firestore.firestore()
    
    
    func checkCameraAuthorization () {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            //setup Capture session
        checkPhotoLibraryPermission()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                if (granted){
                    self.checkPhotoLibraryPermission()
                }
            }
        case .denied:
            //print alert to tell user that they declined access to camera
            print ("Denied")
            return
            
        case .restricted:
            //Tell user that they cant grant permission
            print("User can't change permission")
            return
        }
    }
    
    
    func checkPhotoLibraryPermission() {
        
        PHPhotoLibrary.requestAuthorization { (status) in
            
            if status == .notDetermined {
                PHPhotoLibrary.requestAuthorization { (userStatus) in
                    
                    if (userStatus == .authorized){
                        self.setupCaptureSession()
                    }
                }
            }
            else if (status == .authorized){
                self.setupCaptureSession()
            }
        }
    }
    
    func setupCaptureSession (){
        
        //setting up session to back camera
        captureSession.beginConfiguration()
        
        let videoDevice = AVCaptureDevice.default(.builtInDualWideCamera,
                                                  for: .video,
                                                  position: .back)
        
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!),
              captureSession.canAddInput(videoDeviceInput)
        
        else {return}
        
        captureSession.addInput(videoDeviceInput)
        
        
        //Part 2
        //creating output for photo
        photoOutput.isHighResolutionCaptureEnabled = true
        guard captureSession.canAddOutput(photoOutput) else {return}
        
        captureSession.sessionPreset = .photo
        captureSession.addOutput(photoOutput)
        captureSession.commitConfiguration()
        captureSession.startRunning()
        
        
        
        delegate?.setupCameraPreview()
        
        
        
        
        
        //captureSession.startRunning()
        
        
                  let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
                  let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                                       kCVPixelBufferWidthKey as String: 160,
                                       kCVPixelBufferHeightKey as String: 160]
        settings.previewPhotoFormat = previewFormat
        
        
        delegate?.takePicture()
        
    }

    
    

    
    func updloadImage (photo: AVCapturePhoto) {
        
        let storageReference = storage.reference()
        
        let imagesRef = storageReference.child("securityTriggers")
        
        let fileName = "\(String(Timestamp.init().seconds)).jpg"
        
        let spaceRef = imagesRef.child(fileName)
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        guard let photoData = photo.fileDataRepresentation() else {
                return
            }
            guard let photoImage = UIImage(data: photoData) else {return}
        
        guard let temp2 = photoImage.pngData() else {return}
        
        

        
        // Upload the file to the path "images/rivers.jpg"
        let uploadTask = spaceRef.putData(temp2, metadata: nil) { (metadata, error) in
          guard let metadata = metadata else {
            print ("Error uploading file")
            return
          }
          
            
          spaceRef.downloadURL { (url, error) in
            guard let downloadURL = url else {return}
            
            
            
            if let email = Auth.auth().currentUser?.email{
                
                let doesDocumentExists = self.db.collection("securityEvents").document(email)
                
                doesDocumentExists.getDocument { (returnDocument, error) in
                    
                    if let document = returnDocument {
                        
                        if document.exists {
                            self.updateDatabase(newPictureURL: downloadURL, userEmail: email)
                        }
                        else {
                            self.createNewDataBasePost(newPictureURL: downloadURL, userEmail: email)
                        }
                    }
                }
            }
            
          }
            
        }
    }
    
    func updateDatabase(newPictureURL: URL, userEmail: String){
        
        let documentReference = db.collection("securityEvents").document(userEmail)
        
        
        
        documentReference.getDocument { (snapshot, error) in
            
            if let e = error {
                print (e)
            }
            else {
                
                if let snap = snapshot {
                    var urlHolder = snap["urls"] as! [String]
                    urlHolder.append(newPictureURL.absoluteString)
                    
                    var dateStringHolder = snap["dates"] as! [String]
                    dateStringHolder.append(self.getCurrentDateAndTime())
                    
                    var creationHolder = snap["creation"] as! [Double]
                    creationHolder.append(Date().timeIntervalSince1970)
                    
                    let newObject = notificationTriggerUpdate(theURL: urlHolder, theDate: dateStringHolder, timeSince: creationHolder)
                    
                    
                    documentReference.updateData(["urls" : newObject.theURL,
                                                  "dates": newObject.theDate,
                                                  "creation": newObject.timeSince]) { (error) in
                        
                        if let e = error {
                            print (e)
                        }
                    }
                }
            }
        }
    }
    
    
    func createNewDataBasePost (newPictureURL: URL, userEmail: String ){
        
        let temp = [newPictureURL.absoluteString]
        var newObject = notificationTriggerUpdate(theURL: [], theDate: [], timeSince: [])
        
        newObject.theURL.append(contentsOf: temp)
        newObject.theDate.append(getCurrentDateAndTime())
        newObject.timeSince.append(Date().timeIntervalSince1970)
        
        db.collection("securityEvents").document(userEmail).setData(["urls" : newObject.theURL,
                                                                     "dates": newObject.theDate,
                                                                     "creation": newObject.timeSince]) { (error) in
            
            if let e = error {
                print ("There was an error creating database entry for first time entry: \(e.localizedDescription)")
            }
            else{
                print ("Able to create new entry")
            }
        }
    }
    
    func getCurrentDateAndTime () -> String {
        
        let currentDateTime = Date()
        
        let formatter = DateFormatter()
        
        formatter.timeStyle = .medium
        formatter.dateStyle = .long
        
        let dateTimeString = formatter.string(from: currentDateTime)
        
        return dateTimeString
    }
}
