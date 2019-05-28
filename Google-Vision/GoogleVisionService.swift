//
//  GoogleVisionService.swift
//  Google-Vision
//
//  Created by Russell Stephenson on 7/14/16.
//  Copyright © 2016 Almasy. All rights reserved.
//

import UIKit

public class GoogleVisionService {
  
  let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
  var task: NSURLSessionDataTask?
  static let sharedInstance = GoogleVisionService()
  var API_KEY = "AIzaSyCxS6k4pQvYqm6Uxiby8oRJ1GikiMXUBrU"
  
  func requestImageDescription(visionImage: VisionImage?, takenImage: UIImage){
    guard let image = visionImage else {
      return
    }
    
    let url = NSURL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(API_KEY)")
    let request = NSMutableURLRequest(URL: url!)
    request.HTTPMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue(NSBundle.mainBundle().bundleIdentifier ?? "",
                     forHTTPHeaderField: "X-Ios-Bundle-Identifier")
    
    let base64Image = base64EncodeImage(takenImage)
    
    let jsonRequest: [String: AnyObject] = [
      "requests": [
        "image": [
          "content": base64Image
        ],
        "features": [
          [
            "type": "LABEL_DETECTION",
            "maxResults": 10
          ]
        ]
      ]
    ]
    
    request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonRequest, options: [])
    
    self.task = self.defaultSession.dataTaskWithRequest(request, completionHandler: { data, response, error -> Void in
      if let httpResponse = response as? NSHTTPURLResponse {
        if httpResponse.statusCode == 200 {
          self.parseResults(data!, visionImage: image)
        }
      }
    })
    self.task?.resume()
  }
  
  func parseResults(data: NSData, visionImage: VisionImage?) {
    do {
      if let json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSDictionary {
        if let responses = json["responses"] as? Array<Dictionary<String, AnyObject>>{
          let response = responses[0]
          if let labelAnnotations = response["labelAnnotations"] as? Array<Dictionary<String, AnyObject>>{
            for annotation in labelAnnotations {
              let description = annotation["description"] as! String
              
              if let desc = DataManager.sharedInstance.createGVImageDesc() {
                desc.imageObject = visionImage
                desc.imageDescription = description
              }
            }
            DataManager.sharedInstance.saveContext()
          }
        }
      }
    } catch {
      print("parse error")
    }
  }
  
  //Snippit take from https://github.com/GoogleCloudPlatform/cloud-vision/blob/master/ios/Swift/imagepicker/ImagePickerViewController.swift a tutorial for using Google Cloud Vision
  func base64EncodeImage(image: UIImage) -> String {
    var imagedata = UIImagePNGRepresentation(image)
    
    // Resize the image if it exceeds the 2MB API limit
    if (imagedata?.length > 2097152) {
      let oldSize: CGSize = image.size
      let newSize: CGSize = CGSizeMake(800, oldSize.height / oldSize.width * 800)
      imagedata = resizeImage(newSize, image: image)
    }
    
    return imagedata!.base64EncodedStringWithOptions(.EncodingEndLineWithCarriageReturn)
  }
  
  func resizeImage(imageSize: CGSize, image: UIImage) -> NSData {
    UIGraphicsBeginImageContext(imageSize)
    image.drawInRect(CGRectMake(0, 0, imageSize.width, imageSize.height))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    let resizedImage = UIImagePNGRepresentation(newImage)
    UIGraphicsEndImageContext()
    return resizedImage!
  }
}