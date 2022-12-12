//
//  RegisterViewController.swift
//  MoBall
//
//  Created by Yixiao Li on 2022/11/15.
//
//  Name: Yixiao Li
//  Email: likather@usc.edu

import UIKit
import FirebaseFirestore
import FirebaseAuth

class RegisterViewController: UIViewController, UITextFieldDelegate {
    override func viewDidLoad() {
        // disable done button is nothing is entered
        doneButton.isEnabled = false
        
        passwordField.resignFirstResponder()
        emailField.resignFirstResponder()
        nameField.resignFirstResponder()
        
        // resign keyboard when background is tapped
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.backgroundDidTapped(_:)))
        singleTap.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(singleTap)
    }
    
    // hide keyboard from the view by resigning the first responder
    @objc func backgroundDidTapped(_ tap: UITapGestureRecognizer) {
        passwordField.resignFirstResponder()
        emailField.resignFirstResponder()
        nameField.resignFirstResponder()
    }
    
    @IBOutlet weak var passwordField: UITextField!
    // check if the password is filled out to enable the register button
    @IBAction func passwordFieldDidTapped(_ sender: Any) {
        checkField()
    }
    
    
    @IBOutlet weak var emailField: UITextField!
    // check if the password is filled out to enable the register button
    @IBAction func emailFieldDidTapped(_ sender: Any) {
        checkField()
    }
    
    @IBOutlet weak var nameField: UITextField!
    // check if the password is filled out to enable the register button
    @IBAction func nameFieldDidTapped(_ sender: Any) {
        checkField()
    }
    
    func checkField() {
        // check and enable done button if all fields are entered
        if passwordField.text! != "" && nameField.text! != "" && emailField.text! != "" {
            doneButton.isEnabled = true
        }
        else {
            doneButton.isEnabled = false
        }
    }

    
    @IBAction func cancelButtonDidTapped(_ sender: Any) {
        // resign the keyboard when the cancel button is tapped
        passwordField.resignFirstResponder()
        emailField.resignFirstResponder()
        nameField.resignFirstResponder()
        
        // clear the fields
        nameField.text = ""
        emailField.text = ""
        passwordField.text = ""
        
        // dismiss the page
        dismiss(animated: true)
    }
    
    // when editing ended, resign the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        passwordField.resignFirstResponder()
        emailField.resignFirstResponder()
        nameField.resignFirstResponder()
        return true
    }
    
    
    
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBAction func doneButtonDidTapped(_ sender: Any) {
        let email = emailField.text!
        let password = passwordField.text!
        let name = nameField.text!
        // SDK -> Software development kit
        // Interacting with an API using the native language of the platform
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { (result, error) in
                // If there are no errors, show the authenticated page
                if error == nil{
                    // document user name and email by user id
                    Firestore.firestore().collection("users").document(result!.user.uid).setData(["email": email, "name": name, "onCourt": false])
                    let user = Auth.auth().currentUser
                       if let user = user {
                        let changeRequest = user.createProfileChangeRequest()
                          changeRequest.displayName = name
                        changeRequest.commitChanges { error in
                            if error != nil {
                              // An error happened.
                            } else {
                              // Profile updated.
                            }
                          }
                        }
                    
                    // generate the chat channels
                    self.addChanneltoPeople(userUID: result!.user.uid, username: name)
                    
                    self.passwordField.text = ""
                    self.emailField.text = ""
                    self.nameField.text = ""
                    self.dismiss(animated: true)
                }
                else {
                    let alert = UIAlertController(title: "Warning!", message: "Registration Failed. Please enter a valid email address and a password with length greater than 6.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated:true)
                    self.passwordField.text = ""
                    self.emailField.text = ""
                    self.nameField.text = ""
                    return
                }
            })
    }
    
    
    // for retreiving the user and user id pairs from firebase
    func generateNewChatListDB(onSuccess: @escaping ([(String, String)]) -> Void) {
        Firestore.firestore().collection("users").getDocuments { documentSnapshot, error in
            if let error = error {
                print("error:\(error.localizedDescription)")
            } else {
                var nameUIDPair:[(String, String)] = []
                for document in documentSnapshot!.documents {
                    if(document.get("name") as? String != UserDefaults.standard.string(forKey: "name")){
                        nameUIDPair.append((document.get("name") as! String, document.documentID))
                    }
                }
                onSuccess(nameUIDPair)
            }
        }
    }
    
    // for retreving the channelid, users, and useruid pairs from firebase;
    // this association will be used for chat functionality
    static var nameIDPair:[(String, String, String)] = []
    func addChanneltoPeople(userUID: String, username: String) {
        var ref: DocumentReference? = nil
        self.generateNewChatListDB {nameUIDPair in
            // var nameIDPair:[(String, String, String)] = []
            for pair in nameUIDPair {
                ref = Firestore.firestore().collection("channels").addDocument(data: [
                    "history": [""]
                ]) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        print("Document added with ID: \(ref!.documentID)")
                        Firestore.firestore().collection("users").document(userUID).collection("channels").document(pair.0).setData(["channelID": ref!.documentID])
                        Firestore.firestore().collection("users").document(pair.1).collection("channels").document(username).setData(["channelID": ref!.documentID])
                    }
                }
            }
        }
    }
}
