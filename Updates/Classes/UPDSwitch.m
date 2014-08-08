//
//  UPDSwitch.m
//  Updates
//
//  Created by Bryce Pauken on 8/8/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDSwitch.h"

@interface UPDSwitch()

@property (nonatomic, strong) UIImageView *offIcon;
@property (nonatomic) BOOL on;
@property (nonatomic, strong) UIImageView *onIcon;
@property (nonatomic, strong) UIView *switchView;

@end

@implementation UPDSwitch

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor UPDLightGreyColor]];
        [self.layer setCornerRadius:2];
        _on = YES;
        
        self.switchView = [[UIView alloc] initWithFrame:CGRectMake(UPD_SWITCH_PADDING, UPD_SWITCH_PADDING, self.bounds.size.height-UPD_SWITCH_PADDING*2, self.bounds.size.height-UPD_SWITCH_PADDING*2)];
        [self.switchView setBackgroundColor:[UIColor UPDLightGreyBlueColor]];
        [self.switchView.layer setCornerRadius:2];
        [self addSubview:self.switchView];
        
        self.onIcon = [[UIImageView alloc] initWithFrame:CGRectMake((self.switchView.bounds.size.width-UPD_SWITCH_ICON_SIZE)/2, (self.switchView.bounds.size.height-UPD_SWITCH_ICON_SIZE)/2, UPD_SWITCH_ICON_SIZE, UPD_SWITCH_ICON_SIZE)];
        [self.onIcon setAutoresizingMask:UIViewAutoresizingFlexibleMargins];
        [self.onIcon setImage:[UIImage imageNamed:@"Accept"]];
        [self.switchView addSubview:self.onIcon];
        
        self.offIcon = [[UIImageView alloc] initWithFrame:CGRectMake((self.switchView.bounds.size.width-UPD_SWITCH_ICON_SIZE)/2, (self.switchView.bounds.size.height-UPD_SWITCH_ICON_SIZE)/2, UPD_SWITCH_ICON_SIZE, UPD_SWITCH_ICON_SIZE)];
        [self.offIcon setAlpha:0];
        [self.offIcon setAutoresizingMask:UIViewAutoresizingFlexibleMargins];
        [self.offIcon setImage:[UIImage imageNamed:@"Cancel"]];
        [self.switchView addSubview:self.offIcon];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggle)];
        [self addGestureRecognizer:tapRecognizer];
    }
    return self;
}

- (void)setEnabled:(BOOL)enabled {
    [self setUserInteractionEnabled:enabled];
    [self setAlpha:enabled?1:0.5];
    [self.switchView setBackgroundColor:enabled?[UIColor UPDLightGreyBlueColor]:[UIColor lightGrayColor]];
}

- (void)setOn:(BOOL)on animated:(BOOL)animated {
    if(on!=_on) {
        [self toggleShouldAnimate:animated shouldUseBlock:NO];
    }
}

- (void)toggle {
    [self toggleShouldAnimate:YES shouldUseBlock:YES];
}

- (void)toggleShouldAnimate:(BOOL)animate shouldUseBlock:(BOOL)useBlock {
    CGRect newFrame;
    if(self.on) {
        _on = NO;
        newFrame = CGRectMake(self.bounds.size.width-UPD_SWITCH_PADDING-(self.bounds.size.height-UPD_SWITCH_PADDING*2), UPD_SWITCH_PADDING, self.bounds.size.height-UPD_SWITCH_PADDING*2, self.bounds.size.height-UPD_SWITCH_PADDING*2);
    }
    else {
        _on = YES;
        newFrame = CGRectMake(UPD_SWITCH_PADDING, UPD_SWITCH_PADDING, self.bounds.size.height-UPD_SWITCH_PADDING*2, self.bounds.size.height-UPD_SWITCH_PADDING*2);
    }
    [self setUserInteractionEnabled:NO];
    [UIView animateWithDuration:(animate?UPD_TRANSITION_DURATION_FAST:0) animations:^{
        [self.switchView setFrame:newFrame];
        [self.onIcon setAlpha:self.on?1:0];
        [self.offIcon setAlpha:self.on?0:1];
    } completion:^(BOOL finished) {
        [self setUserInteractionEnabled:YES];
    }];
    if(useBlock&&self.toggleBlock) {
        self.toggleBlock(self.on);
    }
}

@end
