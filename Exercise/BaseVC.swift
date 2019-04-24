//
//  BaseVC.swift
//  Exercise
//
//  Created by Sunil Kumar on 11/03/19.
//  Copyright © 2019 Test. All rights reserved.
//

import UIKit

class BaseVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func showAlert(titleStr: String? = "", messageStr: String? = "") {
        let alert = UIAlertController(title: titleStr, message: messageStr, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
