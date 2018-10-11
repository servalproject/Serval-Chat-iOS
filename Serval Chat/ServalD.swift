//
//  ServalD.swift
//  Serval Chat
//
//  Created by Alexandre Dorys-Charnalet on 30/08/2018.
//  Copyright © 2018 Alexandre Dorys-Charnalet. All rights reserved.
//

import serval_dna.daemon
import serval_dna.lib
import serval_dna.sodium
import serval_dna.sqlite

import Foundation

class ServalD {
    
    var contextFile = CliContextFile(FileHandle.standardOutput)

    private let serverThread = DispatchQueue(label: "Serval DNA daemon processing queue", attributes: .concurrent)
    
    func startServer() {
        // Start the server in a background thread
        serverThread.async { [weak self] in
            serval_commandline_main(context: (self?.contextFile)!, args: ["servald","start","foreground"])
            //TODO : ADD error handling
        }
    }
    
    func stopServer() {
        serverThread.async { [weak self] in
            serval_commandline_main(context: (self?.contextFile)!, args: ["servald","stop"])
            //TODO : ADD error handling
        }
    }
}
