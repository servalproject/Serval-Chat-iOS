//
//  IdentityViewController.swift
//  Serval Chat
//
//  Created by Alexandre Dorys-Charnalet on 30/08/2018.
//  Copyright © 2018 Alexandre Dorys-Charnalet. All rights reserved.
//

import Foundation
import UIKit

class IdentityViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var identityTableView: UITableView!
    
    var identities = [Identity]()
    
    private let keyring = Keyring()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        identityTableView.dataSource = self
        identityTableView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadData()
    }
    
    func reloadData() {
        keyring.getAllIdentities() { result in
            self.identities = result
            self.identityTableView.reloadData()
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return identities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "identityCell")!
        
        let name = "\(identities[indexPath.row].name) (\(identities[indexPath.row].sid.prefix(13))*)"
        
        cell.textLabel?.text = name
        
        return cell
    }
    
    // SWIPE LEFT ON CELL TO REMOVE IDENTITY
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Deleted")
            let sid = identities[indexPath.row].sid
            keyring.deleteIdentity(sid: sid) { () in
                self.reloadData()
            }
        }
    }
    
    // LOGIN WHEN IDENTITY IS SELECTED
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        identityTableView.deselectRow(at: indexPath, animated: true)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBarMenu = storyboard.instantiateViewController(withIdentifier: "TabBarMenu") as! UITabBarController
        let nav = tabBarMenu.viewControllers?[0] as! UINavigationController
        let vc = nav.topViewController as! FeedViewController
        vc.identity = identities[indexPath.row]
        navigationController?.present(tabBarMenu, animated: true)
        
    }
    
    // ADD IDENTITY
    @IBAction func addIdentityButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New identity", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Input your name here..."
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            if let identityName = alert.textFields?.first?.text {
                self.keyring.createIdentity(name: identityName) { () in
                    self.reloadData()
                }
            }
        }))
        self.present(alert, animated: true)
    }
}
