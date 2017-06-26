//
//  ViewController.swift
//  Graffiti
//
//  Created by Raoul Rodriguez on 6/26/17.
//  Copyright © 2017 Raoul Rodriguez. All rights reserved.
//

import UIKit
import JSQMessagesViewController

struct User {
    let id: String
    let name: String
}


final class ChatViewController: JSQMessagesViewController
{
    // For communication
    let communicationService = CommunicationManager()
    
    // For UI
    let user1 = User(id: "1", name: "User 1");
    let user2 = User(id: "2", name: "User 2");
    
    var currentUser: User {
        return user1;
    }
    
    var messages = [JSQMessage]()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.senderId = currentUser.id
        super.senderDisplayName = currentUser.name
        super.viewWillAppear(animated)
        
        communicationService.delegate = self
    }
    
    override func viewDidLoad() {
        senderId = currentUser.id
        senderDisplayName = currentUser.name
        super.viewDidLoad()
        
        // Hide the image attachment button
        self.inputToolbar.contentView.leftBarButtonItem = nil
        
        self.messages = getMessages()
    }
}

extension ChatViewController {
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.row]
        let messageUsername = message.senderDisplayName
        
        return NSAttributedString(string: messageUsername!)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        
        if (messages[indexPath.row].senderId == currentUser.id) {
            return bubbleFactory?.outgoingMessagesBubbleImage(with: .blue)
        }
    
        return bubbleFactory?.incomingMessagesBubbleImage(with: .blue)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return 15
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {

        let newMessage = JSQMessage(senderId: "1", displayName: "Current Device", text: text)
        messages.append(newMessage!)
        
        // Send the message
        communicationService.send(text: text)
        finishSendingMessage()
    }
}


extension ChatViewController {
    func getMessages() -> [JSQMessage] {
        var messages = [JSQMessage]()
        
        let message1 = JSQMessage(senderId: "1", displayName: "User 1", text: "Hello is anyone there?")
        let message2 = JSQMessage(senderId: "2", displayName: "User 2", text: "Yes, I'm here!")

        messages.append(message1!)
        messages.append(message2!)
        
        return messages
    }
}

extension ChatViewController : CommunicationManagerDelegate {
    
    func connectedDevicesChanged(manager: CommunicationManager, connectedDevices: [String]) {
        OperationQueue.main.addOperation {
            print("New connected Device")
            print(connectedDevices)
        }
    }
    
    func newMessage(manager: CommunicationManager, text: String) {
        OperationQueue.main.addOperation {
            let newMessage = JSQMessage(senderId: "2", displayName: "Alien", text: text)
            self.messages.append(newMessage!)
            self.finishReceivingMessage()
        }
    }
}
