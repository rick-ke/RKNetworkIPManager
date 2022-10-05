//
//  ViewController.swift
//  RKNetworkIPManager
//
//  Created by Rick on 2022/10/5.
//

import UIKit

class ViewController: UIViewController {
    
    private lazy var ipLabel: UILabel = {
        let label = UILabel()
        label.frame.origin = CGPoint(x: 100, y: 100)
        label.frame.size = CGSize(width: 100, height: 100)
        label.text = "0.0.0.0"
        label.textColor = .red
        view.addSubview(label)
        return label
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        getIP()
    }
    
    func getIP() {
        let ipAdress = RKNetworkIPManager.shared.loadAdressIP()
        ipLabel.text = ipAdress
    }
}

