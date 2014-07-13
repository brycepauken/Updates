//
//  UPDURLProtocol.m
//  Update
//
//  Created by Bryce Pauken on 5/15/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDURLProtocol.h"

#import <objc/runtime.h>

@implementation UPDURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if([NSURLProtocol propertyForKey:@"UseDefaultImplementation" inRequest:request]) {
        return NO;
    }
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (void)startLoading {
    NSMutableURLRequest *newRequest = [self.request mutableCopy];
    [NSURLProtocol setProperty:@YES forKey:@"UseDefaultImplementation" inRequest:newRequest];
    self.data = [[NSMutableData alloc] init];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 5;
    self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:queue];
    self.task = [_session dataTaskWithRequest:newRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(!error) {
            [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
            [self.client URLProtocol:self didLoadData:data];
            [self.client URLProtocolDidFinishLoading:self];
            
            NSDictionary *headers = [(NSHTTPURLResponse *)response allHeaderFields];
            if([[headers objectForKey:@"Content-Type"] hasPrefix:@"text"]&&![[headers objectForKey:@"Content-Type"] hasPrefix:@"text/css"]&&![[headers objectForKey:@"Content-Type"] hasPrefix:@"text/javascript"]) {
                if(AppDelegate.addInstruction) {
                    NSURLRequest *firstRequest = [NSURLProtocol propertyForKey:@"OriginalRequest" inRequest:self.request]?:self.request;
                    AppDelegate.addInstruction(firstRequest.URL.absoluteString,[[NSString alloc] initWithData:firstRequest.HTTPBody encoding:NSUTF8StringEncoding],[[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding],headers);
                }
            }
        }
        else {
            //NSLog(@"ERROR (2): %@",error);
            [self.client URLProtocol:self didFailWithError:error];
        }
    }];
    [self.task resume];
}

- (void)stopLoading {
    [self.task cancel];
    self.task = nil;
    self.data = nil;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    //NSLog(@"ERROR (1): %@",error);
    [self.client URLProtocol:self didFailWithError:error];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest *))completionHandler {
    if(response!=nil) {
        NSMutableURLRequest *mutableRequest = [request mutableCopy];
        [NSURLProtocol removePropertyForKey:@"UseDefaultImplementation" inRequest:mutableRequest];
        
        [self.client URLProtocol:self wasRedirectedToRequest:request redirectResponse:response];
        [self.task cancel];
        [self.client URLProtocol:self didFailWithError:[NSError errorWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:nil]];
    }
    completionHandler(request);
}

@end
