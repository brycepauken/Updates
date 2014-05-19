//
//  UPDColors.m
//  Updates
//
//  Created by Bryce Pauken on 5/17/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDColors.h"

@implementation UIColor (UPDColors)

+ (UIColor *)UPDBrightBlueColor {
    static UIColor *color = nil;
    if(!color) {
        color = [UIColor colorWithRed:99/255.0 green:161/255.0 blue:247/255.0 alpha:1];
    }
    return color;
}

+ (UIColor *)UPDBrowserStartColor {
    static UIColor *color = nil;
    if(!color) {
        color = [UIColor colorWithRed:13/255.0 green:79/255.0 blue:139/255.0 alpha:1];
    }
    return color;
}

+ (UIColor *)UPDOffBlackColor {
    static UIColor *color = nil;
    if(!color) {
        color = [UIColor colorWithWhite:0.2 alpha:1];
    }
    return color;
}

+ (UIColor *)UPDOffWhiteColor {
    static UIColor *color = nil;
    if(!color) {
        color = [UIColor colorWithWhite:0.95 alpha:1];
    }
    return color;
}

@end