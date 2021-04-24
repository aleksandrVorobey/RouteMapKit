//
//  Alerts.swift
//  Route
//
//  Created by Александр Воробей on 15.04.2021.
//

import UIKit

extension UIViewController {
    
    func alertAddAdress(title: String, placeholder: String, completionHandler: @escaping (String) -> (Void)) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        alertController.addTextField { (tf) in
            tf.placeholder = placeholder
        }
        
        let alertOk = UIAlertAction(title: "Ok", style: .default) { (_) in
            let tfText = alertController.textFields?.first
            guard let text = tfText?.text else { return }
            completionHandler(text)
        }
        let alertCancel = UIAlertAction(title: "Cancel", style: .default) { (_) in
        }

        alertController.addAction(alertOk)
        alertController.addAction(alertCancel)
        present(alertController, animated: true, completion: nil)
    }
    
    func alertError(title: String, massage: String) {
        let alertError = UIAlertController(title: title, message: massage, preferredStyle: .alert)
        let alertOk = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertError.addAction(alertOk)
        present(alertError, animated: true, completion: nil)
    }
    
}

