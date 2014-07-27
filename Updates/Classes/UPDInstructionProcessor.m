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
#import "UPDInternalInstruction.h"

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
        UIImage *favicon=[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[@"http://g.etfv.co/" stringByAppendingString:lastInstruction.request.URL.absoluteString]]]];
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [queue setMaxConcurrentOperationCount:5];
        [self clearPersistentData];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:queue];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:lastInstruction.request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if([UPDDocumentComparator document:lastInstruction.response isEquivalentToDocument:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]]) {
                /*the final request works on its own, use it!*/
                if(self.completionBlock) {
                    self.completionBlock([NSArray arrayWithObject:lastInstruction], favicon, lastInstruction.response, lastInstruction.request.URL);
                }
            }
            else {
                /*step 2*/
                NSLog(@"Error: pages not equivalent");
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

@end
