//
//  DogCell.swift
//  DogBreedRecognizer
//
//  Created by Nurlybek on 3/29/19.
//  Copyright © 2019 Nurlybek. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage

protocol DogDelegate {
    func dogOptionMenuTapped(dog: Dog)
}

class DogCell: UITableViewCell {
    
    //Outlets
    @IBOutlet weak var lastSeenAddress: UILabel!
    @IBOutlet weak var petBreed: UILabel!
    @IBOutlet weak var timestamp: UILabel!
    @IBOutlet weak var petNameLabel: UILabel!
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var numCommentsLabel: UILabel!
    @IBOutlet weak var commentsImage: UIImageView!
    @IBOutlet weak var optionsMenu: UIImageView!
    @IBOutlet weak var dogImage: UIImageView!
    
    //Variables
    //delegate to pass the information to configureCell method
    var delegate: DogDelegate?
    var dog: Dog!
    
    let storage = Storage.storage()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dogImage.layer.cornerRadius = 45.0
        dogImage.clipsToBounds = true
        // Initialization code
    }
    
    func configureCell(dog: Dog, delegate: DogDelegate?) {
        userEmailLabel.text = dog.hostEmail
        petNameLabel.text = dog.name
        petBreed.text = dog.breed
        lastSeenAddress.text = dog.address
        self.dog = dog
        self.delegate = delegate
        let httpsReference = storage.reference(forURL: dog.imageURL )
        httpsReference.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
            if let error = error {
                // Uh-oh, an error occurred!
            } else {
                // Data for "images/island.jpg" is returned
                let image = UIImage(data: data!)
                self.dogImage.image = image
            }
        }
        let formater = DateFormatter()
        formater.dateFormat = "MMM d, hh:mm"
        let formatedDate = formater.string(from: dog.timestamp.dateValue())
        timestamp.text = formatedDate
        numCommentsLabel.text = String(dog.numComments)
        optionsMenu.isHidden = true
        
        //checks if the post belongs to the person who shared it
        if dog.userId == Auth.auth().currentUser?.uid {
            optionsMenu.isHidden = false
            optionsMenu.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(optionMenuTapped))
            optionsMenu.addGestureRecognizer(tap)
        }
    }
    //
    @objc func optionMenuTapped() {
        delegate?.dogOptionMenuTapped(dog: dog)
    }

}
