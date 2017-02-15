//
//  NetworkEngine.swift
//  HDProduktion
//
//  Created by Daniel on 06.01.16.
//  Copyright © 2016 MicroMovie Media GmbH. All rights reserved.
//

import Foundation

enum NetworkEngineRequestMethod : String {
	case Get = "GET"
	case Post = "POST"
}


class NetworkEngine {

//	static let baseURL = URL(string: "http://192.168.10.120:8100/filmtech/api/")
    static let baseURL = URL(string: "http://lvps92-51-162-50.dedicated.hosteurope.de/api/")
//	static let imageBaseURL = URL(string: "http://192.168.10.120:8100/filmtech/img/article_images/")
    static let imageBaseURL = URL(string: "http://lvps92-51-162-50.dedicated.hosteurope.de/img/article_images/")
	
	func jsonRequest(_ endpoint: String, method: NetworkEngineRequestMethod, bodyParams: AnyObject?, baseURL : URL) -> URLRequest {
		
		
		var request = URLRequest(url: (baseURL.appendingPathComponent(endpoint)))
		
		request.httpMethod = method.rawValue
		
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(NSLocale.current.languageCode ?? "en", forHTTPHeaderField: "Accept-Language")
		
		if bodyParams != nil {
			request.httpBody = try! JSONSerialization.data(withJSONObject: bodyParams!, options: []);
		}
		
		return request
	}
	
	func jsonTask(_ endpoint: String, method: NetworkEngineRequestMethod, bodyParams: AnyObject?, baseURL: URL = NetworkEngine.baseURL!, finishedCallback: @escaping (NetworkEngineResponse) -> Void) -> URLSessionDataTask {
		let request = self.jsonRequest(endpoint, method: method, bodyParams: bodyParams, baseURL: baseURL)
        let session = URLSession.shared
		
		let task = session.dataTask(with: request) { (data, response, error) in
            guard data != nil else {
                
                print("no data found: \(error)")
                finishedCallback(NetworkEngineResponse.errorResponse(error?._code, message: error?.localizedDescription))
                return
            }
            
            // this, on the other hand, can quite easily fail if there's a server error, so you definitely
            // want to wrap this in `do`-`try`-`catch`:
            //let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
            //print(jsonStr)
            
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                    
                    if let metadataDict = json["_metadata"] as? NSDictionary {
                        
                        if let status = metadataDict["status"] as? String {
                            if status == "OK" {
                                //success
                                finishedCallback(NetworkEngineResponse.defaultResponse(try JSONSerialization.jsonObject(with: data!, options: []))) //we're using swifty json from here
                            } else {
                                //handle error
                                
                                let errorCode = metadataDict["error_code"] as? Int
//                                let errorMessage = metadataDict["error_message"] as? String
//                                debugPrint(errorMessage ?? "")
                                
                                finishedCallback(NetworkEngineResponse.errorResponse(errorCode))
                            }
                        } else {
                            print("no status")
                            finishedCallback(NetworkEngineResponse.defaultErrorResponse("no status: \(error)"))
                        }
                        
                    } else {
                        print("no metadata")
                        finishedCallback(NetworkEngineResponse.defaultErrorResponse("no metadata: \(error)"))
                    }
                    
                } else {
                    let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)    // No error thrown, but not NSDictionary
                    print("Error could not parse JSON: \(jsonStr)")
                    finishedCallback(NetworkEngineResponse.defaultErrorResponse("Error could not parse JSON: \(jsonStr)"))
                }
            } catch let parseError {
                print(parseError)                                                          // Log the error thrown by `JSONObjectWithData`
                let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                print("Error could not parse JSON: '\(jsonStr)'")
                finishedCallback(NetworkEngineResponse.defaultErrorResponse("Error could not parse JSON: \(jsonStr)"))
            }
        }
        
		return task
	}
	
	func jsonGetTask(_ endpoint: String, finishedCallback: @escaping (NetworkEngineResponse) -> Void) -> URLSessionDataTask {
		return self.jsonTask(endpoint, method: .Get, bodyParams: nil, finishedCallback: finishedCallback)
	}
	
	func jsonPostTask(_ endpoint: String, bodyParams: AnyObject?, finishedCallback: @escaping (NetworkEngineResponse) -> Void) -> URLSessionDataTask {
		return self.jsonTask(endpoint, method: .Post, bodyParams: bodyParams, finishedCallback: finishedCallback)
	}
	
	func downloadTask(_ endpoint: String,  autoDecode: Bool, baseURL: URL = NetworkEngine.baseURL!, finishedCallback: @escaping (NetworkEngineResponse) -> Void) -> URLSessionDownloadTask {
		let session = URLSession.shared
		
		return session.downloadTask(with: baseURL.appendingPathComponent(endpoint), completionHandler: { (tmpUrl, response, error) -> Void in
			
			guard error == nil else {
				finishedCallback(NetworkEngineResponse.errorResponse(error?._code, message: error?.localizedDescription))
				return
			}
			
			if tmpUrl != nil {
				finishedCallback(NetworkEngineResponse.defaultDownloadResponse(tmpUrl!, decompressAndDecode: autoDecode))
			} else {
				finishedCallback(NetworkEngineResponse.defaultErrorResponse("no tmp url"))
			}
		}) 
	}
	
	
}
