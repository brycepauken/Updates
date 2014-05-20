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
    if([[headers objectForKey:@"Content-Type"] hasPrefix:@"text"]) {
        //NSLog(@"REQUEST TO URL: %@\nPOST DATA: %@\nRESPONSE: %@\n HEADERS: %@\n",self.request.URL,[[NSString alloc] initWithData:self.request.HTTPBody encoding:NSUTF8StringEncoding],[[NSString alloc] initWithData:nil encoding:NSUTF8StringEncoding],headers);
        if(AppDelegate.addInstruction) {
            AppDelegate.addInstruction(self.request.URL.absoluteString,[[NSString alloc] initWithData:self.request.HTTPBody encoding:NSUTF8StringEncoding],[[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding],headers);
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
        NSMutableURLRequest *newRequest = [request mutableCopy];
        [newRequest setURL:request.URL];
        if(!([self.response isKindOfClass:[NSHTTPURLResponse class]]&&((NSHTTPURLResponse *)self.response).statusCode==307)) {
            [newRequest setHTTPMethod:@"GET"];
        }
        [self.client URLProtocol:self wasRedirectedToRequest:newRequest redirectResponse:redirectResponse];
        return newRequest;
    }
    return request;
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [challenge.sender performDefaultHandlingForAuthenticationChallenge:challenge];
}

@end
