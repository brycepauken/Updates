//
//  UPDURLProtocol.m
//  Updates
//
//  Created by Bryce Pauken on 7/18/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

/*
 Our custom URL Protocol doesn't have much logic behind it—
 it merely captures requests and forwards them along to the
 designated instruction accumlator.
 */

#import "UPDURLProtocol.h"

#import "UPDInstructionAccumulator.h"

@interface UPDURLProtocol()

@property (nonatomic, retain) NSURLSession *session;
@property (nonatomic, retain) NSURLSessionDataTask *task;

@end

@implementation UPDURLProtocol

static UPDInstructionAccumulator *_instructionAccumulator;

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if([NSURLProtocol propertyForKey:@"UseDefaultImplementation" inRequest:request]) {
        return NO;
    }
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

+ (void)setInstructionAccumulator:(UPDInstructionAccumulator *)instructionAccumulator {
    _instructionAccumulator = instructionAccumulator;
}

- (void)startLoading {
    NSMutableURLRequest *newRequest = [self.request mutableCopy];
    [NSURLProtocol setProperty:@YES forKey:@"UseDefaultImplementation" inRequest:newRequest];
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
                if(_instructionAccumulator) {
                    [_instructionAccumulator addInstructionWithURL:self.request.URL.absoluteString post:[[NSString alloc] initWithData:self.request.HTTPBody encoding:NSUTF8StringEncoding] response:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] headers:headers];
                }
            }
        }
        else {
            [self.client URLProtocol:self didFailWithError:error];
        }
    }];
    [self.task resume];
}

- (void)stopLoading {
    [self.task cancel];
    self.task = nil;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
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
