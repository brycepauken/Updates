//
//  UPDURLProtocolSwitcher.m
//  Updates
//
//  Created by Bryce Pauken on 9/7/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDURLProtocolSwitcher.h"

#pragma mark - SwitcherOutlet

@interface UPDURLProtocolSwitcherOutlet : NSObject

@property (atomic, strong) id<NSURLSessionDataDelegate> delegate;
@property (atomic, copy, readonly) NSArray *modes;
@property (atomic, strong, readonly) NSURLSessionDataTask *task;
@property (atomic, strong) NSThread *thread;

@end

@implementation UPDURLProtocolSwitcherOutlet

- (instancetype)initWithTask:(NSURLSessionDataTask *)task delegate:(id<NSURLSessionDataDelegate>)delegate modes:(NSArray *)modes {
    self = [super init];
    if(self) {
        _task = task;
        _delegate = delegate;
        _thread = [NSThread currentThread];
        _modes = [modes copy];
    }
    return self;
}

- (void)performBlock:(dispatch_block_t)block {
    [self performSelector:@selector(performBlockOnClientThread:) onThread:self.thread withObject:[block copy] waitUntilDone:NO modes:self.modes];
}

- (void)performBlockOnClientThread:(dispatch_block_t)block {
    block();
}

- (void)invalidate {
    [self setDelegate:nil];
    [self setThread:nil];
}

@end

#pragma mark - Switcher

@interface UPDURLProtocolSwitcher() <NSURLSessionDataDelegate>

@property (atomic, copy, readonly) NSURLSessionConfiguration *configuration;
@property (atomic, strong, readonly) NSOperationQueue *delegateQueue;
@property (atomic, strong, readonly) NSURLSession *session;
@property (atomic, strong, readonly) NSMutableDictionary *taskOutlets;

@end

@implementation UPDURLProtocolSwitcher

- (instancetype)initWithConfiguration:(NSURLSessionConfiguration *)configuration {
    self = [super init];
    if(self) {
        _configuration = configuration;
        
        _taskOutlets = [NSMutableDictionary dictionary];
        
        _delegateQueue = [NSOperationQueue new];
        [_delegateQueue setMaxConcurrentOperationCount:5];
        [_delegateQueue setName:@"UPDURLProtocolSwitcher"];
        
        _session = [NSURLSession sessionWithConfiguration:_configuration delegate:self delegateQueue:_delegateQueue];
        [_session setSessionDescription:@"UPDURLProtocolSwitcher"];
    }
    return self;
}

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request delegate:(id<NSURLSessionDataDelegate>)delegate modes:(NSArray *)modes {
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request];
    UPDURLProtocolSwitcherOutlet *taskOutlet = [[UPDURLProtocolSwitcherOutlet alloc] initWithTask:task delegate:delegate modes:modes];

    @synchronized(self) {
        [self.taskOutlets setObject:taskOutlet forKey:@(task.taskIdentifier)];
    }
    return task;
}

- (UPDURLProtocolSwitcherOutlet *)taskOutletForTask:(NSURLSessionTask *)task {
    UPDURLProtocolSwitcherOutlet *taskOutlet;
    @synchronized(self) {
        taskOutlet = [self.taskOutlets objectForKey:@(task.taskIdentifier)];
    }
    return taskOutlet;
}

#pragma mark - Switcher (Delegate Methods)

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask {
    UPDURLProtocolSwitcherOutlet *taskOutlet = [self taskOutletForTask:dataTask];
    if([taskOutlet.delegate respondsToSelector:@selector(URLSession:dataTask:didBecomeDownloadTask:)]) {
        [taskOutlet performBlock:^{
            [taskOutlet.delegate URLSession:session dataTask:dataTask didBecomeDownloadTask:downloadTask];
        }];
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    UPDURLProtocolSwitcherOutlet *taskOutlet = [self taskOutletForTask:dataTask];
    if([taskOutlet.delegate respondsToSelector:@selector(URLSession:dataTask:didReceiveData:)]) {
        [taskOutlet performBlock:^{
            [taskOutlet.delegate URLSession:session dataTask:dataTask didReceiveData:data];
        }];
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    UPDURLProtocolSwitcherOutlet *taskOutlet = [self taskOutletForTask:dataTask];
    if([taskOutlet.delegate respondsToSelector:@selector(URLSession:dataTask:didReceiveResponse:completionHandler:)]) {
        [taskOutlet performBlock:^{
            [taskOutlet.delegate URLSession:session dataTask:dataTask didReceiveResponse:response completionHandler:completionHandler];
        }];
    }
    else {
        completionHandler(NSURLSessionResponseAllow);
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask willCacheResponse:(NSCachedURLResponse *)proposedResponse completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler {
    UPDURLProtocolSwitcherOutlet *taskOutlet = [self taskOutletForTask:dataTask];
    if([taskOutlet.delegate respondsToSelector:@selector(URLSession:dataTask:willCacheResponse:completionHandler:)]) {
        [taskOutlet performBlock:^{
            [taskOutlet.delegate URLSession:session dataTask:dataTask willCacheResponse:proposedResponse completionHandler:completionHandler];
        }];
    }
    else {
        completionHandler(proposedResponse);
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    UPDURLProtocolSwitcherOutlet *taskOutlet = [self taskOutletForTask:task];
    
    @synchronized (self) {
        [self.taskOutlets removeObjectForKey:@(taskOutlet.task.taskIdentifier)];
    }
    
    if([taskOutlet.delegate respondsToSelector:@selector(URLSession:task:didCompleteWithError:)]) {
        [taskOutlet performBlock:^{
            [taskOutlet.delegate URLSession:session task:task didCompleteWithError:error];
            [taskOutlet invalidate];
        }];
    }
    else {
        [taskOutlet invalidate];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    UPDURLProtocolSwitcherOutlet *taskOutlet = [self taskOutletForTask:task];
    if([taskOutlet.delegate respondsToSelector:@selector(URLSession:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:)]) {
        [taskOutlet performBlock:^{
            [taskOutlet.delegate URLSession:session task:task didSendBodyData:bytesSent totalBytesSent:totalBytesSent totalBytesExpectedToSend:totalBytesExpectedToSend];
        }];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task needNewBodyStream:(void (^)(NSInputStream *bodyStream))completionHandler {
    UPDURLProtocolSwitcherOutlet *taskOutlet = [self taskOutletForTask:task];
    if([taskOutlet.delegate respondsToSelector:@selector(URLSession:task:needNewBodyStream:)]) {
        [taskOutlet performBlock:^{
            [taskOutlet.delegate URLSession:session task:task needNewBodyStream:completionHandler];
        }];
    }
    else {
        completionHandler(nil);
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)newRequest completionHandler:(void (^)(NSURLRequest *))completionHandler {
    UPDURLProtocolSwitcherOutlet *taskOutlet = [self taskOutletForTask:task];
    if([taskOutlet.delegate respondsToSelector:@selector(URLSession:task:willPerformHTTPRedirection:newRequest:completionHandler:)]) {
        [taskOutlet performBlock:^{
            [taskOutlet.delegate URLSession:session task:task willPerformHTTPRedirection:response newRequest:newRequest completionHandler:completionHandler];
        }];
    }
    else {
        completionHandler(newRequest);
    }
}

@end
