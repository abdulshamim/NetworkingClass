//
//  NewViewController.swift
//  CallbackDemo
//
//  Created by cl-macmini-23 on 22/09/17.
//  Copyright © 2017 cl-macmini-23. All rights reserved.
//

import UIKit

class NewViewController: UIViewController {


    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.title = "First Controller"
       
    }

    @IBAction func backButtonAction(_ sender: UIButton) {
        //dismiss(animated: true, completion: nil)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
}