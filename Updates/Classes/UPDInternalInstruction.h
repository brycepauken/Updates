//
//  UPDInternalInstruction.h
//  Updates
//
//  Created by Bryce Pauken on 7/19/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UPDInternalInstruction : NSObject <NSCoding>

@property (nonatomic, strong) NSString *baseURL;
@property (nonatomic, strong) NSMutableDictionary *get;
@property (nonatomic, strong) NSDictionary *headers;
@property (nonatomic, strong) NSString *fullURL;
@property (nonatomic, strong) NSMutableDictionary *post;
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSString *response;

@end