//
//  UpdateProfileVC.swift
//  DogBreedRecognizer
//
//  Created by Nurlybek on 4/18/19.
//  Copyright © 2019 Nurlybek. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage

class UpdateProfileVC: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var changedEmail: UITextField!
    @IBOutlet weak var changedPassword: UITextField!
    @IBOutlet weak var changedUsername: UITextField!
    
    //Constants
    let imagePicker = UIImagePickerController()
    let storage = Storage.storage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate   = self
        imagePicker.sourceType = .photoLibrary
        profileImage.layer.cornerRadius = 90
        profileImage.clipsToBounds = true
        guard let imageURL = Auth.auth().currentUser?.photoURL?.absoluteString else { return }
        
        let httpsReference = storage.reference(forURL: imageURL)
        httpsReference.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
            if let error = error {
                // Uh-oh, an error occurred!
            } else {
                // Data for "images/island.jpg" is returned
                let image = UIImage(data: data!)
                self.profileImage.image = image
            }
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func setImageTapped(_ sender: Any) {
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func updatePasswordTapped(_ sender: Any) {
        guard let password = changedPassword.text, password != "" else {
            createAlert(message: "Password is empty, please add password")
            return }
        Auth.auth().currentUser?.updatePassword(to: password) { (error) in
            if let error = error {
                debugPrint("Error changing password \(error.localizedDescription)")
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func updateTapped(_ sender: Any) {
        guard var email = changedEmail.text else {return}
        if email == "" {
            email = Auth.auth().currentUser?.email ?? "Unknown"
        }
        guard var username = changedUsername.text else {return}
        if username == "" {
            username = Auth.auth().currentUser?.displayName ?? "Unknown"
        }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let image = profileImage.image else { return }
        var data = Data()
        data = image.jpegData(compressionQuality: 0.8)!
        
        let imageRef = storage.reference().child( "profile_images/" + uid)
        _ = imageRef.putData(data, metadata: nil, completion: { (metadata, error) in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
            }
            // You can also access to download URL after upload.
            imageRef.downloadURL { (url, error) in
                guard let downloadURL = url else { return }
                
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = username
                changeRequest?.photoURL = downloadURL
                    changeRequest?.commitChanges { (error) in
                        if let error = error {
                            debugPrint("Error updating profile information \(error.localizedDescription)")
                        }
                }
            }
        })
        
        Auth.auth().currentUser?.updateEmail(to: email) { (error) in
            if let error = error {
                debugPrint("Error updating profile information \(error.localizedDescription)")
            } else {
                self.navigationController?.popViewController(animated: true)
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
    
}
extension UpdateProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
                return
        }
        profileImage.image = image
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
}
