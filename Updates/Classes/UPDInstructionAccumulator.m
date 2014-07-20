//
//  UPDInstructionAccumulator.m
//  Updates
//
//  Created by Bryce Pauken on 7/18/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDInstructionAccumulator.h"

#import "UPDInternalInstruction.h"

@interface UPDInstructionAccumulator()

@property (nonatomic, strong) NSMutableArray *instructions;

@end

@implementation UPDInstructionAccumulator

- (instancetype)init {
    self = [super init];
    if(self) {
        self.instructions = [NSMutableArray array];
    }
    return self;
}

/*
 Our URL Protocol calls this method to forward along the instructions
 it recieves. The post argument is an NSString, so this method must
 also parse the string into an NSDictionary.
 */
- (void)addInstructionWithURL:(NSString *)url post:(NSString *)post response:(NSString *)response headers:(NSDictionary *)headers {
    UPDInternalInstruction *instruction = [[UPDInternalInstruction alloc] init];
    NSURL *tempURL = [NSURL URLWithString:url];
    
    [instruction setBaseURL:([url rangeOfString:@"?" options:NSBackwardsSearch].location==NSNotFound?url:[url substringToIndex:[url rangeOfString:@"?" options:NSBackwardsSearch].location])];
    [instruction setHeaders:headers];
    [instruction setFullURL:url];
    [instruction setResponse:response];
    
    for(int getOrPost=0;getOrPost<2;getOrPost++) {
        NSString *targetString = (getOrPost?post:tempURL.query);
        if(targetString.length) {
            NSArray *keyValuePairs = [targetString componentsSeparatedByString:@"&"];
            for(NSString *keyValuePair in keyValuePairs) {
                NSArray *keyValuePairArray = [keyValuePair componentsSeparatedByString:@"="];
                if ([keyValuePairArray count] >= 2) {
                    NSString *key = [[[keyValuePairArray objectAtIndex:0] stringByReplacingOccurrencesOfString:@"+" withString:@" "] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    NSString *value = [[[keyValuePairArray objectAtIndex:1] stringByReplacingOccurrencesOfString:@"+" withString:@" "] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    NSMutableDictionary *targetDictionary = (getOrPost?instruction.post:instruction.get);
                    NSMutableArray *values = [targetDictionary objectForKey:key];
                    if(!values) {
                        values = [[NSMutableArray alloc] initWithCapacity:1];
                        [targetDictionary setObject:values forKey:key];
                    }
                    [values addObject:value];
                }
            }
        }
    }
}

@end
