//
//  Rhizome.swift
//  Serval Chat
//
//  Created by Alexandre Dorys-Charnalet on 15/11/2018.
//  Copyright © 2018 Alexandre Dorys-Charnalet. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class Rhizome {
    
    private let user = "steve"
    private let password = "jobs"
    
    private let serverAddress = "http://127.0.0.1:4110"
    
    private var headers: HTTPHeaders = [:]
    
    func getManifest(identity: String, completion: @escaping () -> Void) {
        
        
        let url = serverAddress + "/restful/rhizome/\(identity).rhm"
        
        if let authorizationHeader = Request.authorizationHeader(user: user, password: password) {
            headers[authorizationHeader.key] = authorizationHeader.value
        }
        
        Alamofire.request(url, method: .get, headers: headers)
            .response { (data) in
                print(data)
        }
    }
}

