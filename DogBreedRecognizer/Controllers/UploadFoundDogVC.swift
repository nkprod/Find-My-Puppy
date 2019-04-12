//
//  UploadFoundDogVC.swift
//  DogBreedRecognizer
//
//  Created by Nurlybek on 3/31/19.
//  Copyright © 2019 Nurlybek. All rights reserved.
//

import UIKit
import LocationPickerController
import CoreLocation
import FirebaseFirestore
import FirebaseAuth

class UploadFoundDogVC: UIViewController, UITextViewDelegate {
    //Outlets
    @IBOutlet weak var dogImageView: UIImageView!

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var moreInfoTextView: UITextView!
    @IBOutlet weak var lastSeenAddressTextField: UITextField!
    @IBOutlet weak var recognizedBreedTextField: UITextField!
    //Constants
    let imagePicker = UIImagePickerController()
    let breedRecognizerModel = breedClassifier_87()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.present(imagePicker, animated: true, completion: nil)
        moreInfoTextView.delegate = self
        moreInfoTextView.text = "Add more information about yourself or the dog ..."
        moreInfoTextView.textColor = .lightGray
        moreInfoTextView.layer.cornerRadius = 5
        moreInfoTextView.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        moreInfoTextView.layer.borderWidth = 0.5
        moreInfoTextView.clipsToBounds = true

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        imagePicker.delegate   = self
        imagePicker.sourceType = .photoLibrary
        predictBreed()
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
        textView.textColor = .black
    }
    
    
    @IBAction func chooseAnotherPhotoTapped(_ sender: Any) {
        self.present(imagePicker, animated: true, completion: nil)
    }
    @IBAction func chooseDifferentBreedTapped(_ sender: Any) {
    }
    @IBAction func locateOnMapTapped(_ sender: Any) {
        let viewController = LocationPickerController(success: {
            [weak self] (coordinate: CLLocationCoordinate2D) -> Void in
            //            self?.locationLabel.text = "".appendingFormat("%.4f, %.4f",
            //                                                          coordinate.latitude, coordinate.longitude)
            self?.getAddressFromLatLon(pdblLatitude: String(coordinate.latitude), withLongitude: String(coordinate.longitude))
        })
        let navigationController = UINavigationController(rootViewController: viewController)
        self.present(navigationController, animated: true, completion: nil)
    }
    
    @IBAction func shareTapped(_ sender: Any) {
        guard let address = lastSeenAddressTextField.text, address != "" else {createAlert(message: "Add the address")
            return
        }
        guard let breed = recognizedBreedTextField.text, breed != "" else {createAlert(message: "Choose a different photo")
            return
        }
        guard let email = Auth.auth().currentUser?.email else {return}
        guard let additionalInfo = moreInfoTextView.text else { return }
        
        Firestore.firestore().collection(DOGS_REF).addDocument(data: [
            CATEGORY : "Found",
            PET_NAME : "",
            PET_AGE : "",
            PET_SEX : "",
            PET_BREED : breed,
            LAST_SEEN_ADDRESS : address,
            MORE_INFO : additionalInfo,
            TIMESTAMP : FieldValue.serverTimestamp(),
            USER_EMAIL : email,
            NUM_COMMENTS : 0,
            USER_ID : Auth.auth().currentUser?.uid ?? ""
        ]) { (err) in
            if let err = err {
                debugPrint("Error adding document \(err)")
            }
            self.navigationController?.popViewController(animated: true)
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
    
    
    func predictBreed() {
        guard let image = dogImageView.highlightedImage, let ref = image.buffer else {
            return
        }
        resnet(ref: ref)
    }
    func getAddressFromLatLon(pdblLatitude: String, withLongitude pdblLongitude: String) {
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        let lat: Double = Double("\(pdblLatitude)")!
        let lon: Double = Double("\(pdblLongitude)")!
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = lat
        center.longitude = lon
        
        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        ceo.reverseGeocodeLocation(loc, completionHandler:
            {(placemarks, error) in
                if (error != nil)
                {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }
                let pm = placemarks! as [CLPlacemark]
                
                if pm.count > 0 {
                    let pm = placemarks![0]
                    var addressString : String = ""
                    if pm.subLocality != nil {
                        addressString = addressString + pm.subLocality! + ", "
                    }
                    if pm.thoroughfare != nil {
                        addressString = addressString + pm.thoroughfare! + ", "
                    }
                    if pm.locality != nil {
                        addressString = addressString + pm.locality! + ", "
                    }
                    if pm.country != nil {
                        addressString = addressString + pm.country! + ", "
                    }
                    if pm.postalCode != nil {
                        addressString = addressString + pm.postalCode! + " "
                    }
                    self.lastSeenAddressTextField.text = addressString
                }
        })
    }
    

}

extension UploadFoundDogVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // The input image size should be 224x224 for Recognition using the CNN model
        guard let image = info[.originalImage] as? UIImage,
            let resized = image.resize(size: CGSize(width: 224, height: 224))else {
                return
        }
        dogImageView.image = image
        dogImageView.highlightedImage = resized
        //        recognizedBreedLabel.text = ""
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
}


private extension UploadFoundDogVC {
    
    func resnet(ref: CVPixelBuffer) {
        do {
            // prediction
            let output = try breedRecognizerModel.prediction(image: ref)
            recognizedBreedTextField.text = output.label
        } catch {
            print(error)
        }
    }
}
