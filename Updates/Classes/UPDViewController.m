//
//  UPDViewController.m
//  Updates
//
//  Created by Bryce Pauken on 7/15/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

/*
 Our view controller just creates another UIView (a UPDInterface, to
 be precise) and adds that to its view. This view-in-the-middle is
 necessary so we can give it a layoutSubviews implementation.
 */

#import "UPDViewController.h"

#import "UPDInterface.h"

@implementation UPDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setHideStatusBar:NO];
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self.view setBackgroundColor:[UIColor UPDLightGreyColor]];
    [self.view setClipsToBounds:YES];
    
    self.interface = [[UPDInterface alloc] initWithFrame:self.view.bounds];
    [self.interface setAutoresizingMask:UIViewAutoresizingFlexibleSize];
    [self.view addSubview:self.interface];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return self.hideStatusBar;
}

@end
