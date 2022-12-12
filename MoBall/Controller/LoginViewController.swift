//
//  LoginViewController.swift
//  MoBall
//
//  Created by Yixiao Li on 2022/11/15.
//
//  Name: Yixiao Li
//  Email: likather@usc.edu

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    let clientID = "985954996990-g0srdvnojtj5e2cgu9n9aqt44m5enr0b.apps.googleusercontent.com"
    let signInConfig = GIDConfiguration(clientID: "985954996990-g0srdvnojtj5e2cgu9n9aqt44m5enr0b.apps.googleusercontent.com")
    
    override func viewDidLoad() {
        
        // resign keyboard when loading the
        passwordField.resignFirstResponder()
        emailField.resignFirstResponder()
        
        // resign keyboard when background is tapped
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.backgroundDidTapped(_:)))
        singleTap.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(singleTap)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        let user = Auth.auth().currentUser
        // if user is already logged-in, keep it login
        if (user != nil) && (UserDefaults.standard.string(forKey: "uid") != nil) {
            //self.performSegue(withIdentifier: "LoginSuccess", sender: nil)
            //self.modalPresentationStyle = .fullScreen
        }
    }
    
    // hide keyboard from the view by resigning the first responder
    @objc func backgroundDidTapped(_ tap: UITapGestureRecognizer) {
        // for resigning the keyboard when background is tapped
        passwordField.resignFirstResponder()
        emailField.resignFirstResponder()
    }
    
    var allUsers = [String]()
    
    @IBAction func LoginButtonDidTapped(_ sender: UIButton) {
        
        passwordField.resignFirstResponder()
        emailField.resignFirstResponder()
        
        // alert if one of the field is empty
        if emailField.text! == "" || passwordField.text! == "" {
            let alert = UIAlertController(title: "Warning!", message: "Email or Password Field(s) is Empty!", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated:true)
            passwordField.text = ""
            emailField.text = ""
            return
        }
        
        let email = emailField.text!
        let password = passwordField.text!
        
        // authenticate email password signin
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if error == nil {
                let user = Auth.auth().currentUser
                // store user information to local
                if let user = user {
                    UserDefaults.standard.setValue(user.uid, forKey: "uid")
                    UserDefaults.standard.setValue(user.email, forKey: "email")
                    UserDefaults.standard.setValue(user.displayName, forKey: "name")
                }
                // set the uid to the default value
                let uid = UserDefaults.standard.string(forKey: "uid")
                Firestore.firestore().collection("users").document(uid!).collection("basketballQueue").getDocuments { (documentSnapshot, error) in
                    if error != nil {
                        
                    } else {
                        // if the document is not empty, add queue field
                        if(documentSnapshot!.documents.count == 0) {
                            Firestore.firestore().collection("users").document(uid!).collection("basketballQueue").document("1").setData(["joined": false])
                            Firestore.firestore().collection("users").document(uid!).collection("basketballQueue").document("2").setData(["joined": false])
                            Firestore.firestore().collection("users").document(uid!).collection("basketballQueue").document("3").setData(["joined": false])
                            Firestore.firestore().collection("users").document(uid!).collection("basketballQueue").document("4").setData(["joined": false])
                            Firestore.firestore().collection("users").document(uid!).collection("basketballQueue").document("5").setData(["joined": false])
                        }
                    }
                }
                self.performSegue(withIdentifier: "LoginSuccess", sender: nil)
                self.modalPresentationStyle = .fullScreen
                
            }
            else {
                // alert error if login failed
                let alert = UIAlertController(title: "Warning!", message: "Email or Password Incorrect!", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated:true)
                self.passwordField.text = ""
                self.emailField.text = ""
                return
            }
        }
    }
    
    // resign keyboard if register button is tapped, and transfer user through the segue
    @IBAction func RegisterButtonDidTapped(_ sender: UIButton) {
        passwordField.resignFirstResponder()
        emailField.resignFirstResponder()
    
    }
    
    @IBOutlet weak var passwordField: UITextField!
    @IBAction func passwordFieldDidTapped(_ sender: Any) {
        
    }
    
    @IBOutlet weak var emailField: UITextField!
    @IBAction func emailFieldDidTapped(_ sender: Any) {
        
    }
    
    // set the textfields as delegte
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        passwordField.resignFirstResponder()
        emailField.resignFirstResponder()
        return true
    }
    
    // let config = GIDConfiguration(clientID: clientID)
  
    
    @IBAction func googleSigninDidTapped(_ sender: Any) {
        // authenticate firebase with google signin
        
        // if sign-in successful
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        // guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { user, error in

            if error != nil {
                let alert = UIAlertController(title: "Warning!", message: "Google Login Unsuccessful!", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated:true)
                return
            }

          guard
            let authentication = user?.authentication,
            let idToken = authentication.idToken
          else {
            return
          }

          let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: authentication.accessToken)
            // authenticate credential with firebase
            Auth.auth().signIn(with: credential) { authResult, error in
                if error != nil {
                    // alert if login failed
                    let alert = UIAlertController(title: "Warning!", message: "Email or Password Incorrect!", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated:true)
                    self.passwordField.text = ""
                    self.emailField.text = ""
                    return
                }
                else {
                    
                    let user = Auth.auth().currentUser
                    // store user information
                    if let user = user {
                        UserDefaults.standard.setValue(user.uid, forKey: "uid")
                        UserDefaults.standard.setValue(user.email, forKey: "email")
                        UserDefaults.standard.setValue(user.displayName, forKey: "name")
                    }
                    
                    Firestore.firestore().collection("users").document(user!.uid).getDocument{ (document, error) in
                        if let document = document {
                            if document.exists {
                                self.performSegue(withIdentifier: "LoginSuccess", sender: nil)
                                self.modalPresentationStyle = .fullScreen
                                return
                            }
                            else {
                                Firestore.firestore().collection("users").document(user!.uid).setData(["email": user!.email!, "name": user!.displayName!, "onCourt": false])
                                
                                // generate the chat channels
                                self.addChanneltoPeople(userUID: user!.uid, username: user!.displayName ?? "")
                                
                                // add basketball queue usage information for google login user
                                let uid = UserDefaults.standard.string(forKey: "uid")
                                Firestore.firestore().collection("users").document(uid!).collection("basketballQueue").getDocuments { (documentSnapshot, error) in
                                    if error != nil {
                                        
                                    } else {
                                        // this is setting data to the firebase
                                        if(documentSnapshot!.documents.count == 0) {
                                            Firestore.firestore().collection("users").document(uid!).collection("basketballQueue").document("1").setData(["joined": false])
                                            Firestore.firestore().collection("users").document(uid!).collection("basketballQueue").document("2").setData(["joined": false])
                                            Firestore.firestore().collection("users").document(uid!).collection("basketballQueue").document("3").setData(["joined": false])
                                            Firestore.firestore().collection("users").document(uid!).collection("basketballQueue").document("4").setData(["joined": false])
                                            Firestore.firestore().collection("users").document(uid!).collection("basketballQueue").document("5").setData(["joined": false])
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    
                    self.performSegue(withIdentifier: "LoginSuccess", sender: nil)
                    self.modalPresentationStyle = .fullScreen
                    
                }
                // User is signed in
                // ...
        
            }
        
        }
    
    }
    
    // function for storing all users and userid pair
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
            // print(self.allUsers)
        }
    }
    
    // function for storing all chat channel, users, and userid pair
    static var nameIDPair:[(String, String, String)] = []
    func addChanneltoPeople(userUID: String, username: String) {
        // var ref: DocumentReference? = nil
        self.generateNewChatListDB {nameUIDPair in
            // var nameIDPair:[(String, String, String)] = []
            for pair in nameUIDPair {
                var ref: DocumentReference? = nil
                ref = Firestore.firestore().collection("channels").addDocument(data: [
                    "history": [""]
                ]) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        // add a new firestore user to the firebase store
                        // add a firestore to the pair 0 is the channel name
                        // pair 1 is the data name
                        // set the document 
                        print("Document added with ID: \(ref!.documentID)")
                        Firestore.firestore().collection("users").document(userUID).collection("channels").document(pair.0).setData(["channelID": ref!.documentID])
                        Firestore.firestore().collection("users").document(pair.1).collection("channels").document(username).setData(["channelID": ref!.documentID])
                    }
                }
            }
        }
    }
}
