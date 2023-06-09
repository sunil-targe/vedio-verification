//
//  ViewController.swift
//  video-verification
//
//  Created by Sunil Targe on 2023/5/31.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var livenessImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func startVerification(sender: Any) {
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BWFLivenessCaptureVC") as? BWFLivenessCaptureVC {
            controller.imageHandler  = { [weak self] image in
                self?.livenessImageView.image = image
            }
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

