//
//  ProfileViewController.swift
//  DogBreedRecognizer
//
//  Created by Nurlybek on 3/14/19.
//  Copyright © 2019 Nurlybek. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    //Outlets
    @IBOutlet weak var emailOutlet: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    //Variables
    private var dogs = [Dog]()
    private var dogsCollectionRef: CollectionReference!
    private var dogsListener: ListenerRegistration!
    //Constants
    let userDefault = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        guard let email = Auth.auth().currentUser?.email else { return }
        emailOutlet.text = "Welcome \(email)"
        dogsCollectionRef = Firestore.firestore().collection(DOGS_REF)
    }
    override func viewWillAppear(_ animated: Bool) {
        dogsListener = dogsCollectionRef
            .order(by: TIMESTAMP, descending: true)
            .addSnapshotListener { (snapshot, error) in
            if let error = error {
                debugPrint("Error fetching documents \(error)")
            } else {
                self.dogs.removeAll()
                guard let snapshot = snapshot else { return }
                for document in snapshot.documents {
                    let data = document.data()
                    let userEmail = data[USER_EMAIL] as? String ?? "Anonymus"
                    let petName = data[PET_NAME] as? String ?? "Unknown"
                    let timestamp = data[TIMESTAMP] as! Timestamp
                    let petAge = data[PET_AGE] as? String ?? "Unknown"
                    let petSex = data[PET_SEX] as? String ?? "Unknown"
                    let petBreed = data[PET_BREED] as? String ?? "Unknown"
                    let address = data[LAST_SEEN_ADDRESS] as? String ?? "Unknown"
                    let documentId = document.documentID
                    
                    let lostDog = Dog(name: petName, age: petAge, sex: petSex, breed: petBreed, address: address, timestamp: timestamp, documentId: documentId, hostEmail: userEmail)
                    self.dogs.append(lostDog)
                }
                self.tableView.reloadData()
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        dogsListener.remove()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dogs.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "dogCell", for: indexPath) as? DogCell {
            cell.configureCell(dog: dogs[indexPath.row])
            return cell
        } else {
            return UITableViewCell()
        }
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
