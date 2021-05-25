//
//  AppBrain.swift
//  Insight Security
//
//  Created by Richard Basdeo on 3/18/21.
//

import Foundation
import Firebase
import Photos
import FirebaseFirestore

protocol cameraProtcol {
    func setupCameraPreview()
    func takePicture()
    func pictureUploadedToDatabase()
    func error(message: String)
}


class CameraAppBrain {
    
    var delegate: cameraProtcol?
    let captureSession = AVCaptureSession()
    let settings = AVCapturePhotoSettings()
    let photoOutput = AVCapturePhotoOutput()
    let storage = Storage.storage()
    let db = Firestore.firestore()
    let firebase = FirebaseHelper()
    
    
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
        
        firebase.delegate = self
        delegate?.takePicture()
        
    }
    
    
    func uploadImage(photo: AVCapturePhoto) {
        firebase.uploadImage(photo: photo)
    }
}




extension CameraAppBrain: FirebaseProtocols {
    func securityObjectsReturned(returnedData: [SecurityImageObject]) {
        
    }
    
    func pictureUploaded() {
        print("Image Uploaded")
        delegate?.pictureUploadedToDatabase()
    }
    
    func error(aError: Error) {
        print(aError.localizedDescription)
        delegate?.error(message: "Something went wrong")
    }
    
}
