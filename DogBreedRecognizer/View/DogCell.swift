//
//  DogCell.swift
//  DogBreedRecognizer
//
//  Created by Nurlybek on 3/29/19.
//  Copyright © 2019 Nurlybek. All rights reserved.
//

import UIKit

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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }
    func configureCell(dog: Dog) {
        userEmailLabel.text = dog.hostEmail
        petNameLabel.text = dog.name
        petBreed.text = dog.breed
        lastSeenAddress.text = dog.address
        let formater = DateFormatter()
        formater.dateFormat = "MMM d, hh:mm"
        let formatedDate = formater.string(from: dog.timestamp.dateValue())
        timestamp.text = formatedDate
        numCommentsLabel.text = String(dog.numComments)
    }

}
