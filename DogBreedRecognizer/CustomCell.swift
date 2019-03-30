//
//  CustomCell.swift
//  DogBreedRecognizer
//
//  Created by Nurlybek on 3/15/19.
//  Copyright © 2019 Nurlybek. All rights reserved.
//

import Foundation
import UIKit

class CustomCell: UITableViewCell {
    var customMessage : String?
    var customImage : UIImage?
    
    var customMessageView : UITextView = {
        var textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = false
        return textView
    }()
    
    var customImageView : UIImageView = {
        var imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(customMessageView)
        self.addSubview(customImageView)
        
        customImageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        customImageView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        customImageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        customImageView.bottomAnchor.constraint(equalTo: self.customMessageView.topAnchor).isActive = true
        customImageView.heightAnchor.constraint(equalToConstant: 250).isActive = true
        
        customMessageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        customMessageView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        customImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

        
    }
    
    override func layoutSubviews() {
        if let message = customMessage {
            customMessageView.text = message
        }
        if let image = customImage {
            customImageView.image = image
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
