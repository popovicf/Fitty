//
//  FirstViewCell.swift
//  Fitty
//
//  Created by Filip Popovic
//

import UIKit
import LetterAvatarKit
import Firebase

class FirstViewCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var numberOfCell = 0
    var users = [User]()
    var usersInfo = [UserInfo]()
    var clients = [User]()
    var clientsInfo = [UserInfo]()
    var isAdmin = false
    var selectedUser: User?
    var selectedUserInfo: UserInfo?
    var selectedClient: User?
    var selectedClientInfo: UserInfo?
    var dataCell = FirstTrainerCell()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.delegate = self
        collectionView.dataSource = self
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell(cellNum: Int){
        numberOfCell = cellNum
        let flowLayout = UICollectionViewFlowLayout()
        
        if numberOfCell == 1 {
            flowLayout.itemSize = CGSize(width: self.contentView.bounds.size.width / 3, height: 90)
        } else if numberOfCell == 2 {
            flowLayout.itemSize =  CGSize(width: self.contentView.bounds.size.width - 50, height: 160)
        } else if numberOfCell == 3 {
            flowLayout.itemSize =  CGSize(width: self.contentView.bounds.size.width - 50, height: 160)
        }
        
        flowLayout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        flowLayout.scrollDirection = .horizontal
        self.collectionView.setCollectionViewLayout(flowLayout, animated: false)
    }
}
extension FirstViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isAdmin == false {
            return users.count
        } else {
            return clients.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.Cell.firstTrainerCell, for: indexPath) as! FirstTrainerCell
        for child in parentContainerViewController!.children {
            for ch in child.children where ch.restorationIdentifier == "FirstVC" {
                (ch as! FirstViewController).delegate = self
            }
        }
        dataCell = cell
        if isAdmin == false {
            cell.trainerName.text = users[indexPath.row].full_name
            cell.setUI(user: self.users[indexPath.row])
            return cell
        } else {
            cell.trainerName.text = clients[indexPath.row].full_name
            cell.setUI(user: self.clients[indexPath.row])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc =  storyboard.instantiateViewController(withIdentifier: "ClientsInfoVC") as! ClientsInfoViewController
        
        for child in parentContainerViewController!.children {
            for ch in child.children where ch.restorationIdentifier == "FirstVC" {
                if isAdmin == false {
                    selectedUser = users[indexPath.row]
                    selectedUserInfo = usersInfo[indexPath.row]
                    vc.user = selectedUser!
                    vc.userInfo = selectedUserInfo!
                    vc.checkIfAdmin(isAdmin: false)
                    ch.navigationController?.pushViewController(vc, animated: true)
                } else {
                    selectedClient = clients[indexPath.row]
                    selectedClientInfo = clientsInfo[indexPath.row]
                    vc.user = selectedClient!
                    vc.userInfo = selectedClientInfo!
                    vc.checkIfAdmin(isAdmin: true)
                    ch.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
}

extension FirstViewCell: FirstViewControllerDelegate {
    func didTapFollowButton() {
        DispatchQueue.main.async {
            FollowService.adminsList { (users) in
                self.users = users
                
                DispatchQueue.main.async {
                    self.users.sort { (user1, user2) -> Bool in
                        return user1.uid > user2.uid
                    }
                    self.collectionView.reloadData()
                }
            } completionUserInfo: { (usersInfo) in
                self.usersInfo = usersInfo
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }
}



