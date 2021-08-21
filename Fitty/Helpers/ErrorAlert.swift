//
//  ErrorAlert.swift
//  Fitty
//
//  Created by Filip Popovic
//

import UIKit

class ErrorAlert: UIViewController {
    
    static var alert :UIAlertController?
    
    static func presentAlert(error: Error?) {
        alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        if let a = alert{
            a.addAction(action)
        }
    }
    
    static func presentAlertwithString(string: String?) {
        alert = UIAlertController(title: "Error", message: string, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        if let a = alert{
            a.addAction(action)
        }
    }
    
    static func alertView(msg: String, completion: @escaping (String) -> ()){
        
        let alert = UIAlertController(title: "Message", message: msg, preferredStyle: .alert)
        
            alert.addTextField { (txt) in
                txt.placeholder = msg.contains("Verification") ? "123456" : ""
            }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: msg.contains("Verification") ? "Verify" : "Update", style: .default, handler: { _ in
            let code = alert.textFields![0].text ?? ""
            if code == "" {
                UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
                return
            }
            completion(code)
        }))
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
    }
    
}
