//
//  UPDProcessingView.m
//  Updates
//
//  Created by Bryce Pauken on 7/21/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDProcessingView.h"

@interface UPDProcessingView()

@property (nonatomic, strong) UIView *browserImageOverlay;
@property (nonatomic, strong) UIImageView *browserImageView;
@property (nonatomic, strong) UIImageView *checkmark;
@property (nonatomic, strong) UIImageView *outline;

@end

@implementation UPDProcessingView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor UPDLightGreyColor]];
        
        self.browserImageView = [[UIImageView alloc] init];
        [self.browserImageView setAutoresizingMask:UIViewAutoresizingFlexibleMargins];
        [self addSubview:self.browserImageView];
        
        self.browserImageOverlay = [[UIView alloc] init];
        [self.browserImageOverlay setAlpha:UPD_BROWSER_IMAGE_OPACITY];
        [self.browserImageOverlay setAutoresizingMask:UIViewAutoresizingFlexibleMargins];
        [self.browserImageOverlay setBackgroundColor:[UIColor UPDOffBlackColor]];
        [self.browserImageOverlay setUserInteractionEnabled:NO];
        [self addSubview:self.browserImageOverlay];
        
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

- (void)beginProcessing {
    [self.browserImageView setTransform:CGAffineTransformIdentity];
    [self.browserImageView setFrame:CGRectMake((self.bounds.size.width-self.browserImage.size.width)/2, (self.bounds.size.height-self.browserImage.size.height)/2, self.browserImage.size.width, self.browserImage.size.height)];
    [self.browserImageView setImage:self.browserImage];
    
    [self.browserImageOverlay setFrame:self.browserImageView.frame];
    [self.browserImageView setTransform:CGAffineTransformScale(CGAffineTransformIdentity, UPD_BROWSER_IMAGE_SCALE, UPD_BROWSER_IMAGE_SCALE)];
    [self.browserImageOverlay setTransform:CGAffineTransformScale(CGAffineTransformIdentity, UPD_BROWSER_IMAGE_SCALE, UPD_BROWSER_IMAGE_SCALE)];
    
}

@end
