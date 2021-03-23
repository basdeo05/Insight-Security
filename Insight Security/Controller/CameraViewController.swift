//
//  CameraViewController.swift
//  Insight Security
//
//  Created by Richard Basdeo on 3/18/21.
//

import UIKit
import Photos
import AVFoundation

class CameraViewController: UIViewController{

    let appBrain = CameraAppBrain()
    var captureDelegate = AVCapturePhotoCaptureDelegate?.self
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appBrain.delegate = self

        //1.
        //I need to see if I have permissons to the camera and access to the photo library
        appBrain.checkCameraAuthorization()
    }
    
}

extension CameraViewController: cameraProtcol {
    func setupCameraPreview() {
        
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
            previewView.videoPreviewLayer.session = self.appBrain.captureSession
            self.view.addSubview(previewView)
            previewView.frame = self.view.layer.frame
        }
    }
    
    func takePicture() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.appBrain.photoOutput.capturePhoto(with: self.appBrain.settings, delegate: self)
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
