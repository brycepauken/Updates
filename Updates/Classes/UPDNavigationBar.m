//
//  UPDNavigationBar.m
//  Update
//
//  Created by Bryce Pauken on 5/16/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDNavigationBar.h"

@implementation UPDNavigationBar

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        NSInteger offset = [UPDCommon isIOS7]?20:0;
        self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, offset, self.bounds.size.width, self.bounds.size.height-offset)];
        [self.contentView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self addSubview:self.contentView];
        
        UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-1, self.bounds.size.width, 1)];
        [divider setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [divider setBackgroundColor:[UIColor lightGrayColor]];
        [self addSubview:divider];
    }
    return self;
}

@end
