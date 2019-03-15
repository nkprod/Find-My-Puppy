//
//  ProfileViewController.swift
//  DogBreedRecognizer
//
//  Created by Nurlybek on 3/14/19.
//  Copyright © 2019 Nurlybek. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {
    //Outlets
    @IBOutlet weak var emailOutlet: UILabel!
    //Variables
    //Constants
    let userDefault = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let email = Auth.auth().currentUser?.email else { return }
        emailOutlet.text = "Welcome \(email)"
        
        
        // Do any additional setup after loading the view.
    }
    //Actions
    @IBAction func signOutPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            userDefault.removeObject(forKey: "usersignedin")
            userDefault.synchronize()
            self.dismiss(animated: true, completion: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
}
