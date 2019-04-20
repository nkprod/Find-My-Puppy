//
//  CommentsVC.swift
//  DogBreedRecognizer
//
//  Created by Nurlybek on 4/10/19.
//  Copyright © 2019 Nurlybek. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class CommentsVC: UIViewController, UITableViewDelegate,UITableViewDataSource, CommentDelegate {

    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addCommentText: UITextField!
    @IBOutlet weak var keyboardView: UIView!
    
    
    @IBOutlet weak var additionalInfo: UILabel!
    @IBOutlet weak var lastSeenAddress: UILabel!
    @IBOutlet weak var breed: UILabel!
    @IBOutlet weak var dogSex: UILabel!
    @IBOutlet weak var dogAge: UILabel!
    @IBOutlet weak var dogName: UILabel!
    @IBOutlet weak var imageOfDog: UIImageView!
    
    var dog: Dog!
    var comments = [Comment]()
    var dogRef: DocumentReference!
    var username: String!
    var commentListener : ListenerRegistration!
    
    let storage = Storage.storage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        dogRef = Firestore.firestore().collection(DOGS_REF).document(dog.documentId)
        if let name = Auth.auth().currentUser?.displayName {
            username = name
        }
        self.view.bindToKeyboard()
        self.dogName.text = dog.name
        self.dogAge.text = dog.age
        self.dogSex.text = dog.sex
        self.breed.text = dog.breed!
        self.lastSeenAddress.text = dog.address!
        self.additionalInfo.text = dog.moreInfo!

        let httpsReference = storage.reference(forURL: dog.imageURL )
        httpsReference.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
            if let error = error {
                // Uh-oh, an error occurred!
            } else {
                // Data for "images/island.jpg" is returned
                let image = UIImage(data: data!)
                self.imageOfDog.image = image
            }
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        commentListener = Firestore.firestore().collection(DOGS_REF).document(self.dog.documentId).collection(COMMENTS_REF)
            .order(by: TIMESTAMP, descending: false)
            .addSnapshotListener({ (snapshot, error) in
            guard let snapshot = snapshot else {
                debugPrint("Error fetching document \(error?.localizedDescription)")
                return
            }
            self.comments.removeAll()
            self.comments = Comment.parseData(snapshot: snapshot)
            self.tableView.reloadData()
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        commentListener.remove()
    }
    
    //to share info with
    func commentOptionsMenuTapped(comment: Comment) {
        print(comment.userId)
        let alert = UIAlertController(title: "Edit Comment", message: "You can delete or edit", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete Comment", style: .default) { (action) in
            //delete the comment
//            self.dogRef.collection(COMMENTS_REF).document(comment.documentId).delete(completion: { (error) in
//                if let error = error {
//                    debugPrint("Unable to delete comment: \(error.localizedDescription)")
//                } else {
//                    alert.dismiss(animated: true, completion: nil)
//                }
//            })
            
            Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
                let dogDocument: DocumentSnapshot
                do {
                    try dogDocument = transaction.getDocument(Firestore.firestore().collection(DOGS_REF).document(self.dog.documentId))
                } catch let error as NSError {
                    debugPrint("Fetch error \(error)")
                    return nil
                }
                guard let oldNumComments = dogDocument.data()?[NUM_COMMENTS] as? Int else { return nil }
                transaction.updateData([NUM_COMMENTS: oldNumComments - 1], forDocument: self.dogRef)
                let commentRef = self.dogRef.collection(COMMENTS_REF).document(comment.documentId)
                transaction.deleteDocument(commentRef)
                return nil
                
            }) { (object, error) in
                if let error = error {
                    debugPrint("Transaction failed: \(error)")
                } else {
                    alert.dismiss(animated: true, completion: nil)
                }
            }

            
            
        }
        let editAction = UIAlertAction(title: "Edit Comment", style: .default) { (action) in
            self.performSegue(withIdentifier: "GoToUpdateCommentVC", sender: (comment, self.dog))
            alert.dismiss(animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(deleteAction)
        alert.addAction(editAction)
        alert.addAction(cancelAction)
        present(alert,animated: true,completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? UpdateCommentVC {
            if let commentData = sender as? (comment: Comment, dog: Dog) {
                destination.data = commentData
            }
        }
    }
    
    
    @IBAction func addCommentTapped(_ sender: Any) {
        guard let commentText = addCommentText.text else { return }
        Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
            let dogDocument: DocumentSnapshot
            do {
                try dogDocument = transaction.getDocument(Firestore.firestore().collection(DOGS_REF).document(self.dog.documentId))
            } catch let error as NSError {
                debugPrint("Fetch error \(error)")
                return nil
            }
            guard let oldNumComments = dogDocument.data()?[NUM_COMMENTS] as? Int else { return nil }
            transaction.updateData([NUM_COMMENTS: oldNumComments + 1], forDocument: self.dogRef)
            let newCommentRef = Firestore.firestore().collection(DOGS_REF).document(self.dog.documentId).collection(COMMENTS_REF).document()
            transaction.setData([
                COMMENT_TEXT : commentText,
                TIMESTAMP : FieldValue.serverTimestamp(),
                USERNAME : self.username,
                USER_EMAIL : Auth.auth().currentUser?.email ?? "",
                USER_ID : Auth.auth().currentUser?.uid ?? ""
                ], forDocument: newCommentRef)
            return nil

        }) { (object, error) in
            if let error = error {
                debugPrint("Transaction failed: \(error)")
            } else {
                self.addCommentText.text = ""
                self.addCommentText.resignFirstResponder()
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as? CommentCell {
            cell.configureCell(comment: comments[indexPath.row], delegate: self)
            return cell
        } else {
            return UITableViewCell()
        }
    }
}
