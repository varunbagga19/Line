//
//  RegisterViewController.swift
//  ChatApp
//
//  Created by Varun Bagga on 30/08/22.
//

import UIKit
import FirebaseAuth
import JGProgressHUD
class RegisterViewController: UIViewController {

    private let spinner = JGProgressHUD(style: .dark)

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
//        navigationItem.hidesBackButton = true
        passwordTextField.delegate = self
        userImage.layer.masksToBounds = true
        userImage.layer.borderWidth = 2
        userImage.layer.borderColor = UIColor.lightGray.cgColor
        userImage.layer.cornerRadius = userImage.bounds.width/2
        // Do any additional setup after loading the view.
    }
    
    @IBAction func didTapImageView(_ sender: UITapGestureRecognizer) {
        presentPhotoActionSheet()
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
        spinner.show(in: view)
      // Firebase Register
        DatabaseManager.shared.userExists(with: email) {[weak self] exists in
            guard let strongSelf = self else{
                return
            }
            DispatchQueue.main.async {
                self?.spinner.dismiss(animated: true)
            }
            guard !exists else{
                strongSelf.alertUserRegisterError(message: "USER ALREADY EXIST")
                return
            }
            strongSelf.auth(firstName: firstName, lastName: lastName, email: email, password: password)
        }
        
       
        
        
    }
    func auth(firstName:String,lastName:String,email:String,password:String){
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) {  AuthDataResult, Error in
           
            if let e = Error{
                print("Error in registering \(e)")
            }else{
                print("user registered")
                let chatUser = ChatAppUser(firstName: firstName,
                                          lastName: lastName, emailAddress: email)
                DatabaseManager.shared.insertUser(with: chatUser) { done in
                    if done{
                    //upload image
                        guard let image = self.userImage.image,
                              let data = image.pngData() else{
                            return
                        }
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
                }
                self.navigationController?.dismiss(animated: true)
            }
        }
    }
    func alertUserRegisterError(message:String = "Enter all the text Field to create a new Account " ){
        
        let alert = UIAlertController(title: "Woops", message: message, preferredStyle: .alert)
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

//MARK: - ACCess of photos
extension RegisterViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    
    func presentPhotoActionSheet(){
        let actionSheet = UIAlertController(title: "Profile Picture", message: "How would you like to select profile photo", preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let action2 = UIAlertAction(title: "Take photo", style: .default) {[weak self] _ in
            self?.presentCamera()
        }
        let action3 = UIAlertAction(title: "Choose photo", style: .default) { [weak self] _ in
            self?.presentPhotoPicker()
        }
        actionSheet.addAction(action1)
        actionSheet.addAction(action2)
        actionSheet.addAction(action3)
        
        present(actionSheet, animated: true)
    }
    
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc,animated: true)
        
    }
    func presentPhotoPicker(){
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc,animated: true)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true,completion: nil)
        print("info  \(info)")
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage]as? UIImage else{
            return
        }
        self.userImage.image = selectedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true,completion: nil)
    }
}

