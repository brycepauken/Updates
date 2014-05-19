//
//  UPDCommon.h
//  Update
//
//  Created by Bryce Pauken on 5/16/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <POP/POP.h>
#import <QuartzCore/QuartzCore.h>
#import "UPDAppDelegate.h"
#import "UPDColors.h"
#import "UPDConstants.h"

#define AppDelegate ((UPDAppDelegate *)[UIApplication sharedApplication].delegate)

@interface UPDCommon : NSObject

+ (BOOL)isIOS7;
+ (BOOL)isIPad;
+ (CGSize)sizeOfText:(NSString *)text withFont:(UIFont *)font;
+ (CGSize)sizeOfText:(NSString *)text withFont:(UIFont *)font constrainedToWidth:(CGFloat)width;
+ (CGSize)sizeOfText:(NSString *)text withFont:(UIFont *)font constrainedToWidth:(CGFloat)width singleLine:(BOOL)singleLine;
+ (CGSize)sizeOfText:(NSString *)text withFont:(UIFont *)font singleLine:(BOOL)singleLine;

@end
