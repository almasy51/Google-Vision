//
//  ImageDescriptionViewController.swift
//  Google-Vision
//
//  Created by Russell Stephenson on 7/13/16.
//  Copyright © 2016 Almasy. All rights reserved.
//

import UIKit

class ImageDescriptionViewController: UIViewController {
  
  @IBOutlet weak var image: UIImageView?
  
  var visionImage: VisionImage?
  var imageDescs: Array<String>?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    imageDescs = Array<String>()
    self.automaticallyAdjustsScrollViewInsets = false
    
    if let vImage = visionImage, vImageData = vImage.imageData {
      image?.image = UIImage(data: vImageData)
      let descriptionObjects = vImage.imageDescriptions?.allObjects as! Array<VisionImageDesc>
      for descObj in descriptionObjects {
        imageDescs?.append(descObj.imageDescription!)
      }
    }
  }
  
  //MARK: Actions
  
  @IBAction func deleteImage(sender: AnyObject) {
    guard let vImage = visionImage else {
      return
    }
    DataManager.sharedInstance.deleteGVImage(vImage)
    navigationController?.popViewControllerAnimated(true)
  }
}


//MARK: UITableView
extension ImageDescriptionViewController: UITableViewDataSource {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let descs = imageDescs else {
      return 0
    }
    
    return descs.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("ImageDescriptionTableViewCell", forIndexPath: indexPath) as! ImageDescriptionTableViewCell
    
    if let descArray = imageDescs{
      let desc = descArray[indexPath.row]
      cell.setCell(desc)
    }
    return cell
  }
}

extension ImageDescriptionViewController: UITableViewDelegate {
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 0.1
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 44.0
  }
  
  func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 0.1
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
}
