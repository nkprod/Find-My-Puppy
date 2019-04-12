//
//  CommentCell.swift
//  DogBreedRecognizer
//
//  Created by Nurlybek on 4/11/19.
//  Copyright © 2019 Nurlybek. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {

    @IBOutlet weak var usernameText: UILabel!
    @IBOutlet weak var timestampText: UILabel!
    @IBOutlet weak var commentText: UILabel!
    @IBOutlet weak var optionsMenu: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(comment: Comment) {
        usernameText.text = comment.hostEmail
        commentText.text = comment.commentText
        let formater = DateFormatter()
        formater.dateFormat = "MMM d, hh:mm"
        let formatedDate = formater.string(from: comment.timestamp.dateValue())
        timestampText.text = formatedDate
    }
}
