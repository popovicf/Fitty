//
//  ChatListViewController.swift
//  Fitty
//
//  Created by Filip Popovic
//

import UIKit
import Firebase
import LetterAvatarKit

class ChatListViewController: UIViewController, UISearchControllerDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var chats = [Chat]()
    var userChatsHandle: DatabaseHandle = 0
    var userChatsRef: DatabaseReference?
    let loader = Loader()
    var hasTheFunctionCalled : Bool = false {
        didSet{
            hasTheFunctionCalled = true
        }
    }
    let refreshControl = UIRefreshControl()
    let searchController = UISearchController()
    var filteredChats = [Chat]()
    var isFiltered = false
    let avatarImage = LetterAvatarMaker()
    var users = [User]()
    
    override func viewWillAppear(_ animated: Bool) {
        if !hasTheFunctionCalled{
            loader.startLoader(vc: self)
        }
        hasTheFunctionCalled = true
        DispatchQueue.global(qos: .background).async {
            self.userChatsHandle = ChatService.observeChats { [weak self] (ref, chats) in
                self?.userChatsRef = ref
                self?.chats = chats
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                self?.loader.endLoader()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 71
        tableView.tableFooterView = UIView()
        addRefreshControl()
        title = "Messages"
        navigationController?.navigationBar.tintColor = .systemOrange
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.systemOrange]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.enablesReturnKeyAutomatically = false
        searchController.searchBar.returnKeyType = UIReturnKeyType.search
        definesPresentationContext = true
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    deinit {
        userChatsRef?.removeObserver(withHandle: userChatsHandle)
    }
    
    @objc func refresh(_ sender: AnyObject) {
        self.refreshControl.beginRefreshing()
        self.userChatsHandle = ChatService.observeChats { [weak self] (ref, chats) in
            self?.userChatsRef = ref
            self?.chats = chats
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        self.refreshControl.endRefreshing()
    }
    
    func addRefreshControl(){
        let refreshImage = UIImageView()
        refreshImage.image = UIImage(named: "fittyLogo.png")
        refreshImage.contentMode = UIView.ContentMode.scaleAspectFit
        refreshImage.frame = refreshControl.bounds.offsetBy(dx: (self.view.frame.size.width / 2) - 30, dy: 0)
        refreshImage.frame.size.width = 80
        refreshImage.frame.size.height = 80
        refreshControl.backgroundColor = UIColor.clear
        refreshControl.tintColor = UIColor.systemOrange
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching messages...", attributes: [.font : UIFont.systemFont(ofSize: 24), .foregroundColor : UIColor.systemOrange] )
        //refreshControl.addSubview(refreshImage)
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
    }
}

extension ChatListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !filteredChats.isEmpty {
            return filteredChats.count
        } else if filteredChats.isEmpty && isFiltered == true {
            return 0
        } else {
            return chats.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListCell") as! ChatListCell
        if filteredChats.isEmpty {
            let chat = chats[indexPath.row]
            cell.titleLabel.tag = 11
            cell.lastMessageLabel.tag = 22
            
            for ch in chat.memberUIDs where ch != User.current.uid {
                users.forEach{ if $0.uid == ch.description {
                    if $0.profile_picture != "" {
                        cell.profilePicture.sd_setImage(with: URL(string: $0.profile_picture), completed: nil)
                    } else {
                        cell.profilePicture.image = self.avatarImage.setUsername($0.full_name).build()?.roundedImage
                    }
                }
            }
                
            for ch in chat.title.replacingOccurrences(of: ", ", with: ",").split(separator: ",") where ch != User.current.full_name {
                cell.titleLabel.text = ch.description
                }
            }
            
            cell.lastMessageLabel.text = chat.lastMessage
        } else {
            let chat = filteredChats[indexPath.row]
            cell.titleLabel.tag = 11
            cell.lastMessageLabel.tag = 22
            
            for ch in chat.memberUIDs where ch != User.current.uid {
                users.forEach{ if $0.full_name == ch.description {
                    if $0.profile_picture != "" {
                        cell.profilePicture.sd_setImage(with: URL(string: $0.profile_picture), completed: nil)
                    } else {
                        cell.profilePicture.image = self.avatarImage.setUsername($0.full_name).build()?.roundedImage
                    }
                }
            }
            
            for ch in chat.title.replacingOccurrences(of: ", ", with: ",").split(separator: ",") where ch != User.current.full_name {
                cell.titleLabel.text = ch.description
                }
            }
            
            cell.lastMessageLabel.text = chat.lastMessage
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.contentView.backgroundColor = UIColor.init(cgColor: #colorLiteral(red: 0.8677101209, green: 0.8539167511, blue: 0.8765505396, alpha: 1))
        }
    }
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.contentView.backgroundColor = nil
        }
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if filteredChats.isEmpty {
            let chat = chats[indexPath.row]
            if editingStyle == .delete {
                tableView.beginUpdates()
                chats.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                Database.database().reference().child("chats").child(User.current.uid).child(chat.key!).removeValue()
                for ch in chat.memberUIDs where ch != User.current.uid {
                    Database.database().reference().child("chats").child(ch).child(chat.key!).removeValue()
                }
                Database.database().reference().child("messages").child(chat.key!).removeValue()
                tableView.endUpdates()
            }
        } else {
            let chat = filteredChats[indexPath.row]
            if editingStyle == .delete {
                tableView.beginUpdates()
                filteredChats.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                Database.database().reference().child("chats").child(User.current.uid).child(chat.key!).removeValue()
                for ch in chat.memberUIDs where ch != User.current.uid {
                    Database.database().reference().child("chats").child(ch).child(chat.key!).removeValue()
                }
                Database.database().reference().child("messages").child(chat.key!).removeValue()
                tableView.endUpdates()
            }
        }
    }
}

extension ChatListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Constants.SegueTo.chatToChat, sender: self)
    }
}

extension ChatListViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == Constants.SegueTo.chatToChat,
           let destination = segue.destination as? ChatViewController,
           let indexPath = tableView.indexPathForSelectedRow {
            if filteredChats.isEmpty {
                destination.chat = chats[indexPath.row]
            } else {
                destination.chat = filteredChats[indexPath.row]
            }
        }
    }
}

extension ChatListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        filteredChats.removeAll()
        if text.isEmpty {
            isFiltered = false
        } else {
            chats.forEach {
                if $0.title.contains(text) {
                    filteredChats.append($0)
                    isFiltered = true
                } else {
                    isFiltered = true
                }
            }
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isFiltered = false
    }
}

