//
//  UPDInstructionRunner.m
//  Updates
//
//  Created by Bryce Pauken on 7/26/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDInstructionRunner.h"

#import "UPDDocumentComparator.h"
#import "UPDDocumentSearcher.h"
#import "UPDInternalInstruction.h"

@implementation UPDInstructionRunner

+ (void)pageFromInstructions:(NSArray *)instructions differsFromPage:(NSString *)page differenceOptions:(NSDictionary *)differenceOptions completionBlock:(void (^)(UPDInstructionRunnerResult result, NSString *newResponse))completionBlock {
    [self clearPersistentData];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue setMaxConcurrentOperationCount:5];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration] delegate:nil delegateQueue:queue];
    if(instructions.count==1) {
        UPDInternalInstruction *instruction = [instructions lastObject];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:instruction.request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            [session invalidateAndCancel];
            NSString *newResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            completionBlock([self page:newResponse differsFromPage:page differenceOptions:differenceOptions], newResponse);
        }];
        [task resume];
    }
    else {
        [self runAllInstructions:instructions fromIndex:0 lastResponse:nil usingSession:session differencePage:page differenceOptions:differenceOptions completionBlock:completionBlock];
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

+ (void)runAllInstructions:(NSArray *)workingInstructions fromIndex:(int)index lastResponse:(NSString *)lastResponse usingSession:(NSURLSession *)session differencePage:(NSString *)page differenceOptions:(NSDictionary *)differenceOptions completionBlock:(void (^)(UPDInstructionRunnerResult result, NSString *newResponse))completionBlock {
    UPDInternalInstruction *prevInstruction = nil;
    UPDInternalInstruction *instruction = [workingInstructions objectAtIndex:index];
    NSURLRequest *request = instruction.request;
    if(index>0 && lastResponse) {
        prevInstruction = [workingInstructions objectAtIndex:index-1];
        NSArray *newPost = [UPDDocumentSearcher document:lastResponse equivilantInputFieldForArray:instruction.post orignalResponse:prevInstruction.response];
        NSMutableString *newHTTPBody = [[NSMutableString alloc] init];
        for(int i=0;i<newPost.count;i++) {
            if(i>0) {
                [newHTTPBody appendString:@"&"];
            }
            [newHTTPBody appendString:CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)[[newPost objectAtIndex:i] objectAtIndex:0], NULL, (__bridge CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ", CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)))];
            [newHTTPBody appendString:@"="];
            [newHTTPBody appendString:CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)[[newPost objectAtIndex:i] objectAtIndex:1], NULL, (__bridge CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ", CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)))];
        }
        NSMutableURLRequest *mutableRequest = [request mutableCopy];
        [mutableRequest setHTTPBody:[newHTTPBody dataUsingEncoding:NSUTF8StringEncoding]];
        request = mutableRequest;
    }
    index++;
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *newResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if(index<workingInstructions.count) {
            [self runAllInstructions:workingInstructions fromIndex:index lastResponse:newResponse usingSession:session differencePage:page differenceOptions:differenceOptions completionBlock:completionBlock];
        }
        else {
            [session invalidateAndCancel];
            completionBlock([self page:newResponse differsFromPage:page differenceOptions:differenceOptions], newResponse);
        }
    }];
    [task resume];
}

@end
