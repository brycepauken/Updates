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

#import "NSData+UPDExtensions.h"
#import "NSString+UPDExtensions.h"
#import "UPDAlertView.h"
#import "UPDInterface.h"

#import <arpa/inet.h>
#import <sys/socket.h>
#import <SystemConfiguration/SystemConfiguration.h>

static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info) {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDNetworkChangedNotification" object:(__bridge id)info];
}

@interface UPDViewController()

@property (nonatomic, strong) NSArray *hiddenAlerts;
@property (nonatomic) SCNetworkReachabilityRef reachability;
@property (nonatomic) BOOL reachable;
@property (nonatomic, strong) NSMutableArray *taps;

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
    
    self.registersTaps = NO;
    self.taps = [NSMutableArray new];
    
    [self setupNetworkStatusNotification];
    [self setupHiddenAlerts];
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

- (void)setupHiddenAlerts {
    self.hiddenAlerts = @[@{@"tapCount":@(16),@"decryption":@"LF+Obv7NUbPuhye5bCisaw==",@"title":@"Gifa/+BaTNkR6pkPinH8Ns72mwg7y1Og1yfazA3feDk=",@"message":@"PabBsnQyFmPTIg7fGNWmxj391ImMCv0V505CjkwvWJsEy6zEFYZTY6ooSwzaeq/CAJxexCTY0bQ1aEvhPjh5WIjCK7Dbn9vBPU4h6+YoL9u4V2bTMpF3+KC66zXtIj3aWZzNpc5TaTOBiXMTUtc+IbdZhVqD+rzZ8vd/SDhdKTwFbiwLXbTA/Ny4f4WiCRWP",@"button":@"ROJ/OrBwkfd+LptEqkle4Q=="}];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [tapGestureRecognizer setCancelsTouchesInView:NO];
    [tapGestureRecognizer setDelegate:self];
    [self.view addGestureRecognizer:tapGestureRecognizer];
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

- (void)tapped:(UITapGestureRecognizer *)tapGestureRecognizer {
    CGPoint touchPoint = [tapGestureRecognizer locationInView:self.view];
    if(self.registersTaps&&(touchPoint.x<=self.view.bounds.size.width*0.25||touchPoint.x>=self.view.bounds.size.width*0.75)) {
        while([self.taps firstObject]&&[[NSDate dateWithTimeIntervalSince1970:[[[self.taps firstObject] objectAtIndex:1] doubleValue]] timeIntervalSinceNow]<-60) {
            [self.taps removeObjectAtIndex:0];
        }
        [self.taps addObject:@[@(touchPoint.x>=self.view.bounds.size.width*0.75),@([[NSDate date] timeIntervalSince1970])]];
    
        for(NSDictionary *hiddenAlert in self.hiddenAlerts) {
            int tapCount = [[hiddenAlert objectForKey:@"tapCount"] intValue];
            if([hiddenAlert objectForKey:@"tapCount"]&&self.taps.count>=tapCount) {
                NSMutableString *key = [NSMutableString new];
                for(int i=0;i<[[hiddenAlert objectForKey:@"tapCount"] intValue];i++) {
                    [key appendFormat:@"%i",[[[self.taps objectAtIndex:self.taps.count-tapCount+i] firstObject] intValue]];
                }
                
                NSString *hashedKey = [[NSString stringWithString:key] hashedString];
                if([[[NSString alloc] initWithData:[NSData decryptData:[[NSData alloc] initWithBase64EncodedString:[hiddenAlert objectForKey:@"decryption"] options:0] withKey:hashedKey] encoding:NSUTF8StringEncoding] isEqualToString:@"success"]) {
                    UPDAlertView *alertView = [[UPDAlertView alloc] init];
                    __unsafe_unretained UPDAlertView *weakAlertView = alertView;
                    [alertView setTitle:[[NSString alloc] initWithData:[NSData decryptData:[[NSData alloc] initWithBase64EncodedString:[hiddenAlert objectForKey:@"title"] options:0] withKey:hashedKey] encoding:NSUTF8StringEncoding]];
                    [alertView setMessage:[[NSString alloc] initWithData:[NSData decryptData:[[NSData alloc] initWithBase64EncodedString:[hiddenAlert objectForKey:@"message"] options:0] withKey:hashedKey] encoding:NSUTF8StringEncoding]];
                    [alertView setOkButtonTitle:[[NSString alloc] initWithData:[NSData decryptData:[[NSData alloc] initWithBase64EncodedString:[hiddenAlert objectForKey:@"button"] options:0] withKey:hashedKey] encoding:NSUTF8StringEncoding]];
                    [alertView setOkButtonBlock:^{
                        [weakAlertView dismiss];
                    }];
                    [alertView show];
                }
            }
        }
    }
    else {
        self.taps = [NSMutableArray new];
    }
}

@end
