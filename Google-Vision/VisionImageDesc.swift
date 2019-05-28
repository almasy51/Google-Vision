//
//  VisionImageDesc.swift
//  Google-Vision
//
//  Created by Russell Stephenson on 7/13/16.
//  Copyright © 2016 Almasy. All rights reserved.
//

import Foundation
import CoreData


class VisionImageDesc: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

}

extension VisionImageDesc {
  
  @NSManaged var imageDescription: String?
  @NSManaged var imageObject: VisionImage?
  
}
