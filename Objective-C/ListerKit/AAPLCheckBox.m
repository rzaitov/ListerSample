/*
    Copyright (C) 2014 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    
                A custom check box for use in the lists, it supports designing live in IB.
            
*/

#import "AAPLCheckbox.h"
#import "AAPLCheckBoxLayer.h"

@interface AAPLCheckBox()

@property (readonly) AAPLCheckBoxLayer *checkBoxLayer;

@end

@implementation AAPLCheckBox

#pragma mark - Overrides

+ (Class)layerClass {
    return [AAPLCheckBoxLayer class];
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    
    self.checkBoxLayer.tintColor = self.tintColor.CGColor;
}

#pragma mark - Property Overrides

- (void)setChecked:(BOOL)checked {
    self.checkBoxLayer.checked = checked;
    
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
}

- (BOOL)isChecked {
    return self.checkBoxLayer.isChecked;
}

- (void)setStrokeFactor:(CGFloat)strokeFactor {
    self.checkBoxLayer.strokeFactor = strokeFactor;
}

- (CGFloat)strokeFactor {
    return self.checkBoxLayer.strokeFactor;
}

- (void)setInsetFactor:(CGFloat)insetFactor {
    self.checkBoxLayer.insetFactor = insetFactor;
}

- (CGFloat)insetFactor {
    return self.insetFactor;
}

- (void)setMarkInsetFactor:(CGFloat)markInsetFactor {
    self.checkBoxLayer.markInsetFactor = markInsetFactor;
}

- (CGFloat)markInsetFactor {
    return self.checkBoxLayer.markInsetFactor;
}

#pragma mark - Convenience

- (AAPLCheckBoxLayer *)checkBoxLayer {
    return (AAPLCheckBoxLayer *)self.layer;
}

@end
