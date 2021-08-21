//
//  ChatViewController.swift
//  Fitty
//
//  Created by Filip Popovic
//

import UIKit
import Firebase

protocol FirstViewControllerDelegate: AnyObject {
    func didTapFollowButton()
}

class FirstViewController: UIViewController {
    
    @IBOutlet var trainingReportView: TrainingReport!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var chatButton: UIBarButtonItem!
    let visualEffectView = UIVisualEffectView()
    var effect = UIVisualEffect()
    let loader = Loader()
    var hasTheFunctionCalled : Bool = false {
        didSet{
            hasTheFunctionCalled = true
        }
    }
    var users = [User]()
    var usersInfo = [UserInfo]()
    var clients = [User]()
    var clientsInfo = [UserInfo]()
    var isAdmin = false
    var dataCell = FirstViewCell()
    weak var delegate: FirstViewControllerDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            FollowService.adminsList { (users) in
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
        if !hasTheFunctionCalled{
            loader.startLoader(vc: self)
            tabBarController!.tabBar.isHidden = true
        }
        hasTheFunctionCalled = true
        Firestore.firestore().collection("users").getDocuments { (querySnap, error) in
            if let user = User(snapshot: querySnap) {
                if let tabBarController = self.tabBarController {
                    if user.admin == true {
                        self.isAdmin = true
                        let nc1 = tabBarController.viewControllers![1] as? UINavigationController
                        if nc1?.topViewController is FindTrainerViewController {
                            tabBarController.viewControllers?.remove(at: 1)
                        }
                        let nc2 = tabBarController.viewControllers![2] as? UINavigationController
                        if nc2?.topViewController is TrainingPlanListViewController {
                            tabBarController.viewControllers?.remove(at: 2)
                        }
                        let nc3 = tabBarController.viewControllers![2] as? UINavigationController
                        if nc3?.topViewController is NutritionPlanListViewController {
                            tabBarController.viewControllers?.remove(at: 2)
                        }
                    } else {
                        let nc1 = tabBarController.viewControllers![1] as? UINavigationController
                        if nc1?.topViewController is FindTrainerViewController {
                            let vc = nc1?.topViewController as! FindTrainerViewController
                            vc.delegate = self
                        }
                        let nc2 = tabBarController.viewControllers![2] as? UINavigationController
                        if nc2?.topViewController is ClientsViewController {
                            tabBarController.viewControllers?.remove(at: 2)
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.loader.endLoader()
                        tabBarController.tabBar.isHidden = false
                    }
                }
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.global(qos: .background).async {
            FollowService.adminClientsList { (users) in
                self.clients = users
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } completionUserInfo: { (usersInfo) in
                self.clientsInfo = usersInfo
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.trainingReportView.delegate = self
        tableView.rowHeight = 180
        navigationController?.navigationBar.tintColor = .systemOrange
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.systemOrange]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        let imageView = UIImageView(image: UIImage(named: "fittyLogo.png"))
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        imageView.frame = titleView.bounds
        titleView.addSubview(imageView)
        self.navigationItem.titleView = titleView
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.SegueTo.mainToChat {
            let vc = segue.destination as! ChatListViewController
            if !self.users.isEmpty {
                vc.users = self.users
            } else {
                vc.users = self.clients
            }
        }
    }
    
    @IBAction func chatButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: Constants.SegueTo.mainToChat, sender: self)
    }
    
}
extension FirstViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.isAdmin == false {
            return 3
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.firstViewCell, for: indexPath) as! FirstViewCell
        let cell2 = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.firstPlanCell, for: indexPath) as! FirstPlanCell
        dataCell = cell
        var uids1 = [String]()
        var uids2 = [String]()
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
        let clientsList = clients.sorted { (client1, client2) -> Bool in
            uids2.append(client1.uid)
            uids2.append(client2.uid)
            return client1.uid > client2.uid
        }
        let clientsInfolist = clientsInfo.sorted { (clientInfo1, clientInfo2) -> Bool in
            if uids2.contains(clientInfo1.uid) && uids2.contains(clientInfo2.uid) {
                return clientInfo1.uid > clientInfo2.uid
            } else {
                return false
            }
        }
        if indexPath.section == 0 {
            tableView.rowHeight = 120
            cell.layer.bounds.size.height = 90
            cell.users = usersList
            cell.usersInfo = usersInfoList
            cell.clients = clientsList
            cell.clientsInfo = clientsInfolist
            cell.isAdmin = self.isAdmin
            cell.configureCell(cellNum: 1)
            return cell
        } else if indexPath.section == 1 && self.isAdmin == false {
            tableView.rowHeight = 180
            cell2.layer.bounds.size.height = 180
            cell2.planNameLabel.text = "Training Plan"
            cell2.planNameLabel.tag = 11
            cell2.setLabelIcons("training")
            return cell2
        } else if indexPath.section == 2 && self.isAdmin == false {
            tableView.rowHeight = 180
            cell2.layer.bounds.size.height = 180
            cell2.planNameLabel.text = "Nutrition Plan"
            cell2.planNameLabel.tag = 11
            cell2.setLabelIcons("nutrition")
            return cell2
        } else {
            tableView.rowHeight = 180
            cell2.layer.bounds.size.height = 180
            cell2.planNameLabel.text = "Training Report"
            cell2.planNameLabel.tag = 11
            cell2.setLabelIcons("report")
            return cell2
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && isAdmin == false {
            self.tabBarController!.selectedIndex = 2
        }
        else if indexPath.section == 2 && isAdmin == false {
            self.tabBarController!.selectedIndex = 3
        }
        else if indexPath.section == 1 && isAdmin == true {
            addView()
        }
    }
    func addView(){
        let clientsList = clients.sorted { (client1, client2) -> Bool in
            return client1.uid > client2.uid
        }
        trainingReportView.clients = clientsList
        trainingReportView.clientsInfo = self.clientsInfo
        
        visualEffectView.effect = UIBlurEffect(style: .dark)
        effect = visualEffectView.effect!
        visualEffectView.frame = self.view.bounds
        self.view.addSubview(visualEffectView)
        
        self.view.addSubview(trainingReportView)
        trainingReportView.center = self.view.center
        
        trainingReportView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        trainingReportView.alpha = 0
        
        UIView.animate(withDuration: 0.4) {
            self.visualEffectView.effect = self.effect
            self.trainingReportView.alpha = 1
            self.trainingReportView.transform = CGAffineTransform.identity
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 30
        } else {
            return 0
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UITableViewHeaderFooterView()
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        view.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = 27
        view.addSubview(button)
        
        if section == 0 && isAdmin == false {
            button.setTitle("Find your trainer", for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize:12)
            button.setTitleColor(.systemOrange, for: .normal)
            button.backgroundColor = .white
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.systemOrange.cgColor
            
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
            button.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            
            button.layer.cornerRadius = button.frame.height / 2
        } else if section == 0 && isAdmin == true {
            button.setTitle("Find your client", for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize:12)
            button.setTitleColor(.systemOrange, for: .normal)
            button.backgroundColor = .white
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.systemOrange.cgColor
            
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
            button.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            
            button.layer.cornerRadius = button.frame.height / 2
        }
        button.addTarget(self, action: #selector(handleExpandClose), for: .touchUpInside)
        return view
    }
    
    @objc func handleExpandClose(button: UIButton){
        let vc1 =  storyboard!.instantiateViewController(withIdentifier: "FindTrainerVC") as! FindTrainerViewController
        vc1.delegate = self
        let vc2 =  storyboard!.instantiateViewController(withIdentifier: "ClientsVC") as! ClientsViewController
        
        if isAdmin == true {
            // self.tabBarController!.selectedIndex = 1
            self.navigationController?.pushViewController(vc2, animated: true)
        } else {
            //self.tabBarController!.selectedIndex = 1
            self.navigationController?.pushViewController(vc1, animated: true)
        }
    }
}
extension FirstViewController: CloseViewTapped {
    func close(view: UIView) {
        visualEffectView.effect = nil
        visualEffectView.removeFromSuperview()
    }
}
extension FirstViewController: FindTrainerViewControllerDelegate {
    func didTapFollowButton() {
        DispatchQueue.main.async {
            FollowService.adminsList { (users) in
                self.users = users
                self.users.sort { (user1, user2) -> Bool in
                    return user1.uid > user2.uid
                }
                self.dataCell.users = self.users
                self.delegate?.didTapFollowButton()
            } completionUserInfo: { (usersInfo) in
                self.usersInfo = usersInfo
            }
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
