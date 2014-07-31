//
//  UPDInstructionAccumulator.m
//  Updates
//
//  Created by Bryce Pauken on 7/18/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDInstructionAccumulator.h"

#import "UPDInternalInstruction.h"

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
- (void)addInstructionWithRequest:(NSURLRequest *)request response:(NSString *)response headers:(NSDictionary *)headers {
    UPDInternalInstruction *instruction = [[UPDInternalInstruction alloc] init];
    [instruction setBaseURL:([request.URL.absoluteString rangeOfString:@"?" options:NSBackwardsSearch].location==NSNotFound?request.URL.absoluteString:[request.URL.absoluteString substringToIndex:[request.URL.absoluteString rangeOfString:@"?" options:NSBackwardsSearch].location])];
    [instruction setHeaders:headers];
    [instruction setFullURL:request.URL.absoluteString];
    [instruction setRequest:request];
    [instruction setResponse:response];
    
    for(int getOrPost=0;getOrPost<2;getOrPost++) {
        NSString *targetString = (getOrPost?[[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]:request.URL.query);
        if(targetString.length) {
            NSArray *keyValuePairs = [targetString componentsSeparatedByString:@"&"];
            for(NSString *keyValuePair in keyValuePairs) {
                NSArray *keyValuePairArray = [keyValuePair componentsSeparatedByString:@"="];
                if ([keyValuePairArray count] >= 2) {
                    NSString *key = [[[keyValuePairArray objectAtIndex:0] stringByReplacingOccurrencesOfString:@"+" withString:@" "] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    NSString *value = [[[keyValuePairArray objectAtIndex:1] stringByReplacingOccurrencesOfString:@"+" withString:@" "] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    NSMutableArray *targetArray = (getOrPost?instruction.post:instruction.get);
                    [targetArray addObject:@[key, value]];
                }
            }
        }
    }
    
    [self.instructions addObject:instruction];
}

@end
