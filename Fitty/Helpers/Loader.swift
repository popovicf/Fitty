//
//  Loader.swift
//  Fitty
//
//  Created by Filip Popovic
//

import UIKit
import NVActivityIndicatorView

class Loader {
    
    var activityIndicatorView: NVActivityIndicatorView? = nil
    var blurEffect = UIBlurEffect()
    var blurEffectTab = UIBlurEffect()
    var blurEffectNav = UIBlurEffect()
    var blurEffectView = UIVisualEffectView()
    var blurEffectViewTab = UIVisualEffectView()
    var blurEffectViewNav = UIVisualEffectView()
    let view = UIView()
    
    func startLoader(vc: UIViewController){
        activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: vc.view.center.x - 75, y: vc.view.center.y - 75, width: 150, height: 150), type: .ballPulseSync, color: .systemOrange, padding: .none)
        blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        blurEffectTab = UIBlurEffect(style: UIBlurEffect.Style.dark)
        blurEffectNav = UIBlurEffect(style: UIBlurEffect.Style.dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectViewTab = UIVisualEffectView(effect: blurEffectTab)
        blurEffectViewNav = UIVisualEffectView(effect: blurEffectNav)
        blurEffectView.frame = vc.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectViewTab.frame = (vc.tabBarController?.tabBar.bounds) ?? CGRect(x: 0, y: 0, width: 0, height: 0)
        blurEffectViewTab.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectViewNav.frame = (vc.navigationController?.navigationBar.bounds) ?? CGRect(x: 0, y: 0, width: 0, height: 0)
        blurEffectViewNav.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        blurEffectView.alpha = 1
//        blurEffectViewTab.alpha = 1
//        blurEffectViewNav.alpha = 1
        vc.view.addSubview(blurEffectView)
//        vc.tabBarController?.tabBar.addSubview(blurEffectViewTab)
//        vc.navigationController?.navigationBar.addSubview(blurEffectViewNav)
        view.frame = vc.view.bounds
        view.backgroundColor = .white
        vc.view.addSubview(view)
        vc.view.addSubview(activityIndicatorView!)
        activityIndicatorView!.startAnimating()
    }

    func endLoader(){
        activityIndicatorView?.stopAnimating()
        view.removeFromSuperview()
        activityIndicatorView?.removeFromSuperview()
        blurEffectView.removeFromSuperview()
        blurEffectViewTab.removeFromSuperview()
        blurEffectViewNav.removeFromSuperview()
    }
    
}
