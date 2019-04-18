//
//  Dog.swift
//  DogBreedRecognizer
//
//  Created by Nurlybek on 3/29/19.
//  Copyright © 2019 Nurlybek. All rights reserved.
//

import Foundation
import FirebaseFirestore

class Dog {
    private(set) var name: String!
    private(set) var age: String!
    private(set) var sex: String!
    private(set) var breed: String!
    private(set) var address: String!
    private(set) var timestamp: Timestamp!
    private(set) var documentId: String!
    private(set) var hostEmail: String!
    private(set) var numComments: Int!
    private(set) var userId: String!
    private(set) var imageURL : String!
    private(set) var moreInfo: String!

    
    init(name: String, age: String, sex: String, breed: String, address:String, timestamp: Timestamp, documentId: String, hostEmail: String, numComments: Int, userId: String, imageURL: String, moreInfo: String) {
        self.name = name
        self.age = age
        self.sex = sex
        self.breed = breed
        self.address = address
        self.timestamp = timestamp
        self.documentId = documentId
        self.hostEmail = hostEmail
        self.numComments = numComments
        self.userId = userId
        self.imageURL = imageURL
        self.moreInfo = moreInfo
    }
    
    class func parseData(snapshot: QuerySnapshot?) -> [Dog] {
        var dogs = [Dog]()
        guard let snapshot = snapshot else { return dogs }
        for document in snapshot.documents {
            let data = document.data()
            let userEmail = data[USER_EMAIL] as? String ?? "Anonymus"
            let petName = data[PET_NAME] as? String ?? "Unknown"
            let timestamp = data[TIMESTAMP] as! Timestamp
            let petAge = data[PET_AGE] as? String ?? "Unknown"
            let petSex = data[PET_SEX] as? String ?? "Unknown"
            let petBreed = data[PET_BREED] as? String ?? "Unknown"
            let address = data[LAST_SEEN_ADDRESS] as? String ?? "Unknown"
            let numComments = data[NUM_COMMENTS] as? Int ?? 0
            let userId = data[USER_ID] as? String ?? ""
            let documentId = document.documentID
            let imageURL = data[IMAGE_URL] as? String ?? ""
            let moreInfo = data[MORE_INFO] as? String ?? ""
            
            let lostDog = Dog(name: petName, age: petAge, sex: petSex, breed: petBreed, address: address, timestamp: timestamp, documentId: documentId, hostEmail: userEmail,numComments: numComments, userId: userId, imageURL: imageURL, moreInfo: moreInfo)
            dogs.append(lostDog)
        }
        return dogs
    }
}

