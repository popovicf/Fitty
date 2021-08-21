//
//  ChatViewController.swift
//  Fitty
//
//  Created by Filip Popovic
//

import UIKit
import Firebase
import LetterAvatarKit
import SDWebImage


class ChatViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    let firbaseService = FirebaseService()
    var messagesHandle: DatabaseHandle = 0
    var messagesRef: DatabaseReference?
    var messages = [Message]()
    var chat: Chat!
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
        tryObservingMessages()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.register(UINib(nibName: Constants.Cell.cellNibName, bundle: nil), forCellReuseIdentifier: Constants.Cell.cellIdentifier)
        sendButton.tintColor = .white
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    deinit {
        messagesRef?.removeObserver(withHandle: messagesHandle)
    }
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        if let text = messageTextField.text, text != "" {
            let message = Message(content: text)
            sendMessage(message)
        }
        DispatchQueue.main.async {
            self.messageTextField.text = ""
            self.tableView.reloadData()
        }
    }
    
    func sendMessage(_ message: Message) {
        if chat?.key == nil {
            ChatService.create(from: message, with: chat, completion: { [weak self] chat in
                guard let chat = chat else { return }
                self!.chat = chat
                self!.tryObservingMessages()
                DispatchQueue.main.async {
                    self!.tableView.reloadData()
                }
            })
        } else {
            ChatService.sendMessage(message, for: chat)
        }
    }
    
    func tryObservingMessages() {
        guard let chatKey = chat?.key else { return }
        messagesHandle = ChatService.observeMessages(forChatKey: chatKey, completion: { [weak self] (ref, message) in
            self?.messagesRef = ref
            if let message = message {
                self?.messages.append(message)
                DispatchQueue.main.async {
                    self!.tableView.reloadData()
                    let indexPath = IndexPath(row: self!.messages.count-1, section: 0)
                    self!.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                }
            }
        })
    }
}

extension ChatViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.cellIdentifier, for: indexPath) as! MessageCell
        cell.label.text = message.content
        
        let avatarImage = LetterAvatarMaker()
        if message.sender.uid == Auth.auth().currentUser?.uid {
            cell.leftImageView.isHidden = true
            cell.rightImageView.isHidden = false
            cell.messageBubble.backgroundColor = UIColor.systemOrange
            cell.label.textColor = UIColor.white
            if User.current.profile_picture != "" {
                let placeholderImage = avatarImage.setUsername(User.current.full_name).build()?.roundedImage
                cell.rightImageView.sd_setImage(with: URL(string: User.current.profile_picture)!, placeholderImage: placeholderImage)
                cell.rightImageView.layer.cornerRadius = cell.rightImageView.frame.size.width / 2
                cell.rightImageView.clipsToBounds = true
                cell.rightImageView.contentMode = .scaleAspectFill
            } else {
                cell.rightImageView.image = avatarImage.setUsername(User.current.full_name).build()?.roundedImage
            }
        } else {
            cell.leftImageView.isHidden = false
            cell.rightImageView.isHidden = true
            cell.messageBubble.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            cell.label.textColor = UIColor.systemOrange
            for secondUserUID in self.chat.memberUIDs where secondUserUID != Auth.auth().currentUser?.uid {
                self.firbaseService.getUserFromID(collection: "users", ID: secondUserUID) { (user) in
                    if user!.profile_picture != "" {
                        let placeholderImage = avatarImage.setUsername(user!.full_name).build()?.roundedImage
                        cell.leftImageView.sd_setImage(with: URL(string: user!.profile_picture)!, placeholderImage: placeholderImage)
                        cell.leftImageView.layer.cornerRadius = cell.rightImageView.frame.size.width / 2
                        cell.leftImageView.clipsToBounds = true
                        cell.leftImageView.contentMode = .scaleAspectFill
                    } else {
                        cell.leftImageView.image = avatarImage.setUsername(user!.full_name).build()?.roundedImage
                    }
                } completionUserInfo: { (userInfo) in }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
}
