//
//  ViewController.swift
//  video-verification
//
//  Created by Sunil Targe on 2023/5/31.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func startVerification(sender: Any) {
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VideoVerificationVC") as? VideoVerificationVC {
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

