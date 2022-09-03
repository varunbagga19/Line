//
//  RegisterViewController.swift
//  ChatApp
//
//  Created by Varun Bagga on 30/08/22.
//

import UIKit

class RegisterViewController: UIViewController {

    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var userImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func didTapImageView(_ sender: UITapGestureRecognizer) {
        
        print("Image is tappped")
        
    }
    @IBAction func singupButtonPressed(_ sender: Any) {
        
        guard let firstName = firstNameTextField.text,
              let lastName = lastNameTextField.text,
              let email = emailTextField.text ,
              let password = passwordTextField.text,
              !firstName.isEmpty,
              !lastName.isEmpty,
              !email.isEmpty,
              !password.isEmpty,
              password.count>=6 else{
            alertUserRegisterError()
            return
        }
      // Firebase Register
    }
    
    func alertUserRegisterError(){
        
        let alert = UIAlertController(title: "Woops", message: "Enter all the text Field to create a new Account ", preferredStyle: .alert)
        let action = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true)
    }
}

//MARK: - Textfield delegate Methods

extension RegisterViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // firebase register
        print("processing")
        return true
    }
}

