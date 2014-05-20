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
        
        CGFloat buttonMargin = (self.bounds.size.width-(self.bounds.size.height*4))/5;
        for(int i=0;i<4;i++) {
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((i+1)*buttonMargin+i*self.bounds.size.height, 0, self.bounds.size.height, self.bounds.size.height)];
            [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [button setBackgroundImage:[UIImage imageNamed:i==0?@"Cross":(i==1?@"LeftArrow":(i==2?@"RightArrow":@"Checkmark"))] forState:UIControlStateNormal];
            [button setTag:i];
            [button.layer setCornerRadius:4];
            [button.layer setMasksToBounds:YES];
            [self addSubview:button];
        }
        
        UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 1)];
        [divider setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [divider setBackgroundColor:[UIColor lightGrayColor]];
        [self addSubview:divider];
        
        for(int i=0;i<2;i++) {
            UIView *smallDivider = [[UIView alloc] initWithFrame:CGRectMake(i==0?(buttonMargin*3/2+self.bounds.size.height-1):(buttonMargin*7/2+self.bounds.size.height*3), 0, 1, self.bounds.size.height)];
            [smallDivider setBackgroundColor:[UIColor lightGrayColor]];
            [self addSubview:smallDivider];
            if(i==0) {
                self.smallDividerLeft = smallDivider;
            }
            else {
                self.smallDividerRight = smallDivider;
            }
        }
    }
    return self;
}

- (void)buttonTapped:(UIButton *)sender {
    if(sender.tag==3&&self.finishButtonBlock) {
        self.finishButtonBlock();
    }
}

- (void)layoutSubviews {
    CGFloat buttonMargin = (self.bounds.size.width-(self.bounds.size.height*4))/5;
    for(UIView *view in [self subviews]) {
        if([view isKindOfClass:[UIButton class]]) {
            [view setFrame:CGRectMake(view.tag==0?(buttonMargin*3/4):(view.tag==3?(buttonMargin*17/4+self.bounds.size.height*3):(view.tag+1)*buttonMargin+view.tag*self.bounds.size.height), 0, self.bounds.size.height, self.bounds.size.height)];
        }
    }
    [self.smallDividerLeft setFrame:CGRectMake(buttonMargin*3/2+self.bounds.size.height-1, 0, 1, self.bounds.size.height)];
    [self.smallDividerRight setFrame:CGRectMake(buttonMargin*7/2+self.bounds.size.height*3, 0, 1, self.bounds.size.height)];
}

@end
