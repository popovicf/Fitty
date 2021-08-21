//
//  NewChatViewController.swift
//  Fitty
//
//  Created by Filip Popovic
//

import UIKit
import LetterAvatarKit

class NewChatViewController: UIViewController, UISearchControllerDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    var following = [User]()
    var followers = [User]()
    var selectedUser: User?
    var existingChat: Chat?
    let searchController = UISearchController()
    var filteredFollowing = [User]()
    var isFiltered = false
    let avatarImage = LetterAvatarMaker()
    var isSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        nextButton.isEnabled = false
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 71
        
        
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.enablesReturnKeyAutomatically = false
        searchController.searchBar.returnKeyType = UIReturnKeyType.search
        definesPresentationContext = true
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        if User.current.admin == false {
            FollowService.following { [weak self] (following) in
                self?.following = following
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        } else {
            FollowService.followers { [weak self] (followers) in
                self?.following = followers
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    @IBAction func nextButtonPressed(_ sender: UIBarButtonItem) {
        guard let selectedUser = selectedUser else { return }
        sender.isEnabled = false
        ChatService.checkForExistingChat(with: selectedUser) { (chat) in
            sender.isEnabled = true
            self.existingChat = chat
            self.performSegue(withIdentifier: Constants.SegueTo.newChatToChat, sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == Constants.SegueTo.newChatToChat, let destination = segue.destination as? ChatViewController, let selectedUser = selectedUser {
            let members = [selectedUser, User.current]
            destination.chat = existingChat ?? Chat(members: members)
        }
    }
}

extension NewChatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        isSelected.toggle()
        
        if filteredFollowing.isEmpty {
            selectedUser = following[indexPath.row]
        } else {
            selectedUser = filteredFollowing[indexPath.row]
        }
        
        if isSelected {
            cell.accessoryType = .checkmark
            nextButton.isEnabled = true
        } else {
            cell.accessoryType = .none
            nextButton.isEnabled = false
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        isSelected.toggle()
        cell.accessoryType = .none
        nextButton.isEnabled = false
    }
}

extension NewChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !filteredFollowing.isEmpty {
            return filteredFollowing.count
        } else if filteredFollowing.isEmpty && isFiltered == true {
            return 0
        } else {
            return following.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewChatUserCell") as! NewChatUserCell
        configureCell(cell, at: indexPath)
        return cell
    }
    
    func configureCell(_ cell: NewChatUserCell, at indexPath: IndexPath) {
        var follower = User()
        
        if filteredFollowing.isEmpty {
            follower = following[indexPath.row]
            cell.label.text = follower.full_name
            if follower.profile_picture != "" {
                cell.profilePicture.sd_setImage(with: URL(string: follower.profile_picture), completed: nil)
            } else {
                cell.profilePicture.image = self.avatarImage.setUsername(follower.full_name).build()?.roundedImage
            }
        } else {
            follower = filteredFollowing[indexPath.row]
            cell.label.text = follower.full_name
            if follower.profile_picture != "" {
                cell.profilePicture.sd_setImage(with: URL(string: follower.profile_picture), completed: nil)
            } else {
                cell.profilePicture.image = self.avatarImage.setUsername(follower.full_name).build()?.roundedImage
            }
        }
        
        if let selectedUser = selectedUser, selectedUser.uid == follower.uid, isSelected {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
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
}

extension NewChatViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        filteredFollowing.removeAll()
        if text.isEmpty {
            isFiltered = false
        } else {
            following.forEach {
                if $0.full_name.contains(text) {
                    filteredFollowing.append($0)
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
