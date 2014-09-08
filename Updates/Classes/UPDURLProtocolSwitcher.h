//
//  UPDURLProtocolSwitcher.h
//  Updates
//
//  Created by Bryce Pauken on 9/7/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UPDURLProtocolSwitcher : NSObject

- (instancetype)initWithConfiguration:(NSURLSessionConfiguration *)configuration;
- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request delegate:(id<NSURLSessionDataDelegate>)delegate modes:(NSArray *)modes;

@end
