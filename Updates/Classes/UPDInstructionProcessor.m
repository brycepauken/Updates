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
 2) Figure out where a request URL came from
    a) First URL is given, no need for processing
    b) If exact URL shows up on previous response page, use that one in the future
    c) If exact URL doesn't show up, check if base url shows up as GET form action, and use that
 3) Figure out where parameters came from (GET and POST)
    a) Check input forms in prevoius response page for data—use field in the future if possible
 4) Try the entire instruction list again, checking if end page is the same or equivalent
 
 */

#import "UPDInstructionProcessor.h"

#import <libxml/HTMLparser.h>
#import "UPDDocumentComparator.h"
#import "UPDDocumentSearcher.h"
#import "UPDInternalInstruction.h"

@interface UPDInstructionProcessor()

@property (nonatomic, strong) UIImage *favicon;

@end

@implementation UPDInstructionProcessor

/*
 Should call completionBlock with an array of UPDInternalInstructions,
 which can be used to get to the given web page, along with a favicon.
 */
- (void)beginProcessing {
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
        /*find a better source than this! could be an error later on!*/
        self.favicon=[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[@"http://g.etfv.co/" stringByAppendingString:lastInstruction.request.URL.absoluteString]]]];
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [queue setMaxConcurrentOperationCount:5];
        [self clearPersistentData];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration] delegate:nil delegateQueue:queue];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:lastInstruction.request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            [session invalidateAndCancel];
            if([lastInstruction.request.HTTPMethod isEqualToString:@"GET"]&&[UPDDocumentComparator document:lastInstruction.response isEquivalentToDocument:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]]) {
                /*the final request works on its own, use it!*/
                if(self.completionBlock) {
                    self.completionBlock([NSArray arrayWithObject:lastInstruction], self.favicon, lastInstruction.response, lastInstruction.request.URL);
                }
            }
            else {
                /*step 2*/
                if(workingInstructions.count>1) {
                    [self processAllInstructions:workingInstructions fromIndex:0 lastResponse:nil usingSession:nil];
                }
                else {
                    /*using the last instruction alone doesn't work, but there's only one instruction... error*/
                }
            }
        }];
        [task resume];
    }
    else {
        /*no valid instruction found... error*/
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
- (void)processAllInstructions:(NSMutableArray *)workingInstructions fromIndex:(int)index lastResponse:(NSString *)lastResponse usingSession:(NSURLSession *)session {
    if(!session) {
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [queue setMaxConcurrentOperationCount:5];
        [self clearPersistentData];
        session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration] delegate:nil delegateQueue:queue];
    }
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
            [self processAllInstructions:workingInstructions fromIndex:index lastResponse:newResponse usingSession:session];
        }
        else {
            [session invalidateAndCancel];
            if([UPDDocumentComparator document:instruction.response isEquivalentToDocument:newResponse]) {
                /*the final request works on its own, use it!*/
                if(self.completionBlock) {
                    self.completionBlock(workingInstructions, self.favicon, instruction.response, instruction.request.URL);
                }
            }
            else {
                /*step 2 failed, no other options... error*/
            }
        }
    }];
    [task resume];
}

@end
