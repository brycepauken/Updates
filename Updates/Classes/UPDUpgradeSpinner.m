//
//  UPDUpgradeSpinner.m
//  Updates
//
//  Created by Bryce Pauken on 9/20/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDUpgradeSpinner.h"

#import "UPDAppDelegate.h"
#import "UPDInterface.h"
#import "UPDViewController.h"

@interface UPDUpgradeSpinner()

typedef NS_ENUM(NSInteger, UPDUpgradeSpinnerStatus) {
    UPDUpgradeSpinnerStatusHidden,
    UPDUpgradeSpinnerStatusHiding,
    UPDUpgradeSpinnerStatusShown,
    UPDUpgradeSpinnerStatusShowing
};

@property (nonatomic, strong) UIView *interfaceOverlay;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic) UPDUpgradeSpinnerStatus status;

@end

@implementation UPDUpgradeSpinner

- (instancetype)init {
    self = [super init];
    if(self) {
        [self setAlpha:0.98];
        [self setAutoresizingMask:UIViewAutoresizingFlexibleMargins];
        [self setBackgroundColor:[UIColor UPDLightBlueColor]];
        [self setStatus:UPDUpgradeSpinnerStatusHidden];
        [self.layer setCornerRadius:8];
        
        self.interfaceOverlay = [[UIView alloc] init];
        [self.interfaceOverlay setAlpha:0];
        [self.interfaceOverlay setAutoresizingMask:UIViewAutoresizingFlexibleSize];
        [self.interfaceOverlay setBackgroundColor:[UIColor UPDOffBlackColor]];
        [self.interfaceOverlay setUserInteractionEnabled:YES];
        
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self.spinner setAutoresizingMask:UIViewAutoresizingFlexibleMargins];
        [self addSubview:self.spinner];
    }
    return self;
}

+ (void)hide {
    UPDUpgradeSpinner *sharedInstance = [self sharedInstance];
    if(sharedInstance.status==UPDUpgradeSpinnerStatusHidden||sharedInstance.status==UPDUpgradeSpinnerStatusHiding) {
        return;
    }
    [sharedInstance setStatus:UPDUpgradeSpinnerStatusHiding];
    [sharedInstance setUserInteractionEnabled:NO];
    [sharedInstance.interfaceOverlay setUserInteractionEnabled:NO];
    [UIView animateWithDuration:UPD_TRANSITION_DURATION animations:^{
        [sharedInstance setAlpha:0];
        [sharedInstance setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.5, 0.5)];
        [sharedInstance.interfaceOverlay setAlpha:0];
    } completion:^(BOOL finished) {
        [sharedInstance setStatus:UPDUpgradeSpinnerStatusHidden];
        [sharedInstance removeFromSuperview];
        [sharedInstance.interfaceOverlay removeFromSuperview];
        [sharedInstance.spinner stopAnimating];
    }];
}

+ (id)sharedInstance {
    static UPDUpgradeSpinner *sharedInstance;
    static dispatch_once_t dispatchOnceToken;
    dispatch_once(&dispatchOnceToken, ^{
        sharedInstance = [[UPDUpgradeSpinner alloc] init];
    });
    return sharedInstance;
}

+ (void)show {
    UPDUpgradeSpinner *sharedInstance = [self sharedInstance];
    if(sharedInstance.status==UPDUpgradeSpinnerStatusShowing||sharedInstance.status==UPDUpgradeSpinnerStatusShown) {
        return;
    }
    [sharedInstance setStatus:UPDUpgradeSpinnerStatusShowing];
    UIView *interface = ((UPDAppDelegate *)[[UIApplication sharedApplication] delegate]).viewController.interface;
    
    [sharedInstance.interfaceOverlay setFrame:interface.bounds];
    [interface addSubview:sharedInstance.interfaceOverlay];
    
    [sharedInstance setAlpha:1];
    [sharedInstance setTransform:CGAffineTransformIdentity];
    [sharedInstance.spinner startAnimating];
    
    [sharedInstance setFrame:CGRectMake((interface.bounds.size.width-UPD_UPGRADE_SPINNER_SIZE)/2, (interface.bounds.size.height-UPD_UPGRADE_SPINNER_SIZE)/2, UPD_UPGRADE_SPINNER_SIZE, UPD_UPGRADE_SPINNER_SIZE)];
    [interface addSubview:sharedInstance];
    
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
    
    [sharedInstance.layer addAnimation:animation forKey:@"popup"];
    /*end settings animation*/
    
    [UIView animateWithDuration:UPD_TRANSITION_DURATION animations:^{
        [sharedInstance.interfaceOverlay setAlpha:0.8];
    } completion:^(BOOL finished) {
        [sharedInstance setStatus:UPDUpgradeSpinnerStatusShown];
    }];
}

@end
