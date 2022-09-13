//
//  LogInViewController.swift
//  ChatApp
//
//  Created by Varun Bagga on 30/08/22.
//

import UIKit
import FirebaseAuth
import AuthenticationServices
import FBSDKLoginKit
import JGProgressHUD
class LogInViewController: UIViewController{
    
    private let spinner = JGProgressHUD(style: .dark)
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var faceBookButton: FBLoginButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        emailTextField.delegate = self
        passwordTextField.delegate = self
        faceBookButton.permissions = ["public_profile","email"]
        faceBookButton.delegate = self
    }
    
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        guard let email = emailTextField.text ,let password = passwordTextField.text,!email.isEmpty,!password.isEmpty,password.count>=6 else{
            alertUserLoginError()
            return
        }
        // Firebase login
        spinner.show(in: view)
        login(email: email, password: password)
    }
    
    func login(email:String,password:String){
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) {  authResult, error in
            DispatchQueue.main.async {
                self.spinner.dismiss(animated: true)
            }
          
            if let e = error {
                print(e)
            }else{
                print("Logged in")
                self.navigationController?.dismiss(animated: true)
            }
        }
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
//MARK: - FaceBook LogIn Button
extension LogInViewController : LoginButtonDelegate{
    
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else{
            print("User failed to log in with facebook")
            return
        }
        //GraphRequest is used to get the data out of the user
        let faceBookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                         parameters: ["fields" : "email,first_name,last_name,picture.type(large)"],
                                                         tokenString: token,
                                                         version: nil,
                                                         httpMethod: .get)
        faceBookRequest.start { _, Result, error in
            guard let result = Result ,error == nil else{
                print("failed  to make facebook graph request")
                return
            }
            print("\(result)")
            guard let resultNew = result as? [String:Any]else{
                return
            }
            
            print(resultNew)
            
            
            guard let firstName = resultNew["first_name"] as? String,
                let lastName = resultNew["last_name"] as? String,
                let email = resultNew["email"] as? String,
                let picture = resultNew["picture"] as? [String:Any],
                let data = picture["data"] as? [String:Any],
                let pictureUrl = data["url"] as? String else {
                print("Failed to get email and name from fb result")
                return
            }
            
            DatabaseManager.shared.userExists(with: email) { exists in
                if !exists {
                    let chatUser = ChatAppUser(firstName: firstName,
                                               lastName: lastName,
                                               emailAddress: email)
                    DatabaseManager.shared.insertUser(with: chatUser) { done in
                        if done{
                            guard let url = URL(string:pictureUrl)else{
                                print("error finding url")
                                return
                            }
                            print("downloading data fron facebook")
                            
                          let task = URLSession.shared.dataTask(with: url) { data,_ ,_ in
                                print("hi im here")
                                guard let data = data else{
                                    print("failed to get data from facebook")
                                    return
                                }
                                
                                print("got  data from facebook")
                                //uploadImage
                            
                                let fileName = chatUser.profilePictureFileName
                                StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName) { result in
                                    switch result {
                                    case .success(let downloadUrl):
                                        UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                        print (downloadUrl)
                                    case .failure(let error):
                                        print("Storage manager error\(error)")
                                    }
                                }
                            }
                            print("im here part2")
                            task.resume()
                        }
                    }
                }
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            FirebaseAuth.Auth.auth().signIn(with: credential)  { AuthDataResult, Error in
                guard AuthDataResult != nil, Error == nil else{
                    if let error = Error{
                        print("FaceBook credential login failed, MFA may be needed Needed \(error)")
                    }
                    return
                }
                print("Successfully logged user in")
                self.navigationController?.dismiss(animated: true)
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("Logout")
    }
}
