//
//  ViewController.swift
//  DogBreedRecognizer
//
//  Created by Nurlybek on 10/23/18.
//  Copyright © 2018 Nurlybek. All rights reserved.
//

import UIKit
import CoreML

class ViewController: UIViewController {

   
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var probsLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        resultLabel.text = ""
        probsLabel.text  = ""

        // Do any additional setup after loading the view, typically from a nib.
    }
    let breedRecognizerModel = breedClassifier_86()
    let imagePicker = UIImagePickerController()

    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        imagePicker.delegate   = self
        imagePicker.sourceType = .photoLibrary
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        


    @IBAction func openPhotoLibrary(_ sender: UIButton) {
         self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func predict(_ sender: UIButton) {
        guard let image = imageView.highlightedImage, let ref = image.buffer else {
            
            return
        }
        resnet(ref: ref)
    }
    
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // The input image size should be 224x224 for ResNet
        guard let image = info[.originalImage] as? UIImage,
            let resized = image.resize(size: CGSize(width: 224, height: 224))else {
                
                return
        }
        
        imageView.image = image
        imageView.highlightedImage = resized
        resultLabel.text = ""
        probsLabel.text  = ""
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
}

private extension ViewController {
    
    func resnet(ref: CVPixelBuffer) {
        
        do {
            
            // prediction
            let output = try breedRecognizerModel.prediction(image: ref)
            
            // sort classes by probability
            let sorted = output.labelProbability.sorted(by: { (lhs, rhs) -> Bool in
                
                return lhs.value > rhs.value
            })
            
            resultLabel.text = output.label
            probsLabel.text  = "\(sorted[0].key): \(NSString(format: "%.2f", sorted[0].value))\n\(sorted[1].key): \(NSString(format: "%.2f", sorted[1].value))\n\(sorted[2].key): \(NSString(format: "%.2f", sorted[2].value))\n\(sorted[3].key): \(NSString(format: "%.2f", sorted[3].value))\n\(sorted[4].key): \(NSString(format: "%.2f", sorted[4].value))"
            
            print(output.label)
            print(output.labelProbability)
            
        } catch {
            
            print(error)
        }
    }
}
extension ViewController {
    @IBAction func goBackToOneButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "unwindSegueToVC1", sender: self)
    }
}
