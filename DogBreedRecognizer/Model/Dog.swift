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
    init(name: String, age: String, sex: String, breed: String, address:String, timestamp: Timestamp, documentId: String, hostEmail: String) {
        self.name = name
        self.age = age
        self.sex = sex
        self.breed = breed
        self.address = address
        self.timestamp = timestamp
        self.documentId = documentId
        self.hostEmail = hostEmail
    }
}

