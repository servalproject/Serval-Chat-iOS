//
//  OneToOneMessagingViewController.swift
//  Serval Chat
//
//  Created by Alexandre Dorys-Charnalet on 03/10/2018.
//  Copyright © 2018 Alexandre Dorys-Charnalet. All rights reserved.
//

import UIKit
import Avatar

class OneToOneMessagingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    var myIdentity = Identity()
    var hisIdentity = Contact()
    
    let meshMS = MeshMS()
    
    var timer = Timer()
    
    var hisAvatar = UIImage()
    
    var messageArray = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabVC = tabBarController as! MenuTabController
        myIdentity = tabVC.identity
        
        
        messageTableView.delegate = self
        messageTableView.dataSource = self
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil) , forCellReuseIdentifier: "customMessageCell")
        messageTextField.delegate = self
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector (tableViewTapped))
        
        messageTableView.addGestureRecognizer(tapGesture)
        
        messageTableView.separatorStyle = .none
        
        configureTableView()
        generateHisAvatar()

        getMessage()
        getMessagesPeriodically()
      
        messageTableView.reloadData()
        
        let infoButton = UIButton(type: .infoLight)
        infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: infoButton)
        self.navigationItem.rightBarButtonItem = barButton
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timer.invalidate()
    }
    
    @objc func infoButtonTapped() {
        // TODO
    }
    
    @objc func tableViewTapped() {
        messageTextField.endEditing(true)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        cell.date.text = messageArray[indexPath.row].date
        
        if cell.senderUsername.text == "\(hisIdentity.sid.prefix(13))*" {
            cell.messageBackground.backgroundColor = UIColor(red:0.24, green:0.39, blue:0.51, alpha:1.0)
            cell.rightCellConstraint.constant = 40
            cell.leftCellConstraint.constant = 10
            cell.senderAvatar.image = hisAvatar
        } else {
            cell.messageBackground.backgroundColor = UIColor(red:0.00, green:0.57, blue:0.58, alpha:1.0)
            cell.leftCellConstraint.constant = 40
            cell.rightCellConstraint.constant = 10
            cell.senderAvatar.image = UIImage(named: "yellowFootedHead")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    func configureTableView() {
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 100.0
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 260
            self.view.layoutIfNeeded()
        }
        if messageArray.count > 0 {
            let indexPath = IndexPath(item: messageArray.count - 1, section: 0)
            messageTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
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
        
        if let message = messageTextField.text {
            meshMS.sendMessage(senderSID: myIdentity.sid, recipientSID: hisIdentity.sid, message: message) { (response) in
                if response == "201" {
                        self.getMessage()
                } else {
                    print("error: \(response)")
                }
                
                self.messageTextField.isEnabled = true
                self.sendButton.isEnabled = true
                self.messageTextField.text = ""
            }
        }
    }
    
    @objc func getMessage() {
        meshMS.getMessageList(mySid: myIdentity.sid, hisSid: hisIdentity.sid) { (messages) in
            for message in messages {
                if message.sender == self.myIdentity.sid {
                    message.sender = "\(self.myIdentity.sid.prefix(13))*" // REPLACE WITH NAME
                } else if message.sender == self.hisIdentity.sid {
                    message.sender = "\(self.hisIdentity.sid.prefix(13))*" // REPLACE WITH NAME
                }
            }
            if self.messageArray.count != messages.count {
                self.messageArray = messages.reversed()
                self.messageTableView.reloadData()
                if self.messageArray.count > 0 {
                    let indexPath = IndexPath(item: self.messageArray.count - 1, section: 0)
                    self.messageTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            }
        }
    }
    
    func getMessagesPeriodically(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.getMessage), userInfo: nil, repeats: true)
    }
    
    func generateHisAvatar() {
        let frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        if let avatar = Avatar.generate(for: frame.size, scale: 5) {
            hisAvatar = avatar
        }
    }
}
