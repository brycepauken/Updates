//
//  UPDURLProtocol.m
//  Update
//
//  Created by Bryce Pauken on 5/15/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDURLProtocol.h"

#import <objc/runtime.h>

@implementation UPDURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if([NSURLProtocol propertyForKey:@"UseDefaultImplementation" inRequest:request]) {
        return NO;
    }
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (void)startLoading {
    NSMutableURLRequest *newRequest = [self.request mutableCopy];
    [NSURLProtocol setProperty:@YES forKey:@"UseDefaultImplementation" inRequest:newRequest];
    self.data = [[NSMutableData alloc] init];
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
                if(AppDelegate.addInstruction) {
                    NSURLRequest *firstRequest = [NSURLProtocol propertyForKey:@"OriginalRequest" inRequest:self.request];
                    NSString *redirectURL = nil;
                    if(firstRequest!=nil) {
                        redirectURL = self.request.URL.absoluteString;
                    }
                    else {
                        firstRequest = self.request;
                    }
                    AppDelegate.addInstruction(firstRequest.URL.absoluteString,[[NSString alloc] initWithData:firstRequest.HTTPBody encoding:NSUTF8StringEncoding],[[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding],headers,redirectURL);
                }
             }
        }
        else {
            //NSLog(@"ERROR (2): %@",error);
            //[self.client URLProtocol:self didFailWithError:error];
        }
    }];
    [self.task resume];
}

- (void)stopLoading {
    [self.task cancel];
    self.task = nil;
    self.data = nil;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    NSLog(@"ERROR (1): %@",error);
    [self.client URLProtocol:self didFailWithError:error];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest *))completionHandler {
    NSLog(@"%@",response);
    [self.client URLProtocol:self wasRedirectedToRequest:request redirectResponse:response];
    completionHandler(request);
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse {
    if(redirectResponse) {
        NSMutableURLRequest *newRequest = [request mutableCopy];
        [NSURLProtocol removePropertyForKey:@"UseDefaultImplementation" inRequest:newRequest];
        if(![NSURLProtocol propertyForKey:@"OriginalRequest" inRequest:newRequest]) {
            [NSURLProtocol setProperty:self.request forKey:@"OriginalRequest" inRequest:newRequest];
        }
        [newRequest setURL:request.URL];
        if(!([self.response isKindOfClass:[NSHTTPURLResponse class]]&&((NSHTTPURLResponse *)self.response).statusCode==307)) {
            [newRequest setHTTPMethod:@"GET"];
        }
        //[self.client URLProtocol:self wasRedirectedToRequest:newRequest redirectResponse:redirectResponse];
        return newRequest;
    }
    //[self.client URLProtocol:self wasRedirectedToRequest:request redirectResponse:redirectResponse];
    return request;
    
    if(redirectResponse) {
        NSMutableURLRequest *mutableRequest = [request mutableCopy];
        if(((NSHTTPURLResponse *)redirectResponse).statusCode==307) {
            NSString *prevMethod = self.request.HTTPMethod;
            if([prevMethod caseInsensitiveCompare:mutableRequest.HTTPMethod]!=NSOrderedSame) {
                [mutableRequest setHTTPMethod:prevMethod];
                
                NSURLRequest *firstRequest = [NSURLProtocol propertyForKey:@"OriginalRequest" inRequest:request];
                if(firstRequest==nil) {
                    firstRequest = self.request;
                }
                NSData *firstBody = firstRequest.HTTPBody;
                if([prevMethod caseInsensitiveCompare:@"GET"]!=NSOrderedSame&&firstBody&&[firstBody length]) {
                    [mutableRequest setHTTPBody:firstBody];
                }
                NSString *firstContentType = [firstRequest valueForHTTPHeaderField:@"Content-Type"];
                if(firstContentType&&[firstContentType length]) {
                    [mutableRequest setValue:firstContentType forHTTPHeaderField:@"Content-Type"];
                }
            }
        }
        if([mutableRequest.URL.scheme caseInsensitiveCompare:@"https"]!=NSOrderedSame && [mutableRequest valueForHTTPHeaderField:@"Referer"] && [[NSURL URLWithString:[mutableRequest valueForHTTPHeaderField:@"Referer"]].scheme caseInsensitiveCompare:@"https"]==NSOrderedSame) {
            [mutableRequest setValue:nil forHTTPHeaderField:@"Referer"];
        }
        [self.client URLProtocol:self wasRedirectedToRequest:mutableRequest redirectResponse:redirectResponse];
        return mutableRequest;
    }
    [self.client URLProtocol:self wasRedirectedToRequest:request redirectResponse:redirectResponse];
    return request;
}

@end
