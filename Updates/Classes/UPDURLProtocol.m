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
#import "UPDURLProtocolSwitcher.h"

@interface UPDURLProtocol() <NSURLSessionDataDelegate>

@property (atomic, strong, readwrite) NSThread *clientThread;
@property (atomic, copy, readwrite) NSArray *modes;
@property (atomic, strong, readwrite) NSURLSessionDataTask *task;

@end

@implementation UPDURLProtocol

+ (void)createSession{}
+ (void)invalidateSession{}
+ (void)setDisableProtocol:(BOOL)disableProtocol{}
+ (void)setInstructionAccumulator:(UPDInstructionAccumulator *)instructionAccumulator{}
+ (void)setPreventUnnecessaryLoading:(BOOL)preventUnnecessaryLoading{}

#pragma mark - Class Methods

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if(request==nil) {
        return NO;
    }
    NSURL *url = request.URL;
    if(!url) {
        return NO;
    }
    
    if([self propertyForKey:@"UseDefaultImplementation" inRequest:request]) {
        return NO;
    }
    
    NSString *scheme = url.scheme.lowercaseString;
    if(!scheme||([scheme isEqualToString:@"http"]&&[scheme isEqualToString:@"https"])) {
        return NO;
    }
    
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

+ (UPDURLProtocolSwitcher *)sharedSwitcher {
    static dispatch_once_t dispatchOnceToken;
    static UPDURLProtocolSwitcher *switcher;
    dispatch_once(&dispatchOnceToken, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        [configuration setProtocolClasses:@[self]];
        switcher = [[UPDURLProtocolSwitcher alloc] initWithConfiguration:configuration];
    });
    return switcher;
}

#pragma mark - Instance Methods

- (id)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id <NSURLProtocolClient>)client {
    self = [super initWithRequest:request cachedResponse:cachedResponse client:client];
    return self;
}

- (void)startLoading {
    NSMutableArray *modes = [NSMutableArray array];
    [modes addObject:NSDefaultRunLoopMode];
    NSString *currentMode = [[NSRunLoop currentRunLoop] currentMode];
    if(currentMode && ![currentMode isEqual:NSDefaultRunLoopMode]) {
        [modes addObject:currentMode];
    }
    self.modes = modes;
    
    NSMutableURLRequest *mutableRequest = [self.request mutableCopy];
    [[self class] setProperty:@YES forKey:@"UseDefaultImplementation" inRequest:mutableRequest];
    
    self.clientThread = [NSThread currentThread];
    
    self.task = [[[self class] sharedSwitcher] dataTaskWithRequest:mutableRequest delegate:self modes:self.modes];
    [self.task resume];
}

- (void)stopLoading {
    if(self.task) {
        [self.task cancel];
        self.task = nil;
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [[self client] URLProtocol:self didLoadData:data];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if(!error) {
        NSLog(@"%@",task.currentRequest.URL);
        [[self client] URLProtocolDidFinishLoading:self];
    }
    else if(![error.domain isEqual:NSURLErrorDomain] || error.code!=NSURLErrorCancelled) {
        [[self client] URLProtocol:self didFailWithError:error];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)newRequest completionHandler:(void (^)(NSURLRequest *))completionHandler {
    NSMutableURLRequest *mutableRequest = [newRequest mutableCopy];
    [[self class] removePropertyForKey:@"UseDefaultImplementation" inRequest:mutableRequest];
    [[self client] URLProtocol:self wasRedirectedToRequest:mutableRequest redirectResponse:response];
    
    [self.task cancel];
    [[self client] URLProtocol:self didFailWithError:[NSError errorWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:nil]];
}

@end
