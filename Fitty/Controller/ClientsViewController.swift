//
//  ClientsViewController.swift
//  Fitty
//
//  Created by Filip Popovic
//

import UIKit
import Firebase
import LetterAvatarKit

class ClientsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    var users = [User]()
    var selectedUser: User?
    var usersInfo = [UserInfo]()
    var selectedUserInfo: UserInfo?
    let avatarImage = LetterAvatarMaker()
    let searchController = UISearchController()
    var filteredUsers = [User]()
    var filteredUsersInfo = [UserInfo]()
    var isFiltered = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.global(qos: .background).async {
            FollowService.adminClientsList { (users) in
                self.users = users
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } completionUserInfo: { (usersInfo) in
                self.usersInfo = usersInfo
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
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
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !filteredUsers.isEmpty {
            return filteredUsers.count
        } else if filteredUsers.isEmpty && isFiltered == true {
            return 0
        } else {
            return users.count
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.clientsCell,  for: indexPath) as! ClientsCell
        if filteredUsers.isEmpty {
            let user = users[indexPath.row]
            cell.clientNameLabel.text = user.full_name
            cell.profilePic.layer.cornerRadius = cell.profilePic.frame.size.width / 2
            cell.profilePic.clipsToBounds = true
            cell.profilePic.contentMode = .scaleAspectFill
            if user.profile_picture != "" {
                cell.profilePic.sd_setImage(with: URL(string: user.profile_picture), completed: nil)
            } else {
                cell.profilePic.image = self.avatarImage.setUsername(user.full_name).build()?.roundedImage
            }
        } else {
            let user = filteredUsers[indexPath.row]
            cell.clientNameLabel.text = user.full_name
            cell.profilePic.layer.cornerRadius = cell.profilePic.frame.size.width / 2
            cell.profilePic.clipsToBounds = true
            cell.profilePic.contentMode = .scaleAspectFill
            if user.profile_picture != "" {
                cell.profilePic.sd_setImage(with: URL(string: user.profile_picture), completed: nil)
            } else {
                cell.profilePic.image = self.avatarImage.setUsername(user.full_name).build()?.roundedImage
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if filteredUsers.isEmpty {
            selectedUser = users[indexPath.row]
            selectedUserInfo = usersInfo[indexPath.row]
        } else {
            selectedUser = filteredUsers[indexPath.row]
            selectedUserInfo = filteredUsersInfo[indexPath.row]
        }
        
        performSegue(withIdentifier: Constants.SegueTo.clientsListToClientInfo, sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.SegueTo.clientsListToClientInfo {
            let destionation = segue.destination as! ClientsInfoViewController
            destionation.user = selectedUser!
            destionation.userInfo = selectedUserInfo!
        }
    }
    
}
extension ClientsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        filteredUsers.removeAll()
        if text.isEmpty {
            isFiltered = false
        } else {
            users.forEach {
                if $0.full_name.lowercased().contains(text.lowercased()) {
                    filteredUsers.append($0)
                    isFiltered = true
                    for info in usersInfo where info.uid == $0.uid {
                        filteredUsersInfo.append(info)
                    }
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
