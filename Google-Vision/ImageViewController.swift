//
//  ImageViewController.swift
//  Google-Vision
//
//  Created by Russell Stephenson on 7/13/16.
//  Copyright © 2016 Almasy. All rights reserved.
//

import UIKit
import AVFoundation
import SystemConfiguration

class ImageViewController: UIViewController {
  
  private var images = Array<VisionImage>()
  private let imagePicker =  UIImagePickerController()
  private var selectedIndex = -1
  @IBOutlet weak var collectionView: UICollectionView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.automaticallyAdjustsScrollViewInsets = false
    getImages()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "ImageDescriptionSegue" {
      let vc = segue.destinationViewController as! ImageDescriptionViewController
      vc.visionImage = images[selectedIndex]
    }
  }
  
  func getImages() {
    images = DataManager.sharedInstance.getGVImages()
    collectionView.reloadData()
  }
  
  
  // Snippit take from http://www.brianjcoleman.com/tutorial-check-for-internet-connection-in-swift/
  // Normally I would use AFNetworking to check reachability but wanted to refrain from using a podfile for this project.
  func hasInternetAccess() -> Bool {
    var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
    zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
    zeroAddress.sin_family = sa_family_t(AF_INET)
    
    let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
      SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, UnsafePointer($0))
    }
    
    var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
    if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
      return false
    }
    
    let isReachable = flags == .Reachable
    let needsConnection = flags == .ConnectionRequired
    
    return isReachable && !needsConnection
  }
  
  // MARK: Actions
  
  @IBAction func takeImage(sender: UIBarButtonItem) {
    if !hasInternetAccess() {
      let alert = UIAlertController(title: "No Internet Connection", message: "Please connect to the internet.", preferredStyle: .Alert)
      let okAction = UIAlertAction(title: "OK", style: .Cancel) { (_) in
      }
      alert.addAction(okAction)
      self.presentViewController(alert, animated: true, completion: nil)
    } else {
    
      let alertController = UIAlertController(title: nil, message: "Complete Action Using:", preferredStyle: .ActionSheet)
      let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in
      }
      
      let cameraAction = UIAlertAction(title: "Camera", style: .Default) { (_) in
        self.takePhotoFromCamera()
      }
      
      let pickerAction = UIAlertAction(title: "Image Gallery", style: .Default) { (_) in
        self.getImageFromGallery()
      }
      
      alertController.addAction(cancelAction)
      alertController.addAction(cameraAction)
      alertController.addAction(pickerAction)
      
      self.presentViewController(alertController, animated: true, completion: nil)
    }
  }
}

  //MARK: UICollectionView

extension ImageViewController: UICollectionViewDataSource {
  func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return images.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageCollectionViewCell", forIndexPath: indexPath) as! ImageCollectionViewCell
    let gvImage = images[indexPath.row]
    if let imageData = gvImage.imageData {
      let image = UIImage(data: imageData)
      
      cell.imageView.image = image
    }
    
    cell.backgroundColor = UIColor.whiteColor()
    return cell
  }
}

extension ImageViewController: UICollectionViewDelegate {
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    collectionView.deselectItemAtIndexPath(indexPath, animated: true)
    selectedIndex = indexPath.row
    self.performSegueWithIdentifier("ImageDescriptionSegue", sender: nil)
  }
}

extension ImageViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                             sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    return CGSize(width: 90, height: 90)
  }
  
  func collectionView(collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      insetForSectionAtIndex section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
  }
}

  //MARK: UIImageViewController

extension ImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func takePhotoFromCamera() {
    let status = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
    
    if status == .Authorized || status == .NotDetermined {
      if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .Camera
        imagePicker.cameraCaptureMode = .Photo
        imagePicker.modalPresentationStyle = .FullScreen
        presentViewController(imagePicker, animated: true, completion: nil)
      }
    } else {
      let alert = UIAlertController(title: "Permission Required", message: "Please go into settings and enable the camera permission for this app.", preferredStyle: .Alert)
      alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
      self.presentViewController(alert, animated: true, completion: nil)
    }
  }
  
  func getImageFromGallery() {
    imagePicker.delegate = self
    imagePicker.allowsEditing = false
    imagePicker.sourceType = .PhotoLibrary
    
    presentViewController(imagePicker, animated: true, completion: nil)
  }
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    
    let capturedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
      if let gvImage = DataManager.sharedInstance.createGVImage(){
        gvImage.imageData = UIImagePNGRepresentation(capturedImage)
        GoogleVisionService.sharedInstance.requestImageDescription(gvImage, takenImage: capturedImage)
        DataManager.sharedInstance.saveContext()
        dispatch_async(dispatch_get_main_queue(), {
          self.getImages()
          //update collection view placeholder above
        })
      }
    })
    
    picker.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
    if error != nil {
      let ac = UIAlertController(title: "Save error", message: error?.localizedDescription, preferredStyle: .Alert)
      ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
      presentViewController(ac, animated: true, completion: nil)
    }
  }
  
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    imagePicker.dismissViewControllerAnimated(true, completion: nil)
  }
}
