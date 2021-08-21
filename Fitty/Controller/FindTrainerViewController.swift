//
//  FindTrainerViewController.swift
//  Fitty
//
//  Created by Filip Popovic
//

import UIKit
import Firebase
import LetterAvatarKit

protocol FindTrainerViewControllerDelegate: AnyObject {
    func didTapFollowButton()
}

class FindTrainerViewController: UIViewController, UITableViewDelegate, UISearchControllerDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var users = [User]()
    var usersInfo = [UserInfo]()
    let avatarImage = LetterAvatarMaker()
    weak var delegate: FindTrainerViewControllerDelegate?
    let searchController = UISearchController()
    var filteredUsers = [User]()
    var filteredUsersInfo = [UserInfo]()
    var isFiltered = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            FollowService.usersExcludingCurrentUser { [unowned self] (users) in
                self.users = users
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } completionUserInfo: { (userInfo) in
                self.usersInfo = userInfo
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
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
}

extension FindTrainerViewController: UITableViewDataSource {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.findTrainerCell,  for: indexPath) as! FindTrainerCell
        cell.delegate = self
        configure(cell: cell, atIndexPath: indexPath)
        
        if cell.followButton.isSelected {
            cell.followButton.titleLabel?.textColor = .white
            cell.followButton.backgroundColor = .systemOrange
        } else {
            cell.followButton.titleLabel?.textColor = .systemOrange
            cell.followButton.backgroundColor = .white
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc =  storyboard.instantiateViewController(withIdentifier: "ClientsInfoVC") as! ClientsInfoViewController
        
        if filteredUsers.isEmpty {
            var uids1 = [String]()
            let usersList = users.sorted { (user1, user2) -> Bool in
                uids1.append(user1.uid)
                uids1.append(user2.uid)
                return user1.uid > user2.uid
            }
            let usersInfoList = usersInfo.sorted { (userInfo1, userInfo2) -> Bool in
                if uids1.contains(userInfo1.uid) && uids1.contains(userInfo2.uid) {
                    return userInfo1.uid > userInfo2.uid
                } else {
                    return false
                }
            }
            vc.user = usersList[indexPath.row]
            vc.userInfo = usersInfoList[indexPath.row]
            vc.checkIfAdmin(isAdmin: false)
        } else {
            var uids1 = [String]()
            let usersList = filteredUsers.sorted { (user1, user2) -> Bool in
                uids1.append(user1.uid)
                uids1.append(user2.uid)
                return user1.uid > user2.uid
            }
            let usersInfoList = filteredUsersInfo.sorted { (userInfo1, userInfo2) -> Bool in
                if uids1.contains(userInfo1.uid) && uids1.contains(userInfo2.uid) {
                    return userInfo1.uid > userInfo2.uid
                } else {
                    return false
                }
            }
            vc.user = usersList[indexPath.row]
            vc.userInfo = usersInfoList[indexPath.row]
            vc.checkIfAdmin(isAdmin: false)
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func configure(cell: FindTrainerCell, atIndexPath indexPath: IndexPath) {
        if filteredUsers.isEmpty {
            var uids1 = [String]()
            let usersList = users.sorted { (user1, user2) -> Bool in
                uids1.append(user1.uid)
                uids1.append(user2.uid)
                return user1.uid > user2.uid
            }
            let user = usersList[indexPath.row]
            cell.userNameLabel.text = user.full_name
            cell.followButton.isSelected = user.isFollowed
            
            cell.profilePic.layer.cornerRadius = cell.profilePic.frame.size.width / 2
            cell.profilePic.clipsToBounds = true
            cell.profilePic.contentMode = .scaleAspectFill
            if user.profile_picture != "" {
                cell.profilePic.sd_setImage(with: URL(string: user.profile_picture), completed: nil)
            } else {
                cell.profilePic.image = self.avatarImage.setUsername(user.full_name).build()?.roundedImage
            }
        } else {
            var uids1 = [String]()
            let usersList = filteredUsers.sorted { (user1, user2) -> Bool in
                uids1.append(user1.uid)
                uids1.append(user2.uid)
                return user1.uid > user2.uid
            }
            let user = usersList[indexPath.row]
            cell.userNameLabel.text = user.full_name
            cell.followButton.isSelected = user.isFollowed
            
            cell.profilePic.layer.cornerRadius = cell.profilePic.frame.size.width / 2
            cell.profilePic.clipsToBounds = true
            cell.profilePic.contentMode = .scaleAspectFill
            if user.profile_picture != "" {
                cell.profilePic.sd_setImage(with: URL(string: user.profile_picture), completed: nil)
            } else {
                cell.profilePic.image = self.avatarImage.setUsername(user.full_name).build()?.roundedImage
            }
        }
    }
}
extension FindTrainerViewController: FindTrainerCellDelegate {
    func didTapFollowButton(_ followButton: UIButton, on cell: FindTrainerCell) {
        guard let indexPath = self.tableView.indexPath(for: cell) else { return }
        
        followButton.isUserInteractionEnabled = false
        let follower = self.users[indexPath.row]
        
        FollowService.setIsFollowing(!follower.isFollowed, fromCurrentUserTo: follower) { (success) in
            defer {
                followButton.isUserInteractionEnabled = true
            }
            guard success else { return }
        }
        self.users[indexPath.row].isFollowed = !self.users[indexPath.row].isFollowed
        self.tableView.reloadRows(at: [indexPath], with: .none)
        self.delegate?.didTapFollowButton()
    }
}
extension FindTrainerViewController: UISearchResultsUpdating {
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
        print(filteredUsers)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isFiltered = false
    }
}
