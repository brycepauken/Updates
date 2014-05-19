//
//  UPDBrowserBottomBar.m
//  Updates
//
//  Created by Bryce Pauken on 5/18/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDBrowserBottomBar.h"

@implementation UPDBrowserBottomBar

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor UPDOffWhiteColor]];
        
        self.finishButton = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width-self.bounds.size.height, 0, self.bounds.size.height, self.bounds.size.height)];
        [self.finishButton addTarget:self action:@selector(finishButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.finishButton setBackgroundImage:[UIImage imageNamed:@"Checkmark"] forState:UIControlStateNormal];
        [self addSubview:self.finishButton];
        
        UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 1)];
        [divider setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [divider setBackgroundColor:[UIColor lightGrayColor]];
        [self addSubview:divider];
    }
    return self;
}

- (void)finishButtonTapped {
    if(self.finishButtonBlock) {
        self.finishButtonBlock();
    }
}

@end
