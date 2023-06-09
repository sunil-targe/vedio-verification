//
//  BWFLivenessCaptureVC.swift
//  BWF
//
//  Created by Sunil Targe on 2023/6/8.
//  Copyright © 2023 Bang With Friends, Inc. All rights reserved.
//
import UIKit


class BWFLivenessCaptureVC: UIViewController {
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var faceStatusLabel: UILabel!
    @IBOutlet weak var faceFrameImgView: UIImageView!
    var imageHandler : ((UIImage) -> Void)?
    
    var faceDetectorFilter: FaceDetectorFilter!
    lazy var faceDetector: FaceDetector = {
        var detector = FaceDetector()
        self.faceDetectorFilter = FaceDetectorFilter(faceDetector: detector, delegate: self)
        detector.delegate = self.faceDetectorFilter
        return detector
    }()
    
    lazy var blinkCountLabel: UILabel = {
        var label = UILabel()
        label.text = "0"
        label.font = UIFont.systemFont(ofSize: 38)
        label.textColor = .cyan
        label.textAlignment = .center
        label.numberOfLines = 0
        label.frame = CGRect(x: view.frame.width/2 - 100, y: view.frame.height/2 - 50, width: 200, height: 100)
        label.alpha = 0.0
        label.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        return label
    }()
    
    internal func spaceString(_ string: String) -> String {
        return string.uppercased().map({ c in "\(c) " }).joined()
    }
    
    var blinkingNumber: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        faceDetector.beginFaceDetection()
        let cameraView = faceDetector.cameraView
        view.addSubview(cameraView)
        view.addSubview(blinkCountLabel)
        view.bringSubviewToFront(indicatorView)
    }
    
    
}


extension BWFLivenessCaptureVC: FaceDetectorFilterDelegate {
    
    //MARK: FaceDetectorFilter Delegate
    func faceDetected() {
        DispatchQueue.main.async {
            self.faceStatusLabel.text = "Keep face center"
        }
        
    }
    
    func faceUnDetected() {
        DispatchQueue.main.async {
            self.faceStatusLabel.text = "No face detected"
        }
    }
    
    func cancel() {
        //
    }
    
    func faceEyePosition(left: CGPoint, right: CGPoint) {
        if let leftPos = self.faceDetector.leftEyePosition, let rightPos = self.faceDetector.rightEyePosition {
//                debugPrint("leftPos: \(leftPos)")
//                debugPrint("rightPos: \(rightPos)")
            let eyesDistance = leftPos.distance(to: rightPos)
            
            let leftEyeIsInFrame = isPointWithinViewSize(point: leftPos, subview: faceFrameImgView)
            let rightEyeIsInFrame = isPointWithinViewSize(point: rightPos, subview: faceFrameImgView)
            
            if leftEyeIsInFrame, rightEyeIsInFrame {
//                debugPrint("Image is in the center")
            }

        }
        
    }
    
    private func isPointWithinViewSize(point: CGPoint, subview: UIView) -> Bool {
        let convertedPoint = subview.convert(point, from: subview.superview)
        let subviewBounds = CGRect(origin: CGPoint(x: subview.bounds.midX - subview.frame.width / 2, y: subview.bounds.midY - subview.frame.height / 2),
                                   size: subview.frame.size)
        return subviewBounds.contains(convertedPoint)
    }


    
    //MARK: Eye distance should be CGFloat(70.0)
    //MARK: if bliking is true then this method will trigger and you will receive an image here
    // Here
    func blinking(image: UIImage?) {
        blinkingNumber += 1
        showBlinkNumber(blinkingNumber)
        
        debugPrint("Eye blinking: \(blinkingNumber) times")
        if blinkingNumber > 3 {
            faceStatusLabel.text = "Don't move"
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self.faceDetector.endFaceDetection()
                if let handler = self.imageHandler, let image {
                    handler(image)
                    self.navigationController?.popViewController(animated: true)
                }
            })
            
        }
    }
    
    func showBlinkNumber(_ count: Int){
        UIView.animate(withDuration: 0.8, animations: {
            self.blinkCountLabel.text = "Binks: \(count)"
            self.blinkCountLabel.alpha = 1.0
            self.blinkCountLabel.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }, completion: {(_) in
            UIView.animate(withDuration: 1.0, animations: {
                self.blinkCountLabel.alpha = 0.0
                self.blinkCountLabel.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            }, completion: {(_) in
                self.blinkCountLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            })
        })
    }
}
