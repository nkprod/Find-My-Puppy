//
//  CommentCell.swift
//  DogBreedRecognizer
//
//  Created by Nurlybek on 4/11/19.
//  Copyright © 2019 Nurlybek. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

protocol CommentDelegate {
    func commentOptionsMenuTapped(comment: Comment)
}

class CommentCell: UITableViewCell {
    //Outlets
    @IBOutlet weak var usernameText: UILabel!
    @IBOutlet weak var timestampText: UILabel!
    @IBOutlet weak var commentText: UILabel!
    @IBOutlet weak var optionsMenu: UIImageView!
    
    //Variables
    var comment: Comment!
    var delegate: CommentDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(comment: Comment, delegate: CommentDelegate) {
        usernameText.text = comment.hostEmail
        commentText.text = comment.commentText
        optionsMenu.isHidden = true
        optionsMenu.isUserInteractionEnabled = true
        self.delegate = delegate
        self.comment = comment
        
        let formater = DateFormatter()
        formater.dateFormat = "MMM d, hh:mm"
        let formatedDate = formater.string(from: comment.timestamp.dateValue())
        timestampText.text = formatedDate
        optionsMenu.isHidden = true
        
        //checks if the user shared the comment is the person who sees the options menu
        if comment.userId == Auth.auth().currentUser?.uid {
            optionsMenu.isUserInteractionEnabled = true
            optionsMenu.isHidden = false
            let tap = UITapGestureRecognizer(target: self, action: #selector(optionsMenuTapped))
            optionsMenu.addGestureRecognizer(tap)
        }
    }
    @objc func optionsMenuTapped() {
        delegate?.commentOptionsMenuTapped(comment: comment)
    }
}
