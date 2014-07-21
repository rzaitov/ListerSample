# Lister

## Version

1.0

## Build and Runtime Requirements
	+ Xcode 6
	+ iOS 8.0
	+ OS X 10.10
	+ iCloud–enabled provisioning profile


## Configuring the Project

Configuring your Xcode project and your Mac requires a few steps in the iOS and OS X Provisioning Portals, as well as in Xcode:

1) Configure each Mac and iOS device you plan to test with an iCloud account. Create or use an existing Apple ID account that supports iCloud.

2) Configure the team for the targets within the project.

Navigate to the project in the project navigator within Xcode and select each of the targets. Set the Team on the General tab to the team associated with your developer account.

3) Change the Xcode project Entitlements to match your Team ID.

An entitlements file in this sample project includes the key com.apple.developer.ubiquity-container-identifiers. For your own app you will need to use a different value to match your Team ID (or company/organization ID). The following container identifier is shared among all apps included in the Lister sample:

$(TeamIdentifierPrefix)com.example.apple-samplecode.Lister

Where $(TeamIdentifierPrefix) is a placeholder that will be replaced during the build process with the Team ID found on the Provisioning Portal. The remainder is a unique identifier to be shared among all apps that will share documents through iCloud—this identifier must be changed in order to use iCloud.

4) Allow Xcode to generate provisioning profiles to match your needs. 

On each device that you will test with, update the bundle identifier on the Target > Info tab to a valid value for your organization. It is recommended that you use a reverse DNS identifier. The bundle identifier defined on your Xcode project's Target > Info tab needs to match the App ID in the iCloud provisioning profile. To generate provisioning profiles, build the project and accept the Fix Issue option that Xcode provides. When you run the iOS app, a provisioning profile is created for the iOS app. Similarly, running the OS X app creates a provisioning profile for the OS X app.

Note: If your provisioning profile's App ID is $(TeamIdentifierPrefix).com.example.apple-samplecode.Lister, then the bundle identifier of your app must be com.example.apple-samplecode.Lister. 

5) For both iOS and OS X targets, assign the new profile to your Debug > Code Signing Identities in your Xcode project Target > Build Settings.

6) Set your code signing identity in your Xcode project to match your particular App ID.


## About Lister

Lister is a Cocoa productivity sample code project for iOS and OS X. In this sample, the user can create lists, add items to lists, and track the progress of items in the lists.


## Written in Objective-C and Swift

This sample is written in both Objective-C and Swift. Both versions of the sample are at the top level directory of this project in folders named "Objective-C" and "Swift". Both versions of the application have the exact same visual appearance; however, the code and structure may be different depending on the choice of language.

Note: The List class in Swift is conceptually equivalent to the AAPLList class in Objective C. The same applies to other classes mentioned in this README; Swift drops the AAPL from the class. To refer to conceptually-equivalent classes, this README uses the format {AAPL}List.  


## Application Architecture

The Lister project includes iOS and OS X app targets, iOS and OS X app extensions, and frameworks containing shared code.


### OS X

Lister for OS X is a document-based application with a single window per document. To organize the implementation of the app, Lister takes a modular design approach. Three main controllers are each responsible for different portions of the user interface and document interaction: {AAPL}ListWindowController manages a single window and owns the document associated with the window. The window controller also implements interactions with the window’s toolbar such as sharing. The window controller is also responsible for presenting an {AAPL}AddItemViewController object that allows the user to quickly add an item to the list. The {AAPL}ListViewController is responsible for displaying each item in a table view in the window.

Lister's design and controller interactions are implemented in a Mac Storyboard. A storyboard makes it easy to visualize the relationships between view controllers and to lay out the user interface of the app. Lister also takes advantage of Auto Layout to fluidly resize the interface as the user resizes the window. If you're opening the project for the first time, the Storyboard.storyboard file is a good place to understand how the app works.

Although much of the view layer is implemented with built-in AppKit views and controls, there are several interesting custom views in Lister. The {AAPL}ColorPaletteView class is an interface to select a list's color. When the user shows or hides the color palette, the view dynamically animates the constraints defined in Interface Builder. The {AAPL}ListTableView and {AAPL}TableRowView classes are responsible for displaying list items in the table view.

Document storage in Lister is implemented in the {AAPL}ListDocument class, a subclass of NSDocument. Documents are stored as keyed archives. {AAPL}ListDocument reuses much of the same model code shared between the OS X and iOS apps. Additionally, the {AAPL}ListDocument class enables Auto Save and Versions, undo management, and more. With the {AAPL}ListFormatting class, the user can copy and paste items between Lister and other apps, and even share items.

The Lister app manages a Today list that it stores in iCloud document storage. The {AAPL}TodayListManager class is responsible for creating, locating, and retrieving the today {AAPL}ListDocument object from the user's iCloud container. Open the Today list with the Command-T key combination.


### iOS

The iOS version of Lister follows many of the same design principles as the OS X version—the two versions share common code. The iOS version  follows the Model-View-Controller (MVC) design pattern and uses modern app development practices including Storyboards and Auto Layout. In the iOS version of Lister, the user manages multiple lists using a table view implemented in the {AAPL}ListDocumentsViewController class. In addition to vending rows in the table view, the list documents controller observes changes to the lists, as well as the status of iCloud. Tapping on a list brings the user to the ListViewController. This class displays and manages a single document. The {AAPL}NewListDocumentController class allows a user to create a new list.

The {AAPL}ListCoordinator class tracks the user's storage choice—local or iCloud—and moves the user's documents between the two storage locations. The {AAPL}ListDocument class, a subclass of UIDocument, represents an individual list document that is responsible for serialization and deserialization. 

Rather than directly manage {AAPL}List objects, the {AAPL}ListDocumentsViewController class manages an array of {AAPL}ListInfo objects. The {AAPL}ListInfo class abstracts the particular storage mechanism away from APIs that contain similar metadata-related properties required for display (a list’s name and color). The backing metadata is provided by an object that conforms to the {AAPL}ListInfoProvider protocol—either an NSURL object or an NSMetadataItem object. 


### Shared Code

Much of the model layer code for Lister is used throughout the entire project, across the iOS and OS X platforms. {AAPL}List and {AAPL}ListItem are the two main model objects. The {AAPL}ListItem class represents a single item in a list. It contains only three stored properties: the text of the item, a Boolean indicating whether the user has completed it, and a unique identifier. Along with these properties, the {AAPL}ListItem class also implements the functionality required to compare, archive, and unarchive a {AAPL}ListItem object. The {AAPL}List class holds an array of these {AAPL}ListItem objects, as well as the color the desired list color. The {AAPL}List class also supports indexed subscripting, archiving, unarchiving, and equality.

Archiving and unarchiving are specifically designed and implemented so that model objects can be unarchived regardless of the language, Swift or Objective–C, or the platform, iOS or OS X, that they were archived on.

In addition to model code, by subclassing CALayer(a class shared by iOS and OS X),Lister shares checkbox drawing code with both platforms. The project includes a control class for each platform with user interface framework–specific code. These {AAPL}CheckBox classes use the designable and inspectable attributes so that the custom drawing code is viewable and adjustable live in Interface Builder.


## Swift Features

The Lister sample leverages many features unique to Swift, including the following:

#### Nested types

The List.Color enumeration represents a list's associated color.

#### String Constants

Constants are defined using structs and static members to avoid keeping constants in the global namespace. One example is notification constants, which are typically defined as global string constants in Objective-C. Nested structures inside types allow for better organization of notifications in Swift.

#### Extensions on Types at Different Layers of a Project

The List.Color enum is defined in the List model object. It is extended in the UI layer (ListColorUI.swift) so that it can be easily converted into a platform-specific color object.

#### Subscripting

The List class provides access to its ListItem objects through indexed subscripting. The List object stores ListItem objects in an in-memory Array.

#### Tuples

List is responsible for managing the order of its ListItem objects. When an item is moved from one row to another, the list returns a lightweight tuple that contains both the "from" and "to" indices. This tuple is used in a few different methods in the List class.

Copyright (C) 2014 Apple Inc. All rights reserved.
