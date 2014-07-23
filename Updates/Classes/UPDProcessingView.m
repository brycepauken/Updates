//
//  UPDProcessingView.m
//  Updates
//
//  Created by Bryce Pauken on 7/22/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDProcessingView.h"

@interface UPDProcessingView()

@property (nonatomic, strong) UIImageView *checkmark;
@property (nonatomic, strong) UIImageView *outline;
@property (nonatomic, strong) UIImageView *outlineQuarter;

@end

@implementation UPDProcessingView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor UPDLightBlueColor]];
        
        self.outlineQuarter = [[UIImageView alloc] initWithFrame:CGRectMake((self.bounds.size.width-UPD_CONFIRM_BUTTON_SIZE)/2, (self.bounds.size.height-UPD_CONFIRM_BUTTON_SIZE)/2, UPD_CONFIRM_BUTTON_SIZE, UPD_CONFIRM_BUTTON_SIZE)];
        [self.outlineQuarter setAutoresizingMask:UIViewAutoresizingFlexibleMargins];
        [self.outlineQuarter setImage:[UIImage imageNamed:@"ButtonOutlineQuarter"]];
        [self.outlineQuarter setHidden:YES];
        [self addSubview:self.outlineQuarter];
        
        self.outline = [[UIImageView alloc] initWithFrame:CGRectMake((self.bounds.size.width-UPD_CONFIRM_BUTTON_SIZE)/2, (self.bounds.size.height-UPD_CONFIRM_BUTTON_SIZE)/2, UPD_CONFIRM_BUTTON_SIZE, UPD_CONFIRM_BUTTON_SIZE)];
        [self.outline setAutoresizingMask:UIViewAutoresizingFlexibleMargins];
        [self.outline setImage:[UIImage imageNamed:@"ButtonOutline"]];
        [self addSubview:self.outline];
        
        self.checkmark = [[UIImageView alloc] initWithFrame:CGRectMake((self.bounds.size.width-UPD_CONFIRM_BUTTON_SIZE)/2, (self.bounds.size.height-UPD_CONFIRM_BUTTON_SIZE)/2, UPD_CONFIRM_BUTTON_SIZE, UPD_CONFIRM_BUTTON_SIZE)];
        [self.checkmark setAutoresizingMask:UIViewAutoresizingFlexibleMargins];
        [self.checkmark setImage:[UIImage imageNamed:@"AcceptLarge"]];
        [self addSubview:self.checkmark];
    }
    return self;
}

- (void)beginProcessingAnimation {
    [self.outlineQuarter setHidden:NO];
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    [rotationAnimation setCumulative:YES];
    [rotationAnimation setDuration:UPD_PROCESSING_ANIMATION_DURATION];
    [rotationAnimation setToValue:@(M_PI*2)];
    [rotationAnimation setRepeatCount:MAXFLOAT];
    [self.outlineQuarter.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    
    [UIView animateWithDuration:UPD_PROCESSING_ANIMATION_DURATION animations:^{
        [self.outline setAlpha:0];
        
        CGRect newFrame = CGRectMake((self.bounds.size.width-UPD_CONFIRM_BUTTON_SIZE)/2, (self.bounds.size.height/2-UPD_CONFIRM_BUTTON_SIZE)/2, UPD_CONFIRM_BUTTON_SIZE, UPD_CONFIRM_BUTTON_SIZE);
        [self.checkmark setFrame:newFrame];
        [self.outline setFrame:newFrame];
        [self.outlineQuarter setFrame:newFrame];
    }];
}

@end
