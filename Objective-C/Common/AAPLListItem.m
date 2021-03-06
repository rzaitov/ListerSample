/*
     Copyright (C) 2014 Apple Inc. All Rights Reserved.
     See LICENSE.txt for this sample’s licensing information
     
     Abstract:
     
                  The AAPLListItem class represents the text and completion state of a single item in the list.
              
 */

#import "AAPLListItem.h"

@interface AAPLListItem()

@property NSUUID *UUID;

@end

NSString *const AAPLListItemEncodingTextKey = @"text";
NSString *const AAPLListItemEncodingCompletedKey = @"completed";
NSString *const AAPLListItemEncodingUUIDKey = @"uuid";

@implementation AAPLListItem

#pragma mark - Initialization

- (instancetype)initWithText:(NSString *)text complete:(BOOL)complete UUID:(NSUUID *)UUID {
    self = [super init];
    
    if (self) {
        _text = [text copy];
        _complete = complete;
        _UUID = UUID;
    }
    
    return self;
}

- (instancetype)initWithText:(NSString *)text {
    return [self initWithText:text complete:NO UUID:[NSUUID UUID]];
}


#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    return [[AAPLListItem alloc] initWithText:self.text complete:self.isComplete UUID:self.UUID];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    
    if (self) {
        _text = [aDecoder decodeObjectForKey:AAPLListItemEncodingTextKey];
        _UUID = [aDecoder decodeObjectForKey:AAPLListItemEncodingUUIDKey];
        _complete = [aDecoder decodeBoolForKey:AAPLListItemEncodingCompletedKey];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.text forKey:AAPLListItemEncodingTextKey];
    [aCoder encodeObject:self.UUID forKey:AAPLListItemEncodingUUIDKey];
    [aCoder encodeBool:self.isComplete forKey:AAPLListItemEncodingCompletedKey];
}

- (void)refreshIdentity {
    self.UUID = [NSUUID UUID];
}

#pragma mark - Equality

- (BOOL)isEqualToListItem:(AAPLListItem *)item {
    return [self.UUID isEqual:item.UUID];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[AAPLListItem class]]) {
        return [self isEqualToListItem:object];
    }
    
    return NO;
}

@end
