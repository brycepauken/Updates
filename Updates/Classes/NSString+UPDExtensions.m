//
//  NSString+UPDExtensions.m
//  Updates
//
//  Created by Bryce Pauken on 8/7/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "NSString+UPDExtensions.h"

#import <CommonCrypto/CommonHMAC.h>

@implementation NSString (UPDExtensions)

- (NSString *)hashedString; {
    const char *cString = [self UTF8String];
    unsigned char hashResult[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(cString, (CC_LONG)strlen(cString), hashResult);
    
    NSMutableString *returnString = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH*2];
    for(int i=0; i<CC_SHA256_DIGEST_LENGTH; i++) {
        [returnString appendFormat:@"%02x",hashResult[i]];
    }
    return returnString;
}

@end
