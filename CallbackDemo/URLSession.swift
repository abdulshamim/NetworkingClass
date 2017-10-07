//
//  URLSession.swift
//  CallbackDemo
//
//  Created by cl-macmini-23 on 09/09/17.
//  Copyright © 2017 cl-macmini-23. All rights reserved.
//

import Foundation
import Alamofire

public typealias Completion = (_ result: Any?, _ error: Error?) -> Void

class NetworkingClass {

    //static let share = NetworkingClass()
    
    private var urlString: String?
    private var method: HTTPMethod? = .get
    private var headers = [String: String]()
    private var urlRequest: URLRequest?
    private var session = URLSession()
    private let config = URLSessionConfiguration.default
    
    private var isNetworkActivityIndicatorEnable: Bool = false

    private var completeCallBack: Completion?



    init(path: String, method: HTTPMethod) {
        self.urlString = path
        self.method = method
        
        guard let urlString = URL(string: path) else {
            return
        }
        
        self.session = URLSession(configuration: config)
        
        do {
            urlRequest = try URLRequest(url: urlString,
                                        method: method,
                                        headers: nil)
        } catch {
             print("Some error occurred")
        }
    }
    
    @discardableResult
    func config(activityIndicatorEnable: Bool) -> NetworkingClass {
        DispatchQueue.main.async {
            self.isNetworkActivityIndicatorEnable = activityIndicatorEnable
        }
        return self
    }
    
    @discardableResult
    func headers(headers: [String: String]) -> NetworkingClass {
        self.headers = headers
        return self
    }
    
    // MARK :-  Make server call without Images
    func connectServerWithoutImage(delay: Double, completion: @escaping Completion) {
       self.completeCallBack = completion

       if delay == 0.0 {
           self.startRequest()
       } else {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
            self.startRequest()
        })
       }
    }
    
    // MARK :-  Make server call with Images
    func connectServerWithImages(delay: Double, completion: @escaping Completion) {
        self.completeCallBack = completion
        
        if delay == 0.0 {
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
            })
        }
    }

    
    
    // MARK :- Start server requesting
    func startRequest() {
        guard let urlRequest = urlRequest else {
            self.completeCallBack?(nil, nil)
            return
        }
       
        UIApplication.shared.isNetworkActivityIndicatorVisible = self.isNetworkActivityIndicatorEnable
        let task = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            self.requestSucceededWith(response: data, error: error)
        })
        task.resume()
    }
    
    // MARK :- Response handling
    private func requestSucceededWith(response: Data?, error: Error?) {
        guard let responseData = response else {
            print("Error: did not receive data")
            self.completeCallBack?(nil, nil)
            return
        }
        do {
            guard let result = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
                print("error trying to convert data to JSON")
                self.completeCallBack?(nil, error)
                return
            }
            self.completeCallBack?(result, error)
        } catch {
            print("Some error occurred")
            self.completeCallBack?(nil, nil)
        }
    }
}
