//
//  UPDSessionDelegate.m
//  Updates
//
//  Created by Bryce Pauken on 8/11/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDSessionDelegate.h"

@interface UPDSessionDelegate()

@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSMutableArray *redirectedTasks;
@property (nonatomic, strong) NSLock *redirectedTasksLock;

@end

@implementation UPDSessionDelegate

- (instancetype)init {
    self = [super init];
    if(self) {
        [self setData:[NSMutableData data]];
        [self setRedirectedTasks:[NSMutableArray array]];
        [self setRedirectedTasksLock:[NSLock new]];
    }
    return self;
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop){
        [self.data appendBytes:bytes length:byteRange.length];
    }];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
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
    [self.redirectedTasksLock unlock];
    if(!wasRedirected&&self.completionBlock) {
        if(!error) {
            self.completionBlock(self.data, task.response, nil);
        }
        else {
            self.completionBlock(nil, nil, error);
        }
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest *))completionHandler {
    NSMutableURLRequest *mutableRequest = [self.request mutableCopy];
    [mutableRequest setHTTPBody:nil];
    [mutableRequest setHTTPMethod:@"GET"];
    [mutableRequest setURL:request.URL];
    
    if(response) {
        __unsafe_unretained NSURLSessionTask *weakTask = task;
        [self.redirectedTasksLock lock];
        [self.redirectedTasks addObject:weakTask];
        [self.redirectedTasksLock unlock];
        [task cancel];
        
        UPDSessionDelegate *delegate = [[UPDSessionDelegate alloc] init];
        NSURLSession *newSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:delegate delegateQueue:session.delegateQueue];
        [delegate setRequest:mutableRequest];
        [delegate setCompletionBlock:self.completionBlock];
        NSURLSessionDataTask *newTask = [newSession dataTaskWithRequest:mutableRequest];
        [newTask resume];
    }
    completionHandler(mutableRequest);
}

@end
