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
@property (atomic, strong, readwrite) NSMutableData *data;
@property (atomic, copy, readwrite) NSArray *modes;
@property (atomic, strong, readwrite) NSURLSessionDataTask *task;

@end

@implementation UPDURLProtocol

static BOOL _disableProtocol;
static UPDInstructionAccumulator *_instructionAccumulator;
static BOOL _preventUnnecessaryLoading;

#pragma mark - Class Methods

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if(_disableProtocol) {
        return NO;
    }
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

+ (void)setDisableProtocol:(BOOL)disableProtocol {
    _disableProtocol = disableProtocol;
}

+ (void)setInstructionAccumulator:(UPDInstructionAccumulator *)instructionAccumulator {
    _instructionAccumulator = instructionAccumulator;
}

+ (void)setPreventUnnecessaryLoading:(BOOL)preventUnnecessaryLoading {
    _preventUnnecessaryLoading = preventUnnecessaryLoading;
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
    self.data = [NSMutableData data];
    
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
    @synchronized(self) {
        [self.data appendData:data];
    }
    [[self client] URLProtocol:self didLoadData:data];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    BOOL shouldCancel = NO;
    if(_preventUnnecessaryLoading&&([[((NSHTTPURLResponse *)response).allHeaderFields objectForKey:@"Content-Type"] hasPrefix:@"image"])) {
        shouldCancel = YES;
    }
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    completionHandler(NSURLSessionResponseAllow);
    if(shouldCancel) {
        [self.task cancel];
        [self.client URLProtocolDidFinishLoading:self];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
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
        
        [[self client] URLProtocolDidFinishLoading:self];
    }
    else if(![error.domain isEqual:NSURLErrorDomain] || error.code!=NSURLErrorCancelled) {
        [[self client] URLProtocol:self didFailWithError:error];
    }
    self.data = nil;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)newRequest completionHandler:(void (^)(NSURLRequest *))completionHandler {
    NSMutableURLRequest *mutableRequest = [newRequest mutableCopy];
    [[self class] removePropertyForKey:@"UseDefaultImplementation" inRequest:mutableRequest];
    [[self client] URLProtocol:self wasRedirectedToRequest:mutableRequest redirectResponse:response];
    
    NSURLRequest *firstRequest = [NSURLProtocol propertyForKey:@"OriginalRequest" inRequest:self.request];
    if(!firstRequest) {
        firstRequest = self.request;
    }
    [NSURLProtocol setProperty:firstRequest forKey:@"OriginalRequest" inRequest:mutableRequest];
    
    [self.task cancel];
    [[self client] URLProtocol:self didFailWithError:[NSError errorWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:nil]];
}

@end
