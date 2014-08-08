//
//  UPDInstructionRunner.m
//  Updates
//
//  Created by Bryce Pauken on 7/26/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDInstructionRunner.h"

#import "UPDDocumentComparator.h"
#import "UPDDocumentRenderer.h"
#import "UPDDocumentSearcher.h"
#import "UPDInternalInstruction.h"

@implementation UPDInstructionRunner

+ (void)pageFromInstructions:(NSArray *)instructions differsFromPage:(NSString *)page differenceOptions:(NSDictionary *)differenceOptions completionBlock:(void (^)(UPDInstructionRunnerResult result, NSString *newResponse, NSDictionary *newDifferenceOptions))completionBlock {
    [self clearPersistentData];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue setMaxConcurrentOperationCount:5];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration] delegate:nil delegateQueue:queue];
    if(instructions.count==1) {
        UPDInternalInstruction *instruction = [instructions lastObject];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:instruction.request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            [session invalidateAndCancel];
            NSString *newResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [self page:newResponse differsFromPage:page baseURL:instruction.endRequest.URL differenceOptions:differenceOptions completionBlock:completionBlock];
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

+ (void)page:(NSString *)page differsFromPage:(NSString *)difPage baseURL:(NSURL *)url differenceOptions:(NSDictionary *)differenceOptions completionBlock:(void (^)(UPDInstructionRunnerResult result, NSString *newResponse, NSDictionary *newDifferenceOptions))completionBlock {
    if([[differenceOptions objectForKey:@"DifferenceType"] isEqualToString:@"Any"]) {
        if([UPDDocumentComparator document:page visibleTextIsEqualToDocument:difPage]) {
            completionBlock(UPDInstructionRunnerResultNoChange, page, nil);
        }
        else {
            completionBlock(UPDInstructionRunnerResultChange, page, nil);
        }
    }
    else if([[differenceOptions objectForKey:@"DifferenceType"] isEqualToString:@"Text"]) {
        UPDDocumentRenderer *renderer = [[UPDDocumentRenderer alloc] init];
        [renderer countOccurrencesOfString:[differenceOptions objectForKey:@"DifferenceText"] inDocument:page withBaseURL:url withCompletionBlock:^(int count){
            [renderer clearWebView];
            int oldCount = [[differenceOptions objectForKey:@"DifferenceCount"] intValue];
            if(count==oldCount) {
                completionBlock(UPDInstructionRunnerResultNoChange, page, nil);
            }
            else {
                NSMutableDictionary *newDifferenceOptions = [differenceOptions mutableCopy];
                [newDifferenceOptions setObject:@(count) forKey:@"DifferenceCount"];
                completionBlock(UPDInstructionRunnerResultChange, page, [NSDictionary dictionaryWithDictionary:newDifferenceOptions]);
            }
        }];
    }
    else {
        completionBlock(UPDInstructionRunnerResultChange, page, nil);
    }
}

+ (void)runAllInstructions:(NSArray *)workingInstructions fromIndex:(int)index lastResponse:(NSString *)lastResponse usingSession:(NSURLSession *)session differencePage:(NSString *)page differenceOptions:(NSDictionary *)differenceOptions completionBlock:(void (^)(UPDInstructionRunnerResult result, NSString *newResponse, NSDictionary *newDifferenceOptions))completionBlock {
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
            [self page:newResponse differsFromPage:page baseURL:instruction.endRequest.URL differenceOptions:differenceOptions completionBlock:completionBlock];
        }
    }];
    [task resume];
}

@end
