//
//  ContactsViewController.swift
//  Serval Chat
//
//  Created by Alexandre Dorys-Charnalet on 03/10/2018.
//  Copyright © 2018 Alexandre Dorys-Charnalet. All rights reserved.
//

import UIKit

class ContactsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var contactTableView: UITableView!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    let route = Route()
    let rhizome = Rhizome()
    let meshMS = MeshMS()
    let keyring = Keyring()
    
    var identity = Identity()
    
    var identities = [Identity]()
    
    var contacts = [Contact]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contactTableView.dataSource = self
        contactTableView.delegate = self
        
        let tabVC = tabBarController as! MenuTabController
        identity = tabVC.identity
        
        updatedSegmentedControl()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            return contacts.count
        case 1:
            return identities.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell")!
        
        var name = ""
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            name = contacts[indexPath.row].name
        case 1:
            if identities[indexPath.row].name != "" {
                name = identities[indexPath.row].name
            } else {
                name = "\(identities[indexPath.row].sid.prefix(13))*"
            }
        default:
            break
        }
        
        cell.textLabel?.text = name
        
        return cell
    }
    
    // Go to the 1-To-1 messaging service when a person is selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            let titleString = contacts[indexPath.row].name
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "OneToOneMessage") as! OneToOneMessagingViewController
            viewController.title = titleString
            viewController.hisIdentity.name = contacts[indexPath.row].name
            viewController.hisIdentity.sid = contacts[indexPath.row].sid
            navigationController?.pushViewController(viewController, animated: true)

            
        case 1:
            let titleString = identities[indexPath.row].name
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "OneToOneMessage") as! OneToOneMessagingViewController
            viewController.title = titleString
            viewController.hisIdentity.name = identities[indexPath.row].name
            viewController.hisIdentity.sid = identities[indexPath.row].sid
            navigationController?.pushViewController(viewController, animated: true)
        default:
            break
        }
        
    }
    
    @IBAction func indexChanged(_ sender: Any) {
        updatedSegmentedControl()
    }
    
    // Update the view when segmented control changes
    // When segmented control = 1 -> "My Contacts" view || 2 -> "All" view
    func updatedSegmentedControl () {
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            meshMS.getConversationList(sid: identity.sid) { (result) in
                self.contacts.removeAll()
                if let conversations = result {
                    for conversation in conversations {
                        self.keyring.getIdentity(sid: conversation.theirSid, completion: { (identity) in
                            let contact = Contact(sid: identity.sid, name: identity.name)
                            if contact.name != "" {
                                self.contacts.append(contact)
                                self.contactTableView.reloadData()
                            }
                        })
                    }
                } else {
                    print("noConv")
                }
                
                self.contactTableView.reloadData()
                
            }
        case 1:
//            rhizome.getManifest(identity: identity.identity) {
//                
//            }
            route.getAll { result in
                self.identities = result
                if let index = self.identities.firstIndex(where: {$0.sid == self.identity.sid}) {
                    self.identities.remove(at: index)
                }
                self.contactTableView.reloadData()
            }
        default:
            break
        }
    }
}
