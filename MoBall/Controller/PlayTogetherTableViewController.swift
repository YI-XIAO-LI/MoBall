//
//  PlayTogetherTableViewController.swift
//  MoBall
//
//  Created by Yixiao Li on 2022/11/15.
//
//  Name: Yixiao Li
//  Email: likather@usc.edu

import UIKit
import FirebaseFirestore

class PlayTogetherTableViewController: UITableViewController {
    var allUsers = [String]()
    
    // load the tableview
    override func viewDidLoad() {
        self.tableView.reloadData()
        return
    }
    
    // set table view size (height) to 50
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // refresh the table when the tab is pressed
        
        if (allUsers.count == 0) {
            Firestore.firestore().collection("users").getDocuments { documentSnapshot, error in
                if let error = error {
                    print("error:\(error.localizedDescription)")
                } else {
                    // display all names to the view and refresh the page
                    for document in documentSnapshot!.documents {
                        if(document.get("name") as? String != UserDefaults.standard.string(forKey: "name")){
                            self.allUsers.append(document.get("name") as! String)
                        }
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return allUsers.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath)
        // Configure the cell...
        cell.textLabel?.font = UIFont(name: "Times", size: 20)
        cell.textLabel?.text = "Name: " + String(allUsers[indexPath.row])
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // send info to destination viewcontroller
        if segue.identifier == "ChatSegue" {
            let dest  = segue.destination as? PlayTogetherMessageViewController
            dest?.name = allUsers[self.currentSelect]
        }
    }
    
    var currentSelect = 0
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // if any cell is clicked, get the cell index and send it to the next viewcontroller
        currentSelect = indexPath.row
        performSegue(withIdentifier: "ChatSegue", sender: self)
    }
}

