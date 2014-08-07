//
//  NSData+UPDExtensions.h
//  Updates
//
//  Created by Bryce Pauken on 8/6/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (UPDExtensions)

+ (NSData *)decryptData:(NSData *)data withKey:(NSString *)key;
+ (NSData *)encryptData:(NSData *)data withKey:(NSString *)key;

@end
