//
//  VideoVerificationVC+Helper.swift
//  video-verification
//
//  Created by Sunil Targe on 2023/6/1.
//

import UIKit
import AVFoundation
import Vision

extension VideoVerificationVC: AVCaptureVideoDataOutputSampleBufferDelegate {
    func setupCaptureSession() {
        captureSession = AVCaptureSession()
        
        guard let captureDevice = AVCaptureDevice.default(.builtInTrueDepthCamera, for: .video, position: .front) else {
            print("Failed to get the front camera device")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
            
            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: .userInteractive))
            captureSession.addOutput(videoOutput)
        } catch {
            print("Failed to initialize AVCaptureDeviceInput: \(error)")
        }
    }
    
    
    func setupVideoPreview() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.frame = view.bounds
        
        view.layer.addSublayer(videoPreviewLayer)
    }
    
    func startVideoCapture() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    func processVideoFrame(_ sampleBuffer: CMSampleBuffer) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let faceDetectionRequest = VNDetectFaceLandmarksRequest { [weak self] request, error in
            guard let observations = request.results as? [VNFaceObservation] else {
                return
            }
            
            for observation in observations {
                self?.analyzeFaceLandmarks(observation)
                // Analyze face landmarks and apply verification criteria
                // Determine if the detected face belongs to a real human
            }
            DispatchQueue.main.async {
                self?.updateUI(observations.count > 0)
            }
        }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        do {
            try imageRequestHandler.perform([faceDetectionRequest])
        } catch {
            print("Failed to perform face detection: \(error)")
        }
    }
    
    // AVCaptureVideoDataOutputSampleBufferDelegate method
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        processVideoFrame(sampleBuffer)
    }
}
