//
//  NewViewController.swift
//  CallbackDemo
//
//  Created by cl-macmini-23 on 22/09/17.
//  Copyright © 2017 cl-macmini-23. All rights reserved.
//

import UIKit

class NewViewController: UIViewController {

    @IBOutlet weak var newLabel: UILabel!
    
    func setLabelTilte() {
        self.newLabel.text = "Shamim Khan"
        self.newFeature()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.title = "First Controller"
       setLabelTilte()
    }

    @IBAction func backButtonAction(_ sender: UIButton) {
        
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func newFeature() {
        print("Hey it is working")
    }
}
