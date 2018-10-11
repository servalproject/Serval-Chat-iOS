//
//  MeshMS.swift
//  Serval Chat
//
//  Created by Alexandre Dorys-Charnalet on 08/10/2018.
//  Copyright © 2018 Alexandre Dorys-Charnalet. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class MeshMS {
    
    private let user = "steve"
    private let password = "jobs"
    
    private let serverAddress = "http://127.0.0.1:4110"
    
    private var headers: HTTPHeaders = [:]
    
    func sendMessage(senderSID: String, recipientSID: String, message: String, completion: @escaping(String) -> Void) {
        let url = serverAddress + "/restful/meshms/\(senderSID)/\(recipientSID)/sendmessage"
        
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
    
    func getConversationList(sid: String, completion: @escaping ([Conversation]?) -> Void) {
        
        let url = serverAddress + "/restful/meshms/\(sid)/conversationlist.json"
        
        if let authorizationHeader = Request.authorizationHeader(user: user, password: password) {
            headers[authorizationHeader.key] = authorizationHeader.value
        }
        
        Alamofire.request(url, method: .get, headers: headers)
            .responseJSON { responseData in
                let json = JSON(responseData.result.value!)
                
                let rows = json["rows"].arrayValue
                
                if rows.count == 0 {
                    completion(nil)
                } else {
                    var conversations = [Conversation]()
                    for element in rows {
                        let id = element[0].stringValue
                        let mySid = element[1].stringValue
                        let theirSid = element[2].stringValue
                        conversations.append(Conversation(id: id, mySid: mySid, theirSid: theirSid))
                    }
                    completion(conversations)
                }
        }
    }
    
    func getMessageList(mySid: String, hisSid: String, completion: @escaping ([Message]) -> Void) {
        
        let url = serverAddress + "/restful/meshms/\(mySid)/\(hisSid)/messagelist.json"
        
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
                    if element[6].stringValue != "" {
                        message.messageBody = element[6].stringValue
                        if element[0].stringValue == ">" {
                            message.sender = element[1].stringValue
                        } else if element[0].stringValue == "<" {
                            message.sender = element[2].stringValue
                        }
                        let unixTimestamp = element[9].doubleValue
                        let date = Date(timeIntervalSince1970: unixTimestamp)
                        let dateFormatter = DateFormatter()
                        dateFormatter.locale = NSLocale.current
                        dateFormatter.dateFormat = "HH:mm - dd-MM-yyyy " //Specify your format that you want
                        message.date = dateFormatter.string(from: date)
                        
                        messages.append(message)
                    }
                }
                completion(messages)
        }
    }
}
