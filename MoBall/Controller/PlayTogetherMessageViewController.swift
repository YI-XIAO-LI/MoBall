//
//  PlayTogetherMessageViewController.swift
//  MoBall
//
//  Created by Yixiao Li on 2022/11/17.
//
//  Name: Yixiao Li
//  Email: likather@usc.edu

import UIKit
import MessageKit
import Messages
import InputBarAccessoryView
import FirebaseFirestore

// 1. Get me all the channels I'm a member of: A,B,C
// 2. Get me all the messages the belongs to this channel: A


class PlayTogetherMessageViewController: MessagesViewController, MessagesDataSource, MessagesDisplayDelegate, MessagesLayoutDelegate, InputBarAccessoryViewDelegate {
    
    // set the count of the section to the number of the message
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    let currentUser = Sender(senderId: "self", displayName: "Display Name", messageId: 1)
    let otherUser = Sender(senderId: "other", displayName: "Display Other Name", messageId: 1)
    // var messages = [MessageType]()
    var messages = [Message]()
    
    func currentSender() -> SenderType {
        return currentUser
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        let returnMessage: Message_
        // set the returnMessage to the Message_ type for aligning with the MessageKit
        if(messages[indexPath.section].from == UserDefaults.standard.string(forKey: "name")) {
            // set the sent date to the current date
            returnMessage = Message_(sender: currentUser, messageId: "1", sentDate: Date(), kind: .text(messages[indexPath.section].content))
                return returnMessage
        }
        // for other user
        returnMessage = Message_(sender: otherUser, messageId: "1", sentDate: Date(), kind: .text(messages[indexPath.section].content))
            return returnMessage
    }

    var name: String = ""
    var channelID: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Firestore.firestore().collection("users").document(UserDefaults.standard.string(forKey: "uid")!).collection("channels").getDocuments{ documentSnapshot, error in
            if let error = error {
                print("error:\(error.localizedDescription)")
            } else {
                
                for document in documentSnapshot!.documents {
                    // retrieve and display all messages for the current channel
                    if(self.name == document.documentID) {
                        self.channelID = document.get("channelID") as! String
                        Firestore.firestore().collection("channels").getDocuments{ documentSnapshot, error in
                            if let error = error {
                                print("error:\(error.localizedDescription)")
                            } else {
                                // print("hi")
                                for document in documentSnapshot!.documents {
                                    if(self.channelID == document.documentID) {
                                        let allMessages = document.get("history") as! [String]
                                        // display all mesages to the current view
                                        var k = 1
                                        while (k < allMessages.count) {
                                            let splitStringArray = allMessages[k].split(separator: ",", maxSplits: 1).map(String.init)
                                            self.messages.append(Message(from: splitStringArray[0], content: splitStringArray[1]))
                                            k += 1
                                        }
                                        
                                        // reload data
                                        DispatchQueue.main.async {
                                            // update the view
                                            self.messagesCollectionView.reloadData()
                                        }
                                    }
                                }
                                // reload data
                                DispatchQueue.main.async {
                                    self.messagesCollectionView.reloadData()
                                }
                            }
                        }
                    }
                }
            }
        }
        
        
        // messages.append(Message(from: "other", content: "text"))
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
        // initialize messages to a list read from firestore
        
        return
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        if (text != "") {
            // alert user if duplicate message is sent
            if messages.contains(Message(from: UserDefaults.standard.string(forKey: "name")!, content: text)) {
                let alert = UIAlertController(title: "Warning!", message: "Chat does not Support Duplicate Messages", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)
                present(alert, animated:true)
                return
            }
            // store the newly sent message to firestore
            messages.append(Message(from: UserDefaults.standard.string(forKey: "name")!, content: text))
            // add the message to firebase
            Firestore.firestore().collection("channels").document(self.channelID).updateData([
                "history": FieldValue.arrayUnion(["\(UserDefaults.standard.string(forKey: "name")!),\(text)"])
            ])
            
            messagesCollectionView.reloadData()
            
            inputBar.inputTextView.text = ""
            messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)

        }
        
    }
    
    
}

