//
//  NetworkEngineResponse.swift
//  lingvo-swift-client
//
//  Created by Daniel on 06.01.16.
//  Copyright © 2016 MicroMovie Media GmbH. All rights reserved.
//
import Foundation

class NetworkEngineResponse {
	
	var errorCode: Int? = nil
	var errorMessage: String? = nil
	
	var responseData: Any? = nil
	var downloadUrl: URL? = nil
	
	var hasError: Bool {
		get {
			return (self.errorCode != nil)
		}
	}
	
	static func errorResponse(_ code: Int?, message: String?) -> NetworkEngineResponse {
		let response = NetworkEngineResponse()
		
		if code != nil {
			response.errorCode = code
		}
        
        if message != nil {
            response.errorMessage = message
        }
		
		return response
	}
    
    static func errorResponse(_ code: Int?) -> NetworkEngineResponse {
        let response = NetworkEngineResponse()
        
        if code != nil {
            response.errorCode = code
        }
        
        response.errorMessage = NetworkEngineResponse.message(forCode: code)
        
        return response
    }
	
	static func defaultErrorResponse(_ message: String?) -> NetworkEngineResponse {
		return NetworkEngineResponse.errorResponse(-999, message: message)
	}
	
	static func defaultResponse(_ data: Any?) -> NetworkEngineResponse {
		let response = NetworkEngineResponse()
		
		response.responseData = data
		
		return response
	}
	
	static func defaultDownloadResponse(_ url: URL, decompressAndDecode: Bool) -> NetworkEngineResponse {
		let response = NetworkEngineResponse()
		response.downloadUrl = url
		
//		if decompressAndDecode {
//			response.decompressAndDecode()
//		}
		
		return response
	}
    
    static func message(forCode code : Int?)-> String {
        if let code = code {
            debugPrint(code)
            switch code {
            case 2001, 2004:
                return "error_invalid_input".localize()
            case 2002:
                return "error_invalid_email".localize()
            case 2003:
                return "error_code_limit_reached".localize()
            default:
                return "error_unknown_error".localize()
            }
        }
        return "error_unknown_error".localize()
    }
			
//	func decompressAndDecode() {
//		if !self.hasError && self.downloadUrl != nil {
//			
//			let tmpUrl = self.downloadUrl!
//			
//			let compressedData = try? Data(contentsOf: tmpUrl)
//			
//			do {
//				let packageData = try compressedData?.gunzipped()
//				self.responseData = JSON(data: packageData!) //try NSJSONSerialization.JSONObjectWithData(packageData!, options: [])
//			} catch {
//				print("Error decompressing or parsing package")
//			}
//			
//			
//		}
//	}

}
