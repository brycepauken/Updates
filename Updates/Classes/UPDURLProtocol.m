//
//  UPDURLProtocol.m
//  Update
//
//  Created by Bryce Pauken on 5/15/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDURLProtocol.h"

@implementation UPDURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if([NSURLProtocol propertyForKey:@"UseDefaultImplementation" inRequest:request]) {
        return NO;
    }
    NSLog(@"Starting: %@",request.URL.absoluteString);
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (void)startLoading {
    NSMutableURLRequest *newRequest = [self.request mutableCopy];
    [NSURLProtocol setProperty:@YES forKey:@"UseDefaultImplementation" inRequest:newRequest];
    self.data = [[NSMutableData alloc] init];
    self.connection = [NSURLConnection connectionWithRequest:newRequest delegate:self];
}

- (void)stopLoading {
    [self.connection cancel];
    self.connection = nil;
    self.data = nil;
}

#pragma mark NSURLConnectionDelegate Implementation

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSDictionary *headers = [(NSHTTPURLResponse *)self.response allHeaderFields];
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
    [self.client URLProtocolDidFinishLoading:self];
}

- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [self.client URLProtocol:self didCancelAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"%@",error);
    [self.client URLProtocol:self didFailWithError:error];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [self.client URLProtocol:self didReceiveAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.data appendData:data];
    [self.client URLProtocol:self didLoadData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.response = response;
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse {
    if(redirectResponse) {
        NSLog(@"Redirecting: %@->%@",self.request.URL.absoluteString,request.URL.absoluteString);
        NSMutableURLRequest *newRequest = [request mutableCopy];
        [NSURLProtocol removePropertyForKey:@"UseDefaultImplementation" inRequest:newRequest];
        if(![NSURLProtocol propertyForKey:@"OriginalRequest" inRequest:newRequest]) {
            [NSURLProtocol setProperty:self.request forKey:@"OriginalRequest" inRequest:newRequest];
        }
        [newRequest setURL:request.URL];
        if(!([self.response isKindOfClass:[NSHTTPURLResponse class]]&&((NSHTTPURLResponse *)self.response).statusCode==307)) {
            [newRequest setHTTPMethod:@"GET"];
        }
        [self.client URLProtocol:self wasRedirectedToRequest:newRequest redirectResponse:redirectResponse];
        return newRequest;
    }
    NSLog(@"Not Redirecting");
    return request;
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [challenge.sender performDefaultHandlingForAuthenticationChallenge:challenge];
}

@end
