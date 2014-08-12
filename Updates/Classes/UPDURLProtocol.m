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

@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSMutableArray *redirectedTasks;
@property (nonatomic, strong) NSLock *redirectedTasksLock;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionTask *task;

@end

@implementation UPDURLProtocol

static UPDInstructionAccumulator *_instructionAccumulator;
static NSOperationQueue *_operationQueue;

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    return ![NSURLProtocol propertyForKey:@"UseDefaultImplementation" inRequest:request];
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

+ (void)createSession{
    _operationQueue = [[NSOperationQueue alloc] init];
    _operationQueue.maxConcurrentOperationCount = 5;
}

+ (void)invalidateSession{
    _operationQueue = nil;
}

+ (void)setInstructionAccumulator:(UPDInstructionAccumulator *)instructionAccumulator {
    _instructionAccumulator = instructionAccumulator;
}

- (void)startLoading {
    self.data = [[NSMutableData alloc] init];
    self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:_operationQueue];
    
    NSMutableURLRequest *newRequest = [self.request mutableCopy];
    [NSURLProtocol setProperty:@YES forKey:@"UseDefaultImplementation" inRequest:newRequest];
    self.task = [self.session dataTaskWithRequest:newRequest];
    [self.task resume];
}

- (void)stopLoading {
    
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop){
        [self.data appendBytes:bytes length:byteRange.length];
        [self.client URLProtocol:self didLoadData:[NSData dataWithBytes:bytes length:byteRange.length]];
    }];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    BOOL wasRedirected = NO;
    [self.redirectedTasksLock lock];
    for(NSURLSessionTask *singleTask in self.redirectedTasks) {
        if(singleTask==task) {
            wasRedirected = YES;
            [self.redirectedTasks removeObject:singleTask];
            break;
        }
    }
    if(!wasRedirected) {
        if(!error) {
            NSDictionary *headers;
            if(task.response && [task.response respondsToSelector:@selector(allHeaderFields)]) {
                headers = [(NSHTTPURLResponse *)task.response allHeaderFields];
            }
            if(headers && [[headers objectForKey:@"Content-Type"] hasPrefix:@"text"]&&![[headers objectForKey:@"Content-Type"] hasPrefix:@"text/css"]&&![[headers objectForKey:@"Content-Type"] hasPrefix:@"text/javascript"]) {
                if(_instructionAccumulator) {
                    NSURLRequest *firstRequest = [NSURLProtocol propertyForKey:@"OriginalRequest" inRequest:self.request];
                    if(!firstRequest) {
                        firstRequest = self.request;
                    }
                    [_instructionAccumulator addInstructionWithRequest:firstRequest endRequest:self.request response:[[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding] headers:headers];
                }
            }
            [self.client URLProtocolDidFinishLoading:self];
        }
        else {
            [self.client URLProtocol:self didFailWithError:error];
        }
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest *))completionHandler {
    NSMutableURLRequest *mutableRequest = [self.request mutableCopy];
    [NSURLProtocol removePropertyForKey:@"UseDefaultImplementation" inRequest:mutableRequest];
    [mutableRequest setHTTPBody:nil];
    [mutableRequest setHTTPMethod:@"GET"];
    [mutableRequest setURL:request.URL];
    if(response) {
        NSURLRequest *firstRequest = [NSURLProtocol propertyForKey:@"OriginalRequest" inRequest:self.request];
        if(!firstRequest) {
            firstRequest = self.request;
        }
        [NSURLProtocol setProperty:firstRequest forKey:@"OriginalRequest" inRequest:mutableRequest];
        [self.client URLProtocol:self wasRedirectedToRequest:mutableRequest redirectResponse:response];
        
        __unsafe_unretained NSURLSessionTask *weakTask = task;
        [self.redirectedTasksLock lock];
        [self.redirectedTasks addObject:weakTask];
        [self.redirectedTasksLock unlock];
        [self.task cancel];
        [self.client URLProtocol:self didFailWithError:[NSError errorWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:nil]];
    }
    completionHandler(mutableRequest);
}

@end
