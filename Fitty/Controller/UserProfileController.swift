//
//  MainViewController.swift
//  Fitty
//
//  Created by Filip Popovic
//

import UIKit
import Firebase
import FirebaseStorage
import FBSDKLoginKit
import SwiftUI

class UserProfileController: UIViewController, ObservableObject {
    
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var logOut: UIButton!
    @IBOutlet weak var bmiButton: UIButton!
    @IBOutlet weak var profilePictureImageView: UIImageView!
    let profileView = UIHostingController(rootView: UserProfileView())
    let defaults = UserDefaults.standard
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addChild(profileView)
        view.addSubview(profileView.view)
        setupConstraints()
    }
    
    fileprivate func setupConstraints() {
        profileView.view.translatesAutoresizingMaskIntoConstraints = false
        profileView.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        profileView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        profileView.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        profileView.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
    
    @IBAction func logOutPressed(_ sender: UIButton) {
        self.defaults.set(false, forKey: Constants.UserDefaults.isLoggedIn)
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        LoginManager().logOut()
    }
    
    func logout(){
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func bmiButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: Constants.SegueTo.mainToBMI, sender: self)
    }
    
}

