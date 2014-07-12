//
//  UPDURLProtocol.h
//  Update
//
//  Created by Bryce Pauken on 5/15/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UPDURLProtocol : NSURLProtocol <NSURLSessionDelegate>

@property (nonatomic, retain) NSMutableData *data;
@property (nonatomic, retain) NSURLResponse *response;
@property (nonatomic, retain) NSURLSession *session;
@property (nonatomic, retain) NSURLSessionDataTask *task;

@end
