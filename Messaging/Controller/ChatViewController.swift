//
//  ChatViewController.swift
//  Messaging
//
//  Created by Piyatat  Thianboonsong on 13/2/2563 BE.
//  Copyright © 2563 iTiiiM. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ChatViewController: UIViewController {
    
    let db = Firestore.firestore()
    var messageCollection: [QueryDocumentSnapshot] = []
//    var messages: [Message] = []

    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var channel: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.navigationItem.title = channel
        // Register TableViewCell to use custom cell
        tableView.separatorStyle = .none
        addChatListener()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadAllChats()
    }
    
    func addChatListener() {
        // Add listener to documents to update chat sort by timeStamp
        db.collection("channels").document(channel ?? "").collection("messages").order(by: "timeStamp", descending: false).addSnapshotListener { (snapShot, error) in
            if error != nil {
//            guard let documents = snapShot?.documents else {
//                print("Error fetching documents: \(error!)")
//                return
//            }
                print(error!)
            } else {
                self.messageCollection = snapShot!.documents
                self.tableView.reloadData()
            }
        }
    }
    
    func loadAllChats() {
                db.collection("channels").document(channel ?? "").collection("messages").order(by: "timeStamp", descending: false).getDocuments { (snapShot, error) in
//            guard let documents = snapShot?.documents else {
//                print("Error fetching documents: \(error!)")
//                return
//            }
                    if error != nil {
                        print(error!)
                    } else  {
                        self.messageCollection = snapShot!.documents
                        self.tableView.reloadData()
                    }
        }
    }
    
    @IBAction func sendButtonDidTapped(_ sender: Any) {
        db.collection("channels").document(channel ?? "").collection("messages").addDocument(data: ["senderName": Auth.auth().currentUser?.displayName, "messageBody": messageTextField.text!, "timeStamp": NSDate().timeIntervalSince1970])
        
    }
    
}

extension ChatViewController: UITableViewDelegate {
    
    
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageCollection.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let senderName = messageCollection[indexPath.row].data()["senderName"] as? String
        let message = messageCollection[indexPath.row].data()["messageBody"] as? String
        
        if senderName != Auth.auth().currentUser?.displayName {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "otherMessageCell") as! OtherMessageCell
            cell.selectionStyle = .none
            cell.configCell(name: senderName ?? "", message: message ?? "")
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "myMessageCell") as! MyMessageCell
            cell.selectionStyle = .none
            cell.configCell(name: senderName ?? "", message: message ?? "")
            return cell
        }
    }
}
