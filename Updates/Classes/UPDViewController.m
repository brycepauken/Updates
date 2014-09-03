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

#import "UPDAlertView.h"
#import "UPDInterface.h"

#import <arpa/inet.h>
#import <sys/socket.h>
#import <SystemConfiguration/SystemConfiguration.h>

static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info) {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDNetworkChangedNotification" object:(__bridge id)info];
}

@interface UPDViewController()

@property (nonatomic) SCNetworkReachabilityRef reachability;
@property (nonatomic) BOOL reachable;

@end

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
    
    [self setupNetworkStatusNotification];
}

- (void)networkStatusChanged:(NSNotification *)notice {
    SCNetworkReachabilityFlags flags;
    SCNetworkReachabilityGetFlags(self.reachability, &flags);
    
    self.reachable = (flags & kSCNetworkReachabilityFlagsReachable);
    if(!self.reachable) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self showUnreachableAlert];
        });
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return self.hideStatusBar;
}

- (void)setupNetworkStatusNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStatusChanged:) name:@"UPDNetworkChangedNotification" object:nil];
    
    self.reachability = SCNetworkReachabilityCreateWithName(NULL, [@"www.apple.com" UTF8String]);
    
    SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    SCNetworkReachabilitySetCallback(self.reachability, ReachabilityCallback, &context);
    SCNetworkReachabilityScheduleWithRunLoop(self.reachability, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
}

- (void)showUnreachableAlert {
    if(!self.reachable) {
        UPDAlertView *alertView = [[UPDAlertView alloc] init];
        __unsafe_unretained UPDAlertView *weakAlertView = alertView;
        [alertView setTitle:@"No Internet"];
        [alertView setMessage:@"You need an active internet connection to use Updates.\n\nCheck to make sure you are connected to the internet\nand then try again."];
        [alertView setOkButtonBlock:^{
            [weakAlertView dismiss];
        }];
        [alertView show];
    }
}

@end
