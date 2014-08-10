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

@interface UPDURLProtocol()

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionTask *task;

@end

@implementation UPDURLProtocol

static NSOperationQueue *_operationQueue;

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    return ![NSURLProtocol propertyForKey:@"UseDefaultImplementation" inRequest:request];
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

+ (void)createSession{
    _operationQueue.maxConcurrentOperationCount = 5;
}

+ (void)invalidateSession{
    _operationQueue = nil;
}

+ (void)setInstructionAccumulator:(UPDInstructionAccumulator *)instructionAccumulator{}

- (void)startLoading {
    self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:_operationQueue];
    
    NSMutableURLRequest *newRequest = [self.request mutableCopy];
    [NSURLProtocol setProperty:@YES forKey:@"UseDefaultImplementation" inRequest:newRequest];
    self.task = [self.session dataTaskWithRequest:newRequest];
    [self.task resume];
}

- (void)stopLoading {
    
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    NSString *stringFromData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if(stringFromData&&[stringFromData rangeOfString:@"<title>"].location!=NSNotFound) {
        NSLog(@"Found DOC");
    }
    [self.client URLProtocol:self didLoadData:data];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if(!error) {
        [self.client URLProtocolDidFinishLoading:self];
    }
    else {
        [self.client URLProtocol:self didFailWithError:error];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest *))completionHandler {
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    [NSURLProtocol removePropertyForKey:@"UseDefaultImplementation" inRequest:mutableRequest];
    if(response) {
        [self.client URLProtocol:self wasRedirectedToRequest:mutableRequest redirectResponse:response];
    }
    completionHandler(mutableRequest);
}

@end
