//
//  Route.swift
//  Serval Chat
//
//  Created by Alexandre Dorys-Charnalet on 08/10/2018.
//  Copyright © 2018 Alexandre Dorys-Charnalet. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class Route {
    
    private let user = "steve"
    private let password = "jobs"
    
    private let serverAddress = "http://127.0.0.1:4110"
    
    private var headers: HTTPHeaders = [:]
    
    func getAll(completion: @escaping ([Identity]) -> Void) {
        
        var identities = [Identity]()
        
        let url = serverAddress + "/restful/route/all.json"
        
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
                        let did = element[1].stringValue
                        let name = element[2].stringValue
                        
                        identities.append(Identity(sid: sid, identity: "", did: did, name: name))
                        
                    }
                    print(identities)
                    completion(identities)
                }
                
        }
    }
}
