//
//  LogInViewController.swift
//  ChatApp
//
//  Created by Varun Bagga on 30/08/22.
//

import UIKit

class LogInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        guard let email = emailTextField.text ,let password = passwordTextField.text,!email.isEmpty,!password.isEmpty,password.count>=6 else{
            alertUserLoginError()
            return
        }
      // Firebase login
        
    }
    
    func alertUserLoginError(){
        let alert  = UIAlertController(title: "Woops",
                                       message: "Please Enter all information to login",
                                       preferredStyle: .alert)
        let action  = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true)
    }
}
//MARK: - Textfield delegate Methods

extension LogInViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // firebase login
        print("processing")
        return true
    }
}
