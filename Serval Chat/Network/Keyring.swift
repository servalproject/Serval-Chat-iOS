//
//  Keyring.swift
//  Serval Chat
//
//  Created by Alexandre Dorys-Charnalet on 30/08/2018.
//  Copyright © 2018 Alexandre Dorys-Charnalet. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class Keyring {
    
    private let user = "steve"
    private let password = "jobs"
    
    private let serverAddress = "http://127.0.0.1:4110"
    
    private var headers: HTTPHeaders = [:]
    
    func getAllIdentities(completion: @escaping ([Identity]) -> Void) {
        
        var identities = [Identity]()

        let url = serverAddress + "/restful/keyring/identities.json"
        
        if let authorizationHeader = Request.authorizationHeader(user: user, password: password) {
            headers[authorizationHeader.key] = authorizationHeader.value
        }
        
        Alamofire.request(url, method: .get, headers: headers)
            .responseJSON { responseData in
                if((responseData.result.value) != nil) {
                    let json = JSON(responseData.result.value!)
                    
                    let rows = json["rows"].arrayValue
                    
                    for element in rows {
                        let sid = element[0].stringValue
                        let identity = element[1].stringValue
                        let did = element[2].stringValue
                        let name = element[3].stringValue
                        
                        identities.append(Identity(sid: sid, identity: identity, did: did, name: name))
                        
                    }
                    print(identities)
                    completion(identities)
                }
        }
    }
    
    func getIdentity(sid: String, completion: @escaping (Identity) -> Void) {
        
        let url = serverAddress + "/restful/keyring/\(sid)"
        
        if let authorizationHeader = Request.authorizationHeader(user: user, password: password) {
            headers[authorizationHeader.key] = authorizationHeader.value
        }
        
        Alamofire.request(url, method: .get, headers: headers)
            .responseJSON { responseData in
                print(responseData)
                if((responseData.result.value) != nil) {
                    let json = JSON(responseData.result.value!)
                    
                    var identity = Identity()
                    
                    let identityJson = json["identity"]
                    identity.name = identityJson["name"].stringValue
                    identity.sid = identityJson["sid"].stringValue
                
                    completion(identity)
                }
        }
    }
    
    func createIdentity(name: String, completion: @escaping() -> Void) {
        let url = serverAddress + "/restful/keyring/add?name=\(name)"
        
        if let authorizationHeader = Request.authorizationHeader(user: user, password: password) {
            headers[authorizationHeader.key] = authorizationHeader.value
        }
        
        Alamofire.request(url, method: .post, headers: headers)
            .responseJSON { response in
                print(response)
                completion()
        }
    }
    
    func deleteIdentity(sid: String, completion: @escaping() -> Void) {
        let url = serverAddress + "/restful/keyring/" + sid
        
        if let authorizationHeader = Request.authorizationHeader(user: user, password: password) {
            headers[authorizationHeader.key] = authorizationHeader.value
        }
        
        Alamofire.request(url, method: .delete, headers: headers)
            .responseJSON { response in
                print(response)
                completion()
        }
    }
}
