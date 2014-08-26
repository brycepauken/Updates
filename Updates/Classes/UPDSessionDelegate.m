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
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSMutableDictionary *returnedCookies;
@property (nonatomic, strong) NSURLSessionTask *task;

@end

@implementation UPDSessionDelegate

NSMutableArray *_instances;
NSLock *_instancesLock;

+ (void)initialize {
    _instances = [NSMutableArray array];
    _instancesLock = [NSLock new];
}

- (instancetype)initWithTask:(NSURLSessionTask *)task request:(NSURLRequest *)request {
    self = [super init];
    if(self) {
        [_instancesLock lock];
        [_instances addObject:self];
        [_instancesLock unlock];
        
        [self setData:[NSMutableData data]];
        [self setRedirectedTasks:[NSMutableArray array]];
        [self setRedirectedTasksLock:[NSLock new]];
        [self setRequest:request];
        [self setReturnedCookies:[NSMutableDictionary dictionary]];
        [self setTask:task];
    }
    return self;
}

+ (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    UPDSessionDelegate *instance;
    [_instancesLock lock];
    for(UPDSessionDelegate *inst in _instances) {
        if(inst.task==dataTask) {
            instance = inst;
            break;
        }
    }
    [_instancesLock unlock];
    
    if(instance) {
        [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop){
            [instance.data appendBytes:bytes length:byteRange.length];
        }];
    }
}

+ (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    UPDSessionDelegate *instance;
    [_instancesLock lock];
    for(UPDSessionDelegate *inst in _instances) {
        if(inst.task==dataTask) {
            instance = inst;
            break;
        }
    }
    [_instancesLock unlock];
    
    if(instance) {
        completionHandler(NSURLSessionResponseAllow);
    }
}

+ (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    UPDSessionDelegate *instance;
    [_instancesLock lock];
    for(UPDSessionDelegate *inst in _instances) {
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
        [instance.redirectedTasksLock unlock];
        if(!wasRedirected&&instance.completionBlock) {
            if(!error) {
                instance.completionBlock(instance.data, task.response, nil, nil);
            }
            else {
                instance.completionBlock(nil, nil, nil, error);
            }
        }
    }
}

+ (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
    UPDSessionDelegate *instance;
    [_instancesLock lock];
    for(UPDSessionDelegate *inst in _instances) {
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
    UPDSessionDelegate *instance;
    [_instancesLock lock];
    for(UPDSessionDelegate *inst in _instances) {
        if(inst.task==task) {
            instance = inst;
            break;
        }
    }
    [_instancesLock unlock];
    
    if(instance) {
        NSMutableURLRequest *mutableRequest = [instance.request mutableCopy];
        [mutableRequest setHTTPBody:nil];
        [mutableRequest setHTTPMethod:@"GET"];
        [mutableRequest setURL:request.URL];
        
        [mutableRequest setAllHTTPHeaderFields:[NSHTTPCookie requestHeaderFieldsWithCookies:[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:mutableRequest.URL]]];
        
        if(response) {
            __unsafe_unretained NSURLSessionTask *weakTask = task;
            [instance.redirectedTasksLock lock];
            [instance.redirectedTasks addObject:weakTask];
            [instance.redirectedTasksLock unlock];
            [task cancel];
            
            NSURLSessionDataTask *newTask = [session dataTaskWithRequest:mutableRequest];
            UPDSessionDelegate *delegate = [[UPDSessionDelegate alloc] initWithTask:newTask request:mutableRequest];
            [delegate setCompletionBlock:instance.completionBlock];
            [newTask resume];
        }
        completionHandler(mutableRequest);
    }
}

@end
