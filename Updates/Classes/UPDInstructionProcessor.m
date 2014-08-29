//
//  UPDInstructionProcessor.m
//  Updates
//
//  Created by Bryce Pauken on 7/22/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

/*
 This object goes through a list of UPDInternalInstruction's and
 attempts to recreate the actions given by those instructions, making
 optimizations if possible.
 
 The general steps involed in this process are:
 1) Check if final page is reachable by single GET request—if it is, just use that. If not...
 2) Try the entire instruction list to get to the final page
    a) Get parameters from previous page input forms (GET and POST)
    b) If that doesn't work, give up hope
 3) Try fetching only requests that are...
    a) The final request
    b) POST requests
    c) Requests before POST requests, if it provides the POST fields
 */

#import "UPDInstructionProcessor.h"

#import <libxml/HTMLparser.h>
#import "UPDDocumentComparator.h"
#import "UPDDocumentSearcher.h"
#import "UPDInternalInstruction.h"
#import "UPDSessionDelegate.h"

@interface UPDInstructionProcessor()

@property (nonatomic, strong) UIImage *favicon;

@end

@implementation UPDInstructionProcessor

/*
 Should call completionBlock with an array of UPDInternalInstructions,
 which can be used to get to the given web page, along with a favicon.
 */
- (void)beginProcessingWithLastInstructionBlock:(void (^)(UPDInternalInstruction *))lastInstructionBlock {
    NSMutableArray *workingInstructions = [self.instructions mutableCopy];
    NSURL *workingURL = [NSURL URLWithString:self.url];
    
    /*step 1*/
    UPDInternalInstruction *lastInstruction;
    for(int i=(int)workingInstructions.count-1;i>=0;i--) {
        NSURL *instructionURL = [NSURL URLWithString:((UPDInternalInstruction *)[workingInstructions objectAtIndex:i]).fullURL];
        if(([instructionURL.scheme isEqualToString:workingURL.scheme]||(!instructionURL.scheme&&!workingURL.scheme)) && ([instructionURL.host isEqualToString:workingURL.host]||(!instructionURL.host&&!workingURL.host)) && ([instructionURL.path isEqualToString:workingURL.path]||(!instructionURL.path&&!workingURL.path)) && ([instructionURL.parameterString isEqualToString:workingURL.parameterString]||(!instructionURL.parameterString&&!workingURL.parameterString))) {
            lastInstruction = [workingInstructions objectAtIndex:i];
            break;
        }
    }
    if(!lastInstruction) {
        for(int i=(int)workingInstructions.count-1;i>=0;i--) {
            if(((UPDInternalInstruction *)[workingInstructions objectAtIndex:i]).response.length) {
                lastInstruction = [workingInstructions objectAtIndex:i];
                break;
            }
        }
    }
    if(lastInstruction) {
        lastInstructionBlock(lastInstruction);
        /*find a better source than this! could be an error later on!*/
        self.favicon=[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[@"http://g.etfv.co/" stringByAppendingString:lastInstruction.request.URL.absoluteString]]]];
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [queue setMaxConcurrentOperationCount:5];
        [self clearPersistentData];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:(id<NSURLSessionDelegate>)[UPDSessionDelegate class] delegateQueue:queue];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:lastInstruction.request];
        UPDSessionDelegate *delegate = [[UPDSessionDelegate alloc] initWithTask:task request:lastInstruction.request];
        [delegate setCompletionBlock:^(NSData *data, NSURLResponse *response, NSMutableDictionary *returnedCookies, NSError *error) {
            [self clearPersistentData];
            if([lastInstruction.request.HTTPMethod isEqualToString:@"GET"]&&[UPDDocumentComparator document:lastInstruction.response isEquivalentToDocument:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]]) {
                /*the final request works on its own, use it!*/
                if(self.completionBlock) {
                    self.completionBlock([NSArray arrayWithObject:lastInstruction], self.favicon, lastInstruction.response, lastInstruction.request.URL);
                }
            }
            else {
                /*step 2*/
                if(workingInstructions.count>1) {
                    [self processAllInstructions:workingInstructions fromIndex:0 currentStep:2 lastResponse:nil usingSession:nil withDelegateQueue:queue lastSuccessfulCompletionBlock:nil];
                }
                else {
                    /*using the last instruction alone doesn't work, but there's only one instruction... error*/
                    if(self.errorBlock) {
                        self.errorBlock();
                    }
                }
            }
        }];
        [task resume];
    }
    else {
        /*no valid instruction found... error*/
        if(self.errorBlock) {
            self.errorBlock();
        }
    }
}

/*
 Clears cookies and the cache—important for making sure a request
 can be duplicated every time.
 */
- (void)clearPersistentData {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/*
 Try reaching the final page by using every instruction available.
 Called if beginProcessing determines that just querying the last page
 doesn't work as expected.
 */
- (void)processAllInstructions:(NSMutableArray *)workingInstructions fromIndex:(int)index currentStep:(int)currentStep lastResponse:(NSString *)lastResponse usingSession:(NSURLSession *)session withDelegateQueue:(NSOperationQueue *)queue lastSuccessfulCompletionBlock:(void (^)())lastSuccessfulCompletionBlock {
    if(!session) {
        session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:(id<NSURLSessionDelegate>)[UPDSessionDelegate class] delegateQueue:queue];
    }
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
            [instruction setReliesOnPrevRequest:YES];
        }
        else if(instruction.reliesOnPrevRequest) {
            if(lastSuccessfulCompletionBlock) {
                lastSuccessfulCompletionBlock();
            }
            return;
        }
    }
    NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:request.URL]];
    [request setAllHTTPHeaderFields:headers];
    index++;
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
    UPDSessionDelegate *delegate = [[UPDSessionDelegate alloc] initWithTask:task request:request];
    [delegate setCompletionBlock:^(NSData *data, NSURLResponse *response, NSMutableDictionary *returnedCookies, NSError *error) {
        NSString *newResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if(index<workingInstructions.count) {
            [self processAllInstructions:workingInstructions fromIndex:index currentStep:currentStep lastResponse:newResponse usingSession:session withDelegateQueue:queue lastSuccessfulCompletionBlock:lastSuccessfulCompletionBlock];
        }
        else {
            [self clearPersistentData];
            if([UPDDocumentComparator document:instruction.response isEquivalentToDocument:newResponse]) {
                switch(currentStep) {
                    case 2: {
                        void (^newLastSuccessfulCompletionBlock)() = ^{
                            self.completionBlock(workingInstructions, self.favicon, instruction.response, instruction.request.URL);
                        };
                        for(int i=0;i<workingInstructions.count;i++) {
                            if(i<workingInstructions.count-1&&![[[workingInstructions objectAtIndex:i] request].HTTPMethod isEqualToString:@"POST"]&&[[workingInstructions objectAtIndex:i] reliesOnPrevRequest]==NO) {
                                [workingInstructions removeObjectAtIndex:i];
                                i--;
                            }
                        }
                        [self processAllInstructions:workingInstructions fromIndex:0 currentStep:3 lastResponse:nil usingSession:nil withDelegateQueue:queue lastSuccessfulCompletionBlock:newLastSuccessfulCompletionBlock];
                        break;
                    }
                    case 3:
                        if(self.completionBlock) {
                            self.completionBlock(workingInstructions, self.favicon, instruction.response, instruction.request.URL);
                        }
                        break;
                    default:
                        if(self.errorBlock) {
                            self.errorBlock();
                        }
                        break;
                }
            }
            else {
                switch(currentStep) {
                    case 3:
                        if(self.completionBlock) {
                            self.completionBlock(workingInstructions, self.favicon, instruction.response, instruction.request.URL);
                        }
                        break;
                    default:
                        /*step 2 failed (or invalid step)... error*/
                        if(self.errorBlock) {
                            self.errorBlock();
                        }
                        break;
                }
            }
        }
    }];
    [task resume];
}

@end
