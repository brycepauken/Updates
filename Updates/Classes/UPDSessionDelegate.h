//
//  UPDSessionDelegate.h
//  Updates
//
//  Created by Bryce Pauken on 8/11/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UPDSessionDelegate : NSObject <NSURLSessionDelegate>

@property (nonatomic, copy) void(^completionBlock)(NSData *data, NSURLResponse *response, NSMutableDictionary *returnedCookies, NSError *error);

- (instancetype)initWithTask:(NSURLSessionTask *)task request:(NSURLRequest *)request;

@end
