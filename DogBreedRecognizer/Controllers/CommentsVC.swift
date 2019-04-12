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

class CommentsVC: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addCommentText: UITextField!
    @IBOutlet weak var keyboardView: UIView!
    
    var dog: Dog!
    var comments = [Comment]()
    var dogRef: DocumentReference!
    var username: String!
    var commentListener : ListenerRegistration!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        dogRef = Firestore.firestore().collection(DOGS_REF).document(dog.documentId)
        if let name = Auth.auth().currentUser?.displayName {
            username = name
        }
        self.view.bindToKeyboard()
        print(dog.name)
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
            cell.configureCell(comment: comments[indexPath.row])
            return cell
        } else {
            return UITableViewCell()
        }
    }
}
