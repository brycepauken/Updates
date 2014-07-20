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
        self.get = [NSMutableDictionary dictionary];
        self.post = [NSMutableDictionary dictionary];
    }
    return self;
}

@end