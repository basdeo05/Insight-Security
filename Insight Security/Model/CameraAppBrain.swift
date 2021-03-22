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

class CameraAppBrain {
    
    var delegate: cameraProtcol?
    let captureSession = AVCaptureSession()
    let settings = AVCapturePhotoSettings()
    let photoOutput = AVCapturePhotoOutput()
    
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

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    let storage = Storage.storage()
    
    func updloadImage (photo: AVCapturePhoto) {
        
        let storageReference = storage.reference()
        
        let imagesRef = storageReference.child("securityTriggers")
        
        let fileName = "\(NSTimeIntervalSince1970).jpg"
        
        let spaceRef = imagesRef.child(fileName)
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        var temp: UIImage?
        // Try getting preview photo
          if let previewPixelBuffer = photo.previewPixelBuffer {
            var previewCiImage = CIImage(cvPixelBuffer: previewPixelBuffer)
            // If we managed to get the oreintation, update the image
            if let previewCgImage = CIContext().createCGImage(previewCiImage, from: previewCiImage.extent) {
              temp = UIImage(cgImage: previewCgImage)
            }
          }
        
        guard let temp2 = temp?.pngData() else {return}

        
        
        // Upload data and metadata
        imagesRef.putData(temp2, metadata: nil)

        // Upload file and metadata
        //imagesRef.putFile(from: temp2, metadata: metadata)
        
    }
}
