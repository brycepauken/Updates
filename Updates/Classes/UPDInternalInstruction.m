//
//  UPDInternalInstruction.m
//  Updates
//
//  Created by Bryce Pauken on 7/19/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

/*
 The internal instruction class basically represents an
 instruction during prosessing, before being saved to disk.
 */

#import "UPDInternalInstruction.h"

@implementation UPDInternalInstruction

- (instancetype)init {
    self = [super init];
    if(self) {
        /*don't need to initialize headers, it's added directly later on*/
        self.get = [NSMutableArray array];
        self.post = [NSMutableArray array];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if(self) {
        self.baseURL = [decoder decodeObjectForKey:@"baseURL"];
        self.endRequest = [decoder decodeObjectForKey:@"endRequest"];
        self.get = [decoder decodeObjectForKey:@"get"];
        self.headers = [decoder decodeObjectForKey:@"headers"];
        self.fullURL = [decoder decodeObjectForKey:@"fullURL"];
        self.post = [decoder decodeObjectForKey:@"post"];
        self.reliesOnPrevRequest = [[decoder decodeObjectForKey:@"reliesOnPrevRequest"] boolValue];
        self.request = [decoder decodeObjectForKey:@"request"];
        self.response = [decoder decodeObjectForKey:@"response"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.baseURL forKey:@"baseURL"];
    [encoder encodeObject:self.endRequest forKey:@"endRequest"];
    [encoder encodeObject:self.get forKey:@"get"];
    [encoder encodeObject:self.headers forKey:@"headers"];
    [encoder encodeObject:self.fullURL forKey:@"fullURL"];
    [encoder encodeObject:self.post forKey:@"post"];
    [encoder encodeObject:@(self.reliesOnPrevRequest) forKey:@"reliesOnPrevRequest"];
    [encoder encodeObject:self.request forKey:@"request"];
    [encoder encodeObject:self.response forKey:@"response"];
}

@end