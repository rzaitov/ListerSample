/*
    Copyright (C) 2014 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    
                A UIDocument subclass that represents a list. It mainly manages the serialization / deserialization of the list object.
            
*/

import UIKit

/// Protocol that allows a list document to notify other objects of it being deleted.
@objc
public protocol ListDocumentDelegate {
    func listDocumentWasDeleted(listDocument: ListDocument)
}

public class ListDocument: UIDocument {
    // MARK: Properties

    public weak var delegate: ListDocumentDelegate?
    
    // Use a default, empty list.
    public var list = List()
    
    // MARK: Initializers
    
    public init(fileURL url: NSURL) {
        super.init(fileURL: url)
    }

    // MARK: Serialization / Deserialization
    
    override public func loadFromContents(contents: AnyObject, ofType typeName: String, error outError: NSErrorPointer) -> Bool {
        if let deserializedList = NSKeyedUnarchiver.unarchiveObjectWithData(contents as NSData) as? List {
            list = deserializedList
            
            return true
        }
        
        if outError {
            outError.memory = NSError(domain: NSCocoaErrorDomain, code: NSFileReadCorruptFileError, userInfo: [
                NSLocalizedDescriptionKey: NSLocalizedString("Could not read file", comment: "Read error description"),
                NSLocalizedFailureReasonErrorKey: NSLocalizedString("File was in an invalid format", comment: "Read failure reason")
            ])
        }
        
        return false
    }

    override public func contentsForType(typeName: String, error outError: NSErrorPointer) -> AnyObject? {
        if let serializedList = NSKeyedArchiver.archivedDataWithRootObject(list) {
            return serializedList
        }
        
        if outError {
            outError.memory = NSError(domain: NSCocoaErrorDomain, code: NSFileWriteUnknownError, userInfo: [
                NSLocalizedDescriptionKey: NSLocalizedString("Could not save file", comment: "Write error description"),
                NSLocalizedFailureReasonErrorKey: NSLocalizedString("An unexpected error occured", comment: "Write failure reason")
            ])
        }
        
        return nil
    }
    
    // MARK: Deletion

    public override func accommodatePresentedItemDeletionWithCompletionHandler(completionHandler: ((NSError?) -> Void)?) {
        super.accommodatePresentedItemDeletionWithCompletionHandler(completionHandler)

        delegate?.listDocumentWasDeleted(self)
    }
}
