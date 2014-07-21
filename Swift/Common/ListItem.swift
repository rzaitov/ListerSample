/*
    Copyright (C) 2014 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    
                The ListItem class represents the text and completion state of a single item in the list.
            
*/

import Foundation

// To ensure that the ListItem class can be serialized from both Swift and Objective-C, we need to make sure that
// the runtime name of the ListItem class is the same in both contexts. To do these in Swift, we use the @objc marker
// on the class with the desired runtime name.
@objc(AAPLListItem)
public class ListItem: NSObject, NSCoding, NSCopying {
    // MARK: Types

    // Serialization keys that are using to implement NSCoding.
    private struct SerializationKey {
        static let text = "text"
        static let uuid = "uuid"
        static let completed = "completed"
    }

    // MARK: Properties

    public var text: String
    public var isComplete: Bool

    // Used for ListItem equality.
    private(set) var UUID: NSUUID

    // MARK: Initialization

    public init(text: String, completed: Bool, UUID: NSUUID) {
        self.text = text
        self.isComplete = completed
        self.UUID = UUID
    }
    
    public convenience init(text: String) {
        self.init(text: text, completed: false, UUID: NSUUID())
    }
    
    // MARK: NSCopying

    public func copyWithZone(zone: NSZone) -> AnyObject  {
        return ListItem(text: text, completed: isComplete, UUID: UUID)
    }
    
    // MARK: NSCoding

    public init(coder aDecoder: NSCoder) {
        text = aDecoder.decodeObjectForKey(SerializationKey.text) as String
        UUID = aDecoder.decodeObjectForKey(SerializationKey.uuid) as NSUUID
        isComplete = aDecoder.decodeBoolForKey(SerializationKey.completed)
    }
    
    public func encodeWithCoder(encoder: NSCoder) {
        encoder.encodeObject(text, forKey: SerializationKey.text)
        encoder.encodeObject(UUID, forKey: SerializationKey.uuid)
        encoder.encodeBool(isComplete, forKey: SerializationKey.completed)
    }

    /// Reset the UUID if the object needs to be re-tracked.
    public func refreshIdentity() {
        UUID = NSUUID()
    }
    
    // MARK: Overrides

    override public func isEqual(object: AnyObject?) -> Bool {
        if let listItem = object as? ListItem {
            return UUID == listItem.UUID
        }
        
        return false
    }
}
