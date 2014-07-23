//
//  UPDInstructionAccumulator.h
//  Updates
//
//  Created by Bryce Pauken on 7/18/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UPDInstructionAccumulator : NSObject

@property (nonatomic, strong) NSMutableArray *instructions;

- (void)addInstructionWithURL:(NSString *)url post:(NSString *)post response:(NSString *)response headers:(NSDictionary *)headers;

@end
