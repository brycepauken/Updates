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
@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) NSURLSessionDataTask *task;

@end

@implementation UPDURLProtocol

static NSMutableArray *_instances;
static NSLock *_instancesLock;
static UPDInstructionAccumulator *_instructionAccumulator;
static NSURLSession *_session;

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if([NSURLProtocol propertyForKey:@"UseDefaultImplementation" inRequest:request]) {
        return NO;
    }
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

+ (void)createSession {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue setMaxConcurrentOperationCount:5];
    _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:(id<NSURLSessionDelegate>)self delegateQueue:queue];
    _instances = [[NSMutableArray alloc] init];
    _instancesLock = [[NSLock alloc] init];
}

+ (void)invalidateSession {
    [_session invalidateAndCancel];
    _session = nil;
    _instances = nil;
    _instancesLock = nil;
}

+ (void)setInstructionAccumulator:(UPDInstructionAccumulator *)instructionAccumulator {
    _instructionAccumulator = instructionAccumulator;
}

- (void)startLoading {
    [_instancesLock lock];
    [_instances addObject:self];
    [_instancesLock unlock];
    NSMutableURLRequest *newRequest = [self.request mutableCopy];
    [NSURLProtocol setProperty:@YES forKey:@"UseDefaultImplementation" inRequest:newRequest];
    self.data = [[NSMutableData alloc] init];
    self.task = [_session dataTaskWithRequest:newRequest];
    [self.task resume];
}

- (void)stopLoading {
    [self.task cancel];
    self.task = nil;
}

+ (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    UPDURLProtocol *instance;
    [_instancesLock lock];
    for(UPDURLProtocol *singleInstance in _instances) {
        if([singleInstance.task isEqual:dataTask]) {
            instance = singleInstance;
            break;
        }
    }
    [_instancesLock unlock];
    if(instance) {
        [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop){
            [instance.data appendBytes:bytes length:byteRange.length];
        }];
        [instance.client URLProtocol:instance didLoadData:data];
    }
}

+ (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    UPDURLProtocol *instance;
    [_instancesLock lock];
    for(UPDURLProtocol *singleInstance in _instances) {
        if([singleInstance.task isEqual:dataTask]) {
            instance = singleInstance;
            break;
        }
    }
    [_instancesLock unlock];
    if(instance) {
        [instance setResponse:response];
        [instance.client URLProtocol:instance didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    }
    completionHandler(NSURLSessionResponseAllow);
}

+ (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    UPDURLProtocol *instance;
    [_instancesLock lock];
    for(UPDURLProtocol *singleInstance in _instances) {
        if([singleInstance.task isEqual:task]) {
            instance = singleInstance;
            break;
        }
    }
    [_instancesLock unlock];
    if(instance) {
        __unsafe_unretained UPDURLProtocol *weakInstance = instance;
        [_instancesLock lock];
        [_instances removeObject:weakInstance];
        [_instancesLock unlock];
        if(!error) {
            NSDictionary *headers;
            if(instance.response && [instance.response respondsToSelector:@selector(allHeaderFields)]) {
                headers = [(NSHTTPURLResponse *)instance.response allHeaderFields];
            }
            if(headers && [[headers objectForKey:@"Content-Type"] hasPrefix:@"text"]&&![[headers objectForKey:@"Content-Type"] hasPrefix:@"text/css"]&&![[headers objectForKey:@"Content-Type"] hasPrefix:@"text/javascript"]) {
                if(_instructionAccumulator) {
                    NSURLRequest *firstRequest = instance.request;
                    while([NSURLProtocol propertyForKey:@"PreviousRequest" inRequest:firstRequest]) {
                        firstRequest = [NSURLProtocol propertyForKey:@"PreviousRequest" inRequest:firstRequest];
                    }
                    [_instructionAccumulator addInstructionWithRequest:firstRequest endRequest:instance.request response:[[NSString alloc] initWithData:instance.data encoding:NSUTF8StringEncoding] headers:headers];
                }
            }
            [instance.client URLProtocolDidFinishLoading:instance];
        }
        else {
            [instance.client URLProtocol:instance didFailWithError:error];
        }
    }
}

+ (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
}

+ (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest *))completionHandler {
    UPDURLProtocol *instance;
    [_instancesLock lock];
    for(UPDURLProtocol *singleInstance in _instances) {
        if([singleInstance.task isEqual:task]) {
            instance = singleInstance;
            break;
        }
    }
    [_instancesLock unlock];
    if(instance) {
        NSMutableURLRequest *mutableRequest = [request mutableCopy];
        [NSURLProtocol removePropertyForKey:@"UseDefaultImplementation" inRequest:mutableRequest];
        if(response) {
            [NSURLProtocol setProperty:instance.request forKey:@"PreviousRequest" inRequest:mutableRequest];
            [NSURLProtocol setProperty:response forKey:@"RedirectResponse" inRequest:mutableRequest];
            [instance.client URLProtocol:instance wasRedirectedToRequest:mutableRequest redirectResponse:nil];
        }
        UPDURLProtocol *newProtocol = [[UPDURLProtocol alloc] initWithRequest:[mutableRequest copy] cachedResponse:nil client:instance.client];
        [newProtocol startLoading];
    }
}

@end
