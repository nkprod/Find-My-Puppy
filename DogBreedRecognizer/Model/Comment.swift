//
//  Comment.swift
//  DogBreedRecognizer
//
//  Created by Nurlybek on 4/11/19.
//  Copyright © 2019 Nurlybek. All rights reserved.
//

import Foundation
import FirebaseFirestore

class Comment {
    private(set) var hostEmail: String!
    private(set) var timestamp: Timestamp!
    private(set) var commentText: String!
    private(set) var documentId: String!
    private(set) var userId: String!

    
    init(hostEmail: String, commentText: String, timestamp:Timestamp, documentId: String, userId: String) {
        self.hostEmail = hostEmail
        self.commentText = commentText
        self.timestamp = timestamp
        self.documentId = documentId
        self.userId = userId
    }
    
    class func parseData(snapshot: QuerySnapshot?) -> [Comment] {
        var comments = [Comment]()
        guard let snapshot = snapshot else { return comments }
        for document in snapshot.documents {
            let data = document.data()
            let userEmail = data[USER_EMAIL] as? String ?? "Anonymus"
//            let username = data[USERNAME] as? String ?? ""
            let timestamp = data[TIMESTAMP] as! Timestamp
            let commentText = data[COMMENT_TEXT] as? String ?? ""
            let documentId = document.documentID
            let userId = data[USER_ID] as? String ?? ""

            let newElement = Comment(hostEmail: userEmail, commentText: commentText, timestamp: timestamp, documentId: documentId, userId:userId)
            comments.append(newElement)
        }
        return comments
    }
}
