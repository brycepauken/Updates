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
    b) If exact URL shows up on previous reponse page, use that one in the future
    c) If exact URL doesn't show up, check if base url shows up as GET form action, and use that
 3) Figure out where parameters came from (GET and POST)
    a) Check input forms in prevoius response page for data—use field in the future if possible
 4) Try the entire instruction list again, checking if end page is the same or equivalent
 
 */

#import "UPDInstructionProcessor.h"

#import <libxml/HTMLparser.h>
#import "UPDDocumentComparator.h"
#import "UPDInternalInstruction.h"

@implementation UPDInstructionProcessor

- (void)beginProcessing {
    NSMutableArray *workingInstructions = [self.instructions mutableCopy];
    
    /*step 1*/
    UPDInternalInstruction *lastInstruction;
    for(int i=(int)workingInstructions.count-1;i>=0;i--) {
        if(((UPDInternalInstruction *)[workingInstructions objectAtIndex:i]).response.length) {
            lastInstruction = [workingInstructions objectAtIndex:i];
            break;
        }
    }
    if(lastInstruction) {
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [queue setMaxConcurrentOperationCount:5];
        [self clearPersistentData];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:queue];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:lastInstruction.request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if([UPDDocumentComparator document:lastInstruction.response isEquivalentToDocument:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]]) {
                /*the last request works on its own, use it!*/
                
            }
            else {
                /*step 2*/
                
            }
        }];
        [task resume];
    }
    else {
        /*no valid instruction found...*/
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

@end