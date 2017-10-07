//
//  ViewController.swift
//  CallbackDemo
//
//  Created by cl-macmini-23 on 09/09/17.
//  Copyright © 2017 cl-macmini-23. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var result: UILabel!
    let httpReqest = ANetworkingHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getCallBackStatus()
       // self.getFAQ()
        self.navigationController?.title = "First Controller"
    }

    func getCallBackStatus() {
        httpReqest.getResponse(10, callBack: { (_ response: Any?, error: Error?) in
            
            if let result = response as? String {
                print(result)
                DispatchQueue.main.async {
                     self.result.text = result
                }
            }
        })
    }
  
    func getFAQ() {
        ANetworkingHandler(method: .get,
                    path: "http://34.207.220.100:3000/get_faqs",
                    parameters: nil,
                    encoding: .url)
            .handler() { (response: Any?, error: Error?) in
                print(response ?? "")
        }
    }

    @IBAction func serverCall(_ sender: UIButton) {
      
        NetworkingClass(path: "http://34.207.220.100:3000/get_faqs",
                        method: .get)
            .config(activityIndicatorEnable: false)
            .connectServerWithoutImage(delay: 0){(_ response: Any?, error: Error?) in
            print("\(String(describing: response))")
        }
     
    }
    
    @IBAction func newController(_ sender: UIButton) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "NewViewController") as? NewViewController {
            self.navigationController?.modalTransitionStyle = .crossDissolve
            self.navigationController?.modalPresentationStyle = .overCurrentContext
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}








