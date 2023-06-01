//
//  StatusVC.swift
//  video-verification
//
//  Created by Sunil Targe on 2023/6/1.
//

import UIKit

class StatusVC: UIViewController {
    @IBOutlet weak var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.statusLabel.text = "Verified successfully"
            self?.statusLabel.textColor = .green
        }
    }

}
