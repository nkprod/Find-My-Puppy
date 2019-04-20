//
//  UpdateCommentVC.swift
//  DogBreedRecognizer
//
//  Created by Nurlybek on 4/18/19.
//  Copyright © 2019 Nurlybek. All rights reserved.
//

import UIKit
import FirebaseFirestore

class UpdateCommentVC: UIViewController,UITextViewDelegate {
    
    @IBOutlet weak var commentText: UITextView!
    @IBOutlet weak var updateBtn: UIButton!
    
    //Variables
    var data : (comment: Comment, dog: Dog)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commentText.delegate = self
        commentText.text = "Update your comment ..."
        commentText.textColor = .lightGray
        commentText.layer.cornerRadius = 5
        commentText.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        commentText.layer.borderWidth = 0.5
        commentText.clipsToBounds = true
        print(data.comment.commentText)
        // Do any additional setup after loading the view.
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
        textView.textColor = .black
    }
    @IBAction func updateTapped(_ sender: Any) {
        Firestore.firestore().collection(DOGS_REF).document(data.dog.documentId).collection(COMMENTS_REF).document(data.comment.documentId).updateData([COMMENT_TEXT : commentText.text]) { (error) in
            if let error = error {
                debugPrint("Error updating the comment: \(error.localizedDescription)")
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
}
