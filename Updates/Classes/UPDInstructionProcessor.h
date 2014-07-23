//
//  UPDInstructionProcessor.h
//  Updates
//
//  Created by Bryce Pauken on 7/22/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UPDInstructionProcessor : NSObject

@property (nonatomic, strong) NSArray *instructions;

- (void)beginProcessing;

@end
