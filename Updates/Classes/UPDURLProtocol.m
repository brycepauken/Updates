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
@property (nonatomic, strong) NSURLSessionTask *task;

@end

@implementation UPDURLProtocol

static BOOL _disableProtocol;
static NSMutableArray *_instances;
static NSLock *_instancesLock;
static UPDInstructionAccumulator *_instructionAccumulator;
static NSOperationQueue *_operationQueue;
static BOOL _preventUnnecessaryLoading;
static NSURLSession *_session;

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    return !_disableProtocol&&![NSURLProtocol propertyForKey:@"UseDefaultImplementation" inRequest:request];
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

+ (void)createSession {
    _operationQueue = [[NSOperationQueue alloc] init];
    _operationQueue.maxConcurrentOperationCount = 5;
    _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:(id<NSURLSessionDelegate>)self delegateQueue:_operationQueue];
    _instances = [NSMutableArray array];
    _instancesLock = [NSLock new];
}

- (id)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id<NSURLProtocolClient>)client {
    self = [super initWithRequest:request cachedResponse:cachedResponse client:client];
    if(self) {
        CFRetain((__bridge CFTypeRef)(client));
    }
    return self;
}

+ (void)invalidateSession {
    [_session invalidateAndCancel];
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)aRequest toRequest:(NSURLRequest *)bRequest {
    return NO;
}

+ (void)setDisableProtocol:(BOOL)disableProtocol {
    _disableProtocol = disableProtocol;
}

+ (void)setInstructionAccumulator:(UPDInstructionAccumulator *)instructionAccumulator {
    _instructionAccumulator = instructionAccumulator;
}

+ (void)setPreventUnnecessaryLoading:(BOOL)preventUnnecessaryLoading {
    _preventUnnecessaryLoading = preventUnnecessaryLoading;
}

- (void)startLoading {
    [_instancesLock lock];
    [_instances addObject:self]; /*we need the strong reference, actually*/
    [_instancesLock unlock];
    
    self.data = [[NSMutableData alloc] init];
    
    NSMutableURLRequest *newRequest = [self.request mutableCopy];
    [NSURLProtocol setProperty:@YES forKey:@"UseDefaultImplementation" inRequest:newRequest];
    self.task = [_session dataTaskWithRequest:newRequest];
    [self.task resume];
}

- (void)stopLoading {
    
}

+ (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    UPDURLProtocol *instance;
    [_instancesLock lock];
    for(UPDURLProtocol *inst in _instances) {
        if(inst.task==dataTask) {
            instance = inst;
            break;
        }
    }
    [_instancesLock unlock];
    
    if(instance) {
        [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop){
            [instance.data appendBytes:bytes length:byteRange.length];
            [instance.client URLProtocol:instance didLoadData:[NSData dataWithBytes:bytes length:byteRange.length]];
        }];
    }
}

+ (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    UPDURLProtocol *instance;
    [_instancesLock lock];
    for(UPDURLProtocol *inst in _instances) {
        if(inst.task==dataTask) {
            instance = inst;
            break;
        }
    }
    [_instancesLock unlock];
    
    if(instance) {
        BOOL didCancel = NO;
        if(_preventUnnecessaryLoading&&([[((NSHTTPURLResponse *)response).allHeaderFields objectForKey:@"Content-Type"] hasPrefix:@"image"])) {
            [instance.task cancel];
            didCancel = YES;
        }
        [instance.client URLProtocol:instance didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        completionHandler(NSURLSessionResponseAllow);
        if(didCancel) {
            [instance.client URLProtocolDidFinishLoading:instance];
        }
    }
}

+ (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    UPDURLProtocol *instance;
    [_instancesLock lock];
    for(UPDURLProtocol *inst in _instances) {
        if(inst.task==task) {
            instance = inst;
            [_instances removeObject:inst];
            break;
        }
    }
    [_instancesLock unlock];
    
    if(instance) {
        BOOL wasRedirected = NO;
        [instance.redirectedTasksLock lock];
        for(NSURLSessionTask *singleTask in instance.redirectedTasks) {
            if(singleTask==task) {
                wasRedirected = YES;
                [instance.redirectedTasks removeObject:singleTask];
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
                        NSURLRequest *firstRequest = [NSURLProtocol propertyForKey:@"OriginalRequest" inRequest:instance.request];
                        if(!firstRequest) {
                            firstRequest = instance.request;
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
}

+ (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
    UPDURLProtocol *instance;
    [_instancesLock lock];
    for(UPDURLProtocol *inst in _instances) {
        if(inst.task==task) {
            instance = inst;
            break;
        }
    }
    [_instancesLock unlock];
    
    if(instance) {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}

+ (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest *))completionHandler {
    UPDURLProtocol *instance;
    [_instancesLock lock];
    for(UPDURLProtocol *inst in _instances) {
        if(inst.task==task) {
            instance = inst;
            break;
        }
    }
    [_instancesLock unlock];
    
    if(instance) {
        NSMutableURLRequest *mutableRequest = [instance.request mutableCopy];
        [NSURLProtocol removePropertyForKey:@"UseDefaultImplementation" inRequest:mutableRequest];
        [mutableRequest setHTTPBody:nil];
        [mutableRequest setHTTPMethod:@"GET"];
        [mutableRequest setURL:request.URL];
        
        [mutableRequest setAllHTTPHeaderFields:[NSHTTPCookie requestHeaderFieldsWithCookies:[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:mutableRequest.URL]]];
        
        if(response) {
            NSURLRequest *firstRequest = [NSURLProtocol propertyForKey:@"OriginalRequest" inRequest:instance.request];
            if(!firstRequest) {
                firstRequest = instance.request;
            }
            [NSURLProtocol setProperty:firstRequest forKey:@"OriginalRequest" inRequest:mutableRequest];
            
            __unsafe_unretained NSURLSessionTask *weakTask = task;
            [instance.redirectedTasksLock lock];
            [instance.redirectedTasks addObject:weakTask];
            [instance.redirectedTasksLock unlock];
            [instance.task cancel];
            [instance.client URLProtocol:instance wasRedirectedToRequest:mutableRequest redirectResponse:response];
            [instance.client URLProtocol:instance didFailWithError:[NSError errorWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:nil]];
        }
        else {
            completionHandler(mutableRequest);
        }
    }
}

@end
