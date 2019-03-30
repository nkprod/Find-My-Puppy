//
//  SignInViewController.swift
//  DogBreedRecognizer
//
//  Created by Nurlybek on 3/14/19.
//  Copyright © 2019 Nurlybek. All rights reserved.
//

import UIKit
import Firebase


class SignInViewController: UIViewController{
    
    //Outlets
    //Log in
    @IBOutlet weak var emailOutlet: UITextField!
    @IBOutlet weak var passwordOutlet: UITextField!
    //Register
    @IBOutlet weak var usernameSignUpOutlet: UITextField!
    @IBOutlet weak var emailSignUpOutlet: UITextField!
    @IBOutlet weak var passwordSignUpOutlet: UITextField!
    //Variables
    //Constants
    let userDefaults = UserDefaults.standard
    
    //New Sign In Trial
    
    @IBAction func signUpTapped(_ sender: Any) {
        guard let username = usernameSignUpOutlet.text, username != "" else{
            createAlert(message: "Please input a username")
            return
        }
        guard let email = emailSignUpOutlet.text, email != "" else {
            // create the alert
            createAlert(message: "Please input an email")
            return
        }
        guard let password = passwordSignUpOutlet.text, !password.isEmpty else {
            createAlert(message: "Please input a password")
            return
        }
        createUser(email: email, password: password)

    }
    //Puts sign up view down
    @IBAction func notNowTapped(_ sender: Any) {
        topConstraintHeight.constant = 800;
        logoTopConstraintHeight.constant = 249;
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        usernameSignUpOutlet.text = ""
        emailSignUpOutlet.text = ""
        passwordSignUpOutlet.text = ""
    }
    //Constraints
    @IBOutlet weak var logoTopConstraintHeight: NSLayoutConstraint!
    @IBOutlet weak var topConstraintHeight: NSLayoutConstraint!
    //Puts sign up view up
    @IBAction func showSignInTapped(_ sender: Any) {
        topConstraintHeight.constant = 200;
        logoTopConstraintHeight.constant = 130;
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        print("clicked")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        topConstraintHeight.constant = 800;
        logoTopConstraintHeight.constant = 249;
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        if userDefaults.bool(forKey: "usersignedin") {
            performSegue(withIdentifier: "LogInToList", sender: self)
        }
        emailOutlet.text = ""
        passwordOutlet.text = ""
        usernameSignUpOutlet.text = ""
        emailSignUpOutlet.text = ""
        passwordSignUpOutlet.text = ""
    }
    
    //register a user
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
    //log in a registered user
    func signInUser(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error == nil {
                //User has signed in
                self.userDefaults.set(true, forKey: "usersignedin")
                self.userDefaults.synchronize()
                self.performSegue(withIdentifier: "LogInToList", sender: self)
            } else if error?._code == AuthErrorCode.userNotFound.rawValue {
//                self.createUser(email: email, password: password)
                // create the alert
                self.createAlert(message: "User not found")
            } else {
                print(error?.localizedDescription as Any)
            }
        }
    }
    
    func createAlert(message: String) {
        // create the alert
        let alert = UIAlertController(title: "Warning", message: message, preferredStyle: UIAlertController.Style.alert)
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Continue", style: UIAlertAction.Style.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func signInPressed(_ sender: Any) {
        guard let email = emailOutlet.text, email != "" else {
            createAlert(message: "Please Input an email")
            return
        }
        guard let password = passwordOutlet.text, !password.isEmpty else {
            createAlert(message: "Please Input a password")
            return
        }
        self.signInUser(email: email, password: password)
        
    }
    
}
