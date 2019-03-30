//
//  TableViewController.swift
//  DogBreedRecognizer
//
//  Created by Nurlybek on 3/15/19.
//  Copyright © 2019 Nurlybek. All rights reserved.
//

import UIKit

struct CellData {
    let image : UIImage?
    let message : String?
}

class TableViewController: UITableViewController {
    
    var data = [CellData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        data = [CellData(image: #imageLiteral(resourceName: "ImageForCell.jpg"), message: "Information about the dog"),
                CellData(image: #imageLiteral(resourceName: "ImageForCell.jpg"), message: "Information about the dog"),
                CellData(image: #imageLiteral(resourceName: "ImageForCell.jpg"), message: "Information about the dog"),
                CellData(image: #imageLiteral(resourceName: "ImageForCell.jpg"), message: "Information about the dog"),
                CellData(image: #imageLiteral(resourceName: "ImageForCell.jpg"), message: "Information about the dog")
        ]
        self.tableView.register(CustomCell.self, forCellReuseIdentifier: "custom")
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 200

    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "custom") as! CustomCell
        cell.customImage = data[indexPath.row].image
        cell.customMessage = data[indexPath.row].message
        cell.layoutSubviews()
        return cell
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

}
