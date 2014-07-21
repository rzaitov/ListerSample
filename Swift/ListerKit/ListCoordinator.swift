/*
    Copyright (C) 2014 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    
                The ListCoordinator handles file operations and tracking based on the users storage choice (local vs. cloud).
            
*/

import UIKit

public class ListCoordinator: NSObject {
    // MARK: Types

    public struct Notifications {
        public struct StorageDidChange {
            public static let name = "storageChoiceDidChangeNotification"
        }
    }

    // MARK: Class Properties

    public class var sharedListCoordinator: ListCoordinator {
        struct Singleton {
            static let sharedListCoordinator: ListCoordinator = {
                let listCoordinator = ListCoordinator()
                
                NSNotificationCenter.defaultCenter().addObserver(listCoordinator, selector: "updateDocumentStorageContainerURL", name: AppConfiguration.Notifications.StorageOptionDidChange.name, object: nil)
                
                return listCoordinator
            }()
        }

        return Singleton.sharedListCoordinator
    }
    
    // MARK: Properties
    
    public var documentsDirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as NSURL
    
    private var todayDocumentURL: NSURL {
        return documentsDirectory.URLByAppendingPathComponent(AppConfiguration.localizedTodayDocumentNameAndExtension)
    }
    
    // MARK: Document Management
    
    public func copyInitialDocuments() {
        let defaultListURLs = NSBundle.mainBundle().URLsForResourcesWithExtension(AppConfiguration.listerFileExtension, subdirectory: "") as [NSURL]
        
        for url in defaultListURLs {
            copyFileToDocumentsDirectory(url)
        }
    }
    
    public func updateDocumentStorageContainerURL() {
        let oldDocumentsDirectory = documentsDirectory
        
        let fileManager = NSFileManager.defaultManager()

        if AppConfiguration.sharedConfiguration.storageOption != .Cloud {
            documentsDirectory = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as NSURL

            NSNotificationCenter.defaultCenter().postNotificationName(Notifications.StorageDidChange.name, object: self)
        }
        else {
            let defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
            dispatch_async(defaultQueue) {
                // The call to URLForUbiquityContainerIdentifier should be on a background queue.
                let cloudDirectory = fileManager.URLForUbiquityContainerIdentifier(nil)
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.documentsDirectory = cloudDirectory.URLByAppendingPathComponent("Documents")
                    
                    let localDocuments = fileManager.contentsOfDirectoryAtURL(oldDocumentsDirectory, includingPropertiesForKeys: nil, options: .SkipsPackageDescendants, error: nil) as [NSURL]?
                    
                    if let localDocuments = localDocuments {
                        for url in localDocuments {
                            if url.pathExtension == AppConfiguration.listerFileExtension {
                                self.makeItemUbiquitousAtURL(url)
                            }
                        }
                    }
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(Notifications.StorageDidChange.name, object: self)
                }
            }
        }
    }
    
    private func makeItemUbiquitousAtURL(sourceURL: NSURL) {
        let destinationFileName = sourceURL.lastPathComponent
        let destinationURL = documentsDirectory.URLByAppendingPathComponent(destinationFileName)
        
        // Upload the file to iCloud on a background queue.
        var defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(defaultQueue) {
            let fileManager = NSFileManager()

            let success = fileManager.setUbiquitous(true, itemAtURL: sourceURL, destinationURL: destinationURL, error: nil)
            
            // If the move wasn't successful, try removing the item locally since the document may already exist in the cloud.
            if !success {
                fileManager.removeItemAtURL(sourceURL, error: nil)
            }
        }
    }

    // MARK: Convenience

    private func copyFileToDocumentsDirectory(fromURL: NSURL) {
        let toURL = documentsDirectory.URLByAppendingPathComponent(fromURL.lastPathComponent)
        let coordinator = NSFileCoordinator()
        var success = false
        var error: NSError?

        coordinator.coordinateWritingItemAtURL(fromURL, options: .ForMoving, writingItemAtURL: toURL, options: .ForReplacing, error: &error) { sourceURL, destinationURL in
            let fileManager = NSFileManager()

            success = fileManager.copyItemAtURL(sourceURL, toURL: destinationURL, error: &error)

            if success {
                let fileAttributes = [NSFileExtensionHidden: true]
                fileManager.setAttributes(fileAttributes, ofItemAtPath: destinationURL.path, error: nil)

                NSLog("Moved file: \(sourceURL.absoluteString) to: \(destinationURL.absoluteString).")
            }
        }
        
        if !success {
            // In your app, handle this gracefully.
            NSLog("Couldn't move file: \(fromURL.absoluteString) to: \(toURL.absoluteString). Error: \(error).")
        }
    }
    
    public func deleteFileAtURL(fileURL: NSURL) {
        let fileCoordinator = NSFileCoordinator()
        var error: NSError?
        var success = false
        
        fileCoordinator.coordinateWritingItemAtURL(fileURL, options: .ForDeleting, error: &error) { writingURL in
            let fileManager = NSFileManager()

            success = fileManager.removeItemAtURL(writingURL, error: &error)
        }

        if !success {
            // In your app, handle this gracefully.
            NSLog("Couldn't delete file at URL \(fileURL.absoluteString). Error: \(error).")
            abort()
        }
    }
    
    // MARK: Document Name Helper Methods
    
    public func documentURLForName(name: String) -> NSURL {
        return documentsDirectory.URLByAppendingPathComponent(name).URLByAppendingPathExtension(AppConfiguration.listerFileExtension)
    }
    
    public func isValidDocumentName(name: String) -> Bool {
        if name.isEmpty {
            return false
        }
        
        let proposedDocumentPath = documentURLForName(name).path
        
        return !NSFileManager.defaultManager().fileExistsAtPath(proposedDocumentPath)
    }
}
