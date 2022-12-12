//
//  CourtUsageViewController.swift
//  MoBall
//
//  Created by Yixiao Li on 2022/11/22.
//
//  Name: Yixiao Li
//  Email: likather@usc.edu

import UIKit
import CoreLocation
import FirebaseFirestore

class CourtUsageViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var addUsageButton: UIBarButtonItem!
    @IBAction func AddUsageDidTapped(_ sender: Any) {
        // check if location is within range
        // if so, set isAround = true
        
        if isAroundLyon == true {
            onCourt = true
            // increment the court value by 1;
            // store it on to the firebase
            leaveCourtButton.isEnabled = true
            addUsageButton.isEnabled = false
            numOfPlayer += 1
            playerCount.text = "\(numOfPlayer)"
            
            // update on fierbase
            Firestore.firestore().collection("users").document(UserDefaults.standard.string(forKey: "uid")!).updateData(["onCourt": true])
            Firestore.firestore().collection("courtUsage").document("totalUsage").updateData(["count": numOfPlayer])
        }
        else {
            // sends alert, not around lyon center
            let alert = UIAlertController(title: "Warning!", message: "To Add Usage, Please be Physically at the Lyon Center.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated:true)
        }
        
    }
    
    @IBOutlet weak var playerCount: UILabel!
    
    @IBOutlet weak var leaveCourtButton: UIBarButtonItem!
    @IBAction func LeaveCourtDidTapped(_ sender: Any) {
        // decrement the court value by 1;
        // store it on to the firebase
        onCourt = false
        leaveCourtButton.isEnabled = false
        addUsageButton.isEnabled = true
        numOfPlayer -= 1
        playerCount.text = "\(numOfPlayer)"
        
        // update on fierbase
        Firestore.firestore().collection("users").document(UserDefaults.standard.string(forKey: "uid")!).updateData(["onCourt": false])
        Firestore.firestore().collection("courtUsage").document("totalUsage").updateData(["count": numOfPlayer])
    }
    
    
    var locationManager: CLLocationManager = CLLocationManager()
    var isAroundLyon = false
    var onCourt = false
    var numOfPlayer = 0
    
    
    override func viewDidLoad() {
        // enable the location manager to check location for adding usage
        // locationManager = CLLocationManager()
        self.locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        // self.locationManager.requestWhenInUseAuthorization()
        
        leaveCourtButton.isEnabled = false
        
        // check if location service is enabled
        if CLLocationManager.locationServicesEnabled() {
            
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.startUpdatingLocation()
        }
        
        Firestore.firestore().collection("users").document(UserDefaults.standard.string(forKey: "uid")!).getDocument{ documentSnapshot, error in
            if let error = error {
                print("error:\(error.localizedDescription)")
            } else {
                // check if the user if on court, enable button accordingly
                self.onCourt = documentSnapshot?.get("onCourt") as! Bool
                DispatchQueue.main.async {
                    if self.onCourt == true {
                        // set current court
                        self.addUsageButton.isEnabled = false
                        self.leaveCourtButton.isEnabled = true
                    }
                    else {
                        self.addUsageButton.isEnabled = true
                        self.leaveCourtButton.isEnabled = false
                    }
                }
            }
        }
        
        // set total number of player on court, set display accordingly
        Firestore.firestore().collection("courtUsage").document("totalUsage").getDocument{ documentSnapshot, error in
            if let error = error {
                print("error:\(error.localizedDescription)")
            } else {
                self.numOfPlayer = documentSnapshot?.get("count") as! Int
                self.playerCount.text = "\(self.numOfPlayer)"
                DispatchQueue.main.async {
                    self.playerCount.text = "\(self.numOfPlayer)"
                }
            }
        }
        
        return
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse {
            // check if the authorization is changed
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first {
            // check if it is within the range of lyon center
            // latitude 34.021, longitude -118.286
            if abs(location.coordinate.latitude - 34.02439) <= 0.00001 && abs(location.coordinate.longitude + 118.2905708) <= 0.000001 {
                isAroundLyon = true
            }
            else {
                // if user left the lyon center, automatically disable usage and set false
                if(onCourt == true) {
                    isAroundLyon = false
                    onCourt = false
                    leaveCourtButton.isEnabled = false
                    addUsageButton.isEnabled = true
                    numOfPlayer -= 1
                    playerCount.text = "\(numOfPlayer)"
                    
                    // update on fierbase
                    Firestore.firestore().collection("users").document(UserDefaults.standard.string(forKey: "uid")!).updateData(["onCourt": false])
                    Firestore.firestore().collection("courtUsage").document("totalUsage").updateData(["count": numOfPlayer])
                    
                    let alert = UIAlertController(title: "Warning!", message: "You left Lyon Center", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated:true)
                }
            }
            return
        }
    }
}
