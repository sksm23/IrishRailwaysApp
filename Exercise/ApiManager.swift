//
//  ApiManager.swift
//  Exercise
//
//  Created by Sunil Kumar on 09/03/19.
//  Copyright © 2019 Test. All rights reserved.
//

import Foundation
import Alamofire
import SWXMLHash

struct ApiManager {
    
    private static let expirytime: TimeInterval = 30
    static let manager = Alamofire.SessionManager.default
    static let baseUrl = "http://api.irishrail.ie/realtime/realtime.asmx/"
    
    static func request(_ url: String,
                        params: Parameters?,
                        method: HTTPMethod,
                        headers: HTTPHeaders,
                        successClosure: @escaping (XMLIndexer?) -> Void,
                        failureClosure: @escaping (Error?) -> Void) {
        let finalUrl = baseUrl + url
        manager.session.configuration.timeoutIntervalForRequest = expirytime
        Alamofire.request(finalUrl,
                          method: method,
                          parameters: params,
                          encoding: PropertyListEncoding.default,
                          headers: headers).responseData { responseObject -> Void in
                            switch responseObject.result {
                            case .success(let xmlData):
                                debugPrint(xmlData)
                                if let xmlString = responseObject.result.value {
                                   // print("XMLString: \(xmlString)")
                                    let xml = SWXMLHash.parse(xmlString)
                                    print("XML: \(xml)")
                                    successClosure(xml)
                                }
                            case .failure(let error):
                                failureClosure(error)
                            }
        }
    }
}

/*
extension ApiManager: RequestRetrier {
    
    public func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: RequestRetryCompletion) {
        if let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 {
            completion(true, 10.0) // retry after 10 second
        } else {
            completion(false, 0.0) // don't retry
        }
    }
}*/
