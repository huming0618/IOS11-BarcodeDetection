//
//  ViewController.swift
//  Vision.Barcode.Detection
//
//  Created by peter on 2017/9/30.
//  Copyright © 2017年 Peter. All rights reserved.
//
// Refer to https://github.com/hansemannn/iOS11-QR-Code-Example

import UIKit
import AVFoundation
import Vision

class ViewController: UIViewController {

    @IBOutlet weak var captureView:UIImageView!;
    var session = AVCaptureSession()
    var requests = [VNRequest]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startLiveVideo()
        startBarcodeDetection()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func startLiveVideo(){
        //1
        session.sessionPreset = AVCaptureSession.Preset.photo
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        //2
        let deviceInput = try! AVCaptureDeviceInput(device: captureDevice!)
        let deviceOutput = AVCaptureVideoDataOutput()
        deviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        deviceOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default))
        session.addInput(deviceInput)
        session.addOutput(deviceOutput)
        
        //3
        let imageLayer = AVCaptureVideoPreviewLayer(session: session)
        imageLayer.frame = captureView.bounds
        captureView.layer.addSublayer(imageLayer)
        
        session.startRunning()
    }
    
    
    
    func startBarcodeDetection() {
        let barcodeRequest = VNDetectBarcodesRequest(completionHandler: self.detectBarcodeHandler)
        
        //textRequest.reportCharacterBoxes = true
        
        self.requests = [barcodeRequest]
    }
    
    func detectBarcodeHandler(request: VNRequest, error: Error?){
        guard let observations = request.results else {
            print("no result")
            return
        }
 
        for result in observations {
            if let barcodeResult = result as? VNBarcodeObservation{
                print("Detect")
                if let payload = barcodeResult.payloadStringValue {
                    print("Payload: \(payload)")
                }
            }
            
        }
 
        DispatchQueue.main.async() {
//            self.imageView.layer.sublayers?.removeSubrange(1...)
//            for region in result {
//                guard let rg = region else {
//                    continue
//                }
//
//                self.highlightWord(box: rg)
//
//                if let boxes = region?.characterBoxes {
//                    for characterBox in boxes {
//                        self.highlightLetters(box: characterBox)
//                    }
//                }
//            }
        }
    }
}


extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        var requestOptions:[VNImageOption : Any] = [:]
        
        if let camData = CMGetAttachment(sampleBuffer, kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, nil) {
            requestOptions = [.cameraIntrinsics:camData]
        }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: CGImagePropertyOrientation.right, options: requestOptions)
        
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }
}


