//
//  DataManager.swift
//  Google-Vision
//
//  Created by Russell Stephenson on 7/13/16.
//  Copyright © 2016 Almasy. All rights reserved.
//

import CoreData
import UIKit

class DataManager {
  private let managedObjectModel: NSManagedObjectModel
  private var presistantStoreCoordinator: NSPersistentStoreCoordinator?
  private var managedObjectContext: NSManagedObjectContext?
  
  static let sharedInstance = DataManager()
  
  private init() {
    let modelURL = NSBundle.mainBundle().URLForResource("ImageModel", withExtension: "momd")!
    managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL)!
  }
  
  func loadDatabase() {
    if managedObjectContext != nil {
      saveContext()
    }
    
    presistantStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
    if presistantStoreCoordinator != nil {
      let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
      let url = urls[urls.count-1].URLByAppendingPathComponent("GoogleVisionImages.sqlite")
      let failureReason = "There was an error creating or loading the application's saved data."
      
      do {
        try presistantStoreCoordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
      } catch {
        // Report any error we got.
        var dict = [String: AnyObject]()
        dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
        dict[NSLocalizedFailureReasonErrorKey] = failureReason
        
        dict[NSUnderlyingErrorKey] = error as NSError
        let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
        abort()
      }
      
      managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
      if managedObjectContext != nil {
        managedObjectContext!.persistentStoreCoordinator = presistantStoreCoordinator
      }
    }
  }
  
  func saveContext() -> Bool {
    guard let managedObjectContext = managedObjectContext else {
      return false
    }
    
    if managedObjectContext.hasChanges {
      do {
        try managedObjectContext.save()
      } catch {
        let nserror = error as NSError
        NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
        return false
      }
    }
    
    return true
  }
  
  // MARK: Create Methods
  
  func createGVImage() -> VisionImage? {
    guard let moc = managedObjectContext else {
      return nil
    }
    
    return NSEntityDescription.insertNewObjectForEntityForName("VisionImage", inManagedObjectContext: moc) as? VisionImage
  }
  
  func createGVImageDesc() -> VisionImageDesc? {
    guard let moc = managedObjectContext else {
      return nil
    }
    
    return NSEntityDescription.insertNewObjectForEntityForName("VisionImageDesc", inManagedObjectContext: moc) as? VisionImageDesc
  }
  
  // MARK: Get Methods
  
  func getGVImages() -> Array<VisionImage> {
    guard let moc = managedObjectContext else {
      return []
    }
    
    let req = NSFetchRequest(entityName: String(VisionImage))
    
    do {
      let res = try moc.executeFetchRequest(req) as! Array<VisionImage>
      return res
    } catch {
      return []
    }
  }
  
  //MARK: Delete Methods
  
  func deleteGVImage(gvImage: VisionImage) {
    guard let moc = managedObjectContext else {
      return
    }
    
    moc.deleteObject(gvImage)
    saveContext()
  }
}
