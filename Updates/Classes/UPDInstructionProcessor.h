//
//  UPDInstructionProcessor.h
//  Updates
//
//  Created by Bryce Pauken on 7/22/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UPDInternalInstruction;

@interface UPDInstructionProcessor : NSObject

@property (nonatomic, copy) void(^completionBlock)(NSArray *instructions, UIImage *favicon, NSString *lastResponse, NSURL *url);
@property (nonatomic, copy) void(^errorBlock)();
@property (nonatomic, strong) NSArray *instructions;
@property (nonatomic, strong) NSString *url;

- (void)beginProcessingWithLastInstructionBlock:(void (^)(UPDInternalInstruction *))lastInstructionBlock;

@end
