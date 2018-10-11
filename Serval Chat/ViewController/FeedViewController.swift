//
//  FeedViewController.swift
//  Serval Chat
//
//  Created by Alexandre Dorys-Charnalet on 03/09/2018.
//  Copyright © 2018 Alexandre Dorys-Charnalet. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var identity: Identity? = nil
    
    let meshMB = MeshMB()
    
    var messageArray : [Message] = [Message]()
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var messageTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTableView.delegate = self
        messageTableView.dataSource = self
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil) , forCellReuseIdentifier: "customMessageCell")
        messageTextField.delegate = self
        
        let tabVC = self.tabBarController as! MenuTabController
        if let identity = identity {
            tabVC.identity = identity
        }
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector (tableViewTapped))
        
        messageTableView.addGestureRecognizer(tapGesture)
        
        messageTableView.separatorStyle = .none
        
        
        configureTableView()
        
        getMessage()
        
    }

    @objc func tableViewTapped() {
        messageTextField.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        cell.messageBackground.backgroundColor = .white
        cell.messageBody.textColor = .black
        cell.senderAvatar.layer.borderWidth = 1
        cell.senderAvatar.layer.borderColor = UIColor(red:0/255, green:145/255, blue:147/255, alpha: 1).cgColor
        
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        cell.senderAvatar.image = UIImage(named: "yellowFootedHead")
                
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    func configureTableView() {
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage()
        return true
    }
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        sendMessage()
    }
    
    func sendMessage() {
        messageTextField.endEditing(true)
        messageTextField.isEnabled = false
        sendButton.isEnabled = false
        
        if let messageText = messageTextField.text, let name = identity?.name, let id = identity?.identity {
            let message = Message()
            message.messageBody = messageText
            message.sender = name
            meshMB.sendMessage(id: id, message: messageText) { (response) in
                self.messageTableView.setContentOffset(.zero, animated: true)
                let indexPath = IndexPath(item: 0, section: 0)
                self.messageTableView.scrollToRow(at: indexPath, at: .top, animated: true)
                self.getMessage()
            }
            
            
        }
        self.messageTextField.isEnabled = true
        self.sendButton.isEnabled = true
        self.messageTextField.text = ""
    }
    
    func getMessage() {
        
        meshMB.getMessageList(identity: (identity?.identity)!) { (messages) in
            for message in messages {
                if message.sender == self.identity!.name {
                    //
                } else {
                    message.sender = "Other person" // REPLACE WITH NAME
                }
            }
            self.messageArray = messages
            self.messageTableView.reloadData()
        }
    }
}
