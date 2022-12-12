//
//  ProfileViewController.swift
//  MoBall
//
//  Created by Yixiao Li on 2022/11/16.
//
//  Name: Yixiao Li
//  Email: likather@usc.edu

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    // set the name and the email label
    override func viewDidLoad() {
        nameLabel.text! += UserDefaults.standard.string(forKey: "name") ?? ""
        emailLabel.text! += UserDefaults.standard.string(forKey: "email") ?? ""
    }
    
    @IBAction func logoutDidTapped(_ sender: Any) {
        
        // jump to the register page
        // diabled the authentication
        UserDefaults.standard.removeObject(forKey: "uid")
        UserDefaults.standard.removeObject(forKey: "name")
        UserDefaults.standard.removeObject(forKey: "email")
        
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
          
    }
}
