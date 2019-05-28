//
//  ImageDescriptionTableViewCell.swift
//  Google-Vision
//
//  Created by Russell Stephenson on 7/13/16.
//  Copyright © 2016 Almasy. All rights reserved.
//

import UIKit

class ImageDescriptionTableViewCell: UITableViewCell {
  
  @IBOutlet weak var imageDescription: UILabel!
  
  func setCell(name: String) {
    imageDescription.text = name
  }
}
