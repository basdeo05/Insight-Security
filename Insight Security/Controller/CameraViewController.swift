//
//  CameraViewController.swift
//  Insight Security
//
//  Created by Richard Basdeo on 3/18/21.
//

import UIKit
import Photos
import AVFoundation

class CameraViewController: UIViewController {

    let appBrain = AppBrain()
    override func viewDidLoad() {
        super.viewDidLoad()

        //1.
        //I need to see if I have permissons to the camera and access to the photo library
        checkCameraAuthorization()
    }
    
    func setupCaptureSession (){
        
        //setting up session to back camera
        let captureSession = AVCaptureSession()
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
        let photoOutput = AVCapturePhotoOutput()
        guard captureSession.canAddOutput(photoOutput) else {return}
        
        captureSession.sessionPreset = .photo
        captureSession.addOutput(photoOutput)
        captureSession.commitConfiguration()
        captureSession.startRunning()
        
        class PreviewClass: UIView {
            override class var layerClass: AnyClass {
                return AVCaptureVideoPreviewLayer.self
            }
            
            var videoPreviewLayer: AVCaptureVideoPreviewLayer {
                return layer as! AVCaptureVideoPreviewLayer
            }
            
            
        }
        
        DispatchQueue.main.async {
            let previewView = PreviewClass()
            previewView.videoPreviewLayer.session = captureSession
            self.view.addSubview(previewView)
            previewView.frame = self.view.layer.frame
        }
        
        
        
        
        //captureSession.startRunning()
        
        let settings = AVCapturePhotoSettings()
                  let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
                  let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                                       kCVPixelBufferWidthKey as String: 160,
                                       kCVPixelBufferHeightKey as String: 160]
        settings.previewPhotoFormat = previewFormat
        
        
        
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            photoOutput.capturePhoto(with: settings, delegate: self)
        }
        
        
        
    }
    
    
    
    
    //MARK:: Get Permissons
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
    


}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print ("Preparing to capture photo")
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print ("Photo was taken !")
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        print ("Done taking photo going to process")
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        if let e = error {
            print ("There was an error \(e)")
        }
        else {
            
            PHPhotoLibrary.requestAuthorization { status in
                    guard status == .authorized else { return }
                    
                    PHPhotoLibrary.shared().performChanges({
                        // Add the captured photo's file data as the main resource for the Photos asset.
                        let creationRequest = PHAssetCreationRequest.forAsset()
                        creationRequest.addResource(with: .photo, data: photo.fileDataRepresentation()!, options: nil)
                })
                
                
                
                
                
            }
            
            self.appBrain.updloadImage(photo: photo)
        }
    }
    
}
