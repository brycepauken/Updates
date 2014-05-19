//
//  UPDCommon.m
//  Update
//
//  Created by Bryce Pauken on 5/16/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDCommon.h"

@implementation UPDCommon

+ (BOOL)isIOS7 {
    return ([[[UIDevice currentDevice] systemVersion] compare:@"7" options:NSNumericSearch] != NSOrderedAscending);
}

+ (BOOL)isIPad {
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

+ (CGSize)sizeOfText:(NSString *)text withFont:(UIFont *)font {
    return [self sizeOfText:text withFont:font constrainedToWidth:MAXFLOAT singleLine:NO];
}

+ (CGSize)sizeOfText:(NSString *)text withFont:(UIFont *)font constrainedToWidth:(CGFloat)width {
    return [self sizeOfText:text withFont:font constrainedToWidth:width singleLine:NO];
}

+ (CGSize)sizeOfText:(NSString *)text withFont:(UIFont *)font constrainedToWidth:(CGFloat)width singleLine:(BOOL)singleLine {
    if([self isIOS7]) {
        CGRect labelRect;
        if(singleLine) {
            labelRect = [text boundingRectWithSize:CGSizeMake(width, 1) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:font} context:nil];
        }
        else {
            labelRect = [text boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
        }
        labelRect.size.width = ceil(labelRect.size.width);
        labelRect.size.height = ceil(labelRect.size.height);
        return labelRect.size;
    }
    /*else {
        if(singleLine) {
            return [text sizeWithFont:font forWidth:width lineBreakMode:NSLineBreakByWordWrapping];
        }
        else {
            return [text sizeWithFont:font constrainedToSize:CGSizeMake(width, MAXFLOAT)];
        }
    }*/
    return CGSizeZero;
}

+ (CGSize)sizeOfText:(NSString *)text withFont:(UIFont *)font singleLine:(BOOL)singleLine {
    return [self sizeOfText:text withFont:font constrainedToWidth:MAXFLOAT singleLine:singleLine];
}

@end
