//
//  UPDURLProtocol.h
//  Updates
//
//  Created by Bryce Pauken on 7/18/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UPDInstructionAccumulator;

@interface UPDURLProtocol : NSURLProtocol <NSURLSessionDelegate>

+ (void)createSession;
+ (void)invalidateSession;
+ (void)setDisableProtocol:(BOOL)disableProtocol;
+ (void)setInstructionAccumulator:(UPDInstructionAccumulator *)instructionAccumulator;
+ (void)setPreventUnnecessaryLoading:(BOOL)preventUnnecessaryLoading;

@end