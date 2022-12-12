//
//  BallBorrowTableViewController.swift
//  MoBall
//
//  Created by Yixiao Li on 2022/11/15.
//
//  Name: Yixiao Li
//  Email: likather@usc.edu

import UIKit
import FirebaseFirestore

class BallBorrowTableViewController: UITableViewController {
    var basketballQueue = [(Int, Bool)]()
    override func viewDidLoad() {
        if(basketballQueue.count == 0){
            Firestore.firestore().collection("basketballQueue").getDocuments { documentSnapshot, error in
                if let error = error {
                    print("error:\(error.localizedDescription)")
                } else {
                    
                    for document in documentSnapshot!.documents {
                        self.basketballQueue.append((document.get("wait") as! Int, Bool()))
                        // how to loop through planDetails
                        
                    }
                    // store the basketball usage information from firebase and store it in basketballQueue
                    Firestore.firestore().collection("users").document(UserDefaults.standard.string(forKey: "uid")!).collection("basketballQueue").getDocuments{ documentSnapshot, error in
                        if let error = error {
                            print("error:\(error.localizedDescription)")
                        } else {
                            var i = 0
                            for document in documentSnapshot!.documents {
                                
                                self.basketballQueue[i].1 = document.get("joined") as! Bool
                                i += 1
                                // how to loop through planDetails
                            }
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                   
                }
            }
            
        }
        return
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // refresh the table when the tab is pressed
        // self.tableView.reloadData()
    }
    
    // set the size of each cell of be 90
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 5
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // customize each basketball cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "ballBorrowPrototypeCell", for: indexPath) as? BballQueueCell
        cell?.borrowStatusLabel.numberOfLines = 0
        
        cell?.borrowStatusLabel.font = UIFont(name: "Times", size: 20)
        // if basketballQueue is successfually retrieved from firebase, display it
        if(basketballQueue.count > 0){
            // Configure the cell...
            cell?.borrowStatusLabel.text = "Basketball # \(indexPath.row + 1) \nCurrent Queue: \(basketballQueue[indexPath.row].0)"
            
            cell?.leaveQueueButton.isEnabled = basketballQueue[indexPath.row].1
            cell?.joinQueueButton.isEnabled = !(basketballQueue[indexPath.row].1)
        }
        return cell!
    }
    
}
