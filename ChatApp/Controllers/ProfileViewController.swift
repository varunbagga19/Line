//
//  ProfileViewController.swift
//  ChatApp
//
//  Created by Varun Bagga on 30/08/22.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FBSDKLoginKit
class ProfileViewController: UIViewController {

    
    let data = ["Log out"]
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
    }

    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        
        let firebaseAuth = Auth.auth()
        
        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "LogOut", style: .destructive, handler: { _ in
            
            
            // Log Out FaceBook
            
            FBSDKLoginKit.LoginManager().logOut()
            
            do {
              try firebaseAuth.signOut()
                print("signout")
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyBoard.instantiateViewController(withIdentifier: "NavigationController") as! UINavigationController
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            } catch let signOutError as NSError {
              print("Error signing out: %@", signOutError)
            }
        }))
        present(alert, animated: true)
    }
}

extension ProfileViewController : UITableViewDelegate,UITableViewDataSource {
     
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textAlignment = .center
        
        cell.textLabel?.textColor = .red
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! LogInViewController
        destinationVC.hidesBottomBarWhenPushed = true
    }
    
}
