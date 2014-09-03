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
#import "UPDSessionDelegate.h"

@implementation UPDInstructionRunner

+ (void)pageFromInstructions:(NSArray *)instructions differsFromPage:(NSString *)page differenceOptions:(NSDictionary *)differenceOptions progressBlock:(void (^)(CGFloat progress))progressBlock completionBlock:(void (^)(UPDInstructionRunnerResult result, NSString *newResponse, NSDictionary *newDifferenceOptions))completionBlock {
    [self clearPersistentData];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue setMaxConcurrentOperationCount:5];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:(id<NSURLSessionDelegate>)[UPDSessionDelegate class] delegateQueue:queue];
    UPDDocumentRenderer *renderer = [UPDDocumentRenderer new];
    progressBlock(1/(CGFloat)(instructions.count+1));
    if(instructions.count==1) {
        UPDInternalInstruction *instruction = [instructions lastObject];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:instruction.request];
        UPDSessionDelegate *delegate = [[UPDSessionDelegate alloc] initWithTask:task request:instruction.request];
        [delegate setCompletionBlock:^(NSData *data, NSURLResponse *response, NSMutableDictionary *returnedCookies, NSError *error) {
            [session invalidateAndCancel];
            [renderer renderDocument:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] withBaseURL:instruction.request.URL completionBlock:^(NSString *newResponse) {
                [renderer clearWebView];
                progressBlock(1);
                [self page:newResponse differsFromPage:page baseURL:instruction.endRequest.URL differenceOptions:differenceOptions completionBlock:completionBlock];
            }];
        }];
        [task resume];
    }
    else {
        [self runAllInstructions:instructions fromIndex:0 lastResponse:nil usingRenderer:renderer usingSession:session differencePage:page differenceOptions:differenceOptions progressBlock:progressBlock completionBlock:completionBlock];
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

+ (void)runAllInstructions:(NSArray *)workingInstructions fromIndex:(int)index lastResponse:(NSString *)lastResponse usingRenderer:(UPDDocumentRenderer *)renderer usingSession:(NSURLSession *)session differencePage:(NSString *)page differenceOptions:(NSDictionary *)differenceOptions progressBlock:(void (^)(CGFloat progress))progressBlock completionBlock:(void (^)(UPDInstructionRunnerResult result, NSString *newResponse, NSDictionary *newDifferenceOptions))completionBlock {
    UPDInternalInstruction *prevInstruction = nil;
    UPDInternalInstruction *instruction = [workingInstructions objectAtIndex:index];
    NSMutableURLRequest *request = [instruction.request mutableCopy];
    if(index>0 && lastResponse) {
        prevInstruction = [workingInstructions objectAtIndex:index-1];
        NSArray *newPost = [UPDDocumentSearcher document:lastResponse equivilantInputFieldForArray:instruction.post orignalResponse:prevInstruction.response];
        if(newPost) {
            NSMutableString *newHTTPBody = [[NSMutableString alloc] init];
            for(int i=0;i<newPost.count;i++) {
                if(i>0) {
                    [newHTTPBody appendString:@"&"];
                }
                [newHTTPBody appendString:CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)[[newPost objectAtIndex:i] objectAtIndex:0], NULL, (__bridge CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ", CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)))];
                [newHTTPBody appendString:@"="];
                [newHTTPBody appendString:CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)[[newPost objectAtIndex:i] objectAtIndex:1], NULL, (__bridge CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ", CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)))];
            }
            [request setHTTPBody:[newHTTPBody dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    index++;
    NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:request.URL]];
    [request setAllHTTPHeaderFields:headers];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
    UPDSessionDelegate *delegate = [[UPDSessionDelegate alloc] initWithTask:task request:request];
    [delegate setCompletionBlock:^(NSData *data, NSURLResponse *response, NSMutableDictionary *returnedCookies, NSError *error) {
        [renderer clearWebView];
        [renderer renderDocument:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] withBaseURL:request.URL completionBlock:^(NSString *newResponse) {
            progressBlock((index+2)/(CGFloat)(workingInstructions.count+1));
            if(index<workingInstructions.count) {
                [self runAllInstructions:workingInstructions fromIndex:index lastResponse:newResponse usingRenderer:renderer usingSession:session differencePage:page differenceOptions:differenceOptions progressBlock:progressBlock completionBlock:completionBlock];
            }
            else {
                [session invalidateAndCancel];
                [self page:newResponse differsFromPage:page baseURL:instruction.endRequest.URL differenceOptions:differenceOptions completionBlock:completionBlock];
            }
        }];
    }];
    [task resume];
}

@end
