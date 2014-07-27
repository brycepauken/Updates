//
//  UPDInstructionProcessor.h
//  Updates
//
//  Created by Bryce Pauken on 7/22/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UPDInstructionProcessor : NSObject

@property (nonatomic, copy) void(^completionBlock)(NSArray *instructions, UIImage *favicon, NSString *lastResponse);
@property (nonatomic, strong) NSArray *instructions;
@property (nonatomic, strong) NSString *url;

- (void)beginProcessing;

@end
