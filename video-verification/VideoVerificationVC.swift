//
//  VideoVerificationVC.swift
//  video-verification
//
//  Created by Sunil Targe on 2023/5/31.
//

import UIKit
import AVFoundation
import Vision

class VideoVerificationVC: UIViewController {
    @IBOutlet weak var faceDetectedLabel: UILabel!
    
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var headStatusLabel: UILabel!
    @IBOutlet weak var eyeBlinkStatusLabel: UILabel!
    
    var verifiedHeadMovement: Bool = false
    var verifiedEyeBlinking: Bool = false
    
    var headMovementArray: [Bool] = []
    var eyeBlinkingArray: [Bool] = []
    
    var previousObservation: VNFaceObservation? = nil
    var previousLeftEyeAspectRatio: Float = 0.0
    var previousRightEyeAspectRatio: Float = 0.0
    
    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
        setupVideoPreview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startVideoCapture()
    }
        
    private func checkResult(_ array: [Bool]) -> Bool {
        var trueCount = 0
        var falseCount = 0
        
        for element in array {
            if element {
                trueCount += 1
            } else {
                falseCount += 1
            }
            
            if trueCount > 10 && falseCount > 10 {
                return true
            }
        }
        
        return trueCount == 0 || falseCount == 0
    }
    
    func updateUI(_ faceDetected: Bool = false) {
        view.bringSubviewToFront(statusView)
        faceDetectedLabel.text = faceDetected ? "Face detected" : "Face not in the frame"
        faceDetectedLabel.textColor = faceDetected ? .green : .red
        
        if !faceDetected {
            verifiedHeadMovement = false
            verifiedEyeBlinking = false
            headMovementArray.removeAll()
            eyeBlinkingArray.removeAll()
        }
    }
    
    func gotoVerificationWithDown() {
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StatusVC") as? StatusVC {
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension VideoVerificationVC {
    func analyzeFaceLandmarks(_ observation: VNFaceObservation) {
        guard let leftEye = observation.landmarks?.leftEye,
              let rightEye = observation.landmarks?.rightEye else {
            return
        }
        

        
        let leftEyeAspectRatio = calculateEyeAspectRatio(leftEye)
        let rightEyeAspectRatio = calculateEyeAspectRatio(rightEye, isLeft: false)
        
        // Detect blinking eyes
        let isBlinking = isEyeBlinking(leftEyeAspectRatio, rightEyeAspectRatio)
        eyeBlinkingArray.append(isBlinking)
        
        // Detect facial movement
        let hasFacialMovement = hasMovement(observation)
        headMovementArray.append(hasFacialMovement)
        
        // Update UI or perform actions based on blinking and facial movement detection results
        print("Blinking: \(isBlinking), Facial Movement: \(hasFacialMovement)")
        print("Blinking array: \(eyeBlinkingArray), Facial Movement array: \(headMovementArray)")
        
//        if isBlinking, hasFacialMovement {
//            DispatchQueue.main.async { [weak self] in
//                self?.captureSession.stopRunning()
//                self?.gotoVerificationWithDown()
//            }
//        }
        
        if !verifiedHeadMovement, checkResult(headMovementArray) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                guard let self = self else { return }
                verifiedHeadMovement = true
                if !verifiedEyeBlinking, checkResult(eyeBlinkingArray) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.verifiedEyeBlinking = true
                    }
                }
            }
        }

    }
    
    private func calculateEyeAspectRatio(_ eye: VNFaceLandmarkRegion2D, isLeft: Bool = true) -> Float {
        let eyePoints = eye.normalizedPoints
        
        guard eyePoints.count == 6 else {
            return 0.0
        }
        
        let leftmostPoint = eyePoints[isLeft ? 0 : 3]
        let rightmostPoint = eyePoints[isLeft ? 3 : 0]
        let topPoint = eyePoints[1]
        let bottomPoint = eyePoints[5]
        
        let width = rightmostPoint.x - leftmostPoint.x
        let height = bottomPoint.y - topPoint.y
        let aspectRatio = width / height
        
        return Float(aspectRatio)
    }

    
    private func isEyeBlinking(_ leftEyeAspectRatio: Float, _ rightEyeAspectRatio: Float) -> Bool {
//        let eyeAspectRatioThreshold: Float = 0.05 // Adjust this threshold based on your needs
//        let isLeftBlinking = leftEyeAspectRatio < eyeAspectRatioThreshold
//        let isRightBlinking = rightEyeAspectRatio < eyeAspectRatioThreshold
//        let isBlinking = isLeftBlinking && isRightBlinking
//
//        debugPrint("leftEyeAspectRatio:\(leftEyeAspectRatio)")
//        debugPrint("rightEyeAspectRatio:\(rightEyeAspectRatio)")
//        return isBlinking
        
        let blinkThreshold: Float = 0.2
        let isLeftBlinking = abs(leftEyeAspectRatio - previousLeftEyeAspectRatio) > blinkThreshold
        let isRightBlinking = abs(rightEyeAspectRatio - previousRightEyeAspectRatio) > blinkThreshold
        
        // Update the previous aspect ratios
        previousLeftEyeAspectRatio = leftEyeAspectRatio
        previousRightEyeAspectRatio = rightEyeAspectRatio
        
        let isBlinking = isLeftBlinking && isRightBlinking
        return isBlinking
    }

    
    
    private func hasMovement(_ observation: VNFaceObservation) -> Bool {
        let facialMovementThreshold: CGFloat = 0.05
                
        // Capture a new observation and compare it with the old one
        // Check for significant changes in facial landmark positions
        
        // Example:
        let newLeftEyePoints = observation.landmarks?.leftEye?.normalizedPoints ?? []
        let oldLeftEyePoints = previousObservation?.landmarks?.leftEye?.normalizedPoints ?? []
                
        for i in 0..<newLeftEyePoints.count {
            if oldLeftEyePoints.count > i {
                let pointChange = abs(newLeftEyePoints[i].x - oldLeftEyePoints[i].x) + abs(newLeftEyePoints[i].y - oldLeftEyePoints[i].y)
                if pointChange > facialMovementThreshold {
                    return true
                }
            }
        }
        
        previousObservation = observation // Store the previous observation
        
        return false
    }
}
