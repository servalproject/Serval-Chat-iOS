//
//  MeshMB.swift
//  Serval Chat
//
//  Created by Alexandre Dorys-Charnalet on 17/09/2018.
//  Copyright © 2018 Alexandre Dorys-Charnalet. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class MeshMB {
    
    private let user = "steve"
    private let password = "jobs"
    
    private let serverAddress = "http://127.0.0.1:4110"
    
    private var headers: HTTPHeaders = [:]
    
    // SERVICE NOT WORKING
    func sendMessage(id: String, message: String, completion: @escaping(String) -> Void) {
        let url = serverAddress + "/restful/meshmb/\(id)/sendmessage"
        
        if let authorizationHeader = Request.authorizationHeader(user: user, password: password) {
            headers[authorizationHeader.key] = authorizationHeader.value
        }
        
        let someString = message
        let data = Data(someString.utf8)
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(data, withName: "message", mimeType: "text/plain; charset=utf-8")
        },
            to: url,
            method: .post,
            headers: headers,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        print(response)
                        let json = JSON(response.result.value!)
                        let errorCode = json["http_status_code"].stringValue
                        completion(errorCode)
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
        })
    }
    
    func getMessageList(identity: String, completion: @escaping ([Message]) -> Void) {
        
        let url = serverAddress + "/restful/meshmb/\(identity)/messagelist.json"
        
        if let authorizationHeader = Request.authorizationHeader(user: user, password: password) {
            headers[authorizationHeader.key] = authorizationHeader.value
        }
        
        Alamofire.request(url, method: .get, headers: headers)
            .responseJSON { responseData in
                print(responseData)
                let json = JSON(responseData.result.value!)
                
                let rows = json["rows"].arrayValue
                
                var messages = [Message]()
                
                for element in rows {
                    var message = Message()
                    message.messageBody = element[2].stringValue
                    message.sender = json["name"].stringValue
                    messages.append(message)
                }
                completion(messages)
        }
    }
}
