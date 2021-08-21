//
//  LoginViewController.swift
//  Fitty
//
//  Created by Filip Popovic
//

import UIKit
import Firebase
import FBSDKLoginKit
import SwiftyJSON
import SwiftUI

typealias FIRUser = FirebaseAuth.User
class LoginFormViewController: UIViewController {
    
    @IBOutlet weak var imageStackView: UIView!
    @IBOutlet weak var trainerStackView: UIStackView!
    @IBOutlet weak var trainerLabel: UILabel!
    @IBOutlet weak var trainerButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginRegisterSwitchControl: UISegmentedControl!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var fullNameStackView: UIStackView!
    @IBOutlet weak var loginStackView: UIStackView!
    @IBOutlet  var facebookButton: UIButton!
    
    let db = Firestore.firestore()
    var dbData = User.userInstance
    var dbDataInfo = UserInfo.userInfoInstance
    let firbaseService = FirebaseService()
    let defaults = UserDefaults.standard
    var newUser: Bool = false
    var isSelected: Bool = false
    
    private var newLoginView: UIStackView = {
        let loginView = UIStackView(frame: CGRect(x: 57, y: 0, width: 300, height: 429))
        return loginView
    }()
    
    private let newImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 224, height: 174))
        imageView.image = UIImage(named: "fittyLogo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        isLoggedIn()
        isLoggedInFB()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addRoundedButton()
        loginRegisterSwitchControl.addUnderlineForSelectedSegment()
        changeInterface(loginRegisterSwitchControl.selectedSegmentIndex)
        addImageView()
        self.animateImageView()
        self.animateLoginView()
    }
    
    private func addImageView() {
        newLoginView = loginStackView
        view.addSubview(newLoginView)
        view.addSubview(newImageView)
        loginStackView.isHidden = true
        imageStackView.isHidden = true
        trainerStackView.isHidden = true
        fullNameStackView.isHidden = true
        self.newImageView.center = self.view.center
        self.newLoginView.center = self.loginStackView.center
        self.newLoginView.frame = CGRect(x: 57, y: self.view.frame.size.height, width: 300, height: 429)
    }
    
    private func animateImageView() {
        UIView.animate(withDuration: 1, delay: 0.5) {
            self.newImageView.frame = CGRect(x: (self.view.frame.size.width-224) / 2, y: 52, width: 224, height: 174)
            self.newImageView.alpha = 1
        } completion: { (done) in
            if done {
                self.newImageView.isHidden = true
                self.imageStackView.isHidden = false
            }
        }
    }
    
    private func animateLoginView() {
        UIView.animate(withDuration: 1, delay: 1.5, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: [.allowAnimatedContent, .allowUserInteraction, .curveEaseInOut]) {
            self.newLoginView.frame = CGRect(x: 57, y: 244, width: 300, height: 429)
            self.loginStackView = self.newLoginView
            self.newLoginView.isHidden = true
            self.loginStackView.isHidden = false
        }
    }
    
    func isLoggedIn(){
        if defaults.bool(forKey: Constants.UserDefaults.isLoggedIn) == true {
            performSegue(withIdentifier: Constants.SegueTo.loginToMain, sender: self)
        }
    }
    
    func hasAlreadyLaunched() {
        if defaults.bool(forKey: Constants.UserDefaults.hasAlreadyLaunched) == true {
            performSegue(withIdentifier: Constants.SegueTo.loginToMain, sender: self)
            defaults.set(true, forKey: Constants.UserDefaults.hasAlreadyLaunched)
        } else {
            performSegue(withIdentifier: Constants.SegueTo.loginToBMI, sender: self)
            defaults.set(true, forKey: Constants.UserDefaults.hasAlreadyLaunched)
        }
    }
    
    func changeInterface(_ index: Int) {
        loginButton.removeTarget(nil, action: nil, for: .allEvents)
        switch index {
        case 0:
            fullNameTextField.isHidden = true
            fullNameStackView.isHidden = true
            emailTextField.delegate = self
            passwordTextField.delegate = self
            loginButton.layer.cornerRadius = 20
            loginButton.setTitle("Log in", for: .normal)
            loginButton.addTarget(self, action: #selector(login), for: .touchUpInside)
            trainerStackView.isHidden = true
        case 1:
            fullNameTextField.isHidden = false
            fullNameStackView.isHidden = false
            fullNameTextField.delegate = self
            emailTextField.delegate = self
            passwordTextField.delegate = self
            loginButton.layer.cornerRadius = 20
            loginButton.setTitle("Sign up", for: .normal)
            loginButton.addTarget(self, action: #selector(signUp), for: .touchUpInside)
            trainerStackView.isHidden = false
            trainerButton.layer.borderWidth = 1
            let myColor = UIColor.lightGray
            trainerButton.layer.borderColor = myColor.cgColor
        default:
            break
        }
    }
    
    @IBAction func loginRegisterChanged(_ sender: UISegmentedControl) {
        changeInterface(loginRegisterSwitchControl.selectedSegmentIndex)
        loginRegisterSwitchControl.changeUnderlinePosition()
    }
    
    @IBAction func trainerButtonPressed(_ sender: UIButton) {
        isSelected.toggle()
        if isSelected == true {
            self.trainerButton.setBackgroundImage(#imageLiteral(resourceName: "checkmark"), for: .normal)
        } else {
            self.trainerButton.setBackgroundImage(.none, for: .normal)
        }
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
    }
    
    @objc func login(){
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                if let e = error {
                    ErrorAlert.presentAlert(error: e)
                    self.present(ErrorAlert.alert!, animated: true, completion: nil)
                } else {
                    self.defaults.set(true, forKey: Constants.UserDefaults.isLoggedIn)
                    self.performSegue(withIdentifier: Constants.SegueTo.loginToMain, sender: self)
                    self.defaults.set(true, forKey: Constants.UserDefaults.hasAlreadyLaunched)
                }
            }
        }
    }
    
    @objc func signUp(){
        if let email = emailTextField.text, let password = passwordTextField.text, let fullName = fullNameTextField.text {
            if fullName != ""{
                Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                    if let e = error {
                        ErrorAlert.presentAlert(error: e)
                        self.present(ErrorAlert.alert!, animated: true, completion: nil)
                    } else {
                        self.db.collection("users").addDocument(data: ["full_name" : self.fullNameTextField.text!, "uid" : result!.user.uid, "profile_picture" : "", "email" : self.emailTextField.text!, "admin": self.isSelected]) { (error) in
                            if let err = error {
                                ErrorAlert.presentAlert(error: err)
                                self.present(ErrorAlert.alert!, animated: true, completion: nil)
                            }
                            guard let newUserStatus = result?.additionalUserInfo?.isNewUser else {return}
                            self.newUser = newUserStatus
                        }
                        self.defaults.set(true, forKey: Constants.UserDefaults.isLoggedIn)
                        self.performSegue(withIdentifier: Constants.SegueTo.loginToBMI, sender: self)
                    }
                }
            } else {
                ErrorAlert.presentAlertwithString(string: "A full name must be provided.")
                self.present(ErrorAlert.alert!, animated: true, completion: nil)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.db.collection("users").addSnapshotListener { (querySnapshot, error) in
            if let e = error {
                print(e)
            } else {
                if let user = User(snapshot: querySnapshot){
                    print("Welcome \(user.full_name)")
                    self.dbData = user
                } else {
                    print("New User!")
                }
                self.firbaseService.dbData = self.dbData
                User.setCurrent(self.dbData)
            }
        }
        self.db.collection("users_info").addSnapshotListener { (querySnapshot, error) in
            if let e = error {
                print(e)
            } else {
                if let userInfo = UserInfo(snapshot: querySnapshot) {
                    print("User Info \(userInfo)")
                    self.dbDataInfo = userInfo
                } else {
                    print("New User Info!")
                }
                self.firbaseService.dbDataInfo = self.dbDataInfo
                UserInfo.setCurrent(self.dbDataInfo)
            }
        }
    }
    
}

extension LoginFormViewController: LoginButtonDelegate {
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        let token = result?.token?.tokenString
        let request = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields" : "name,email,picture{url}"], tokenString: token, version: nil, httpMethod: .get)
        let requestImage = FBSDKLoginKit.GraphRequest(graphPath: "me/picture?redirect=0&height=800&type=normal&width=800", httpMethod: .get)
        var name: String = ""
        var profilePictureURL: String = ""
        var email: String = ""
        
        request.start { (connection, result, error) in
            let json = JSON(result as Any)
            name = json["name"].stringValue
            email = json["email"].stringValue
        }
        requestImage.start { (connection, result, error) in
            let json = JSON(result as Any)
            profilePictureURL = json["data"]["url"].stringValue
        }
        if let error = error {
            print(error.localizedDescription)
            return
        }
        let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current?.tokenString ?? "")
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print("Facebook authentication with Firebase error: ", error)
                return
            }
            guard let newUserStatus = authResult?.additionalUserInfo?.isNewUser else {return}
            self.newUser = newUserStatus
            if newUserStatus == true{
                self.db.collection("users").addDocument(data: ["uid":authResult?.user.uid ?? "", "full_name":name, "profile_picture":profilePictureURL, "email":email, "admin":false])
                URLSession.shared.dataTask(with: URL(string: profilePictureURL)!) { (data, response, error) in
                    if let err = error {
                        print(err)
                    }
                    guard let dataNew = data else { return }
                    guard let profilePicture = UIImage(data: dataNew) else {return}
                    self.firbaseService.setDataToStorage(image: profilePicture, folder: "profile_picture", fileExtension: ".png")
                }.resume()
                self.defaults.set(true, forKey: Constants.UserDefaults.isLoggedInFB)
                self.performSegue(withIdentifier: Constants.SegueTo.loginToBMI, sender: self)
            }
            else{
                self.defaults.set(true, forKey: Constants.UserDefaults.isLoggedInFB)
                self.hasAlreadyLaunched()
            }
            print("Login success!")
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
    }
    
    @IBAction func facebookButtonPressed(_ sender: UIButton) {
        facebookButton = FBLoginButton()
        (facebookButton as! FBLoginButton).delegate = self
        (facebookButton as! FBLoginButton).permissions = [ "public_profile", "email" ]
        facebookButton.isHidden = true
        self.loginStackView.addSubview(loginButton)
        facebookButton.sendActions(for: UIControl.Event.touchUpInside)
    }
    
    func addRoundedButton() {
        facebookButton.setTitle("Continue with Facebook", for: .normal)
        facebookButton.setImage(UIImage(named: "f_logo_RGB-White_1024"), for: .normal)
        facebookButton.alignImageLeft()
        facebookButton.layer.cornerRadius = 20
        self.loginStackView.addSubview(loginButton)
    }
    
    func isLoggedInFB(){
        if defaults.bool(forKey: Constants.UserDefaults.isLoggedInFB) == true {
            if let token = AccessToken.current, !token.isExpired {
                performSegue(withIdentifier: Constants.SegueTo.loginToMain, sender: self)
            }
        }
    }
}

extension LoginFormViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
