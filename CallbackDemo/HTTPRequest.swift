//
//  Networking class
//  CallbackDemo
//
//  Created by Abdul on 09/09/17.
//  Copyright © 2017 Abdul. All rights reserved.
//

import Foundation
import Alamofire


enum CallBackError: Error {
    case working
    case notWorking
}

enum EncodingType {
    case json
    case url
    case propertyType
    
    func value() -> ParameterEncoding {
        switch self {
        case .json:
            return JSONEncoding.default
        case .url:
            return URLEncoding.default
        case .propertyType:
            return PropertyListEncoding.default
        }
    }
}

public typealias HTTPRequestHandler = (_ response: Any?, Error?) -> Void
public typealias HTTPTimelineHandler = (_ timeline: Timeline) -> Void

class ANetworkingHandler {
    
    public typealias HTTPEncodingCompletionHandler = (_ request: ANetworkingHandler) -> Void
    
    private var urlString: String?
    private var methodType: Alamofire.HTTPMethod
    private var parameters: Parameters?
    private var encoding: ParameterEncoding?
    private var headers = [String: String]()
    private var isIndicatorEnable = true
    private var isAlertEnable = true
    
    private(set) var timeline: Timeline?
    private var dataRequest: DataRequest?
 
    //CallBack
    private var completeCallBack: HTTPRequestHandler?
    private var timelineCallBack: HTTPTimelineHandler?
    private var encodingCompletion: HTTPEncodingCompletionHandler?
    
    func getResponse(_ second: Double, callBack: @escaping HTTPRequestHandler) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + second){
            callBack("Its working fine", CallBackError.working)
        }
    }
    
    init() {
        self.methodType = .get
        self.encoding = URLEncoding.default
        self.urlString = ""
    }
    
    @discardableResult
    convenience init(method: HTTPMethod = .get,
                     fullURLStr: String,
                     parameters: Parameters? = nil,
                     encoding: EncodingType = .url) {
        self.init()
        self.methodType = method
        self.urlString = fullURLStr
        self.parameters = parameters
        self.encoding = encoding.value()
    }
    
    
    convenience init(method: HTTPMethod = .get,
                     path: String,
                     parameters: Parameters? = nil,
                     encoding: EncodingType = .url) {
        self.init(method: method,
                  fullURLStr: path,
                  parameters: parameters,
                  encoding: encoding)
    }
    
    
    /// Handle server request withou Image
    ///
    /// - Parameter completion: completion handler return once server responded
    func handler(completion: @escaping HTTPRequestHandler) {
        self.completeCallBack = completion
        self.startRequest()
    }
    
    
    func multipartHandler(completion: @escaping HTTPRequestHandler) {
        self.completeCallBack = completion
    }
    
    /// Make dataRequest
    private func makeDataRequest() {
        guard let urlString = self.urlString else {
            fatalError("HTTPRequest:- URL string is not exist")
        }
        
        let dataRequest = Alamofire.request(urlString,
                                            method: methodType,
                                            parameters: parameters,
                                            encoding: encoding!,
                                            headers: nil)
        self.dataRequest = dataRequest
    }
    
    /// Start reuqesting to server
    private func startRequest() {
        self.makeDataRequest()
        
        if let dataRequest = self.dataRequest {
            
            dataRequest.responseJSON(completionHandler: { (response: DataResponse<Any>) in
                
                self.timeline = response.timeline
                if let timeLine = self.timeline {
                    if let timelineCallBack = self.timelineCallBack {
                        timelineCallBack(timeLine)
                    }
                }
                
                switch response.result {
                case .success(_):
                    self.requestSucceededWith(response: response)
                case .failure(let error):
                    self.requestFailedWith(error: error)
                }
                
            })
            
        }
    }
    
    /// Upload images on server using multipart
    private func upload() {
        guard let urlString = self.urlString else {
            fatalError("HTTPRequest:- URL string is not exist")
        }
        
        Alamofire.upload(multipartFormData: { [weak self] multipartFormData in
            
            if let parameters = self?.parameters {
                for (key, value) in parameters {
                    if value is [String: Any] || value is [Any] {
                        
                        do {
                            let data = try JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
                            print(data)
                            
                            if let jsonString: NSString = NSString(data: data, encoding: String.Encoding.utf8.rawValue),
                                let data = jsonString.data(using: String.Encoding.utf8.rawValue) {
                                multipartFormData.append(data, withName: key)
                            }
                            
                        } catch {
                            print ("Error in parsing" )
                        }
                        
                    } else {
                        if let data = "\(value)".data(using: String.Encoding.utf8) {
                            multipartFormData.append(data, withName: key)
                        }
                    }
                }
            }
            
        },
                         to: urlString,
                         headers: nil,
                         encodingCompletion: { encodingResult in
                            
                            if let encodingCompletion = self.encodingCompletion {
                                encodingCompletion(self)
                            }
                            
                            switch encodingResult {
                            case .success(let upload, _, _):
                                
                                self.dataRequest = upload
                                
                                upload.responseJSON { response in
                                    self.requestSucceededWith(response: response)
                                }
                                
                            case .failure(let error):
                                self.requestFailedWith(error: error)
                            }
        })
    }
    
    
     /// Request Success
    private func requestSucceededWith(response: DataResponse<Any>) {
        let responseObject = response.result.value
        let resultDict = responseObject as? [String: Any]
        self.completeCallBack?(resultDict, nil)
    }
    
     /// Request Failure
    private func requestFailedWith(error: Error) {
        self.completeCallBack?(nil, error)
    }
    
    
}
