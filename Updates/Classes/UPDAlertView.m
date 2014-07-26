//
//  UPDAlertView.m
//  Updates
//
//  Created by Bryce Pauken on 7/19/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

/*
 A modified view that we can use as an alert—automatically adds
 itself right on top of the interface when show is called
 */

#import "UPDAlertView.h"

#import "UPDAlertViewButton.h"
#import "UPDAppDelegate.h"
#import "UPDViewController.h"

@interface UPDInterface : UIView

@end


@interface UPDAlertView()

@property (nonatomic, strong) UIView *interfaceOverlay;
@property (nonatomic, strong) UPDAlertViewButton *noButton;
@property (nonatomic, strong) UPDAlertViewButton *okButton;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UPDAlertViewButton *yesButton;

@end

@implementation UPDAlertView

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
        [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [self.titleLabel setTextColor:[UIColor UPDOffWhiteColor]];
        [self addSubview:self.titleLabel];
        
        self.messageLabel = [[UILabel alloc] init];
        [self.messageLabel setBackgroundColor:[UIColor UPDLightBlueColor]];
        [self.messageLabel setFont:[UIFont systemFontOfSize:18]];
        [self.messageLabel setNumberOfLines:0];
        [self.messageLabel setTextAlignment:NSTextAlignmentCenter];
        [self.messageLabel setTextColor:[UIColor UPDOffWhiteColor]];
        [self addSubview:self.messageLabel];
        
        self.noButton = [[UPDAlertViewButton alloc] init];
        [self.noButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.noButton setImage:[UIImage imageNamed:@"Cancel"]];
        [self.noButton setTitle:@"No"];
        [self addSubview:self.noButton];
        
        self.yesButton = [[UPDAlertViewButton alloc] init];
        [self.yesButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.yesButton setImage:[UIImage imageNamed:@"Accept"]];
        [self.yesButton setTitle:@"Yes"];
        [self addSubview:self.yesButton];
        
        self.okButton = [[UPDAlertViewButton alloc] init];
        [self.okButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.okButton setTitle:@"Got it"];
        [self addSubview:self.okButton];
    }
    return self;
}

- (void)buttonTapped:(UIButton *)button {
    if(button==self.noButton&&self.noButtonBlock) {
        self.noButtonBlock();
    }
    else if(button==self.yesButton&&self.yesButtonBlock) {
        self.yesButtonBlock();
    }
    else if(button==self.okButton&&self.okButtonBlock) {
        self.okButtonBlock();
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

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return CGRectContainsPoint(self.bounds, point) || (!self.noButton.hidden && CGRectContainsPoint(self.noButton.frame, point)) || (!self.yesButton.hidden && CGRectContainsPoint(self.yesButton.frame, point)) || (!self.okButton.hidden && CGRectContainsPoint(self.okButton.frame, point));
}

- (void)layoutSubviews {
    CGFloat buttonWidth = (self.bounds.size.width-UPD_ALERT_PADDING)/2.0f;
    [self.noButton setFrame:CGRectMake(0, self.bounds.size.height+UPD_ALERT_PADDING, buttonWidth, UPD_ALERT_BUTTON_HEIGHT)];
    [self.yesButton setFrame:CGRectMake(buttonWidth+UPD_ALERT_PADDING, self.bounds.size.height+UPD_ALERT_PADDING, buttonWidth, UPD_ALERT_BUTTON_HEIGHT)];
    [self.okButton setFrame:CGRectMake(0, self.bounds.size.height+UPD_ALERT_PADDING, self.bounds.size.width, UPD_ALERT_BUTTON_HEIGHT)];
}

- (void)setFontSize:(CGFloat)fontSize {
    [self.messageLabel setFont:[UIFont systemFontOfSize:fontSize]];
    [self.titleLabel setFont:[UIFont fontWithName:@"Futura-Medium" size:fontSize+2]];
}

- (void)setTitle:(NSString *)title {
    _title = [title uppercaseString];
}

- (void)show {
    UIView *interface = ((UPDAppDelegate *)[[UIApplication sharedApplication] delegate]).viewController.interface;
    
    [self.yesButton setHidden:!self.yesButtonBlock||!self.noButtonBlock];
    [self.noButton setHidden:!self.yesButtonBlock||!self.noButtonBlock];
    [self.okButton setHidden:!self.okButtonBlock];
    
    [self.interfaceOverlay setFrame:interface.bounds];
    [interface addSubview:self.interfaceOverlay];
    
    CGSize titleLabelSize = [self.title boundingRectWithSize:CGSizeMake(UPD_ALERT_WIDTH-UPD_ALERT_PADDING*2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: self.titleLabel.font} context:nil].size;
    titleLabelSize.height = ceilf(titleLabelSize.height);
    titleLabelSize.width = ceilf(titleLabelSize.width);
    [self.titleLabel setFrame:CGRectMake(UPD_ALERT_PADDING, UPD_ALERT_PADDING, UPD_ALERT_WIDTH-UPD_ALERT_PADDING*2, titleLabelSize.height)];
    [self.titleLabel setText:self.title];
    
    CGSize messageLabelSize = [self.message boundingRectWithSize:CGSizeMake(UPD_ALERT_WIDTH-UPD_ALERT_PADDING*2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: self.messageLabel.font} context:nil].size;
    messageLabelSize.height = ceilf(messageLabelSize.height);
    messageLabelSize.width = ceilf(messageLabelSize.width);
    [self.messageLabel setFrame:CGRectMake(UPD_ALERT_PADDING, self.titleLabel.frame.origin.y+self.titleLabel.frame.size.height+UPD_ALERT_PADDING, UPD_ALERT_WIDTH-UPD_ALERT_PADDING*2, messageLabelSize.height)];
    [self.messageLabel setText:self.message];
    
    CGFloat alertHeight = titleLabelSize.height+messageLabelSize.height+UPD_ALERT_PADDING*3;
    CGFloat alertHeightWithButtons = alertHeight+UPD_ALERT_BUTTON_HEIGHT+UPD_ALERT_PADDING;
    [self setFrame:CGRectMake((interface.bounds.size.width-UPD_ALERT_WIDTH)/2, (interface.bounds.size.height-alertHeightWithButtons)/2, UPD_ALERT_WIDTH, alertHeight)];
    [interface addSubview:self];
    
    /*begin alert animation*/
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
    /*end alert animation*/
    
    [UIView animateWithDuration:UPD_TRANSITION_DURATION animations:^{
        [self.interfaceOverlay setAlpha:0.8];
    }];
}

@end
