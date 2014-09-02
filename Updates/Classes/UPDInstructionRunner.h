//
//  UPDInstructionRunner.h
//  Updates
//
//  Created by Bryce Pauken on 7/26/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UPDInstructionRunnerResult) {
    UPDInstructionRunnerResultNoChange,
    UPDInstructionRunnerResultChange,
    UPDInstructionRunnerResultUnknown
};

@interface UPDInstructionRunner : NSObject

+ (void)pageFromInstructions:(NSArray *)instructions differsFromPage:(NSString *)page differenceOptions:(NSDictionary *)differenceOptions progressBlock:(void (^)(CGFloat progress))progressBlock completionBlock:(void (^)(UPDInstructionRunnerResult result, NSString *newResponse, NSDictionary *newDifferenceOptions))completionBlock;

@end
