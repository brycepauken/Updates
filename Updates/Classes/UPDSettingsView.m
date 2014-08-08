//
//  UPDSettingsView.m
//  Updates
//
//  Created by Bryce Pauken on 8/8/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDSettingsView.h"

#import "UPDAppDelegate.h"
#import "UPDButton.h"
#import "UPDInterface.h"
#import "UPDSwitch.h"
#import "UPDViewController.h"

@interface UPDSettingsView()

@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UPDButton *contactButton;
@property (nonatomic, strong) UPDButton *helpButton;
@property (nonatomic, strong) UIView *interfaceOverlay;
@property (nonatomic, strong) UILabel *saveLabel;
@property (nonatomic, strong) UPDSwitch *saveSwitch;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation UPDSettingsView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setAlpha:0.98];
        [self setAutoresizingMask:UIViewAutoresizingFlexibleMargins];
        [self setBackgroundColor:[UIColor UPDLightBlueColor]];
        [self.layer setCornerRadius:2];
        
        self.interfaceOverlay = [[UIView alloc] init];
        [self.interfaceOverlay setAlpha:0];
        [self.interfaceOverlay setAutoresizingMask:UIViewAutoresizingFlexibleSize];
        [self.interfaceOverlay setBackgroundColor:[UIColor UPDOffBlackColor]];
        [self.interfaceOverlay setUserInteractionEnabled:YES];
        
        self.titleLabel = [[UILabel alloc] init];
        [self.titleLabel setBackgroundColor:[UIColor UPDLightBlueColor]];
        [self.titleLabel setFont:[UIFont fontWithName:@"Futura-Medium" size:20]];
        [self.titleLabel setText:[@"Settings" uppercaseString]];
        [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [self.titleLabel setTextColor:[UIColor UPDOffWhiteColor]];
        [self addSubview:self.titleLabel];
        
        self.saveLabel = [[UILabel alloc] init];
        [self.saveLabel setBackgroundColor:[UIColor UPDLightBlueColor]];
        [self.saveLabel setFont:[UIFont fontWithName:@"Futura-Medium" size:16]];
        [self.saveLabel setNumberOfLines:0];
        [self.saveLabel setText:[@"Save Password" uppercaseString]];
        [self.saveLabel setTextAlignment:NSTextAlignmentCenter];
        [self.saveLabel setTextColor:[UIColor UPDOffWhiteColor]];
        [self addSubview:self.saveLabel];
        
        self.saveSwitch = [[UPDSwitch alloc] initWithFrame:CGRectMake(0, 0, UPD_SWITCH_SIZE_WIDTH, UPD_SWITCH_SIZE_HEIGHT)];
        if([UPDCommon passwordSet]) {
            [self.saveSwitch setOn:[UPDCommon passwordSaved] animated:NO];
        }
        else {
            [self.saveSwitch setEnabled:NO];
        }
        __unsafe_unretained UPDSettingsView *weakSelf = self;
        [self.saveSwitch setToggleBlock:^(BOOL on) {
            if(on) {
                [UPDCommon saveKeychainDataWithCancelBlock:^{
                    [weakSelf.saveSwitch setOn:NO animated:YES];
                }];
            }
            else {
                [UPDCommon clearKeychainData];
            }
        }];
        [self addSubview:self.saveSwitch];
        
        self.helpButton = [[UPDButton alloc] init];
        [self.helpButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.helpButton setTitle:@"Help"];
        [self addSubview:self.helpButton];
        
        self.contactButton = [[UPDButton alloc] init];
        [self.contactButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.contactButton setTitle:@"Contact"];
        [self addSubview:self.contactButton];
        
        self.closeButton = [[UIButton alloc] init];
        [self.closeButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.closeButton setBackgroundColor:[UIColor UPDLightGreyBlueColor]];
        [self.closeButton setImage:[UIImage imageNamed:@"Cancel"] forState:UIControlStateNormal];
        [self.closeButton setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.75, 0.75)];
        [self.closeButton.layer setCornerRadius:UPD_ALERT_CANCEL_BUTTON_SIZE*0.75];
        [self.closeButton.layer setMasksToBounds:NO];
        [self.closeButton.layer setShadowColor:[UIColor UPDOffBlackColor].CGColor];
        [self.closeButton.layer setShadowOffset:CGSizeZero];
        [self.closeButton.layer setShadowOpacity:0.5];
        [self.closeButton.layer setShadowRadius:1];
        [self addSubview:self.closeButton];
    }
    return self;
}

- (void)buttonTapped:(UIButton *)button {
    if(button==self.closeButton && self.closeButtonBlock) {
        self.closeButtonBlock();
    }
}

- (void)dismiss {
    [self setUserInteractionEnabled:NO];
    [self.interfaceOverlay setUserInteractionEnabled:NO];
    [UIView animateWithDuration:UPD_TRANSITION_DURATION animations:^{
        [self setAlpha:0];
        [self setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.5, 0.5)];
        [self.interfaceOverlay setAlpha:0];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [self.interfaceOverlay removeFromSuperview];
    }];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if(CGRectContainsPoint(CGRectInset(self.closeButton.frame, -self.closeButton.frame.size.width, -self.closeButton.frame.size.height), point)) {
        return self.closeButton;
    }
    return [super hitTest:point withEvent:event];
}

- (void)layoutSubviews {
    [self.titleLabel setFrame:CGRectMake((self.bounds.size.width-self.titleLabel.frame.size.width)/2, UPD_ALERT_PADDING, self.titleLabel.frame.size.width, self.titleLabel.frame.size.height)];
    CGFloat saveWidth = self.saveLabel.frame.size.width+UPD_ALERT_PADDING+self.saveSwitch.frame.size.width;
    CGFloat saveHeight = MAX(self.saveLabel.frame.size.height, self.saveSwitch.frame.size.height);
    [self.saveLabel setFrame:CGRectMake((self.bounds.size.width-saveWidth)/2, UPD_ALERT_PADDING+self.titleLabel.frame.size.height+UPD_ALERT_PADDING+(saveHeight-self.saveLabel.frame.size.height)/2, self.saveLabel.frame.size.width, self.saveLabel.frame.size.height)];
    [self.saveSwitch setFrame:CGRectMake((self.bounds.size.width-saveWidth)/2+self.saveLabel.frame.size.width+UPD_ALERT_PADDING, UPD_ALERT_PADDING+self.titleLabel.frame.size.height+UPD_ALERT_PADDING+(saveHeight-self.saveSwitch.frame.size.height)/2, self.saveSwitch.frame.size.width, self.saveSwitch.frame.size.height)];
    [self.helpButton setFrame:CGRectMake((self.bounds.size.width-UPD_SETTINGS_BUTTON_WIDTH)/2, UPD_ALERT_PADDING+self.titleLabel.frame.size.height+UPD_ALERT_PADDING+saveHeight+UPD_ALERT_PADDING, UPD_SETTINGS_BUTTON_WIDTH, UPD_SETTINGS_BUTTON_HEIGHT)];
    [self.contactButton setFrame:CGRectMake((self.bounds.size.width-UPD_SETTINGS_BUTTON_WIDTH)/2, UPD_ALERT_PADDING+self.titleLabel.frame.size.height+UPD_ALERT_PADDING+saveHeight+UPD_ALERT_PADDING+self.helpButton.frame.size.height+UPD_ALERT_PADDING, UPD_SETTINGS_BUTTON_WIDTH, UPD_SETTINGS_BUTTON_HEIGHT)];
    [self.closeButton setFrame:CGRectMake(-UPD_ALERT_CANCEL_BUTTON_SIZE/2, -UPD_ALERT_CANCEL_BUTTON_SIZE/2, UPD_ALERT_CANCEL_BUTTON_SIZE, UPD_ALERT_CANCEL_BUTTON_SIZE)];
}

- (void)show {
    UIView *interface = ((UPDAppDelegate *)[[UIApplication sharedApplication] delegate]).viewController.interface;
    
    [self.interfaceOverlay setFrame:interface.bounds];
    [interface addSubview:self.interfaceOverlay];
    
    [self.titleLabel sizeToFit];
    [self.saveLabel sizeToFit];
    [self.saveSwitch setFrame:CGRectMake(0, 0, UPD_SWITCH_SIZE_WIDTH, UPD_SWITCH_SIZE_HEIGHT)];
    CGFloat saveHeight = MAX(self.saveLabel.frame.size.height, self.saveSwitch.frame.size.height);
    
    [self.helpButton setFrame:CGRectMake(0, 0, UPD_SETTINGS_BUTTON_WIDTH, UPD_SETTINGS_BUTTON_HEIGHT)];
    [self.contactButton setFrame:CGRectMake(0, 0, UPD_SETTINGS_BUTTON_WIDTH, UPD_SETTINGS_BUTTON_HEIGHT)];
    
    [self layoutSubviews];
    
    CGFloat frameHeight = UPD_ALERT_PADDING+self.titleLabel.frame.size.height+UPD_ALERT_PADDING+saveHeight+UPD_ALERT_PADDING+self.helpButton.frame.size.height+UPD_ALERT_PADDING+self.contactButton.frame.size.height+UPD_ALERT_PADDING;
    [self setFrame:CGRectMake((interface.bounds.size.width-UPD_ALERT_WIDTH)/2, (interface.bounds.size.height-frameHeight)/2, UPD_ALERT_WIDTH, frameHeight)];
    [interface addSubview:self];
    
    /*begin settings animation*/
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    CATransform3D scale1 = CATransform3DMakeScale(0.5, 0.5, 1);
    CATransform3D scale2 = CATransform3DMakeScale(1.1, 1.1, 1);
    CATransform3D scale3 = CATransform3DMakeScale(0.9, 0.9, 1);
    CATransform3D scale4 = CATransform3DMakeScale(1.0, 1.0, 1);
    
    NSArray *frameValues = [NSArray arrayWithObjects:[NSValue valueWithCATransform3D:scale1],[NSValue valueWithCATransform3D:scale2],[NSValue valueWithCATransform3D:scale3],[NSValue valueWithCATransform3D:scale4], nil];
    [animation setValues:frameValues];
    
    NSArray *frameTimes = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0],[NSNumber numberWithFloat:0.5],[NSNumber numberWithFloat:0.8],[NSNumber numberWithFloat:1.0], nil];
    [animation setKeyTimes:frameTimes];
    
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = YES;
    animation.duration = UPD_TRANSITION_DURATION;
    
    [self.layer addAnimation:animation forKey:@"popup"];
    /*end settings animation*/
    
    [UIView animateWithDuration:UPD_TRANSITION_DURATION animations:^{
        [self.interfaceOverlay setAlpha:0.8];
    }];
}

@end
