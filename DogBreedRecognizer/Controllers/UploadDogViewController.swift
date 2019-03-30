//
//  UploadDogViewController.swift
//  DogBreedRecognizer
//
//  Created by Nurlybek on 3/20/19.
//  Copyright © 2019 Nurlybek. All rights reserved.
//

import UIKit
import LocationPickerController
import CoreLocation
import FirebaseFirestore
import FirebaseAuth

enum SexCategory : String {
    case male = "Male"
    case female = "Female"
}

class UploadDogViewController: UIViewController,UITextViewDelegate {

    //Outlets
    @IBOutlet private weak var dogImageView: UIImageView!
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var ageTextField: UITextField!
    @IBOutlet private weak var sexSegmentedControl: UISegmentedControl!

    @IBOutlet private weak var moreInfoTextField: UITextView!
    @IBOutlet private weak var recognizedBreedTextView: UITextField!
    @IBOutlet private weak var addressTextField: UITextField!
    
    //Variables
    private var datePicker: UIDatePicker?
    private var petSex: String = SexCategory.male.rawValue
    //Constants
    let imagePicker = UIImagePickerController()
    let breedRecognizerModel = breedClassifier_87()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.addTarget(self, action: #selector(UploadDogViewController.dateChanged(datePicker: )), for: .valueChanged)
        ageTextField.inputView = datePicker
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(UploadDogViewController.viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
        self.present(imagePicker, animated: true, completion: nil)
        moreInfoTextField.delegate = self
        moreInfoTextField.text = "Add more information about yourself or the dog ... "
        moreInfoTextField.textColor = .lightGray
        moreInfoTextField.layer.cornerRadius = 5
        moreInfoTextField.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        moreInfoTextField.layer.borderWidth = 0.5
        moreInfoTextField.clipsToBounds = true
        petSex = "Male"
        print(sexSegmentedControl.selectedSegmentIndex)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        imagePicker.delegate   = self
        imagePicker.sourceType = .photoLibrary
        predictBreed()
    }
    
    //Functions
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
        textView.textColor = .black
    }
    
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    
    @objc func dateChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let calendar: Calendar = Calendar(identifier: .gregorian)
        let currentDate = Date()
        let age = calendar.component(.year, from: datePicker.date).distance(to: calendar.component(.year, from: currentDate))
        let month = calendar.component(.month, from: datePicker.date).distance(to: calendar.component(.month, from: currentDate))
        ageTextField.text = "\(age) years, \(month) months"
//        view.endEditing(true)
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
                    self.addressTextField.text = addressString
                }
        })
    }
    
    //Actions
    
    @IBAction func chooseBreedTapped(_ sender: UIButton) {
        //TODO
    }
    
    @IBAction func sexCategoryChanged(_ sender: Any) {
        switch sexSegmentedControl.selectedSegmentIndex {
        case 0:
            petSex = SexCategory.male.rawValue
        case 1:
            petSex = SexCategory.female.rawValue
        default:
            petSex = SexCategory.male.rawValue
        }
    }
    
    @IBAction func choosePhotoTapped(_ sender: Any) {
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func locateTapped(_ sender: Any) {
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
        guard let name = nameTextField.text, name != "" else {
            createAlert(message: "Please provide a name")
            return
        }
        guard let age = ageTextField.text, age != "" else {
            createAlert(message: "Please provide your pets date of birth")
            return
        }
        guard let address = addressTextField.text, address != "" else {
            createAlert(message: "Please provide address where you think your dog was lost")
            return
        }
        guard let breed = recognizedBreedTextView.text, breed != "" else {
            return
        }
        guard  let additionalInfo = moreInfoTextField.text else {
            return
        }
        guard let email = Auth.auth().currentUser?.email else {return}
        
       Firestore.firestore().collection(DOGS_REF).addDocument(data: [
        PET_NAME : name,
        PET_AGE : age,
        PET_SEX : petSex,
        PET_BREED : breed,
        LAST_SEEN_ADDRESS : address,
        MORE_INFO : additionalInfo,
        TIMESTAMP : FieldValue.serverTimestamp(),
        USER_EMAIL : email
       ]) { (err) in
        if let err = err {
            debugPrint("Error adding document \(err)")
            }
        self.navigationController?.popViewController(animated: true)
        }

    }
    

}
extension UploadDogViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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


private extension UploadDogViewController {
    
    func resnet(ref: CVPixelBuffer) {
        do {
            // prediction
            let output = try breedRecognizerModel.prediction(image: ref)
            recognizedBreedTextView.text = output.label
        } catch {
            print(error)
        }
    }
}



