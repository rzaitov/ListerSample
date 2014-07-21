/*
    Copyright (C) 2014 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    
                Handles application configuration logic and information.
            
*/

import Foundation

public class AppConfiguration {
    private struct Defaults {
        static let firstLaunchKey = "AppConfiguration.Defaults.firstLaunchKey"
        static let storageOptionKey = "AppConfiguration.Defaults.storageOptionKey"
        static let storedUbiquityIdentityToken = "AppConfiguration.Defaults.storedUbiquityIdentityToken"
    }

    public struct Notifications {
        public struct StorageOptionDidChange {
            static let name = "AppConfiguration.Notifications.StorageOptionDidChange"
        }
    }
    
    public struct Extensions {
        #if os(iOS)
        public static let widgetBundleIdentifier = "com.example.apple-samplecode.Lister.ListerToday"
        #elseif os(OSX)
        public static let widgetBundleIdentifier = "com.example.apple-samplecode.Lister.ListerTodayOSX"
        #endif
    }
    
    public enum Storage: Int {
        case NotSet = 0, Local, Cloud
    }
    
    public class var sharedConfiguration: AppConfiguration {
        struct Singleton {
            static let sharedAppConfiguration = AppConfiguration()
        }

        return Singleton.sharedAppConfiguration
    }
    
    public class var listerFileExtension: String {
        return "list"
    }
    
    public class var defaultListerDraftName: String {
        return NSLocalizedString("List", comment: "")
    }
    
    public class var localizedTodayDocumentName: String {
        return NSLocalizedString("Today", comment: "The name of the Today list")
    }
    
    public class var localizedTodayDocumentNameAndExtension: String {
        return "\(localizedTodayDocumentName).\(listerFileExtension)"
    }
    
    public var storedIdentityToken: protocol<NSCoding, NSCopying, NSObjectProtocol>? {
        var storedToken: protocol<NSCoding, NSCopying, NSObjectProtocol>?
        
        // Determine if the logged in iCloud account has changed since the user last launched the app.
        let archivedObject: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey(Defaults.storedUbiquityIdentityToken)
        
        if let ubiquityIdentityTokenArchive = archivedObject as? NSData {
            if let archivedObject = NSKeyedUnarchiver.unarchiveObjectWithData(ubiquityIdentityTokenArchive) as? protocol<NSCoding, NSCopying, NSObjectProtocol> {
                storedToken = archivedObject
            }
        }
        
        return storedToken
    }

    public func runHandlerOnFirstLaunch(handler: Void -> Void) {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        defaults.registerDefaults([
            Defaults.firstLaunchKey: true,
            Defaults.storageOptionKey: Storage.NotSet.toRaw()
        ])

        if defaults.boolForKey(Defaults.firstLaunchKey) {
            defaults.setBool(false, forKey: Defaults.firstLaunchKey)
            handler()
        }
    }
    
    public var storageOption: Storage {
        get {
            let value = NSUserDefaults.standardUserDefaults().integerForKey(Defaults.storageOptionKey)
            
            return Storage.fromRaw(value)!
        }

        set {
            if newValue != Storage.fromRaw(NSUserDefaults.standardUserDefaults().integerForKey(Defaults.storageOptionKey)) {
                NSUserDefaults.standardUserDefaults().setInteger(newValue.toRaw(), forKey: Defaults.storageOptionKey)

                NSNotificationCenter.defaultCenter().postNotificationName(Notifications.StorageOptionDidChange.name, object: self, userInfo: nil)
            }
        }
    }
    
    public var isCloudAvailable: Bool {
        return NSFileManager.defaultManager().ubiquityIdentityToken ? true : false
    }

    // Convenience property to fetch the 3 cloud related states.
    public var storageState: (storageOption: Storage, accountDidChange: Bool, cloudAvailable: Bool) {
        return (storageOption: storageOption, accountDidChange: hasUbiquityIdentityChanged, cloudAvailable: isCloudAvailable)
    }
    
    // MARK: Identity
    
    public var hasUbiquityIdentityChanged: Bool {
        if storageOption != .Cloud {
            return false
        }

        var hasChanged = false
        
        let currentToken: protocol<NSCoding, NSCopying, NSObjectProtocol>? = NSFileManager.defaultManager().ubiquityIdentityToken
        let storedToken: protocol<NSCoding, NSCopying, NSObjectProtocol>? = storedIdentityToken

        let currentTokenNilStoredNonNil = !currentToken && storedToken
        let storedTokenNilCurrentNonNil = currentToken && !storedToken
        // Need to compare the tokens use isEqual(_:) since we only know that they conform to NSObjectProtocol.
        let currentNotEqualStored = currentToken && storedToken && !currentToken!.isEqual(storedToken!)

        if currentTokenNilStoredNonNil || storedTokenNilCurrentNonNil || currentNotEqualStored {
            handleUbiquityIdentityChange()
            hasChanged = true
        }

        return hasChanged
    }
    
    public func handleUbiquityIdentityChange() {
        var defaults = NSUserDefaults.standardUserDefaults()

        if let token = NSFileManager.defaultManager().ubiquityIdentityToken {
            NSLog("The user signed into a different iCloud account.")
            let ubiquityIdentityTokenArchive = NSKeyedArchiver.archivedDataWithRootObject(token)
            defaults.setObject(ubiquityIdentityTokenArchive, forKey: Defaults.storedUbiquityIdentityToken)
        }
        else {
            NSLog("The user signed out of iCloud.")
            defaults.removeObjectForKey(Defaults.storedUbiquityIdentityToken)
        }
    }
}