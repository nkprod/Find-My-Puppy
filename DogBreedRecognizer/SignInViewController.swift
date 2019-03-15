//
//  SignInViewController.swift
//  DogBreedRecognizer
//
//  Created by Nurlybek on 3/14/19.
//  Copyright © 2019 Nurlybek. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
class SignInViewController: UIViewController{
    
    //Outlets
    @IBOutlet weak var emailOutlet: UITextField!
    @IBOutlet weak var passwordOutlet: UITextField!
    //Variables
    //Constants
    let userDefaults = UserDefaults.standard
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        if userDefaults.bool(forKey: "usersignedin") {
            performSegue(withIdentifier: "LogInToList", sender: self)
        }
    }
    
    func createUser(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if error == nil {
                //User has been created
                //Sign In user
                self.signInUser(email: email, password: password)
            } else {
                print(error?.localizedDescription as Any)
            }
        }
    }
    
    func signInUser(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error == nil {
                //User has signed in
                self.userDefaults.set(true, forKey: "usersignedin")
                self.userDefaults.synchronize()
                self.performSegue(withIdentifier: "LogInToList", sender: self)
            } else if error?._code == AuthErrorCode.userNotFound.rawValue {
                self.createUser(email: email, password: password)
            } else {
                print(error?.localizedDescription as Any)
            }
        }
    }
    
    @IBAction func signInPressed(_ sender: Any) {
        guard let email = emailOutlet.text, !email.isEmpty else {return}
        guard let password = passwordOutlet.text, !password.isEmpty else {return}
        self.signInUser(email: email, password: password)
    }
    
}
