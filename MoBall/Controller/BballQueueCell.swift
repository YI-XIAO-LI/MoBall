//
//  BballQueueCell.swift
//  MoBall
//
//  Created by Yixiao Li on 2022/11/16.
//
//  Name: Yixiao Li
//  Email: likather@usc.edu

import UIKit
import FirebaseFirestore

class BballQueueCell: UITableViewCell {

    @IBOutlet weak var borrowStatusLabel: UILabel!
    
    @IBOutlet weak var joinQueueButton: UIButton!
    @IBAction func JoinQueueDidTapped(_ sender: Any) {
        // store usage data to the firebase if joining queue, user can join multiple queue
        leaveQueueButton.isEnabled = true
        joinQueueButton.isEnabled = false
        let previous = String(borrowStatusLabel.text!.remove(at: borrowStatusLabel.text!.index(before: borrowStatusLabel.text!.endIndex)))
        borrowStatusLabel.text! +=  "\(Int(previous)! + 1)"
        let cellIndex = String(borrowStatusLabel.text![borrowStatusLabel.text!.index(borrowStatusLabel.text!.startIndex, offsetBy: 13)])
        
        Firestore.firestore().collection("basketballQueue").document(cellIndex).setData(["wait": Int(previous)! + 1])
        
        Firestore.firestore().collection("users").document(UserDefaults.standard.string(forKey: "uid")!).collection("basketballQueue").document(cellIndex).setData(["joined": true])
    }
    
    @IBOutlet weak var leaveQueueButton: UIButton!
    // function enable firestore update, and display update when the user leave the queue
    @IBAction func LeaveQueueDidTapped(_ sender: Any) {
        leaveQueueButton.isEnabled = false
        joinQueueButton.isEnabled = true
        let previous = String(borrowStatusLabel.text!.remove(at: borrowStatusLabel.text!.index(before: borrowStatusLabel.text!.endIndex)))
        // store usage data to the firebase if leaving queue
        if ((Int(previous)!) > 0) {
            borrowStatusLabel.text! +=  "\(Int(previous)! - 1)"
            
            let cellIndex = String(borrowStatusLabel.text![borrowStatusLabel.text!.index(borrowStatusLabel.text!.startIndex, offsetBy: 13)])
            
            Firestore.firestore().collection("basketballQueue").document(cellIndex).setData(["wait": Int(previous)! - 1])
            
            Firestore.firestore().collection("users").document(UserDefaults.standard.string(forKey: "uid")!).collection("basketballQueue").document(cellIndex).setData(["joined": false])
            print(cellIndex)
        }
        
        
    }
    

}
