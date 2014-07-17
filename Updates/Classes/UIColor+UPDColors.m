//
//  NSColor+UPDColors.m
//  Updates
//
//  Created by Bryce Pauken on 7/15/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UIColor+UPDColors.h"

@implementation UIColor (UPDColors)

+ (UIColor *)UPDApplicationBackgroundColor {
    return [self UPDLightGreyColor];
}

+ (UIColor *)UPDLightBlueColor {
    static UIColor *lightBlueColor = nil;
    static dispatch_once_t dispatchOnceToken;
    
    dispatch_once(&dispatchOnceToken, ^{
        lightBlueColor = [UIColor colorWithRed:115/255.0f green:167/255.0f blue:197/255.0f alpha:1];
    });
    
    return lightBlueColor;
}

+ (UIColor *)UPDLighterBlueColor {
    static UIColor *lighterBlueColor = nil;
    static dispatch_once_t dispatchOnceToken;
    
    dispatch_once(&dispatchOnceToken, ^{
        lighterBlueColor = [UIColor colorWithRed:172/255.0f green:198/255.0f blue:213/255.0f alpha:1];
    });
    
    return lighterBlueColor;
}

+ (UIColor *)UPDLightGreyColor {
    static UIColor *lightGrayColor = nil;
    static dispatch_once_t dispatchOnceToken;
    
    dispatch_once(&dispatchOnceToken, ^{
        lightGrayColor = [UIColor colorWithWhite:0.90 alpha:1];
    });
    
    return lightGrayColor;
}

+ (UIColor *)UPDOffBlackColor {
    static UIColor *offBlackColor = nil;
    static dispatch_once_t dispatchOnceToken;
    
    dispatch_once(&dispatchOnceToken, ^{
        offBlackColor = [UIColor colorWithWhite:0.1 alpha:1];
    });
    
    return offBlackColor;
}

+ (UIColor *)UPDOffWhiteColor {
    static UIColor *offWhiteColor = nil;
    static dispatch_once_t dispatchOnceToken;
    
    dispatch_once(&dispatchOnceToken, ^{
        offWhiteColor = [UIColor colorWithWhite:0.98 alpha:1];
    });
    
    return offWhiteColor;
}

@end
