//
//  UPDInstructionRunner.m
//  Updates
//
//  Created by Bryce Pauken on 7/26/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDInstructionRunner.h"

#import "UPDDocumentComparator.h"
#import "UPDInternalInstruction.h"

@implementation UPDInstructionRunner

+ (void)pageFromInstructions:(NSArray *)instructions differsFromPage:(NSString *)page differenceOptions:(NSDictionary *)differenceOptions completionBlock:(void (^)(UPDInstructionRunnerResult result, NSString *newResponse))completionBlock {
    [self clearPersistentData];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue setMaxConcurrentOperationCount:5];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:queue];
    if(instructions.count==1) {
        UPDInternalInstruction *instruction = [instructions lastObject];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:instruction.request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSString *newResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            completionBlock([self page:newResponse differsFromPage:page differenceOptions:differenceOptions], newResponse);
        }];
        [task resume];
    }
    else {
        completionBlock(UPDInstructionRunnerResultNoChange, nil);
    }
}

/*
 Clears cookies and the cache—important for making sure a request
 can be duplicated every time.
 */
+ (void)clearPersistentData {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (UPDInstructionRunnerResult)page:(NSString *)page differsFromPage:(NSString *)difPage differenceOptions:(NSDictionary *)differenceOptions {
    if([[differenceOptions objectForKey:@"DifferenceType"] isEqualToString:@"Any"]) {
        if([UPDDocumentComparator document:page visibleTextIsEqualToDocument:difPage]) {
            return UPDInstructionRunnerResultNoChange;
        }
        else {
            return UPDInstructionRunnerResultChange;
        }
    }
    return UPDInstructionRunnerResultNoChange;
}

@end
