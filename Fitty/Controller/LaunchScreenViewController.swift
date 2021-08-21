//
//  LaunchScreenViewController.swift
//  Fitty
//
//  Created by Filip Popovic
//

import UIKit
import FBSDKLoginKit

class LaunchScreenViewController: UIViewController {
    
    let defaults = UserDefaults.standard
    
    private let imageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 224, height: 174))
        imageView.image = UIImage(named: "fittyLogo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageView)
        view.backgroundColor = .systemBackground
        //        imageView.center = view.center
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        //            self.animate()
        //        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.center = view.center
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.animate()
        }
    }
    
    private func animate() {
        UIView.animate(withDuration: 1) {
            //            let size = self.view.frame.size.width * 3
            //            let newX = size - self.view.frame.size.width
            //            let newY = self.view.frame.height - size
            //            self.imageView.frame = CGRect(x: -(newX/2), y: newY/2, width: size, height: size)
            self.imageView.frame = CGRect(x: (self.view.frame.size.width-224) / 2, y: 0, width: 224, height: 174)
            self.imageView.alpha = 0
        }
        
        UIView.animate(withDuration: 1.2) {
            self.imageView.alpha = 0
        } completion: { (done) in
            if done {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    let storyboard = UIStoryboard(name: "Main", bundle: .main)
                    let initialViewController = storyboard.instantiateViewController(withIdentifier: "LoginFormViewController")
                    initialViewController.modalTransitionStyle = .crossDissolve
                    initialViewController.modalPresentationStyle = .fullScreen
                    self.present(initialViewController, animated: true)
                }
            }
        }
        //
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        //            let storyboard = UIStoryboard(name: "Main", bundle: .main)
        //            let initialViewController = storyboard.instantiateViewController(withIdentifier: "LoginFormViewController")
        //            initialViewController.modalTransitionStyle = .crossDissolve
        //            initialViewController.modalPresentationStyle = .fullScreen
        //            self.present(initialViewController, animated: true)
        //        }
        //
    }
}
